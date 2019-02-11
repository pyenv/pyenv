#! /bin/sh
#
# shobj-conf -- output a series of variable assignments to be substituted
#		into a Makefile by configure which specify system-dependent
#		information for creating shared objects that may be loaded
#		into bash with `enable -f'
#
# usage: shobj-conf [-C compiler] -c host_cpu -o host_os -v host_vendor
#
# Chet Ramey
# chet@po.cwru.edu

#   Copyright (C) 1996-2014 Free Software Foundation, Inc.
#
#   This file is part of GNU Bash, the Bourne Again SHell.
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
# defaults
#
SHOBJ_STATUS=supported
SHLIB_STATUS=supported

SHOBJ_CC=cc
SHOBJ_CFLAGS=
SHOBJ_LD=
SHOBJ_LDFLAGS=
SHOBJ_XLDFLAGS=
SHOBJ_LIBS=

SHLIB_XLDFLAGS=
SHLIB_LIBS=

SHLIB_DOT='.'
SHLIB_LIBPREF='lib'
SHLIB_LIBSUFF='so'

SHLIB_LIBVERSION='$(SHLIB_LIBSUFF)'
SHLIB_DLLVERSION='$(SHLIB_MAJOR)'

PROGNAME=`basename $0`
USAGE="$PROGNAME [-C compiler] -c host_cpu -o host_os -v host_vendor"

while [ $# -gt 0 ]; do
	case "$1" in
	-C)	shift; SHOBJ_CC="$1"; shift ;;
	-c)	shift; host_cpu="$1"; shift ;;
	-o)	shift; host_os="$1"; shift ;;
	-v)	shift; host_vendor="$1"; shift ;;
	*)	echo "$USAGE" >&2 ; exit 2;;
	esac
done

case "${host_os}-${SHOBJ_CC}-${host_vendor}" in
nsk-cc-tandem)
	SHOBJ_CFLAGS=-Wglobalized
	case `uname -m` in
	NSR*)
		SHOBJ_CFLAGS="${SHOBJ_CFLAGS} -Wcall_shared" # default on TNS/E, needed on TNS/R
		SHOBJ_LD=/usr/bin/ld # for TNS/R
		;;
	NSE*|NEO*)
		SHOBJ_LD=/usr/bin/eld
		;;
	esac
	SHOBJ_LDFLAGS='-shared -bglobalized -unres_symbols ignore'
	;;

sunos4*-*gcc*)
	SHOBJ_CFLAGS=-fpic
	SHOBJ_LD=/usr/bin/ld
	SHOBJ_LDFLAGS='-assert pure-text'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)$(SHLIB_MINOR)'
	;;

sunos4*)
	SHOBJ_CFLAGS=-pic
	SHOBJ_LD=/usr/bin/ld
	SHOBJ_LDFLAGS='-assert pure-text'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)$(SHLIB_MINOR)'
	;;

sunos5*-*gcc*|solaris2*-*gcc*)
	SHOBJ_LD='${CC}'
	ld_used=`gcc -print-prog-name=ld`
	if ${ld_used} -V 2>&1 | grep GNU >/dev/null 2>&1; then
		# This line works for the GNU ld
		SHOBJ_LDFLAGS='-shared -Wl,-h,$@'
		# http://sourceware.org/ml/binutils/2001-08/msg00361.html
		SHOBJ_CFLAGS=-fPIC
	else
		# This line works for the Solaris linker in /usr/ccs/bin/ld
		SHOBJ_LDFLAGS='-shared -Wl,-i -Wl,-h,$@'
		SHOBJ_CFLAGS=-fpic
	fi

#	SHLIB_XLDFLAGS='-R $(libdir)'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

sunos5*|solaris2*)
	SHOBJ_CFLAGS='-K pic'
	SHOBJ_LD=/usr/ccs/bin/ld
	SHOBJ_LDFLAGS='-G -dy -z text -i -h $@'

#	SHLIB_XLDFLAGS='-R $(libdir)'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

# All versions of Linux (including Gentoo/FreeBSD) or the semi-mythical GNU Hurd.
linux*-*|gnu*-*|k*bsd*-gnu-*|freebsd*-gentoo)
	SHOBJ_CFLAGS=-fPIC
	SHOBJ_LD='${CC}'
	SHOBJ_LDFLAGS='-shared -Wl,-soname,$@'

	SHLIB_XLDFLAGS='-Wl,-rpath,$(libdir) -Wl,-soname,`basename $@ $(SHLIB_MINOR)`'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)$(SHLIB_MINOR)'
	;;

