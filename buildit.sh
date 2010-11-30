#!/bin/bash 
#
# PS3 GNU Toolchain builder
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Copyright (C) 2007 Segher Boessenkool <segher@kernel.crashing.org>
# Copyright (C) 2009 Hector Martin "marcan" <hector@marcansoft.com>
# Copyright (C) 2009 Andre Heider "dhewg" <dhewg@V850brew.org>
# Copyright (C) 2010 Alex Marshall "trap15" <trap15@raidenii.net>
#
# Uses patches by Dan Peori "oopo"  <dan.peori@oopo.net>
#
# TODO
# no need to download/check the tarballs so often
#

#
# Start of configuration section.
#

# screen output is more verbose if DEBUG is non-zero, log output is the same
DEBUG="true"
PREP="true"
PATCH="true"

# toolchain components to build
BUILD_BINUTILS="true"
BUILD_CRT="true"
BUILD_GCC1="true"
BUILD_GCC2="true"
BUILD_GDB="true"
BUILD_GMP="true"
BUILD_MPC="true"
BUILD_MPFR="true"
BUILD_NEWLIB="true"

# additional make options
MAKEOPTS="-j1"
# additional compiler/linker flags
EXTRAFLAGS=""

# GNU repository
GNU_URI="http://ftp.gnu.org/gnu"
# newlib repository
NEWLIB_URI="ftp://sources.redhat.com/pub/newlib"
# mpfr repository
MPFR_URI="http://www.mpfr.org"
# mpc repository
MPC_URI="http://www.multiprecision.org/mpc/download"

#
# You should not need to edit anything below here, unless you REALLY know what you are doing
#

# verify README was read or exit
if [ -n "${PS3CHAIN}" -a -n "${1}" ]; then
	echo "********** Starting :: Using environment variable PS3CHAIN=${PS3CHAIN} as destination ..."
elif [ -z "${PS3CHAIN}" -a -n "${PS3DEV}" -a -n "${1}" ]; then
	echo "********** Starting :: Using environment variable PS3DEV=${PS3DEV} as destination, hope that is what you wanted ..."
	PS3CHAIN="${PS3DEV}"
else
	BUILDTYPE="help"
fi

# define type of build from arg1
BUILDTYPE="${BUILDTYPE:-$1}"
# store the present working directory
BUILDIT_DIR="${PWD}"
# patches source directory
PATCHES_SRCDIR="${BUILDIT_DIR}/patches"
# makerules source directory
MAKERULES_SRCDIR="${BUILDIT_DIR}/makerules"
# tar directory
TAR_DIR="${PS3CHAIN}/src"
# src directory
SRC_DIR="${PS3CHAIN}/src"
# build directory
BUILD_DIR="${PS3CHAIN}/build"
# patchces directory
PATCHES_DIR="${PS3CHAIN}/patches"
# PPU directory
PPU_DIR="${PS3CHAIN}/ppu"
# SPU directory
SPU_DIR="${PS3CHAIN}/spu"
# build output filename
BUILDOUTPUT="${PS3CHAIN}/build.${BUILDTYPE}.out"
# SPU settings
SPU_TARGET="spu"
SPU_NEWLIB_TARGET="${SPU_TARGET}"
# PPU settings
#PPU_TARGET="powerpc64-linux"
#PPU_NEWLIB_TARGET="ppc64"
PPU_TARGET="ppu"
PPU_NEWLIB_TARGET="${PPU_TARGET}"
# binutils settings
#BINUTILS_VER="2.20"
BINUTILS_VER="2.20.1"
BINUTILS_TARBALL="${TAR_DIR}/binutils-${BINUTILS_VER}.tar.bz2"
BINUTILS_URI="${GNU_URI}/binutils/${BINUTILS_TARBALL}"
BINUTILS_SRCDIR="${SRC_DIR}/binutils-${BINUTILS_VER}"
BINUTILS_PATCH="${PATCHES_DIR}/binutils-${BINUTILS_VER}-PPU.patch"
BINUTILS_BUILDDIR="${BUILD_DIR}/build_binutils"
BINUTILS_OUT="${BUILDOUTPUT}"
# gcc settings
GCC_VER="4.5.1"
GCC_TARBALL="${TAR_DIR}/gcc-${GCC_VER}.tar.bz2"
GCC_URI="${GNU_URI}/gcc/gcc-${GCC_VER}/${GCC_TARBALL}"
GCC_SRCDIR="${SRC_DIR}/gcc-${GCC_VER}"
GCC_PATCH="${PATCHES_DIR}/gcc-${GCC_VER}-PPU.patch"
GCC_BUILDDIR="${BUILD_DIR}/build_gcc"
GCC_OUT="${BUILDOUTPUT}"
# gdb settings
#GDB_VER="7.1"
GDB_VER="7.2"
GDB_TARBALL="${TAR_DIR}/gdb-${GDB_VER}.tar.bz2"
GDB_URI="${GNU_URI}/gdb/${GDB_TARBALL}"
GDB_SRCDIR="${SRC_DIR}/gdb-${GDB_VER}"
GDB_PATCH="${PATCHES_DIR}/gdb-${GDB_VER}-PPU.patch"
GDB_BUILDDIR="${BUILD_DIR}/build_gdb"
GDB_OUT="${BUILDOUTPUT}"
# crt settings
CRT_DIR="${BUILDIT_DIR}/crt"
CRT_SRCDIR="${SRC_DIR}/crt"
CRT_BUILDDIR="${BUILD_DIR}/build_crt"
CRT_OUT="${BUILDOUTPUT}"
# gmp settings
GMP_VER="5.0.1"
GMP_TARBALL="${TAR_DIR}/gmp-${GMP_VER}.tar.bz2"
GMP_URI="${GNU_URI}/gmp/${GMP_TARBALL}"
GMP_SRCDIR="${SRC_DIR}/gmp-${GMP_VER}"
GMP_GCCSRCDIR="${GCC_SRCDIR}/gmp"
# mpc settings
MPC_VER="0.8.2"
MPC_TARBALL="${TAR_DIR}/mpc-${MPC_VER}.tar.gz"
MPC_URI="${MPC_URI}/${MPC_TARBALL}"
MPC_SRCDIR="${SRC_DIR}/mpc-${MPC_VER}"
MPC_GCCSRCDIR="${GCC_SRCDIR}/mpc"
# mpfr settings
#MPFR_VER="2.4.2"
MPFR_VER="3.0.0"
MPFR_TARBALL="${TAR_DIR}/mpfr-${MPFR_VER}.tar.bz2"
MPFR_URI="${MPFR_URI}/mpfr-${MPFR_VER}/${MPFR_TARBALL}"
MPFR_SRCDIR="${SRC_DIR}/mpfr-${MPFR_VER}"
MPFR_GCCSRCDIR="${GCC_SRCDIR}/mpfr"
# newlib settings
NEWLIB_VER="1.18.0"
NEWLIB_TARBALL="${TAR_DIR}/newlib-${NEWLIB_VER}.tar.gz"
NEWLIB_URI="${NEWLIB_URI}/${NEWLIB_TARBALL}"
NEWLIB_SRCDIR="${SRC_DIR}/newlib-${NEWLIB_VER}"
NEWLIB_PATCH="${PATCHES_DIR}/newlib-${NEWLIB_VER}-PPU.patch"
NEWLIB_BUILDDIR="${BUILD_DIR}/build_newlib"
NEWLIB_OUT="${BUILDOUTPUT}"

