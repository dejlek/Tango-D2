/**
 * D header file for POSIX.
 *
 * Copyright: Public Domain
 * License:   Public Domain
 * Authors:   Sean Kelly
 * Standards: The Open Group Base Specifications Issue 6, IEEE Std 1003.1, 2004 Edition
 */
module tango.stdc.posix.netinet.in_;

private import tango.stdc.posix.config;
public import tango.stdc.inttypes : uint32_t, uint16_t, uint8_t;
public import tango.stdc.posix.arpa.inet;
public import tango.stdc.posix.sys.socket; // for sa_family_t

extern (C):

//
// Required	
//
/*
NOTE: The following must must be defined in tango.stdc.posix.arpa.inet to break
      a circular import: in_port_t, in_addr_t, struct in_addr, INET_ADDRSTRLEN.

in_port_t
in_addr_t

sa_family_t // from tango.stdc.posix.sys.socket
uint8_t     // from tango.stdc.inttypes
uint32_t    // from tango.stdc.inttypes

struct in_addr
{
    in_addr_t   s_addr;
}

struct sockaddr_in
{
    sa_family_t sin_family;
    in_port_t   sin_port;
    in_addr     sin_addr;
}

IPPROTO_IP
IPPROTO_ICMP
IPPROTO_TCP
IPPROTO_UDP

INADDR_ANY
INADDR_BROADCAST

INET_ADDRSTRLEN

htonl() // from tango.stdc.posix.arpa.inet
htons() // from tango.stdc.posix.arpa.inet
ntohl() // from tango.stdc.posix.arpa.inet
ntohs() // from tango.stdc.posix.arpa.inet
*/

version( linux )
{
    private const __SOCK_SIZE__ = 16;

    struct sockaddr_in
    {
        sa_family_t sin_family;
        in_port_t   sin_port;
        in_addr     sin_addr;

        /* Pad to size of `struct sockaddr'. */
        ubyte[__SOCK_SIZE__ - sa_family_t.sizeof -
              in_port_t.sizeof - in_addr.sizeof] __pad;
    }

    enum
    {
        IPPROTO_IP   = 0,
        IPPROTO_ICMP = 1,
        IPPROTO_TCP  = 6,
        IPPROTO_UDP  = 17
    }

    const uint INADDR_ANY       = 0x00000000;
    const uint INADDR_BROADCAST = 0xffffffff;
}
else version( darwin )
{
    private const __SOCK_SIZE__ = 16;

    struct sockaddr_in
    {
        ubyte       sin_len;
        sa_family_t sin_family;
        in_port_t   sin_port;
        in_addr     sin_addr;
        ubyte[8]    sin_zero;
    }

    enum
    {
        IPPROTO_IP   = 0,
        IPPROTO_ICMP = 1,
        IPPROTO_TCP  = 6,
        IPPROTO_UDP  = 17
    }

    const uint INADDR_ANY       = 0x00000000;
    const uint INADDR_BROADCAST = 0xffffffff;
}
else version( freebsd )
{
    private const __SOCK_SIZE__ = 16;

    struct sockaddr_in
    {
        ubyte       sin_len;
        sa_family_t sin_family;
        in_port_t   sin_port;
        in_addr     sin_addr;
        ubyte[8]    sin_zero;
    }

    enum
    {
        IPPROTO_IP   = 0,
        IPPROTO_ICMP = 1,
        IPPROTO_TCP  = 6,
        IPPROTO_UDP  = 17
    }

    const uint INADDR_ANY       = 0x00000000;
    const uint INADDR_BROADCAST = 0xffffffff;
}


//
// IPV6 (IP6)
//
/*
NOTE: The following must must be defined in tango.stdc.posix.arpa.inet to break
      a circular import: INET6_ADDRSTRLEN.

struct in6_addr
{
    uint8_t[16] s6_addr;
}

struct sockaddr_in6
{
    sa_family_t sin6_family;
    in_port_t   sin6_port;
    uint32_t    sin6_flowinfo;
    in6_addr    sin6_addr;
    uint32_t    sin6_scope_id;
}

extern in6_addr in6addr_any;
extern in6_addr in6addr_loopback;

struct ipv6_mreq
{
    in6_addr    ipv6mr_multiaddr;
    uint        ipv6mr_interface;
}

IPPROTO_IPV6

INET6_ADDRSTRLEN

IPV6_JOIN_GROUP
IPV6_LEAVE_GROUP
IPV6_MULTICAST_HOPS
IPV6_MULTICAST_IF
IPV6_MULTICAST_LOOP
IPV6_UNICAST_HOPS
IPV6_V6ONLY

// macros
int IN6_IS_ADDR_UNSPECIFIED(in6_addr*)
int IN6_IS_ADDR_LOOPBACK(in6_addr*)
int IN6_IS_ADDR_MULTICAST(in6_addr*)
int IN6_IS_ADDR_LINKLOCAL(in6_addr*)
int IN6_IS_ADDR_SITELOCAL(in6_addr*)
int IN6_IS_ADDR_V4MAPPED(in6_addr*)
int IN6_IS_ADDR_V4COMPAT(in6_addr*)
int IN6_IS_ADDR_MC_NODELOCAL(in6_addr*)
int IN6_IS_ADDR_MC_LINKLOCAL(in6_addr*)
int IN6_IS_ADDR_MC_SITELOCAL(in6_addr*)
int IN6_IS_ADDR_MC_ORGLOCAL(in6_addr*)
int IN6_IS_ADDR_MC_GLOBAL(in6_addr*)
*/

