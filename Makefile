VERSION = 5.48
NAME = rpmdrake

DIRS = po data mime

PREFIX = /usr/local
DATADIR = $(PREFIX)/share
BINDIR = $(PREFIX)/bin
SBINDIR = $(PREFIX)/sbin
RELATIVE_SBIN = ../sbin
RPM=$(shell rpm --eval %_topdir)
PERL_VENDORLIB=$(DESTDIR)/$(shell perl -V:installvendorlib   | perl -pi -e "s/.*=//; s/[;']//g")

all: dirs

dirs:
	@for n in . $(DIRS); do \
		[ "$$n" = "." ] || make -C $$n || exit 1 ;\
	done

install: $(ALL)
	find -name '*.pm' -o -name rpmdrake -o -name OnlineUpdate | xargs ./simplify-drakx-modules
	./simplify-drakx-modules {gurpmi.addmedia,edit-urpm-sources.pl}
	@for n in $(DIRS); do make -C $$n install; done
	install -d $(SBINDIR)
	install rpmdrake OnlineUpdate edit-urpm-sources.pl gurpmi.addmedia $(SBINDIR)
	install -d $(BINDIR)
	ln -sf $(RELATIVE_SBIN)/rpmdrake $(BINDIR)/rpmdrake
	ln -sf $(RELATIVE_SBIN)/OnlineUpdate $(BINDIR)/OnlineUpdate
	ln -sf $(RELATIVE_SBIN)/edit-urpm-sources.pl $(BINDIR)/edit-urpm-sources.pl
	ln -sf edit-urpm-sources.pl $(SBINDIR)/drakrpm-edit-media
	ln -sf $(RELATIVE_SBIN)/drakrpm-edit-media $(BINDIR)/drakrpm-edit-media
	ln -sf $(RELATIVE_SBIN)/gurpmi.addmedia $(BINDIR)/gurpmi.addmedia
	ln -sf $(RELATIVE_SBIN)/rpmdrake $(BINDIR)/drakrpm
	ln -sf $(RELATIVE_SBIN)/OnlineUpdate $(SBINDIR)/drakrpm-update
	ln -sf $(RELATIVE_SBIN)/drakrpm-update $(BINDIR)/drakrpm-update
	install -d $(DATADIR)/rpmdrake/icons
	install -m644 icons/*.png $(DATADIR)/rpmdrake/icons
	install -m644 gui.lst $(DATADIR)/rpmdrake
	mkdir -p $(PERL_VENDORLIB)/Rpmdrake
	install -m 644 rpmdrake.pm $(PERL_VENDORLIB)
	install -m 644 Rpmdrake/*.pm $(PERL_VENDORLIB)/Rpmdrake
	perl -pi -e "s/version = 1/version = \'$(VERSION)'/" $(PERL_VENDORLIB)/Rpmdrake/init.pm

clean:
	@for n in $(DIRS); do make -C $$n clean; done

dis: dist
dist: clean
	rm -rf ../$(NAME)-$(VERSION).tar*
	@if [ -e ".svn" ]; then \
		$(MAKE) dist-svn; \
	elif [ -e ".git" ]; then \
		$(MAKE) dist-git; \
	else \
		echo "Unknown SCM (not SVN nor GIT)";\
		exit 1; \
	fi;
	$(info $(NAME)-$(VERSION).tar.xz is ready)

dist-svn:
	rm -rf $(NAME)-$(VERSION) ../$(NAME)-$(VERSION).tar*
	svn export -q -rBASE . $(NAME)-$(VERSION)
	find $(NAME)-$(VERSION) -name .svnignore |xargs rm -rf
	tar cfa ../$(NAME)-$(VERSION).tar.xz $(NAME)-$(VERSION)
	rm -rf $(NAME)-$(VERSION)

dist-git:
	 @git archive --prefix=$(NAME)-$(VERSION)/ HEAD | xz  >../$(NAME)-$(VERSION).tar.xz;

gui.lst:
	export LC_COLLATE=C; ( echo -e "cedega-mandriva\npicasa\nVariCAD_2009-en\nVariCAD_View_2009-en\nVMware-Player" ; \
	urpmf "/usr/share/((applnk|applications(|/kde)|apps/kicker/applets)/|kde4/services/plasma-applet).*.desktop" |sed -e 's!:.*!!') \
	 | sort -u > gui.lst

check:
	rm -f po/*.pot 
	@make -C po rpmdrake.pot

.PHONY: ChangeLog log changelog gui.lst

log: ChangeLog

changelog: ChangeLog

ChangeLog:
	svn2cl --accum
	rm -f *.bak