# define MAKE according to system architecture
case `uname -s` in
	*BSD*)
		OS="BSD";
		MAKEBIN="gmake"
		PATCHBIN="patch"
		ECHOBIN="echo"
		SEDBIN="sed"
		TARBIN="tar"
		WGETBIN="wget"
		
		;;
	*CYGWIN*)
		OS="CYGWIN";
		MAKEBIN="make"
		PATCHBIN="patch"
		ECHOBIN="echo"
		SEDBIN="sed"
		TARBIN="tar"
		WGETBIN="wget"
		
		;;
	*Darwin*)
		OS="DARWIN";
		MAKEBIN="gmake"
		PATCHBIN="/usr/bin/patch"
		ECHOBIN="/bin/echo"
		SEDBIN="/usr/bin/sed"
		TARBIN="/usr/bin/tar"
		WGETBIN="wget"
		
		;;
	*Linux*)
		OS="LINUX";
		MAKEBIN="make"
		PATCHBIN="/usr/bin/patch"
		ECHOBIN="echo"
		SEDBIN="sed"
		TARBIN="tar"
		WGETBIN="wget"
		
		;;
	*MINGW*)
		OS="MINGW";
		MAKEBIN="make"
		PATCHBIN="patch"
		ECHOBIN="echo"
		SEDBIN="sed"
		TARBIN="tar"
		WGETBIN="wget"
		
		;;
	*)
		OS="UNKNOWN";
		MAKEBIN="make"
		PATCHBIN="patch"
		ECHOBIN="echo"
		SEDBIN="sed"
		TARBIN="tar"
		WGETBIN="wget"
		
esac

# default make options
if [ -z "${MAKEOPTS}" ]; then
	MAKEOPTS="-j1"
fi

# default extra flags for building gcc
if [ -z "${EXTRAFLAGS}" ]; then
	EXTRAFLAGS=""
fi

#
# End of configuration section.
#

#
# Start of functions.
#

# echo debug message wrapper
function EchoDebug() {
	TEXT="${1}"
	[ "${DEBUG}" = "true" -o "${DEBUG}" = "TRUE" ] && "${ECHOBIN}" "${TEXT}"
}

# echo to file wrapper
function EchoFile() {
	TEXT="${1}"
	"${ECHOBIN}" "${TEXT}" >> "${BUILDOUTPUT}"
}

# echo to screen wrapper
function EchoTTY() {
	TEXT="${1}"
	"${ECHOBIN}" "${TEXT}"
}

# failure function
function die() {
	EchoTTY "ERROR :: ${FUNCNAME} :: ${@}"
	exit 1
}

# usage
function usage() {
cat README
EchoTTY
EchoTTY "To build the toolchain you must set PS3CHAIN or PS3DEV environment variable, and use one of the following arguments ..."
EchoTTY "Known to work on Linux and Mac OS X, but should compile for any GNU supported OS."
EchoTTY
EchoTTY "${0} <ARG>"
EchoTTY
EchoTTY "ARGUMENTS	Description"
EchoTTY "all		download, and build everything"
EchoTTY "ppu		download, and build the PPU chain"
EchoTTY "spu		download, and build the SPU chain"
EchoTTY "install	installs the built PPU/SPU chain"
EchoTTY "clean	clean src and build directories"
EchoTTY "wipe		wipe EVERYTHING, only needed if something goes wrong"
EchoTTY
EchoTTY "All output will be written to build.<ARG>.out in your PS3CHAIN/PS3DEV directory."
EchoTTY
EchoTTY "If you have already built a PS3 toolchain in the past, it is a good idea to set PS3CHAIN/PS3DEV to a temporary location for this build, then use the install option."
EchoTTY
EchoTTY "Recommended procedure:"
EchoTTY "export PS3CHAIN=/some/location/to/build"
EchoTTY "./${0} all"
EchoTTY "verify all went well"
EchoTTY "./${0} install /some/location"
EchoTTY
exit
}

# Copy file/directory wrapper
function Copy() {
	(
		SRC="${1}"
		DST="${2}"
		FLAG="${3}"
		if [ -e "${DST}" -a "${FLAG}" != "-f" -a "${FLAG}" != "-rf" ]; then
			EchoDebug "*** Did not copy ${SRC} --> ${DST}, already there ..."
		elif [ ! -f "${DST}" -a -z "${FLAG}" ]; then
			EchoDebug "*** Copying ${SRC} --> ${DST} ..."
			cp -v "${SRC}" "${DST}" >> "${BUILDOUTPUT}" 2>&1
		elif [ ! -f "${DST}" -a -n "${FLAG}" ]; then
			EchoDebug "*** Copying with flag: \"${FLAG}v\" ${SRC} --> ${DST} ..."
			cp "${FLAG}v" "${SRC}" "${DST}" >> "${BUILDOUTPUT}" 2>&1
		else
			ls -la "${DST}" >> "${BUILDOUTPUT}" 2>&1
			die "could not copy ${SRC} --> ${DST}"
		fi
	)
}