version ( linux )
{
    struct in6_addr
    {
        union
        {
            uint8_t[16] s6_addr;
            uint16_t[8] s6_addr16;
            uint32_t[4] s6_addr32;
        }
    }
    
    struct sockaddr_in6
    {
        sa_family_t sin6_family;
        in_port_t   sin6_port;
        uint32_t    sin6_flowinfo;
        in6_addr    sin6_addr;
        uint32_t    sin6_scope_id;
    }
    
    extern in6_addr in6addr_any;
    extern in6_addr in6addr_loopback;
    
    struct ipv6_mreq
    {
        in6_addr    ipv6mr_multiaddr;
        uint        ipv6mr_interface;
    }
    
    enum : uint
    {
        IPPROTO_IPV6        = 41,
    
        INET6_ADDRSTRLEN    = 46,
    
        IPV6_JOIN_GROUP     = 20,
        IPV6_LEAVE_GROUP    = 21,
        IPV6_MULTICAST_HOPS = 18,
        IPV6_MULTICAST_IF   = 17,
        IPV6_MULTICAST_LOOP = 19,
        IPV6_UNICAST_HOPS   = 16,
        IPV6_V6ONLY         = 26
    }

    // macros
    extern (D) int IN6_IS_ADDR_UNSPECIFIED( in6_addr* addr )
    {
        return (cast(uint32_t*) addr)[0] == 0 &&
               (cast(uint32_t*) addr)[1] == 0 &&
               (cast(uint32_t*) addr)[2] == 0 &&
               (cast(uint32_t*) addr)[3] == 0;
    }

    extern (D) int IN6_IS_ADDR_LOOPBACK( in6_addr* addr )
    {
        return (cast(uint32_t*) addr)[0] == 0  &&
               (cast(uint32_t*) addr)[1] == 0  &&
               (cast(uint32_t*) addr)[2] == 0  &&
               (cast(uint32_t*) addr)[3] == htonl( 1 );
    }

    extern (D) int IN6_IS_ADDR_MULTICAST( in6_addr* addr )
    {
        return (cast(uint8_t*) addr)[0] == 0xff;
    }

    extern (D) int IN6_IS_ADDR_LINKLOCAL( in6_addr* addr )
    {
        return ((cast(uint32_t*) addr)[0] & htonl( 0xffc00000 )) == htonl( 0xfe800000 );
    }

    extern (D) int IN6_IS_ADDR_SITELOCAL( in6_addr* addr )
    {
        return ((cast(uint32_t*) addr)[0] & htonl( 0xffc00000 )) == htonl( 0xfec00000 );
    }

    extern (D) int IN6_IS_ADDR_V4MAPPED( in6_addr* addr )
    {
        return (cast(uint32_t*) addr)[0] == 0 &&
               (cast(uint32_t*) addr)[1] == 0 &&
               (cast(uint32_t*) addr)[2] == htonl( 0xffff );
    }

    extern (D) int IN6_IS_ADDR_V4COMPAT( in6_addr* addr )
    {
        return (cast(uint32_t*) addr)[0] == 0 &&
               (cast(uint32_t*) addr)[1] == 0 &&
               (cast(uint32_t*) addr)[2] == 0 &&
               ntohl( (cast(uint32_t*) addr)[3] ) > 1;
    }

    extern (D) int IN6_IS_ADDR_MC_NODELOCAL( in6_addr* addr )
    {
        return IN6_IS_ADDR_MULTICAST( addr ) &&
               ((cast(uint8_t*) addr)[1] & 0xf) == 0x1;
    }

    extern (D) int IN6_IS_ADDR_MC_LINKLOCAL( in6_addr* addr )
    {
        return IN6_IS_ADDR_MULTICAST( addr ) &&
               ((cast(uint8_t*) addr)[1] & 0xf) == 0x2;
    }

    extern (D) int IN6_IS_ADDR_MC_SITELOCAL( in6_addr* addr )
    {
        return IN6_IS_ADDR_MULTICAST(addr) &&
               ((cast(uint8_t*) addr)[1] & 0xf) == 0x5;
    }

    extern (D) int IN6_IS_ADDR_MC_ORGLOCAL( in6_addr* addr )
    {
        return IN6_IS_ADDR_MULTICAST( addr) &&
               ((cast(uint8_t*) addr)[1] & 0xf) == 0x8;
    }

    extern (D) int IN6_IS_ADDR_MC_GLOBAL( in6_addr* addr )
    {
        return IN6_IS_ADDR_MULTICAST( addr ) &&
               ((cast(uint8_t*) addr)[1] & 0xf) == 0xe;
    }
}


//
// Raw Sockets (RS)
//
/*
IPPROTO_RAW
*/

version (linux )
{
    const uint IPPROTO_RAW = 255;
}
