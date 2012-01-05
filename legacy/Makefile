# $Id: Makefile,v 1.68 2008/02/06 19:43:52 eveogro Exp $
# Warren W. Gay VE3WWG
#
# Licensed under the ACL (Ada Community License)
# or GPL2 :

include Makeincl

DISTDIR=apq-$(VERSION)
DISTFILE=apq-$(VERSION).tar.gz

#DBG=-g
OPTZ=-O0

CC=gcc

ZOPTS=$(DBG) $(OPTZ)
COPTS=-Wall $(ZOPTS)
AOPTS=-gnata -gnatf -gnato -gnatwp $(ZOPTS)

.c.o:
	$(CC) -c $(COPTS) $(ZOPTS) $(PG_INCL) $(MY_INCL) $< -o $*.o

all:	sybase$(HAVE_SY) setup$(HAVE_MY) mysql$(HAVE_MY) postgresql$(HAVE_PG) libapq.a finish

tmysql::
	rm -f tmysql mysql.trc
	gnatmake -gnatf tmysql


setup0:        # MySQL support is not being included
sybase0:       # Sybase support is not being included
mysql0:        # MySQL support is not being included
postgresql0:   # PostgreSQL is not being included

apq-sybase.ads: apq-sybase.ads-in sybase_gentyp.c prep_sybase
	$(CC) $(COPTS) $(SY_INCL) sybase_gentyp.c -o sybase_gentyp
	$(CC) $(COPTS) $(SY_INCL) sybaseopts.c -o sybaseopts
	./sybaseopts >sybopts.tmp
	./sybase_gentyp | ./prep_sybase "$(SY_LIBS)" >apq-sybase.ads
	rm -f sybase_gentyp

c_sybase.o: c_sybase.c
	$(CC) -c $(COPTS) $(ZOPTS) $(SY_INCL) $< -o c_sybase.o

sybase1: apq-sybase.ads c_sybase.o
	gnatmake -c $(AOPTS) comp_sybase

setup1:	mysql_xcr mysql_xcr2 mysql_xcr3 mysql_incl
	chmod u+x mysql_xcr mysql_xcr2 mysql_xcr3 mysql_incl mysql_xty mysql_linker_options

mysql1: apq-mysql.ads c_mysql.o
	gnatmake -c $(AOPTS) comp_mysql

c_mysql.o: c_mysql.c
	$(CC) -c $(COPTS) $(ZOPTS) $(MY_INCL) c_mysql.c -o c_mysql.o

apq-mysql.ads: apq-mysql.ads-in mysql_generr.c mysql_xcr2 mysql_xcr3
	@rm -f mysql_errmsg.h mysql_generr
	./mysql_xcr >mysql_errmsg.h
	./mysql_xty >mysql_type_codes.h
	$(CC) $(COPTS) $(MY_INCL) mysql_generr.c -o mysql_generr
	$(CC) $(COPTS) $(MY_INCL) mysql_gentyp.c -o mysql_gentyp
	$(CC) $(COPTS) $(MY_INCL) mysqlopts.c -o mysql_opts
	./mysql_opts >opts.tmp
	./mysql_generr | sort -k1,1n | ./mysql_xcr2 >gen.tmp
	./mysql_gentyp | sort -k1,1n | ./mysql_xcr3
	rm -f mysql_generr mysql_errmsg.h mysql_gentyp mysql_type_codes.h gen.tmp opts.tmp mysql_opts gen.tmp

postgresql1: numeric.o notices.o
	gnatmake -c $(AOPTS) comp_pg

libapq.a::
	@rm -f libapq.a
	ar cr libapq.a apq.o $(PG_OBJS) $(MY_OBJS) $(SY_OBJS)
	ar tv libapq.a

finish:
	@echo "--"
	@echo "Now do 'make install' to install the library"
	@echo
	@echo "NOTE: Remove any prior versions of the APQ library"
	@echo "and package, if you have it installed. You will"
	@echo "need to remove those packages and libraries"
	@echo "manually."
	@echo
	@echo "You may 'make uninstall' if you are about to"
	@echo "reinstall APQ version $(VERSION). This will not"
	@echo "work for prior versions of APQ however."
	@echo

install: libapq.a
	HAVE_PG=$(HAVE_PG) HAVE_MY=$(HAVE_MY) HAVE_SY=$(HAVE_SY) ./install_lib
	@echo "--"
	@echo "For fun do:"
	@echo "  1. cd ./eg2"
	@echo "  2. make"
	@echo "  3. follow instructions given."
	@echo "--"
	
uninstall:
	HAVE_PG=1 HAVE_MY=1 HAVE_SY=1 ./install_lib uninstall

reinstall: uninstall clobber all install

clean:
	rm -f *.o *.ali *.core b~*.ad[sb] errs.t libapq.a mysql.trc comp_pg comp_mysql
	rm -f sybase_gentyp gen.tmp sybopts.tmp sybaseopts
	rm -f mysql_gentyp mysql_opts opts.tmp
	(cd sybase ; make clean)

clobber: clean
	rm -f mysql_errmsg.h mysql_type_codes.h mysql_generr Makeincl tmysql apq-mysql.ads
	rm -f tsybase apq-sybase.ads
	rm -f libapq.a GNUmakefile
	rm -fr ./release $(DISTFILE)
	cd ./eg; $(MAKE) clobber
	rm -f apq-1.93-win32-2.7.1.tar.gz
	rm -f apq_manual.dvi apq_manual.pdf binding2.aux binding2.toc binding2.log
	(cd sybase ; make clobber)

manual:	apq_manual.pdf

apq_manual.dvi: binding2.tex
	@rm -f binding2.toc binding2.log binding2.dvi binding2.aux
	latex binding2.tex
	latex binding2.tex
	latex binding2.tex
	mv binding2.dvi apq_manual.dvi

apq_manual.pdf: apq_manual.dvi
	dvipdf apq_manual.dvi apq_manual.pdf

manlabels:
	sed <binding2.tex -n '/\\label{.*}/p' | sed 's|.*\(\\label{.*}\).*$$|\1|g'

distribution: manual
	./build_release
	@mv release $(DISTDIR)
	tar czf $(DISTFILE) $(DISTDIR)
	@rm -fr $(DISTDIR)
	@ls -l $(DISTFILE)

makedist:
	./build_release FORCE
	@mv release $(DISTDIR)
	tar czf $(DISTFILE) $(DISTDIR)
	@rm -fr $(DISTDIR)
	@ls -l $(DISTFILE)

#binary-distributions:
#	./build_release build-win32-1.93-2.7.1
#	@mv release apq-1.93-win32-2.7.1
#	tar czf apq-1.93-win32-2.7.1.tar.gz apq-1.93-win32-2.7.1
#	rm -fr apq-1.93-win32-2.7.1
#	ls -l apq-1.93-win32-2.7.1.tar.gz

# End $Source: /cvsroot/apq/apq/Makefile,v $