# download tarballs if they do not exist, if tarball exists verify it is ok
function Download() {
	(
		DL="1"
		TARURL="${1}"
		TARBALL="${2}"
		if [ -f "${TARBALL}" ]; then
			EchoDebug "*** Found ${TARBALL}, using that ..."
			EchoDebug "*** Testing ${TARBALL} ... 1st attempt ..."
			# try to test without specifying compression type
			"${TARBIN}" tf "${TARBALL}" >> "${BUILDOUTPUT}" 2>&1 && DL="0"
			if [ "${DL}" -eq "1" ]; then
				EchoDebug "*** 2nd attempt ..."
				# Check bz2
				"${TARBIN}" tjf "${TARBALL}" >> "${BUILDOUTPUT}" 2>&1 && DL="0"
				if [ "${DL}" -eq "1" ]; then
					EchoDebug "*** 3rd attempt ..."
					# Check gz
					"${TARBIN}" tzf "${TARBALL}" >> "${BUILDOUTPUT}" 2>&1 && DL="0"
				fi
				if [ "${DL}" -eq "1" ]; then
					EchoDebug "*** testing failed, downloading ${TARURL} ..."
				fi
			fi
		fi
		if [ "${DL}" -eq "1" ]; then
			EchoDebug "*** Downloading ${TARURL} to ${TARBALL} ..."
			"${WGETBIN}" "${TARURL}" -c -O "${TARBALL}" || die "could not download ${TARBALL} from ${TARURL} "
		fi
	)
}

# export environment variable
function Export() {
	VARIABLE="${1}"
	VALUE="${2}"
	FLAG="${3}"
	if [ -z "${!VARIABLE}" -a -n "${VALUE}" -a -z "${FLAG}" ]; then
		EchoDebug "*** Creating environment variable ${VARIABLE}=${VALUE} ..."
		export "${VARIABLE}=${VALUE}" >> "${BUILDOUTPUT}" 2>&1
	elif [ -n "${!VARIABLE}" -a -n "${VALUE}" -a -z "${FLAG}" ]; then
		EchoDebug "*** Reassigning environment variable ${VARIABLE}=${VALUE} was `declare -p ${VARIABLE}` ..."
		export "${VARIABLE}=${VALUE}" >> "${BUILDOUTPUT}" 2>&1
	elif [ -n "${!VARIABLE}" -a -n "${FLAG}" ]; then
		EchoDebug "*** Removing environment variable ${VARIABLE}=${VALUE} was `declare -p ${VARIABLE}` ..."
		export -n "${VARIABLE}" >> "${BUILDOUTPUT}" 2>&1
		unset -v "${VARIABLE}" >> "${BUILDOUTPUT}" 2>&1
	else
		die "could not export variable ${VARIABLE}=${VALUE} with FLAG=${FLAG} :: `declare -p ${VARIABLE}`"
	fi
}

# tar Extract wrapper
function Extract() {
	(
		EX="1"
		SRC="${1}"
		DST="${2}"
		TARDST=`"${ECHOBIN}" "${SRC}" | "${SEDBIN}" 's/.tar.*//g'`
		if [ -e "${TARDST}" -a -d "${TARDST}" ]; then
			EchoDebug "*** Did not extract ${SRC} --> ${TARDST}, already there ..."
		elif [ ! -d "${TARDST}" -a -f "${SRC}" ]; then
			EchoDebug "*** Extracting ${SRC} --> ${TARDST} ..."
			"${TARBIN}" xvf "${SRC}" -C "${DST}" >> "${BUILDOUTPUT}" 2>&1 && EX="0"
			if [ "${EX}" -eq "1" ]; then
				EchoDebug " maybe bzip2 ..."
				"${TARBIN}" xvfj "${SRC}" -C "${DST}" >> "${BUILDOUTPUT}" 2>&1 && EX="0"
				if [ "${EX}" -eq "1" ]; then
					EchoDebug " maybe gzip ..."
					"${TARBIN}" xvfz "${SRC}" -C "${DST}" >> "${BUILDOUTPUT}" 2>&1 && EX="0"
				fi
			fi
			if [ "${EX}" -eq "1" ]; then
				die "could not untar ${SRC} --> ${TARDST} in ${DST} ..."
			fi
		else
			EchoDebug "*** Did not extract ${SRC} --> ${TARDST} in ${DST}, you should probably look into why." 
			ls -la "${SRC}" "${DST}" "${TARDST}" >> "${BUILDOUTPUT}" 2>&1
		fi
	)
}

# make a directory
function Makedir() {
	(
		DST="${1}"
		if [ -d "${DST}" ]; then
			EchoDebug "*** Did not create directory ${DST}, already there ..."
		elif [ ! -d "${DST}" -a ! -f "${DST}" ]; then
			EchoDebug "*** Making directory ${DST} ..."
			mkdir -pv "${DST}" >> "${BUILDOUTPUT}" 2>&1
		else
			ls -la "${DST}" >> "${BUILDOUTPUT}" 2>&1
			die "could not make directory ${DST}"
		fi
	)
}

# Patch wrapper
function Patch() {
	(
		PATCH_FILE="${1}"
		SRC="${2}"
		if [ -f "${PATCH_FILE}" -a -d "${SRC}" ]; then
			EchoDebug "*** Patching ${SRC} with ${PATCH_FILE} ..." 
			cd "${SRC}"
			cat "${PATCH_FILE}" | "${PATCHBIN}" -p1 >> "${BUILDOUTPUT}" 2>&1 || die "could not patch ${SRC} with ${PATCH_FILE}"
		else
			EchoDebug "*** Did not patch ${SRC} with ${PATCH_FILE}, you should probably look into why." 
		fi
	)
}

# Relocate wrapper
function Relocate() {
	(
		SRC="${1}"
		DST="${2}"
		if [ -e "${DST}" -a -d "${DST}" ]; then
			EchoDebug "*** Did not Relocate ${SRC} --> ${DST}, already there ..."
		else
			EchoDebug "*** Relocating ${SRC} --> ${DST} ..."
			mv -v "${SRC}" "${DST}" >> "${BUILDOUTPUT}" 2>&1 || die "while relocating ${SRC} --> ${DST}"
		fi
	)
}

# Remove/delete wrapper
function Remove() {
	(
		SRC="${1}"
		FLAG="${2}"
		if [ -e "${SRC}" -a ! -f "${SRC}" -a ! -d "${SRC}" -a ! -L "${SRC}" ]; then
			EchoTTY "*** Did not Remove ${SRC}, not a file, directory, or symbolic link ..."
			ls -la "${SRC}"
		else
			if [ -z "${FLAG}" ]; then
				EchoDebug "*** Removing ${SRC} ..."
				rm -v "${SRC}" >> "${BUILDOUTPUT}" 2>&1 || die "while removing ${SRC}"
			elif [ -n "${FLAG}" ]; then
				EchoDebug "*** Removing ${SRC} with FLAG=${FLAG}v..."
				rm "${FLAG}v" "${SRC}" >> "${BUILDOUTPUT}" 2>&1 || die "while removing ${SRC} with FLAG=${FLAG}"
			fi
		fi
	)
}

