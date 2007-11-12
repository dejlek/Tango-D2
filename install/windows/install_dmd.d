import tango.io.FileConduit;
import tango.io.FilePath;
import tango.io.FileScan;
import tango.io.MappedBuffer;
import tango.io.Stdout;
import tango.sys.Environment;
import tango.text.Util;
import tango.util.ArgParser;


void main( char[][] args )
{
    scope(exit) Stdout.flush;

    auto     parser = new ArgParser;
    char[]   prefix = null;
    bool     uninst = false;

    parser.bind( "--", "prefix",
                 delegate void( char[] val )
                 {
                    require( val[0] == '=', "Invalid parameter format." );
                    prefix = val[1 .. $];
                 } );
    parser.bind( "--", "uninstall",
                 delegate void( char[] val )
                 {
                    uninst = true;
                 } );
    parser.parse( args[1 .. $] );

    auto     binPath = Environment.exePath( "dmd.exe" );
    require( binPath !is null, "DMD installation not found." );
    auto     usePath = new FilePath( "" );
    auto     impPath = new FilePath( "" );
    auto     libPath = new FilePath( "" );

    usePath.set( prefix ? prefix : usePath.set( binPath.parent ).parent );
    require( usePath.exists, "Path specified by prefix does not exist." );
    usePath.path( usePath.toUtf8 );

    impPath.set( usePath.path ~ "import" );
    if( !impPath.exists )
        impPath.create();
    impPath.path = impPath.toUtf8;

    libPath.set( usePath.path ~ "lib" );
    if( !libPath.exists )
        libPath.create();
    libPath.path = libPath.toUtf8;

    if( uninst )
    {
        restoreFile( binPath.file( "sc.ini" ) );
        removeFile( libPath.file( "tango-user-tango.lib" ) );
        removeFile( libPath.file( "tango-arch-win32.lib" ) );
        removeFile( libPath.file( "tango-base-dmd.lib" ) );

        removeFile( impPath.file( "object.di" ) );
        removeTree( impPath.file( "tango" ) );
        removeTree( impPath.file( "std" ) );
    }
    else
    {
        require( !binPath.file( "sc.ini.phobos" ).exists,
                 "Tango is already installed." );

        copyTree( impPath.file( "std" ), "..\\" );
        copyTree( impPath.file( "tango" ), "..\\" );
        copyFile( impPath.file( "object.di" ), "..\\" );

        copyFile( libPath.file( "tango-user-tango.lib" ), ".\\" );
        copyFile( libPath.file( "tango-arch-win32.lib" ), ".\\" );
        copyFile( libPath.file( "tango-base-dmd.lib" ), ".\\" );

        backupFile( binPath.file( "sc.ini" ) );
        scope(failure) restoreFile( libPath.file( "sc.ini" ) );

        if( prefix )
        {
            writeFile( binPath.file( "sc.ini" ),
                       iniFile( FilePath.stripped( impPath.path ),
                                FilePath.stripped( libPath.path ) ) );
        }
        else
        {
            writeFile( binPath.file( "sc.ini" ),
                       iniFile( "%@P%\\..\\import",
                                "%@P%\\..\\lib" ) );
        }
    }
}


void backupFile( FilePath fp, char[] suffix = ".phobos" )
{
    char[]  orig = fp.file.dup;
    char[]  back = orig ~ suffix;

    require( !fp.file( back ).exists, back ~ " already exists." );
    require( fp.file( orig ).exists, orig ~ " does not exist." );
    fp.file( orig ).rename( fp.path ~ back );
}


void restoreFile( FilePath fp, char[] suffix = ".phobos" )
{
    char[]  orig = fp.file.dup;
    char[]  back = orig ~ suffix;

    // NOTE: The backup may not exist if Tango was installed using
    //       the --prefix option.
    //require( fp.file( back ).exists, back ~ " does not exist." );
    if( !fp.file( back ).exists )
        return;

    removeFile( fp.file( orig ) );
    fp.file( back ).rename( fp.path ~ orig );
}


void removeFile( FilePath fp )
{
    if( fp.exists )
        fp.remove();
}


void writeFile( FilePath fp, lazy char[] buf )
{
    scope fc = new FileConduit( fp.toUtf8, FileConduit.WriteCreate );
    scope(exit) fc.close();
    fc.output.write( buf );
}


void copyFile( FilePath dstFile, char[] srcPath )
{
    scope srcFc = new FileConduit( FilePath.padded( srcPath ) ~ dstFile.file,
                                   FileConduit.ReadExisting );
    scope(exit) srcFc.close();
    scope dstFc = new FileConduit( dstFile.toUtf8, FileConduit.WriteCreate );
    scope(exit) dstFc.close();
    dstFc.copy( srcFc );
}


void copyTree( FilePath dstPath, char[] srcPath )
{
    bool matchAll( FilePath fp, bool isDir )
    {
        return true;
    }

    scope   scan    = new FileScan;
    scope   dstFile = new FilePath( "" );

    srcPath = FilePath.padded( srcPath ) ~ dstPath.file;
    scan.sweep( srcPath, &matchAll );
    dstFile.path = dstPath.toUtf8;

    foreach( f; scan.folders )
    {
        dstFile.set( dstPath.toUtf8 ~ f.toUtf8[srcPath.length .. $] );
        if( !dstFile.exists )
            dstFile.create();
    }

    foreach( f; scan.files )
    {
        dstFile.set( dstPath.toUtf8 ~ f.toUtf8[srcPath.length .. $] );
        copyFile( dstFile, f.path );
    }
}


void removeTree( FilePath root )
{
    if( !root.exists )
        return;

    bool matchAll( FilePath fp, bool isDir )
    {
        return true;
    }

    scope scan = new FileScan;

    scan.sweep( root.toUtf8, &matchAll );

    foreach( f; scan.files )
    {
        f.remove();
    }

    foreach( f; scan.folders )
    {
        f.remove();
    }
}


void require( bool result, char[] msg )
{
    if( !result )
        throw new Exception( msg );
}


char[] iniFile( char[] impPath, char[] libPath )
{
    return "[Version]\n"
           "version=7.51 Build 020\n"
           "\n"
           "[Environment]\n"
           "LIB=\"" ~ libPath ~ "\"\n"
           "DFLAGS=\"-I" ~ impPath ~ "\" -version=Tango -defaultlib=tango-base-dmd.lib -debuglib=tango-base-dmd.lib -L+tango-user-tango.lib\n"
           "LINKCMD=%@P%\\..\\..\\dm\\bin\\link.exe\n";
}
