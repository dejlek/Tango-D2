/*******************************************************************************

        copyright:      Copyright (c) 2004 Kris Bell. All rights reserved

        license:        BSD style: $(LICENSE)

        version:        Mar 2004 : Initial release
        version:        Jan 2005 : RedShodan patch for timeout query
        version:        Dec 2006 : Outback release
        
        author:         Kris

*******************************************************************************/

module tango.net.SocketConduit;

private import  tango.net.Socket;

private import  tango.io.Conduit;

private import  tango.core.Interval;

/*******************************************************************************

        A wrapper around the bare Socket to implement the IConduit abstraction
        and add socket-specific functionality.

        SocketConduit data-transfer is typically performed in conjunction with
        an IBuffer, but can happily be handled directly using void array where
        preferred
        
*******************************************************************************/

class SocketConduit : Conduit
{
        private timeval                 tv;
        private SocketSet               ss;
        package Socket                  socket;
        private bool                    timeout;

        // freelist support
        private SocketConduit           next;   
        private bool                    fromList;
        private static SocketConduit    freelist;

        /***********************************************************************
        
                Create a streaming Internet Socket

        ***********************************************************************/

        this ()
        {
                this (Access.ReadWrite, SocketType.STREAM);
        }

        /***********************************************************************
        
                Create an Internet Socket. Used by subclasses and by
                ServerSocket; the latter via method allocate() below

        ***********************************************************************/

        protected this (Access access, SocketType type, bool create=true)
        {
                super (access);
                socket = new Socket (AddressFamily.INET, type, ProtocolType.TCP, create);
        }

        /***********************************************************************

                Return a preferred size for buffering conduit I/O

        ***********************************************************************/

        uint bufferSize ()
        {
                return 1024 * 8;
        }

        /***********************************************************************

                Return the socket wrapper
                
        ***********************************************************************/

        Socket getSocket ()
        {
                return socket;
        }

        /***********************************************************************

                Models a handle-oriented device. We need to revisit this.

                TODO: figure out how to avoid exposing this in the general
                case

        ***********************************************************************/

        Handle getHandle ()
        {
                return cast(Handle) socket.handle;
        }

        /***********************************************************************

                Set the read timeout to the specified microseconds. Set a
                value of zero to disable timeout support.

                Note that only a fairly short timeout period is supported: 
                (2^32 / 1_000_000) seconds

        ***********************************************************************/

        void setTimeout (Interval us)
        {
                tv.tv_sec = cast(int) (us / Interval.second);
                tv.tv_usec = cast(int) (us % Interval.second);
        }

        /***********************************************************************

                Did the last operation result in a timeout? 

        ***********************************************************************/

        bool hadTimeout ()
        {
                return timeout;
        }

        /***********************************************************************

                Is this socket still alive?

        ***********************************************************************/

        override bool isAlive ()
        {
                return socket.isAlive;
        }

        /***********************************************************************

                Connect to the provided endpoint
        
        ***********************************************************************/

        SocketConduit connect (Address addr)
        {
                socket.connect (addr);
                return this;
        }

        /***********************************************************************

                Bind the socket. This is typically used to configure a
                listening socket (such as a server or multicast socket).
                The address given should describe a local adapter, or
                specify the port alone (ADDR_ANY) to have the OS assign
                a local adapter address.
        
        ***********************************************************************/

        SocketConduit bind (Address address)
        {
                socket.bind (address);
                return this;
        }

        /***********************************************************************

                Inform other end of a connected socket that we're no longer
                available. In general, this should be invoked before close()
                is invoked
        
        ***********************************************************************/

        SocketConduit shutdown ()
        {
                socket.shutdown (SocketShutdown.BOTH);
                return this;
        }

        /***********************************************************************

                Deallocate this SocketConduit when it is been closed.

                Note that one should always close a SocketConduit under
                normal conditions, and generally invoke shutdown on all
                connected sockets beforehand

        ***********************************************************************/

        override void close ()
        {
                super.close;
                socket.close;

                // deallocate if this came from the free-list,
                // otherwise just wait for the GC to handle it
                if (fromList)
                    deallocate (this);
        }

        /***********************************************************************

                Read content from socket. This is implemented as a callback
                from the reader() method so we can expose the timout support
                to subclasses
                
        ***********************************************************************/

        protected uint socketReader (void[] dst)
        {
                return socket.receive (dst);
        }
        
       /***********************************************************************

                Callback routine to read content from the socket. Note
                that the operation may timeout if method setTimeout()
                has been invoked with a non-zero value.

                Returns the number of bytes read from the socket, or
                IConduit.Eof where there's no more content available

                Note that a timeout is equivalent to Eof. Isolating
                a timeout condition can be achieved via hadTimeout()

                Note also that a zero return value is not legitimate;
                such a value indicates Eof

        ***********************************************************************/

        protected override uint reader (void[] dst)
        {
                // ensure just one read at a time
                synchronized (this)
                {
                // reset timeout; we assume there's no thread contention
                timeout = false;

                // did user disable timeout checks?
                if (tv.tv_usec)
                   {
                   // nope: ensure we have a SocketSet
                   if (ss is null)
                       ss = new SocketSet (1);

                   ss.reset ();
                   ss.add (socket);

                   // wait until data is available, or a timeout occurs
                   int i = socket.select (ss, null, null, &tv);
                       
                   if (i <= 0)
                      {
                      if (i is 0)
                          timeout = true;
                      return Eof;
                      }
                   }       

                // invoke the actual read op
                int count = socketReader (dst);
                if (count <= 0)
                    count = Eof;
                return count;
                }
        }
        
        /***********************************************************************

                Callback routine to write the provided content to the
                socket. This will stall until the socket responds in
                some manner. Returns the number of bytes sent to the
                output, or IConduit.Eof if the socket cannot write.

        ***********************************************************************/

        protected override uint writer (void[] src)
        {
                int count = socket.send (src);
                if (count <= 0)
                    count = Eof;
                return count;
        }

        /***********************************************************************

                Allocate a SocketConduit from a list rather than creating
                a new one. Note that the socket itself is not opened; only
                the wrappers. This is because the socket is often assigned
                directly via accept()

        ***********************************************************************/

        package static synchronized SocketConduit allocate ()
        {       
                SocketConduit s;

                if (freelist)
                   {
                   s = freelist;
                   freelist = s.next;
                   }
                else
                   {
                   s = new SocketConduit (Access.ReadWrite, SocketType.STREAM, false);
                   s.fromList = true;
                   }
                return s;
        }

        /***********************************************************************

                Return this SocketConduit to the free-list

        ***********************************************************************/

        private static synchronized void deallocate (SocketConduit s)
        {
                s.next = freelist;
                freelist = s;
        }
}