freebsd2*)
	SHOBJ_CFLAGS=-fpic
	SHOBJ_LD=ld
	SHOBJ_LDFLAGS='-x -Bshareable'

	SHLIB_XLDFLAGS='-R$(libdir)'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)$(SHLIB_MINOR)'
	;;

# FreeBSD-3.x ELF
freebsd3*|freebsdaout*)
	SHOBJ_CFLAGS=-fPIC
	SHOBJ_LD='${CC}'

	if [ -x /usr/bin/objformat ] && [ "`/usr/bin/objformat`" = "elf" ]; then
		SHOBJ_LDFLAGS='-shared -Wl,-soname,$@'

		SHLIB_XLDFLAGS='-Wl,-rpath,$(libdir)'
		SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	else
		SHOBJ_LDFLAGS='-shared'

		SHLIB_XLDFLAGS='-R$(libdir)'
		SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)$(SHLIB_MINOR)'
	fi
	;;

# FreeBSD-4.x and later have only ELF
freebsd[4-9]*|freebsd1[0-9]*|freebsdelf*|dragonfly*)
	SHOBJ_CFLAGS=-fPIC
	SHOBJ_LD='${CC}'

	SHOBJ_LDFLAGS='-shared -Wl,-soname,$@'
	SHLIB_XLDFLAGS='-Wl,-rpath,$(libdir)'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

# Darwin/MacOS X
darwin*)
	# Common definitions for all darwin/mac os x versions
	SHOBJ_CFLAGS='-fno-common'

	SHOBJ_LD='${CC}'

	SHLIB_LIBVERSION='$(SHLIB_MAJOR)$(SHLIB_MINOR).$(SHLIB_LIBSUFF)'
	SHLIB_LIBSUFF='dylib'

	# unused at this time
	SHLIB_SONAME='$(libdir)/`echo $@ | sed "s:\\..*::"`.$(SHLIB_MAJOR).$(SHLIB_LIBSUFF)'

	case "${host_os}" in
	# Darwin versions 1, 5, 6, 7 correspond to Mac OS X 10.0, 10.1, 10.2,
	# and 10.3, respectively.
	darwin[1-7].*)
		SHOBJ_STATUS=unsupported
		SHOBJ_LDFLAGS='-dynamic'
		SHLIB_XLDFLAGS='-arch_only `/usr/bin/arch` -install_name $(libdir)/`echo $@ | sed "s:\\..*::"`.$(SHLIB_MAJOR).$(SHLIB_LIBSUFF) -current_version $(SHLIB_MAJOR)$(SHLIB_MINOR) -compatibility_version $(SHLIB_MAJOR) -v'
		;;
	# Darwin 8 == Mac OS X 10.4; Mac OS X 10.N == Darwin N+4
	*)
		case "${host_os}" in
		darwin[89]*|darwin1[012]*)
			SHOBJ_ARCHFLAGS='-arch_only `/usr/bin/arch`'
			;;
		 *) 	# Mac OS X 10.9 (Mavericks) and later
			SHOBJ_ARCHFLAGS=
			# for 32 and 64bit universal library
			#SHOBJ_ARCHFLAGS='-arch i386 -arch x86_64'
			#SHOBJ_CFLAGS=${SHOBJ_CFLAGS}' -arch i386 -arch x86_64'
			;;
		 esac
		 SHOBJ_LDFLAGS="-dynamiclib -dynamic -undefined dynamic_lookup ${SHOBJ_ARCHFLAGS}"
		 SHLIB_XLDFLAGS="-dynamiclib ${SHOBJ_ARCHFLAGS}"' -install_name $(libdir)/`echo $@ | sed "s:\\..*::"`.$(SHLIB_MAJOR).$(SHLIB_LIBSUFF) -current_version $(SHLIB_MAJOR)$(SHLIB_MINOR) -compatibility_version $(SHLIB_MAJOR) -v'
		;;
	esac

	SHLIB_LIBS='-lncurses'	# see if -lcurses works on MacOS X 10.1 
	;;

openbsd*|netbsd*|mirbsd*)
	SHOBJ_CFLAGS=-fPIC
	SHOBJ_LD='${CC}'
	SHOBJ_LDFLAGS='-shared'

	SHLIB_XLDFLAGS='-R$(libdir)'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)$(SHLIB_MINOR)'
	;;

