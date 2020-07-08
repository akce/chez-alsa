# chez-alsa Makefile.
# Written by Akce 2020.
# SPDX-License-Identifier: Unlicense

# Install destination directory. This should be an object directory contained in (library-directories).
# eg, set in CHEZSCHEMELIBDIRS environment variable.
LIBDIR = ~/lib

# Path to chez scheme executable.
SCHEME = /usr/bin/scheme

# Scheme compile flags.
SFLAGS = -q

# Path to install executable.
INSTALL = /usr/bin/install

# Path to rm executable.
RM = /bin/rm

## Should be no need to edit anything below here.

# Scheme sources need to be in order of dependencies first, library last.
# That should avoid compile/load errors.
LIBSRC = alsa/ftypes-util.chezscheme.sls alsa/pcm.sls
ROOTSRC =
LIBBIN =

LIBSO = $(LIBSRC:.sls=.so)
ROOTSO = $(ROOTSRC:.sls=.so)

ILIBSRC = $(addprefix $(LIBDIR)/,$(LIBSRC))
IROOTSRC = $(addprefix $(LIBDIR)/,$(ROOTSRC))

ILIBSO = $(addprefix $(LIBDIR)/,$(LIBSO))
IROOTSO = $(addprefix $(LIBDIR)/,$(ROOTSO))
ILIBBIN = $(addprefix $(LIBDIR)/,$(LIBBIN))

all: $(LIBSO) $(ROOTSO)

$(LIBBIN):
	echo "You must manually build $(LIBBIN)"
	exit 1

%.so: %.sls
	echo '(reset-handler abort) (compile-library "'$<'")' | $(SCHEME) $(SFLAGS)

$(LIBDIR)/%.sls: %.sls
	$(INSTALL) -D -p $< $@

$(ILIBBIN): $(LIBBIN)
	$(INSTALL) -D -p $< $@

# install-lib is always required, installations then need to decide what combination of src/so they want.
# Default install target is for everything.
install: install-lib install-so install-src

install-lib: $(ILIBBIN)


install-so: $(ILIBSO) $(IROOTSO)

install-src: $(ILIBSRC) $(IROOTSRC)

clean:
	$(RM) -f $(LIBSO) $(ROOTSO) $(ILIBSO) $(ILIBSRC) $(IROOTSO) $(IROOTSRC) $(ILIBBIN)