# create a symbolic link
function Symlink() {
	(
		SRC="${1}"
		DST="${2}"
		if [ -f "${SRC}" -a -L "${DST}" ]; then
			EchoDebug "*** ${DST} is already a symbolic link ..."
		elif [ -f "${SRC}" -a -f "${DST}" ]; then
			EchoDebug "*** ${DST} is already a file ..."
		elif [ -f "${SRC}" -a -d "${DST}" ]; then
			EchoDebug "*** ${DST} is already a directory ..."
		else
			EchoDebug "*** Creating symbolic link ${SRC} --> ${DST}"
			ln -sv "${SRC}" "${DST}" >> "${BUILDOUTPUT}" 2>&1
		fi
	)
}

# copy the make rules
function copy_makerules() {
	TARGET="${1}"
	MKDST="${2}"
	EchoTTY "******* Copying :: make rules to ${MKDST}"
	[ ! -d "${MKDST}/${TARGET}" ] && Makedir "${MKDST}/${TARGET}"
	[ -e "${MAKERULES_SRCDIR}/common.mk" -a ! -e "${MKDST}/common.mk" ] && Copy "${MAKERULES_SRCDIR}/common.mk" "${MKDST}/common.mk"
	[ -e "${MAKERULES_SRCDIR}/common_pre.mk" -a ! -e "${MKDST}/common_pre.mk" ] && Copy "${MAKERULES_SRCDIR}/common_pre.mk" "${MKDST}/common_pre.mk"
	[ -e "${MAKERULES_SRCDIR}/${TARGET}.mk" -a ! -e "${MKDST}/${TARGET}/${TARGET}.mk" ] && Copy "${MAKERULES_SRCDIR}/${TARGET}.mk" "${MKDST}/${TARGET}/${TARGET}.mk"
	EchoTTY "******* Copied :: make rules to ${MKDST}"
}

# Copy patches to PS3CHAIN build directory if they exist
function copy_patches() {
	EchoTTY "******* Copying :: patches from ${PATCHES_SRCDIR}"
	[ -e "${PATCHES_SRCDIR}" -a -d "${PATCHES_SRCDIR}" ] && Copy "${PATCHES_SRCDIR}" "${PATCHES_DIR}" "-R" || EchoDebug "*** No patches to apply ..."
	EchoTTY "******* Copied :: patches from ${PATCHES_SRCDIR}"
}

# clean source directories
function clean_src() {
	EchoTTY "******* Cleaning :: src directories in ${SRC_DIR}"
	[ -e "${BINUTILS_SRCDIR}" ] && Remove "${BINUTILS_SRCDIR}" "-rf"
	[ -e "${GCC_SRCDIR}" ] && Remove "${GCC_SRCDIR}" "-rf"
	[ -e "${NEWLIB_SRCDIR}" ] && Remove "${NEWLIB_SRCDIR}" "-rf"
	[ -e "${CRT_SRCDIR}" ] && Remove "${CRT_SRCDIR}" "-rf"
	[ -e "${GMP_SRCDIR}" ] && Remove "${GMP_SRCDIR}" "-rf"
	[ -e "${MPFR_SRCDIR}" ] && Remove "${MPFR_SRCDIR}" "-rf"
	[ -e "${MPC_SRCDIR}" ] && Remove "${MPC_SRCDIR}" "-rf"
	[ -e "${GDB_SRCDIR}" ] && Remove "${GDB_SRCDIR}" "-rf"
	[ -e "${PS3CHAIN}/common.mk" ] && Remove "${PS3CHAIN}/common.mk" "-rf"
	[ -e "${PS3CHAIN}/common_pre.mk" ] && Remove "${PS3CHAIN}/common_pre.mk" "-rf"
	EchoTTY "******* Cleaned :: src directories in ${SRC_DIR}"
}

# clean built directories
function clean_build() {
	EchoTTY "******* Cleaning :: build directories in ${BUILD_DIR}"
	[ -e "${BINUTILS_BUILDDIR}" ] && Remove "${BINUTILS_BUILDDIR}" "-rf"
	[ -e "${GCC_BUILDDIR}" ] && Remove "${GCC_BUILDDIR}" "-rf"
	[ -e "${NEWLIB_BUILDDIR}" ] && Remove "${NEWLIB_BUILDDIR}" "-rf"
	[ -e "${CRT_BUILDDIR}" ] && Remove "${CRT_BUILDDIR}" "-rf"
	[ -e "${GDB_BUILDDIR}" ] && Remove "${GDB_BUILDDIR}" "-rf"
	[ -e "${BUILD_DIR}" ] && Remove "${BUILD_DIR}" "-rf"
	EchoTTY "******* Cleaned :: build directories in ${BUILD_DIR}"
}

# clean all
function clean_toolchains() {
	EchoTTY "******* Cleaning :: toolchains ${PPU_DIR} and ${SPU_DIR}"
	[ -e "${PPU_DIR}" ] && Remove "${PPU_DIR}" "-rf"
	[ -e "${SPU_DIR}" ] && Remove "${SPU_DIR}" "-rf"
	[ -e "${PATCHES_DIR}" ] && Remove "${PATCHES_DIR}" "-rf"
	EchoTTY "******* Cleaned :: toolchains ${PPU_DIR} and ${SPU_DIR}"
}

# create the build directories
function create_builddirs() {
	EchoTTY "******* Creating :: build directories in ${BUILD_DIR}"
	[ ! -d "${BINUTILS_BUILDDIR}" ] && Makedir "${BINUTILS_BUILDDIR}" || die "could not make binutils build directory ${BINUTILS_BUILDDIR}"
	[ ! -d "${GCC_BUILDDIR}" ] && Makedir "${GCC_BUILDDIR}" || die "could not make gcc build directory ${GCC_BUILDDIR}"
	[ ! -d "${CRT_BUILDDIR}" ] && Makedir "${CRT_BUILDDIR}" || die "could not make crt build directory ${CRT_BUILDDIR}"
	[ ! -d "${GDB_BUILDDIR}" ] && Makedir "${GDB_BUILDDIR}" || die "could not make gdb build directory ${GDB_BUILDDIR}"
	[ ! -d "${NEWLIB_BUILDDIR}" ] && Makedir "${NEWLIB_BUILDDIR}" || die "could not make newlib build directory ${NEWLIB_BUILDDIR}"
	EchoTTY "******* Created :: build directories in ${BUILD_DIR}"
}

