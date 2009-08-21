# Makefile for the APQ
#
# @author Marcelo Coraça de Freitas <marcelo@kow.com.br> 

VERSION=3.0

ifeq ($(PREFIX), $(SOME_RANDOM_EMPTY_VAR_LALALELEL))
	PREFIX=/usr/local
endif


projectFile="apq.gpr"


all: libs gprfile

libs:
	gnatmake -P ${projectFile}

gprfile:
	@echo "Preparing GPR file.."
	@echo version:=\"$(VERSION)\" > gpr/apq.def
	@echo prefix:=\"$(PREFIX)\" >> gpr/apq.def
	@gnatprep gpr/apq.gpr.in gpr/apq.gpr gpr/apq.def




clean:
	@gnatclean -P ${projectFile}
	@rm -f gpr/apq.def gpr/apq.gpr
	@echo "All clean"

docs:
	@-./gendoc.sh
	@echo "The documentation is generated by a bash script. Then it might fail in other platforms"

install:
	@echo "Installing files"
	install gpr/apq.gpr $(PREFIX)/lib/gnat
	install lib/* $(PREFIX)/lib
