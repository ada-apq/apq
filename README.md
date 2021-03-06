APQ Version 3.0
===============

```
===========================================================================
=                      The APQ Ada95 Database Library                     = 
=                                                                         =
=  This package has the commmon part for all the APQ drivers available.   =
=  In order to connect to a database, you'll have to download and install =
= one of the database bindings being:                                     =
=        * MySQL :: apq-mysql package                                     =
=        * PostgreSQL :: apq-postgresql package                           =
=        * Ms. SQL Server/Sybase :: apq-ct_lib package                    =
=        * Sybase (more specialized) :: apq-sybase                        =
=                                                                         =
= Authors:                                                                =
=   Warren W. Gay VE3WWG <ve3wwg@cogeco.ca>                               =
=                http://home.cogeco.ca/~ve3wwg                            =
=   Marcelo C. de Freitas <marcelo@kow.com.br>                            =
===========================================================================
```              

Why use APQ over other products?


APQ Features:
-------------

  - It is a thick binding, making it natural for Ada programmers.
  - It is very simple to use, making programming easy.
  - Can be used with strong Ada types.
  - Generic procedure and function support for strong types.
  - Supports multiple database engines generically
  - MySQL supported as of APQ-2.0
  - Sybase supported as of APQ-2.2
  - Database neutral code is possible (portable)

  - Full BLOB support (for PostgreSQL)
  - Blob I/O is performed through Ada95 stream I/O.
  - High performance blob I/O through buffered stream I/O
  - Optionally blob I/O can be unbuffered.

  - Native binding (no ODBC muss or fuss!)
  - Full support for NULL values.
  - Additional support for DATE, TIME and TIMESTAMP data types.
  - Some support for TIMEZONE types (PostgreSQL)
  - Supports bit string types (PostgreSQL)
  - Leaves the SQL in human readable form

  - 4 levels of tracing for application debugging
    - Trace_None  (no tracing)
    - Trace_DB    (C library trace information only)
    - Trace_APQ   (SQL query trace information only)
    - Trace_Full  (both Trace_DB and Trace_APQ)
  - Trace_APQ output can be fed as SQL text for testing

  - Non restritive license :
    - MGPL (GNAT Modified GNU Public License)

  - Extensive manual, with examples for nearly every function.
    - notice while the manual hasn't been update for a while, it's
    still a great source of information.
  - Manual includes a chapter on generic database programming.

  - Experimental support of the Decimal_Type package (using
    decimal routines used internally by the PostgreSQL database
    engine).
  - Under active development and use

Design Goals:
-------------

The main design goals for the APQ binding development were:

  - simple to use
  - easy to read
  - reliable
  - database vendor neutral (generic database programming)
  - at the user's option, strongly typed
  - strong blob support
  - No C language interfaces or types
  - good documentation

It is the authors' belief that these goals have been suitably met,
although the package is still undergoing active research. Excluding blob
support, there are only 2 tagged object types that the programmer must
become familiar with. These objects include Finalization and  nicely
clean up after themselves. Blob support adds one more tagged object that
the programmer can interact with.

  1. The Connection_Type object for database connections
  2. The Query_Type object for SQL interactions with server
  3. The Blob_Type type for Blob I/O and operations

Having few objects reduces the learning curve substantially. A large
number of functions and procedures are overloaded -- reusing the same
name. This also reduces the learning curve, since the remaining
differences are only in the involved data types. Much complexity
is hidden within the state driven objects.

The APQ binding allows the Ada95 programmer to interface with blobs
using stream I/O. This preserves the Ada advantage for strong type
checking while making it simple for the programmer to perform I/O. As of
APQ 1.2, the blob I/O is buffered, giving the stream I/O for blobs a
major performance boost. No longer will the programmer need to search
for performance work-arounds for blob operations.

Version 2.2 of APQ brings Sybase into the fold of supported
databases. This is particularly useful now that Sybase has
generously made their ASE-12.5x Express edition of their
server available to developers for free.

Version 3.0 provides full compatibility with the FreeTDS library, 
thus providing Microsoft SQL Server support in adition to the
already existing Sybase support.

Trial Programs:
---------------

In the 3.0 the old trial programs has been removed from the distribution.

However, there are some examples in the "samples" folder for testing
some of the features (but not all of them).

If you'd like to help, providing such tests would be agreat place to
start.


Platforms:
----------

These are the platforms where we've been sucessful in compilling and using APQ so far:

OS:
	Linux Kernel 2.6
	Windows 2k, 2k3, XP and Vista
Compiler:
	GNAT 3.14p
	GNAT GCC 4.2 and 4.3

Database Servers:
	PostgreSQL 7.3.5
	MySQL 4.0.14 and 5.0.76
	Sybase ASE 12.52
	Microsoft SQL Server 2005

While not yet tested on all platforms, this package will likely
port well for must UNIX platforms, including:

 - FreeBSD		(untested)
 - NetBSD 		(untested)
 - OpenBSD		(untested)
 - HP-UX 10.2 or higher (untested)
 - Sun Solaris 		(untested)


Win32 Builds:
-------------

Win32 builds are now possible. See the pdf document
named win32.pdf for instructions on how to build APQ
from sources.


Feedback:
---------

Please feedback suggestion and bugs to the project homepage:
	http://framework.kow.com.br

When reporing bugs please provide also:
	. Database server with version
	. OS with version
	. Ada compiler with version


Thank-you for downloading and using APQ.


See file HISTORY for revision history

- End -