bsdi2*)
	SHOBJ_CC=shlicc2
	SHOBJ_CFLAGS=
	SHOBJ_LD=ld
	SHOBJ_LDFLAGS=-r
	SHOBJ_LIBS=-lc_s.2.1.0

	# BSD/OS 2.x and 3.x `shared libraries' are too much of a pain in
	# the ass -- they require changing {/usr/lib,etc}/shlib.map on
	# each system, and the library creation process is byzantine
	SHLIB_STATUS=unsupported
	;;

bsdi3*)
	SHOBJ_CC=shlicc2
	SHOBJ_CFLAGS=
	SHOBJ_LD=ld
	SHOBJ_LDFLAGS=-r
	SHOBJ_LIBS=-lc_s.3.0.0

	# BSD/OS 2.x and 3.x `shared libraries' are too much of a pain in
	# the ass -- they require changing {/usr/lib,etc}/shlib.map on
	# each system, and the library creation process is byzantine
	SHLIB_STATUS=unsupported
	;;

bsdi4*)
	# BSD/OS 4.x now supports ELF and SunOS-style dynamically-linked
	# shared libraries.  gcc 2.x is the standard compiler, and the
	# `normal' gcc options should work as they do in Linux.

	SHOBJ_CFLAGS=-fPIC
	SHOBJ_LD='${CC}'
	SHOBJ_LDFLAGS='-shared -Wl,-soname,$@'

	SHLIB_XLDFLAGS='-Wl,-soname,`basename $@ $(SHLIB_MINOR)`'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)$(SHLIB_MINOR)'
	;;

osf*-*gcc*)
	# Fix to use gcc linker driver from bfischer@TechFak.Uni-Bielefeld.DE
	SHOBJ_LD='${CC}'
	SHOBJ_LDFLAGS='-shared -Wl,-soname,$@'

	SHLIB_XLDFLAGS='-rpath $(libdir)'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

osf*)
	SHOBJ_LD=ld
	SHOBJ_LDFLAGS='-shared -soname $@ -expect_unresolved "*"'

	SHLIB_XLDFLAGS='-rpath $(libdir)'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

aix4.[2-9]*-*gcc*|aix[5-9].*-*gcc*)		# lightly tested by jik@cisco.com
	SHOBJ_CFLAGS=-fpic
	SHOBJ_LD='ld'
	SHOBJ_LDFLAGS='-bdynamic -bnoentry -bexpall'
	SHOBJ_XLDFLAGS='-G'

	SHLIB_XLDFLAGS='-bM:SRE'
	SHLIB_LIBS='-lcurses -lc'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

aix4.[2-9]*|aix[5-9].*)
	SHOBJ_CFLAGS=-K
	SHOBJ_LD='ld'
	SHOBJ_LDFLAGS='-bdynamic -bnoentry -bexpall'
	SHOBJ_XLDFLAGS='-G'

	SHLIB_XLDFLAGS='-bM:SRE'
	SHLIB_LIBS='-lcurses -lc'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

#
# THE FOLLOWING ARE UNTESTED -- and some may not support the dlopen interface
#
irix[56]*-*gcc*)
	SHOBJ_CFLAGS='-fpic'
	SHOBJ_LD='${CC}'
	SHOBJ_LDFLAGS='-shared -Wl,-soname,$@'

	SHLIB_XLDFLAGS='-Wl,-rpath,$(libdir)'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

irix[56]*)
	SHOBJ_CFLAGS='-K PIC'
	SHOBJ_LD=ld
#	SHOBJ_LDFLAGS='-call_shared -hidden_symbol -no_unresolved -soname $@'
#	Change from David Kaelbling <drk@sgi.com>.  If you have problems,
#	remove the `-no_unresolved'
	SHOBJ_LDFLAGS='-shared -no_unresolved -soname $@'

	SHLIB_XLDFLAGS='-rpath $(libdir)'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

hpux9*-*gcc*)
	# must use gcc; the bundled cc cannot compile PIC code
	SHOBJ_CFLAGS='-fpic'
	SHOBJ_LD='${CC}'
	SHOBJ_LDFLAGS='-shared -Wl,-b -Wl,+s'

	SHLIB_XLDFLAGS='-Wl,+b,$(libdir)'
	SHLIB_LIBSUFF='sl'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

hpux9*)
	SHOBJ_STATUS=unsupported
	SHLIB_STATUS=unsupported

	# If you are using the HP ANSI C compiler, you can uncomment and use
	# this code (I have not tested it)