# setup src directories
function create_srcdirs() {
	EchoTTY "******* Extracting :: tarballs to ${SRC_DIR}"
	[ -f "${BINUTILS_TARBALL}" -a -d "${SRC_DIR}" ] && Extract "${BINUTILS_TARBALL}" "${SRC_DIR}"
	[ -f "${GCC_TARBALL}" -a -d "${SRC_DIR}" ] && Extract "${GCC_TARBALL}" "${SRC_DIR}"
	[ -f "${NEWLIB_TARBALL}" -a -d "${SRC_DIR}" ] && Extract "${NEWLIB_TARBALL}" "${SRC_DIR}"
	[ -f "${GMP_TARBALL}" -a -d "${SRC_DIR}" ] && Extract "${GMP_TARBALL}" "${SRC_DIR}"
	[ -f "${MPFR_TARBALL}" -a -d "${SRC_DIR}" ] && Extract "${MPFR_TARBALL}" "${SRC_DIR}"
	[ -f "${MPC_TARBALL}" -a -d "${SRC_DIR}" ] && Extract "${MPC_TARBALL}" "${SRC_DIR}"
	[ -f "${GDB_TARBALL}" -a -d "${SRC_DIR}" ] && Extract "${GDB_TARBALL}" "${SRC_DIR}"
	EchoTTY "******* Extracted :: tarballs to ${SRC_DIR}"
	EchoTTY "******* Symlinking :: gmp, mpfr, mpc to ${GCC_SRCDIR}"
	[ -d "${GMP_SRCDIR}" -a -d ${GCC_SRCDIR} -a ! -e ${GMP_GCCSRCDIR} ] && Symlink "${GMP_SRCDIR}" "${GMP_GCCSRCDIR}"
	[ -d "${MPC_SRCDIR}" -a -d ${GCC_SRCDIR} -a ! -e ${MPC_GCCSRCDIR} ] && Symlink "${MPC_SRCDIR}" "${MPC_GCCSRCDIR}"
	[ -d "${MPFR_SRCDIR}" -a -d ${GCC_SRCDIR} -a ! -e ${MPFR_GCCSRCDIR} ] && Symlink "${MPFR_SRCDIR}" "${MPFR_GCCSRCDIR}"
	EchoTTY "******* Symlinked :: gmp, mpfr, mpc to ${GCC_SRCDIR}"
	EchoTTY "******* Copying :: crt to ${CRT_SRCDIR}"
	[ -d "${CRT_DIR}" -a ! -d "${CRT_SRCDIR}" ] && Copy "${CRT_DIR}" "${CRT_SRCDIR}" "-r"
	EchoTTY "******* Copied :: crt to ${CRT_SRCDIR}"
# HACK1 start :: BUG ID 44455 this is a hack to fix this bug http://gcc.gnu.org/bugzilla/show_bug.cgi?id=44455
	EchoTTY "******* Copying :: (HACK1 gcc bug id 44455) gmp includes from ${GMP_SRCDIR} to ${GMP_GCCSRCDIR}"
	[ -d "${GCC_BUILDDIR}" ] && Makedir "${GCC_BUILDDIR}/gmp" || die "HACK1 could not make gmp build directory ${GCC_BUILDDIR}/gmp"
	[ -d "${GCC_BUILDDIR}/gmp" -a -f "${GMP_SRCDIR}/gmp-impl.h" ] && Copy "${GMP_SRCDIR}/gmp-impl.h" "${GCC_BUILDDIR}/gmp/gmp-impl.h" || die "HACK1 no gmp-impl.h"
	[ -d "${GCC_BUILDDIR}/gmp" -a -f "${GMP_SRCDIR}/longlong.h" ] && Copy "${GMP_SRCDIR}/longlong.h" "${GCC_BUILDDIR}/gmp/longlong.h" || die "HACK1 no longlong.h"
	EchoTTY "******* Copied :: (HACK1 gcc bug id 44455) gmp includes from ${GMP_SRCDIR} to ${GMP_GCCSRCDIR}"
# HACK1 end
}

# create symbolic links
function create_symlinks() {
	(
		TARGET="${1}"
		FOLDER="${2}"
		ARRAY_TOOLS=( "addr2line" "ar" "as" "c++" "c++filt" "cpp" "embedspu" "g++" "gcc" "gcc-${GCC_VER}" "gccbug" "gcov" "gdb" "gdbtui" "gprof" "ld" "nm" "objcopy" "objdump" "ranlib" "readelf" "size" "strings" "strip" )
		cd "${FOLDER}"
		EchoTTY "*** Creating :: symbolic links for ${TARGET} in ${FOLDER}"
		for tool in ${ARRAY_TOOLS[@]}; do
			[ ! -e "ppu-${tool}" -a -e "${TARGET}-${tool}" ] && Symlink "${TARGET}-${tool}" "ppu-${tool}"
		done
		EchoTTY "*** Created :: symbolic links for ${TARGET} in ${FOLDER}"
		cd "${BUILDIT_DIR}"
	)
}

# download the necessary source tarballs
function download_src() {
	EchoTTY "******* Downloading :: tarballs to ${TAR_DIR}"
	[ ! -d "${TAR_DIR}" ] && Makedir "${TAR_DIR}"
	[ ! -f "${BINUTILS_TARBALL}" ] && Download "${BINUTILS_URI}" "${BINUTILS_TARBALL}"
	[ ! -f "${GCC_TARBALL}" ] && Download "${GCC_URI}" "${GCC_TARBALL}"
	[ ! -f "${NEWLIB_TARBALL}" ] && Download "${NEWLIB_URI}" "${NEWLIB_TARBALL}"
	[ ! -f "${GMP_TARBALL}" ] && Download "${GMP_URI}" "${GMP_TARBALL}"
	[ ! -f "${MPFR_TARBALL}" ] && Download "${MPFR_URI}" "${MPFR_TARBALL}"
	[ ! -f "${MPC_TARBALL}" ] && Download "${MPC_URI}" "${MPC_TARBALL}"
	[ ! -f "${GDB_TARBALL}" ] && Download "${GDB_URI}" "${GDB_TARBALL}"
	EchoTTY "******* Downloaded :: tarballs to ${TAR_DIR}"
}

# export build variables
function export_buildvars() {
	PREFIX="${1}"
	FLAG="${2}"
	ARRAY_VARIABLES=( "CC" "GCC" "CXX" "LD" "AS" "AR" "RANLIB" "NM" "STRIP" "OBJDUMP" "OBJCOPY" )
	ARRAY_VALUES=( "gcc" "gcc" "g++" "ld" "as" "ar" "ranlib" "nm" "strip" "objdump" "objcopy" )
	counter=0
	EchoTTY "******* Exporting :: build variables for ${PREFIX}-* FLAG=${FLAG}"
	for arrayvariable in ${ARRAY_VARIABLES[@]}; do
		[ -n "${PREFIX}-${ARRAY_VALUES[${counter}]}" ] && Export "${arrayvariable}_FOR_TARGET" "${PREFIX}-${ARRAY_VALUES[${counter}]}" ${FLAG}
		let counter+=1
	done
	EchoTTY "******* Exported :: build variables for ${PREFIX}-* FLAG=${FLAG}"
}

