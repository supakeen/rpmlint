#############################################################################
# File		: Makefile
# Package	: rpmlint
# Author	: Frederic Lepied
# Created on	: Mon Sep 30 13:20:18 1999
# Version	: $Id$
# Purpose	: rules to manage the files.
#############################################################################

BINDIR=/usr/bin
LIBDIR=/usr/share/rpmlint
ETCDIR=/etc/rpmlint

FILES= rpmlint *.py INSTALL README README.CVS COPYING ChangeLog Makefile config rpmlint.spec rpmdiff

PACKAGE=rpmlint
VERSION:=$(shell grep '%define *version ' $(PACKAGE).spec| cut -d ' ' -f 3)
RELEASE:=$(shell grep '%define *release ' $(PACKAGE).spec| cut -d ' ' -f 3)
TAG := $(shell echo "V$(VERSION)_$(RELEASE)" | tr -- '-.' '__')

all:
	./compile.py "$(LIBDIR)/" [A-Z]*.py

clean:
	rm -f *~ *.pyc *.pyo

install:
	-mkdir -p $(DESTDIR)$(LIBDIR) $(DESTDIR)$(BINDIR) $(DESTDIR)$(ETCDIR)
	cp -p *.py *.pyo $(DESTDIR)$(LIBDIR)
	cp -p rpmlint $(DESTDIR)$(BINDIR)
	cp -p rpmdiff $(DESTDIR)$(BINDIR)/rpmdiff.py
	cp -p config  $(DESTDIR)$(ETCDIR)

verify:
	pychecker *.py

# rules to build a test rpm

localrpm: localdist buildrpm

localdist: cleandist dir localcopy tar

cleandist:
	rm -rf $(PACKAGE)-$(VERSION) $(PACKAGE)-$(VERSION).tar.bz2

dir:
	mkdir $(PACKAGE)-$(VERSION)

localcopy:
	tar c $(FILES) | tar x -C $(PACKAGE)-$(VERSION)

tar:
	tar cvf $(PACKAGE)-$(VERSION).tar $(PACKAGE)-$(VERSION)
	bzip2 -9vf $(PACKAGE)-$(VERSION).tar
	rm -rf $(PACKAGE)-$(VERSION)

buildrpm:
	rpm -ta $(PACKAGE)-$(VERSION).tar.bz2

# rules to build a distributable rpm

rpm: changelog cvstag dist buildrpm

dist: cleandist dir export tar

export:
	cvs export -d $(PACKAGE)-$(VERSION) -r $(TAG) $(PACKAGE)

cvstag:
	cvs commit
	cvs tag $(CVSTAGOPT) $(TAG)

changelog: ../common/username
	cvs2cl -U ../common/username -I ChangeLog 
	rm -f ChangeLog.bak
	cvs commit -m "Generated by cvs2cl the `date '+%d_%b'`" ChangeLog

# Makefile ends here