#	SHOBJ_STATUS=supported
#	SHLIB_STATUS=supported
#
#	SHOBJ_CFLAGS='+z'
#	SHOBJ_LD='ld'
#	SHOBJ_LDFLAGS='-b +s'
#
#	SHLIB_XLDFLAGS='+b $(libdir)'
#	SHLIB_LIBSUFF='sl'
#	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'	

	;;

hpux10*-*gcc*)
	# must use gcc; the bundled cc cannot compile PIC code
	SHOBJ_CFLAGS='-fpic'
	SHOBJ_LD='${CC}'
	# if you have problems linking here, moving the `-Wl,+h,$@' from
	# SHLIB_XLDFLAGS to SHOBJ_LDFLAGS has been reported to work
	SHOBJ_LDFLAGS='-shared -fpic -Wl,-b -Wl,+s'

	SHLIB_XLDFLAGS='-Wl,+h,$@ -Wl,+b,$(libdir)'
	SHLIB_LIBSUFF='sl'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

hpux10*)
	SHOBJ_STATUS=unsupported
	SHLIB_STATUS=unsupported

	# If you are using the HP ANSI C compiler, you can uncomment and use
	# this code (I have not tested it)
#	SHOBJ_STATUS=supported
#	SHLIB_STATUS=supported
#
#	SHOBJ_CFLAGS='+z'
#	SHOBJ_LD='ld'
#	SHOBJ_LDFLAGS='-b +s +h $@'
#
#	SHLIB_XLDFLAGS='+b $(libdir)'
#	SHLIB_LIBSUFF='sl'
#	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'	

	;;

hpux11*-*gcc*)
	# must use gcc; the bundled cc cannot compile PIC code
	SHOBJ_CFLAGS='-fpic'
	SHOBJ_LD='${CC}'
#	SHOBJ_LDFLAGS='-shared -Wl,-b -Wl,-B,symbolic -Wl,+s -Wl,+std -Wl,+h,$@'
	SHOBJ_LDFLAGS='-shared -fpic -Wl,-b -Wl,+s -Wl,+h,$@'

	SHLIB_XLDFLAGS='-Wl,+b,$(libdir)'
	SHLIB_LIBSUFF='sl'
	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

hpux11*)
	SHOBJ_STATUS=unsupported
	SHLIB_STATUS=unsupported

	# If you are using the HP ANSI C compiler, you can uncomment and use
	# this code (I have not tested it)
#	SHOBJ_STATUS=supported
#	SHLIB_STATUS=supported
#
#	SHOBJ_CFLAGS='+z'
#	SHOBJ_LD='ld'
#	SHOBJ_LDFLAGS='-b +s +h $@'
#
#	SHLIB_XLDFLAGS='+b $(libdir)'
#	SHLIB_LIBSUFF='sl'
#	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'	

	;;

sysv4*-*gcc*)
	SHOBJ_CFLAGS=-shared
	SHOBJ_LDFLAGS='-shared -h $@'
	SHOBJ_LD='${CC}'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

sysv4*)
	SHOBJ_CFLAGS='-K PIC'
	SHOBJ_LD=ld
	SHOBJ_LDFLAGS='-dy -z text -G -h $@'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

sco3.2v5*-*gcc*)
	SHOBJ_CFLAGS='-fpic'		# DEFAULTS TO ELF
	SHOBJ_LD='${CC}'
	SHOBJ_LDFLAGS='-shared'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

sco3.2v5*)
	SHOBJ_CFLAGS='-K pic -b elf'
	SHOBJ_LD=ld
	SHOBJ_LDFLAGS='-G -b elf -dy -z text -h $@'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

sysv5uw7*-*gcc*)
	SHOBJ_CFLAGS='-fpic'
	SHOBJ_LD='${CC}'
	SHOBJ_LDFLAGS='-shared'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

sysv5uw7*)
	SHOBJ_CFLAGS='-K PIC'
	SHOBJ_LD=ld
	SHOBJ_LDFLAGS='-G -dy -z text -h $@'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

sysv5UnixWare*-*gcc*)
	SHOBJ_CFLAGS=-fpic
	SHOBJ_LD='${CC}'
	SHOBJ_LDFLAGS='-shared'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

sysv5UnixWare*)
	SHOBJ_CFLAGS='-K PIC'
	SHOBJ_LD=ld
	SHOBJ_LDFLAGS='-G -dy -z text -h $@'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

