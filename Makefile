PROJECT ?= radxa-desktop-branding
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib
MANDIR ?= $(PREFIX)/share/man
ETCDIR ?= /etc

.PHONY: all
all: build

.PHONY: build
build:
	./gen-assets.sh
#
# Test
#
.PHONY: test
test:

#
# Clean
#
.PHONY: distclean
distclean: clean

.PHONY: clean
clean: clean-deb


.PHONY: clean-deb
clean-deb:
	rm -rf debian/.debhelper debian/$(PROJECT)/ debian/debhelper-build-stamp debian/files debian/*.debhelper.log debian/*.postrm.debhelper debian/*.substvars \
		src/usr/share/wallpapers/ src/usr/share/images/ src/usr/share/gnome-shell/gnome-shell-theme.gresource src/gnome-shell/data/gnome-shell-theme.gresource \
		src/gnome-shell/data/theme/background.svg

#
# Release
#
.PHONY: dch
dch: debian/changelog
	EDITOR=true gbp dch --ignore-branch --multimaint-merge --commit --release --dch-opt=--upstream

.PHONY: deb
deb: debian
	debuild --no-lintian --lintian-hook "lintian --fail-on error,warning --suppress-tags bad-distribution-in-changes-file -- %p_%v_*.changes" --no-sign -b

.PHONY: release
release:
	gh workflow run .github/workflows/new_version.yml --ref $(shell git branch --show-current)
