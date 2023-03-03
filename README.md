Some reading about Postgresql C Functions
https://www.postgresql.org/docs/current/xfunc-c.html

# Dependencies
* PostgreSQL
* PROJ 

# LINUX & MAC
    mkdir build && cd build && cmake .. && make && make install
Installs pg_eyevigis.so, eyevigis.control and eyevigis--x.sql files for PostgreSQL
(If Mac Postgres.app is present, extension is installed for it's PG13 into app). 

# WINDOWS
* Compile the code. if you have PostgreSQL installed in the default directory, \Program Files\postgreSQL\8.3, the command line is
    cl /I "\Program Files\postgreSQL\8.3\include\server" /I "\Program Files\postgreSQL\8.3\include\server\port\win32" /c <path to to where you have stored pg_eyevigis.c>pg_eyevigis.c

cl is the C compiler (it can also link, but we are not using that capability; for our task, it's easier to call the linker directly). /I indicates directories to search for include files, /c indicates the file to compile. The quotes are needed around any path name that includes spaces so that the spaces are not taken as switch separators.

* Link the resulting object file to make a DLL: if you have postgreSQL installed in the default directory, the command line is
    link /DLL pg_eyevigis.obj "\Program Files\postgreSQL\8.3\lib\postgres.lib"

link is the linker. /DLL says to make a DLL file. postgres.lib needs to be linked with pg_eyevigis.obj so that code needed for the DLL to communicate with postgreSQL is present.