# apply oopo's patches so ps3libraries will compile
function patch_srcdirs() {
	EchoTTY "******* Patching :: with patches from ${PATCHES_SRCDIR}"
	[ -f "${BINUTILS_PATCH}" -a -d "${BINUTILS_SRCDIR}" ] && Patch "${BINUTILS_PATCH}" "${BINUTILS_SRCDIR}"
	[ -f "${GCC_PATCH}" -a -d "${GCC_SRCDIR}" ] && Patch "${GCC_PATCH}" "${GCC_SRCDIR}"
	[ -f "${NEWLIB_PATCH}" -a -d "${NEWLIB_SRCDIR}" ] && Patch "${NEWLIB_PATCH}" "${NEWLIB_SRCDIR}"
	[ -f "${GDB_PATCH}" -a -d "${GDB_SRCDIR}" ] && Patch "${GDB_PATCH}" "${GDB_SRCDIR}"
	EchoTTY "******* Patched :: with patches from ${PATCHES_SRCDIR}"
}

# build binutils
function build_binutils() {
	TARGET="${1}"
	FOLDER="${2}"
	EchoDebug "*** Building :: binutils for ${TARGET} in ${BINUTILS_BUILDDIR}"
	EchoFile "*** Building :: binutils for ${TARGET} in ${BINUTILS_BUILDDIR}"
	(
		cd "${BINUTILS_BUILDDIR}" && \
		"${BINUTILS_SRCDIR}/configure" \
			--target="${TARGET}" \
			--prefix="${FOLDER}" \
			--disable-multilib \
			--disable-nls \
			--disable-shared \
			--disable-werror \
			--enable-64-bit-bfd >> "${BINUTILS_OUT}" 2>&1 && \
		"${MAKEBIN}" "${MAKEOPTS}" >> "${BINUTILS_OUT}" 2>&1 && \
		"${MAKEBIN}" install >> "${BINUTILS_OUT}" 2>&1
	) || die "building binutils for target ${TARGET}"
	EchoDebug "*** Built :: binutils for ${TARGET} in ${BINUTILS_BUILDDIR}"
	cd "${BUILDIT_DIR}"
}

# build gcc stage1 ppu
function build_gcc_stage1_ppu() {
	TARGET="${1}"
	FOLDER="${2}"
	EchoDebug "*** Building :: gcc stage 1 for ${TARGET} in ${GCC_BUILDDIR} with CPUFLAG=${CPUFLAG}"
	EchoFile "*** Building :: gcc stage 1 for ${TARGET} in ${GCC_BUILDDIR} with CPUFLAG=${CPUFLAG}"
	(
		cd "${GCC_BUILDDIR}" && \
#			--disable-checking \
#			--disable-libmudflap \
#			--disable-libunwind-exceptions \
#			--enable-__cxa_atexit \
#			--enable-secureplt \
		"${GCC_SRCDIR}/configure" \
			--target="${TARGET}" \
			--prefix="${FOLDER}" \
			--disable-bootstrap \
			--disable-libgomp \
			--disable-multilib \
			--disable-nls \
			--disable-shared \
			--disable-threads \
			--enable-altivec \
			--enable-checking=release \
			--enable-languages="c,c++" \
			--with-cpu=cell \
			--with-newlib \
			"${EXTRAFLAGS}" >> "${GCC_OUT}" 2>&1 && \
		"${MAKEBIN}" all-gcc "${MAKEOPTS}" >> "${GCC_OUT}" 2>&1 && \
		"${MAKEBIN}" install-gcc >> "${GCC_OUT}" 2>&1
	) || die "building gcc for target ${TARGET}"
	EchoDebug "*** Built :: gcc stage 1 for ${TARGET} in ${GCC_BUILDDIR} with CPUFLAG=${CPUFLAG}"
	cd "${BUILDIT_DIR}"
}

# build gcc stage 1 spu
function build_gcc_stage1_spu() {
	TARGET="${1}"
	FOLDER="${2}"
	EchoDebug "*** Building :: gcc stage 1 for ${TARGET} in ${GCC_BUILDDIR} with CPUFLAG=${CPUFLAG}"
	EchoFile "*** Building :: gcc stage 1 for ${TARGET} in ${GCC_BUILDDIR} with CPUFLAG=${CPUFLAG}"
	(
		cd "${GCC_BUILDDIR}" && \
		"${GCC_SRCDIR}/configure" \
			--target="${TARGET}" \
			--prefix="${FOLDER}" \
			--disable-libssp \
			--disable-nls \
			--disable-shared \
			--enable-checking=release \
			--enable-languages="c,c++" \
			--with-newlib \
			"${EXTRAFLAGS}" >> "${GCC_OUT}" 2>&1 && \
		"${MAKEBIN}" all-gcc "${MAKEOPTS}" >> "${GCC_OUT}" 2>&1 && \
		"${MAKEBIN}" install-gcc >> "${GCC_OUT}" 2>&1
	) || die "building gcc for target ${TARGET}"
	EchoDebug "*** Built :: gcc stage 1 for ${TARGET} in ${GCC_BUILDDIR} with CPUFLAG=${CPUFLAG}"
	cd "${BUILDIT_DIR}"
}

# continue building/compiling gcc
function build_gcc_stage2() {
	TARGET="${1}"
	EchoDebug "*** Building :: gcc stage 2 for ${TARGET} in ${GCC_BUILDDIR}"
	EchoFile "*** Building :: gcc stage 2 for ${TARGET} in ${GCC_BUILDDIR}"
	(
		cd "${GCC_BUILDDIR}" && \
		"${MAKEBIN}" all "${MAKEOPTS}" >> "${GCC_OUT}" 2>&1 && \
		"${MAKEBIN}" install >> "${GCC_OUT}" 2>&1
	) || die "building gcc support libs for target ${TARGET}"
	EchoDebug "*** Built :: gcc stage 2 for ${TARGET} in ${GCC_BUILDDIR}"
	cd "${BUILDIT_DIR}"
}