sysv5OpenUNIX*-*gcc*)
	SHOBJ_CFLAGS=-fpic
	SHOBJ_LD='${CC}'
	SHOBJ_LDFLAGS='-shared'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

sysv5OpenUNIX*)
	SHOBJ_CFLAGS='-K PIC'
	SHOBJ_LD=ld
	SHOBJ_LDFLAGS='-G -dy -z text -h $@'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

dgux*-*gcc*)
	SHOBJ_CFLAGS=-fpic
	SHOBJ_LD='${CC}'
	SHOBJ_LDFLAGS='-shared'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

dgux*)
	SHOBJ_CFLAGS='-K pic'
	SHOBJ_LD=ld
	SHOBJ_LDFLAGS='-G -dy -h $@'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

msdos*)
	SHOBJ_STATUS=unsupported
	SHLIB_STATUS=unsupported
	;;

cygwin*)
	SHOBJ_LD='$(CC)'
	SHOBJ_LDFLAGS='-shared -Wl,--enable-auto-import -Wl,--enable-auto-image-base -Wl,--export-all -Wl,--out-implib=$(@).a'
	SHLIB_LIBPREF='cyg'
	SHLIB_LIBSUFF='dll'
	SHLIB_LIBVERSION='$(SHLIB_DLLVERSION).$(SHLIB_LIBSUFF)'
	SHLIB_LIBS='$(TERMCAP_LIB)'

	SHLIB_DOT=
	# For official cygwin releases, DLLVERSION will be defined in the
	# environment of configure, and will be incremented any time the API
	# changes in a non-backwards compatible manner.  Otherwise, it is just
	# SHLIB_MAJOR.
	if [ -n "$DLLVERSION" ] ; then
		SHLIB_DLLVERSION="$DLLVERSION"
	fi
	;;

mingw*)
	SHOBJ_LD='$(CC)'
	SHOBJ_LDFLAGS='-shared -Wl,--enable-auto-import -Wl,--enable-auto-image-base -Wl,--export-all -Wl,--out-implib=$(@).a'
	SHLIB_LIBSUFF='dll'
	SHLIB_LIBVERSION='$(SHLIB_DLLVERSION).$(SHLIB_LIBSUFF)'
	SHLIB_LIBS='$(TERMCAP_LIB)'

	SHLIB_DOT=
	# For official cygwin releases, DLLVERSION will be defined in the
	# environment of configure, and will be incremented any time the API
	# changes in a non-backwards compatible manner.  Otherwise, it is just
	# SHLIB_MAJOR.
	if [ -n "$DLLVERSION" ] ; then
		SHLIB_DLLVERSION="$DLLVERSION"
	fi
	;;

#
# Rely on correct gcc configuration for everything else
#
*-*gcc*)
	SHOBJ_CFLAGS=-fpic
	SHOBJ_LD='${CC}'
	SHOBJ_LDFLAGS='-shared'

	SHLIB_LIBVERSION='$(SHLIB_LIBSUFF).$(SHLIB_MAJOR)'
	;;

*)
	SHOBJ_STATUS=unsupported
	SHLIB_STATUS=unsupported
	;;

esac

echo SHOBJ_CC=\'"$SHOBJ_CC"\'
echo SHOBJ_CFLAGS=\'"$SHOBJ_CFLAGS"\'
echo SHOBJ_LD=\'"$SHOBJ_LD"\'
echo SHOBJ_LDFLAGS=\'"$SHOBJ_LDFLAGS"\'
echo SHOBJ_XLDFLAGS=\'"$SHOBJ_XLDFLAGS"\'
echo SHOBJ_LIBS=\'"$SHOBJ_LIBS"\'

echo SHLIB_XLDFLAGS=\'"$SHLIB_XLDFLAGS"\'
echo SHLIB_LIBS=\'"$SHLIB_LIBS"\'

echo SHLIB_DOT=\'"$SHLIB_DOT"\'

echo SHLIB_LIBPREF=\'"$SHLIB_LIBPREF"\'
echo SHLIB_LIBSUFF=\'"$SHLIB_LIBSUFF"\'

echo SHLIB_LIBVERSION=\'"$SHLIB_LIBVERSION"\'
echo SHLIB_DLLVERSION=\'"$SHLIB_DLLVERSION"\'

echo SHOBJ_STATUS=\'"$SHOBJ_STATUS"\'
echo SHLIB_STATUS=\'"$SHLIB_STATUS"\'

exit 0
