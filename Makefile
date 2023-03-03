# makefile for LGPL-licensed LAStools
#
#COPTS    = -g -Wall -Wno-deprecated -DDEBUG 
#COPTS     = -O3 -Wall -Wno-deprecated -Wno-strict-aliasing -Wno-write-strings -Wno-unused-result -DNDEBUG 
COPTS     = -bundle -flat_namespace -undefined suppress
COMPILER  = cc
LINKER  = cc

#LIBS     = -L/Applications/Postgres.app/Contents/Versions/13/lib/
#INCLUDE  = -I/Applications/Postgres.app/Contents/Versions/13/include/ -I/Applications/Postgres.app/Contents/Versions/13/include/postgresql/server/
LIBS     = -L/usr/local/lib/
#INCLUDE  = -I/usr/local/include/ -I/usr/local/include/postgresql/server
INCLUDE  = -I/usr/local/include/ -I/Applications/Postgres.app/Contents/Versions/13/include/postgresql/server/

all: pg_eyevigis

pg_eyevigis: src/pg_eyevigis.o 
	mkdir -p bin
	${LINKER} ${COPTS} src/pg_eyevigis.o -lproj -o bin/$@.so ${LIBS} $(INCLUDE)

.c.o: 
	${COMPILER} -c ${INCLUDE} $< -o $@

clean:
	rm -rf src/*.o
	rm -rf bin