# build newlib
function build_newlib() {
	TARGET="${1}"
	FOLDER="${2}"
	NEWLIB_TARGET="${3}"
	PREFIX="${FOLDER}/bin/${TARGET}"
	EchoDebug "*** Building :: ${TARGET} newlib for ${NEWLIB_TARGET} with stage 1 gcc in ${NEWLIB_BUILDDIR}"
	EchoFile "*** Building :: ${TARGET} newlib for ${NEWLIB_TARGET} with stage 1 gcc in ${NEWLIB_BUILDDIR}"
	(
		export_buildvars "${PREFIX}"
		cd "${NEWLIB_BUILDDIR}" && \
		"${NEWLIB_SRCDIR}/configure" \
			--target="${NEWLIB_TARGET}" \
			--prefix="${FOLDER}" \
			--disable-multilib \
			--disable-nls \
			--disable-shared >> "${NEWLIB_OUT}" 2>&1 && \
		"${MAKEBIN}" "${MAKEOPTS}" >> "${NEWLIB_OUT}" 2>&1 && \
		"${MAKEBIN}" install >> "${NEWLIB_OUT}" 2>&1
	) || die "building newlib for target ${TARGET}"
	(
		if [ "${TARGET}" != "${NEWLIB_TARGET}" ]; then
			EchoDebug "*** Copying :: newlib lib/include from ${FOLDER}/${NEWLIB_TARGET} to ${FOLDER}/${TARGET}"
			Copy "${FOLDER}/${NEWLIB_TARGET}/lib/." "${FOLDER}/${TARGET}/lib" "-rf" && \
			Copy "${FOLDER}/${NEWLIB_TARGET}/include/." "${FOLDER}/${TARGET}/include" "-rf"
			EchoDebug "*** Copied :: newlib lib/include from ${FOLDER}/${NEWLIB_TARGET} to ${FOLDER}/${TARGET}"
			EchoDebug "*** Removing :: newlib ${FOLDER}/${NEWLIB_TARGET}"
			Remove "${FOLDER}/${NEWLIB_TARGET}" "-rf"
			EchoDebug "*** Removed :: newlib ${FOLDER}/${NEWLIB_TARGET}"
		else
			EchoDebug "*** Copy :: newlib lib/include from ${FOLDER}/${NEWLIB_TARGET} to ${FOLDER}/${TARGET} not necessary ..."
		fi
	) || die "copying newlib for target ${TARGET}"
	EchoDebug "*** Built :: ${TARGET} newlib for ${NEWLIB_TARGET} with stage 1 gcc in ${NEWLIB_BUILDDIR}"
	cd "${BUILDIT_DIR}"
}

# build crt
# http://gcc.gnu.org/ml/gcc/2008-03/msg00515.html
# http://osdir.com/ml/lib.newlib/2006-12/msg00037.html
function build_crt() {
	TARGET="${1}"
	FOLDER="${2}"
	EchoDebug "*** Building :: crt for ${TARGET} with ${FOLDER}/bin/${TARGET}-gcc (stage 1) in ${CRT_BUILDDIR} ..."
	EchoFile "*** Building :: crt for ${TARGET} with ${FOLDER}/bin/${TARGET}-gcc (stage 1) in ${CRT_BUILDDIR} ..."
	(
		cd "${CRT_BUILDDIR}" && \
		"${FOLDER}/bin/${TARGET}-gcc" -c "${CRT_SRCDIR}/${TARGET}/crti.S" -o "${CRT_BUILDDIR}/crti.o" >> "${CRT_OUT}" 2>&1 && \
		"${FOLDER}/bin/${TARGET}-gcc" -c "${CRT_SRCDIR}/${TARGET}/crtn.S" -o "${CRT_BUILDDIR}/crtn.o" >> "${CRT_OUT}" 2>&1 && \
		"${FOLDER}/bin/${TARGET}-gcc" -c "${CRT_SRCDIR}/${TARGET}/crt0.S" -o "${CRT_BUILDDIR}/crt0.o" >> "${CRT_OUT}" 2>&1 && \
		"${FOLDER}/bin/${TARGET}-gcc" -c "${CRT_SRCDIR}/${TARGET}/crt1.c" -o "${CRT_BUILDDIR}/crt.o" >> "${CRT_OUT}" 2>&1 && \
		"${FOLDER}/bin/${TARGET}-ld" -r "${CRT_BUILDDIR}/crt0.o" "${CRT_BUILDDIR}/crt.o" -o "${CRT_BUILDDIR}/crt1.o" >> "${CRT_OUT}" 2>&1 && \

		EchoDebug "*** Copying :: crt lib/include to ${FOLDER}/${TARGET} ..."
		Makedir "${FOLDER}/${TARGET}/lib" && \
		Makedir "${FOLDER}/${TARGET}/include" && \
		Copy "${CRT_BUILDDIR}/crt0.o" "${FOLDER}/${TARGET}/lib" "-f" || die "could not copy crt lib and include to ${FOLDER}/${TARGET}"
		Copy "${CRT_BUILDDIR}/crt1.o" "${FOLDER}/${TARGET}/lib" "-f" || die "could not copy crt lib and include to ${FOLDER}/${TARGET}"
		Copy "${CRT_BUILDDIR}/crti.o" "${FOLDER}/${TARGET}/lib" "-f" || die "could not copy crt lib and include to ${FOLDER}/${TARGET}"
		Copy "${CRT_BUILDDIR}/crtn.o" "${FOLDER}/${TARGET}/lib" "-f" || die "could not copy crt lib and include to ${FOLDER}/${TARGET}"
		Copy "${CRT_SRCDIR}/fenv.h" "${FOLDER}/${TARGET}/include" "-f" || die "could not copy crt lib and include to ${FOLDER}/${TARGET}"
		EchoDebug "*** Copied :: crt lib/include to ${FOLDER}/${TARGET} ..."
	) || die "building crt for target ${TARGET} in ${CRT_BUILDDIR} with ${TARGET}-gcc"
	EchoDebug "*** Built :: crt for ${TARGET} with ${TARGET}-gcc (stage 1) in ${CRT_BUILDDIR} ..."
	cd "${BUILDIT_DIR}"
}

# build gdb
function build_gdb() {
	TARGET="${1}"
	FOLDER="${2}"
	EchoDebug "*** Building :: gdb for ${TARGET} in ${GDB_BUILDDIR}"
	EchoFile "*** Building :: gdb for ${TARGET} in ${GDB_BUILDDIR}"
	(
		cd "${GDB_BUILDDIR}" && \
		"${GDB_SRCDIR}/configure" \
			--target="${TARGET}" \
			--prefix="${FOLDER}" \
			--disable-multilib \
			--disable-nls \
			--disable-sim \
			--disable-werror >> "${GDB_OUT}" 2>&1 && \
		"${MAKEBIN}" "${MAKEOPTS}" >> "${GDB_OUT}" 2>&1 && \
		"${MAKEBIN}" install >> "${GDB_OUT}" 2>&1
	) || die "building gdb for target ${TARGET}"
	EchoDebug "*** Built :: gdb for ${TARGET} in ${GDB_BUILDDIR}"
	cd "${BUILDIT_DIR}"
}

# prepare the chain src and build directories for building
function prep_chain() {
	EchoTTY "******** PREP START :: preparing for ${1} build"
	download_src && \
	clean_build && \
	create_builddirs && \
	create_srcdirs && \
	copy_patches && \
	copy_makerules "${1}" "${2}" && \
	EchoTTY "******** PREP COMPLETE :: prepared for ${1} build"
}

# build the PPU chain
function build_ppu() {
	EchoTTY "******* Building :: PPU binutils"
	[ "${BUILD_BINUTILS}" != "false" -a "${BUILD_BINUTILS}" != "FALSE" ] && build_binutils "${PPU_TARGET}" "${PPU_DIR}"
	EchoTTY "******* Building :: PPU GCC stage 1"
	[ "${BUILD_GCC1}" != "false" -a "${BUILD_GCC1}" != "FALSE" ] && build_gcc_stage1_ppu "${PPU_TARGET}" "${PPU_DIR}"
	EchoTTY "******* Building :: PPU newlib"
	[ "${BUILD_NEWLIB}" != "false" -a "${BUILD_NEWLIB}" != "FALSE" ] && build_newlib "${PPU_TARGET}" ${PPU_DIR} "${PPU_NEWLIB_TARGET}"
	EchoTTY "******* Building :: PPU CRT"
	[ "${BUILD_CRT}" != "false" -a "${BUILD_CRT}" != "FALSE" ] && build_crt "${PPU_TARGET}" "${PPU_DIR}"
	EchoTTY "******* Building :: PPU GCC stage 2"
	[ "${BUILD_GCC2}" != "false" -a "${BUILD_GCC2}" != "FALSE" ] && build_gcc_stage2 "${PPU_TARGET}"
	EchoTTY "******* Building :: PPU GDB"
	[ "${BUILD_GDB}" != "false" -a "${BUILD_GDB}" != "FALSE" ] && build_gdb "${PPU_TARGET}" "${PPU_DIR}"
	EchoTTY "******* Creating :: symbolic links"
	create_symlinks "${PPU_TARGET}" "${PPU_DIR}/bin"
	cd "${BUILDIT_DIR}"
}

#build the SPU chain
function build_spu() {
	EchoTTY "******* Building :: SPU binutils"
	[ "${BUILD_BINUTILS}" != "false" -a "${BUILD_BINUTILS}" != "FALSE" ] && build_binutils "${SPU_TARGET}" "${SPU_DIR}"
	EchoTTY "******* Building :: SPU GCC stage 1"
	[ "${BUILD_GCC1}" != "false" -a "${BUILD_GCC1}" != "FALSE" ] && build_gcc_stage1_spu "${SPU_TARGET}" "${SPU_DIR}"
	EchoTTY "******* Building :: SPU newlib"
	[ "${BUILD_NEWLIB}" != "false" -a "${BUILD_NEWLIB}" != "FALSE" ] && build_newlib "${SPU_TARGET}" "${SPU_DIR}" "${SPU_NEWLIB_TARGET}"
	EchoTTY "******* Building :: SPU GCC stage 2"
	[ "${BUILD_GCC2}" != "false" -a "${BUILD_GCC2}" != "FALSE" ] && build_gcc_stage2 "${SPU_TARGET}"
	EchoTTY "******* Building :: SPU GDB"
	[ "${BUILD_GDB}" != "false" -a "${BUILD_GDB}" != "FALSE" ] && build_gdb "${SPU_TARGET}" "${SPU_DIR}"
	cd "${BUILDIT_DIR}"
}

# build the PPU chain and clean the build directories
function ppu_arg() {
	EchoTTY "******** BUILD START :: PPU toolchain building and installing, output is in ${BUILDOUTPUT}"
	prep_chain "ppu" "${PS3CHAIN}" && \
	patch_srcdirs && \
	build_ppu && \
	clean_build && \
	clean_src
	EchoTTY "******** BUILD COMPLETE :: PPU toolchain built and installed, output is in ${BUILDOUTPUT}"
}

# build the SPU chain and clean the build directories
function spu_arg() {
	EchoTTY "******** BUILD START :: SPU toolchain building and installing, output is in ${BUILDOUTPUT}"
	prep_chain "spu" "${PS3CHAIN}" && \
	build_spu && \
	clean_build && \
	clean_src
	EchoTTY "******** BUILD COMPLETE :: SPU toolchain built and installed, output is in ${BUILDOUTPUT}"
}

# build everything, then cleanup the src and build directories
function all_arg() {
	EchoTTY "******** BUILD START :: PPU/SPU building and installing output will be in ${BUILDOUT}"
	ppu_arg && \
	spu_arg
	EchoTTY "******** BUILD COMPLETE :: PPU/SPU built and installed, output is in ${BUILDOUTPUT}"
}

# clean build/src directories
function cleanall_arg() {
	EchoTTY "******** CLEAN START :: cleaning all, output is in ${BUILDOUTPUT}"
	clean_build
	clean_src
	EchoTTY "******** CLEAN COMPLETE :: cleaned all, output is in ${BUILDOUTPUT}"
}

# wipe build/src/ppu/spu directories
function wipeall_arg() {
	EchoTTY "******** WIPE START :: wiping all, output is in ${BUILDOUTPUT}"
	clean_build
	clean_src
	clean_toolchains
	EchoTTY "******** WIPE COMPLETE :: wiped all, output is in ${BUILDOUTPUT}"
}

#
# End of functions.
#

# evaluate what needs to be built
while true; do
	if [ "${#}" -eq "0" ]; then
		[ "${BUILDTYPE}" == "help" ] && usage
		EchoTTY "********** Completed :: ${BUILDTYPE} in ${PS3CHAIN}"
		exit 0
	fi
	#
	case "${BUILDTYPE}" in
		all)		all_arg ;; # build everything, then cleanup
		ppu)		ppu_arg ;; # build the PPU chain
		spu)		spu_arg ;; # build the SPU chain
		clean)		cleanall_arg ;; # clean build/src
		wipe)		wipeall_arg ;; # wipe everything
		help)		usage ;; # print usage
		*)
			die "unknown build type ${1}" # fall-through error
			;;
	esac
	shift;
done

EchoTTY "Should never get here if you are reading this something went wrong {shrug} ..."
exit 1

#EOF
