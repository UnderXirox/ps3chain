#!/bin/sh 
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
# TODO
# no need to download/check the tarballs so often
#

#
# Start of configuration section.
#

# screen output is more verbose if DEBUG is non-zero, log output is the same
DEBUG="true"
PREP="true"

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
BUILDIT_DIR=`dirname ${PWD}`
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
PPU_TARGET="powerpc64-linux"
PPU_NEWLIB_TARGET="ppc64"
# binutils settings
#BINUTILS_VER="2.20"
BINUTILS_VER="2.20.1"
BINUTILS_TARBALL="binutils-${BINUTILS_VER}.tar.bz2"
BINUTILS_URI="${GNU_URI}/binutils/${BINUTILS_TARBALL}"
BINUTILS_SRCDIR="${SRC_DIR}/binutils-${BINUTILS_VER}"
BINUTILS_BUILDDIR="${BUILD_DIR}/build_binutils"
BINUTILS_OUT="${BUILDOUTPUT}"
# gcc settings
GCC_VER="4.5.1"
GCC_TARBALL="gcc-${GCC_VER}.tar.bz2"
GCC_URI="${GNU_URI}/gcc/gcc-${GCC_VER}/${GCC_TARBALL}"
GCC_SRCDIR="${SRC_DIR}/gcc-${GCC_VER}"
GCC_BUILDDIR="${BUILD_DIR}/build_gcc"
GCC_OUT="${BUILDOUTPUT}"
# gdb settings
#GDB_VER="7.1"
GDB_VER="7.2"
GDB_TARBALL="gdb-${GDB_VER}.tar.bz2"
GDB_URI="${GNU_URI}/gdb/${GDB_TARBALL}"
GDB_SRCDIR="${SRC_DIR}/gdb-${GDB_VER}"
GDB_BUILDDIR="${BUILD_DIR}/build_gdb"
GDB_OUT="${BUILDOUTPUT}"
# crt settings
CRT_DIR="${BUILDIT_DIR}/crt"
CRT_SRCDIR="${SRC_DIR}/crt"
CRT_BUILDDIR="${BUILD_DIR}/build_crt"
CRT_OUT="${BUILDOUTPUT}"
# gmp settings
GMP_VER="5.0.1"
GMP_TARBALL="gmp-${GMP_VER}.tar.bz2"
GMP_URI="${GNU_URI}/gmp/${GMP_TARBALL}"
GMP_SRCDIR="${SRC_DIR}/gmp-${GMP_VER}"
GMP_GCCSRCDIR="${GCC_SRCDIR}/gmp"
# mpc settings
MPC_VER="0.8.2"
MPC_TARBALL="mpc-${MPC_VER}.tar.gz"
MPC_URI="${MPC_URI}/${MPC_TARBALL}"
MPC_SRCDIR="${SRC_DIR}/mpc-${MPC_VER}"
MPC_GCCSRCDIR="${GCC_SRCDIR}/mpc"
# mpfr settings
#MPFR_VER="2.4.2"
MPFR_VER="3.0.0"
MPFR_TARBALL="mpfr-${MPFR_VER}.tar.bz2"
MPFR_URI="${MPFR_URI}/mpfr-${MPFR_VER}/${MPFR_TARBALL}"
MPFR_SRCDIR="${SRC_DIR}/mpfr-${MPFR_VER}"
MPFR_GCCSRCDIR="${GCC_SRCDIR}/mpfr"
# newlib settings
NEWLIB_VER="1.18.0"
NEWLIB_TARBALL="newlib-${NEWLIB_VER}.tar.gz"
NEWLIB_URI="${NEWLIB_URI}/${NEWLIB_TARBALL}"
NEWLIB_SRCDIR="${SRC_DIR}/newlib-${NEWLIB_VER}"
NEWLIB_BUILDDIR="${BUILD_DIR}/build_newlib"
NEWLIB_OUT="${BUILDOUTPUT}"

# define MAKE according to system architecture
case `uname -s` in
	*BSD*)
		OS="BSD";
		MAKE="gmake"
		;;
	*CYGWIN*)
		OS="CYGWIN";
		MAKE="make"
		;;
	*Darwin*)
		OS="DARWIN";
		MAKE="gmake"
		;;
	*Linux*)
		OS="LINUX";
		MAKE="make"
		;;
	*MINGW*)
		OS="MINGW";
		MAKE="make"
		;;
	*)
		OS="UNKNOWN";
		MAKE="make"
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

# failure function
function die() {
	echo "ERROR :: ${FUNCNAME} :: ${@}"
	exit 1
}

# usage
function usage() {
cat README
echo
echo "To build the toolchain you must set PS3CHAIN or PS3DEV environment variable, and use one of the following arguments ..."
echo "It is a good idea to set your "
echo
echo "${0} <ARG>"
echo
echo "ARGUMENTS	Description"
echo "all		download, and build everything"
echo "ppu		download, and build the PPU chain"
echo "spu		download, and build the SPU chain"
echo "clean		clean EVERYTHING, only needed if something goes wrong"
echo
echo "All output will be written to build.<ARG>.out in your PS3CHAIN/PS3DEV directory."
echo "Please keep in mind that the source directories are never cleaned (removed) unless you call \"./${0} clean\"."
echo
exit
}

# download tarballs if they do not exist, if tarball exists verify it is ok
function download() {
	DL="1"
	TARURL="${1}"
	TARBALL="${2}"
	if [ -f "${TARBALL}" ]; then
		[ -n "${DEBUG}" ] && echo "*** Found ${TARBALL}, using that ..."
		[ -n "${DEBUG}" ] && echo -n "*** Testing ${TARBALL} ..."
		[ -n "${DEBUG}" ] && echo -n " 1st attempt ..."
		# try to test without specifying compression type
		tar tf "${TARBALL}" >> "${BUILDOUTPUT}" 2>&1 && DL="0"
		if [ "${DL}" -eq "1" ]; then
			[ -n "${DEBUG}" ] && echo -n " 2nd attempt ..."
			# Check bz2
			tar tjf "${TARBALL}" >> "${BUILDOUTPUT}" 2>&1 && DL="0"
			if [ "${DL}" -eq "1" ]; then
				[ -n "${DEBUG}" ] && echo -n " 3rd attempt ..."
				# Check gz
				tar tzf "${TARBALL}" >> "${BUILDOUTPUT}" 2>&1 && DL="0"
			fi
			if [ "${DL}" -eq "1" ]; then
				[ -n "${DEBUG}" ] && echo -n " testing failed, downloading ${TARURL} ..."
			fi
		fi
		[ -n "${DEBUG}" ] && echo
	fi
	if [ "${DL}" -eq "1" ]; then
		[ -n "${DEBUG}" ] && echo "*** Downloading ${TARURL} to ${TARBALL} ..."
		wget "${TARURL}" -c -O "${TARBALL}" || die "could not download ${TARBALL} from ${TARURL} "
	fi
}

# tar wrapper
function extract() {
	EX="1"
	SRC="${1}"
	DST="${2}"
	TARDST=`echo "${SRC}" | sed 's/.tar.*//g'`
	if [ -e "${TARDST}" -a -d "${TARDST}" ]; then
		[ -n "${DEBUG}" ] && echo "*** Did not extract ${SRC} --> ${TARDST}, already there ..."
	elif [ ! -d "${TARDST}" -a -f "${SRC}" ]; then
		[ -n "${DEBUG}" ] && echo -n "*** Extracting ${SRC} --> ${TARDST} ..."
		tar xvf "${SRC}" -C "${DST}" >> "${BUILDOUTPUT}" 2>&1 && EX="0"
		if [ "${EX}" -eq "1" ]; then
			[ -n "${DEBUG}" ] && echo -n " maybe bzip2 ..."
			tar xvfj "${SRC}" -C "${DST}" >> "${BUILDOUTPUT}" 2>&1 && EX="0"
			if [ "${EX}" -eq "1" ]; then
				[ -n "${DEBUG}" ] && echo -n " maybe gzip ..."
				tar xvfz "${SRC}" -C "${DST}" >> "${BUILDOUTPUT}" 2>&1 && EX="0"
			fi
		fi
		[ -n "${DEBUG}" ] && echo
		if [ "${EX}" -eq "1" ]; then
			die "could not untar ${SRC} --> ${TARDST} in ${DST} ..."
		fi
	else
		[ -n "${DEBUG}" ] && echo "*** Did not extract ${SRC} --> ${TARDST} in ${DST}, you should probably look into why." 
		[ -n "${DEBUG}" ] && ls -la "${SRC}" "${DST}" "${TARDST}" >> "${BUILDOUTPUT}" 2>&1
	fi
}

# relocate wrapper
function relocate() {
	SRC="${1}"
	DST="${2}"
	if [ -e "${DST}" -a -d "${DST}" ]; then
		[ -n "${DEBUG}" ] && echo "*** Did not relocate ${SRC} --> ${DST}, already there ..."
	else
		[ -n "${DEBUG}" ] && echo "*** Relocating ${SRC} --> ${DST} ..."
		mv -v "${SRC}" "${DST}" >> "${BUILDOUTPUT}" 2>&1 || die "while relocating ${SRC} --> ${DST}"
	fi
}

# remove/delete wrapper
function remove() {
	SRC="${1}"
	FLAG="${2}"
	if [ -e "${SRC}" -a ! -f "${SRC}" -a ! -d "${SRC}" -a ! -L "${SRC}" ]; then
		echo "*** Did not remove ${SRC}, not a file, directory, or symbolic link ..."
		ls -la "${SRC}"
	else
		if [ -z "${FLAG}" ]; then
			[ -n "${DEBUG}" ] && echo "*** Removing ${SRC} ..."
			rm -v "${SRC}" >> "${BUILDOUTPUT}" 2>&1 || die "while removing ${SRC}"
		elif [ -n "${FLAG}" ]; then
			[ -n "${DEBUG}" ] && echo "*** Removing ${SRC} with FLAG=${FLAG}..."
			rm "${FLAG}v" "${SRC}" >> "${BUILDOUTPUT}" 2>&1 || die "while removing ${SRC} with FLAG=${FLAG}"
		fi
	fi
}

# copy make rule
function copy() {
	SRC="${1}"
	DST="${2}"
	FLAG="${3}"
	if [ -e "${DST}" -a "${FLAG}" != "-f" -a "${FLAG}" != "-rf" ]; then
		[ -n "${DEBUG}" ] && echo "*** Did not copy ${SRC} --> ${DST}, already there ..."
	elif [ ! -f "${DST}" -a -z "${FLAG}" ]; then
		[ -n "${DEBUG}" ] && echo "*** Copying ${SRC} --> ${DST} ..."
		cp -v "${SRC}" "${DST}" >> "${BUILDOUTPUT}" 2>&1
	elif [ ! -f "${DST}" -a -n "${FLAG}" ]; then
		[ -n "${DEBUG}" ] && echo "*** Copying with flag: \"${FLAG}\" ${SRC} --> ${DST} ..."
		cp "${FLAG}v" "${SRC}" "${DST}" >> "${BUILDOUTPUT}" 2>&1
	else
		ls -la "${DST}" >> "${BUILDOUTPUT}" 2>&1
		die "could not copy ${SRC} --> ${DST}"
	fi
}

# create a symbolic link
function create_symlink() {
	SRC="${1}"
	DST="${2}"
	if [ -f "${SRC}" -a -L "${DST}" ]; then
		[ -n "${DEBUG}" ] && echo "*** ${DST} is already a symbolic link ..."
	elif [ -f "${SRC}" -a -f "${DST}" ]; then
		[ -n "${DEBUG}" ] && echo "*** ${DST} is already a file ..."
	elif [ -f "${SRC}" -a -d "${DST}" ]; then
		[ -n "${DEBUG}" ] && echo "*** ${DST} is already a directory ..."
	else
		[ -n "${DEBUG}" ] && echo "*** Creating symbolic link ${SRC} --> ${DST}"
		ln -sv "${SRC}" "${DST}" >> "${BUILDOUTPUT}" 2>&1
	fi
}

# make a directory
function make_dir() {
	DST="${1}"
	if [ -d "${DST}" ]; then
		[ -n "${DEBUG}" ] && echo "*** Did not create directory ${DST}, already there ..."
	elif [ ! -d "${DST}" -a ! -f "${DST}" ]; then
		[ -n "${DEBUG}" ] && echo "*** Making directory ${DST} ..."
		mkdir -pv "${DST}" >> "${BUILDOUTPUT}" 2>&1
	else
		ls -la "${DST}" >> "${BUILDOUTPUT}" 2>&1
		die "could not make directory ${DST}"
	fi
}

# export environment variable
function export_var() {
	VARIABLE="${1}"
	VALUE="${2}"
	FLAG="${3}"
	if [ -z "${!VARIABLE}" -a -n "${VALUE}" -a -z "${FLAG}" ]; then
		[ -n "${DEBUG}" ] && echo "*** Reassigning environment variable ${VARIABLE}=${VALUE} was `declare -p ${VARIABLE}` ..."
		export "${VARIABLE}=${VALUE}" >> "${BUILDOUTPUT}" 2>&1
	elif [ -n "${!VARIABLE}" -a -n "${VALUE}" -a -z "${FLAG}" ]; then
		[ -n "${DEBUG}" ] && echo "*** Creating environment variable ${VARIABLE}=${VALUE} ..."
		export "${VARIABLE}=${VALUE}" >> "${BUILDOUTPUT}" 2>&1
	elif [ -n "${!VARIABLE}" -a -n "${FLAG}" ]; then
		[ -n "${DEBUG}" ] && echo "*** Removing environment variable ${VARIABLE}=${VALUE} was `declare -p ${VARIABLE}` ..."
		export -n "${VARIABLE}" >> "${BUILDOUTPUT}" 2>&1
		unset -v "${VARIABLE}" >> "${BUILDOUTPUT}" 2>&1
	else
		die "could not export variable ${VARIABLE}=${VALUE} with FLAG=${FLAG} :: `declare -p ${VARIABLE}`"
	fi
}

# clean source directories
function clean_src() {
	echo "******* Cleaning :: src directories in ${SRC_DIR}"
	[ -e "${BINUTILS_SRCDIR}" ] && remove "${BINUTILS_SRCDIR}" "-rf"
	[ -e "${GCC_SRCDIR}" ] && remove "${GCC_SRCDIR}" "-rf"
	[ -e "${NEWLIB_SRCDIR}" ] && remove "${NEWLIB_SRCDIR}" "-rf"
	[ -e "${CRT_SRCDIR}" ] && remove "${CRT_SRCDIR}" "-rf"
	[ -e "${GMP_SRCDIR}" ] && remove "${GMP_SRCDIR}" "-rf"
	[ -e "${MPFR_SRCDIR}" ] && remove "${MPFR_SRCDIR}" "-rf"
	[ -e "${MPC_SRCDIR}" ] && remove "${MPC_SRCDIR}" "-rf"
	[ -e "${GDB_SRCDIR}" ] && remove "${GDB_SRCDIR}" "-rf"
	[ -e "${PS3CHAIN}/common.mk" ] && remove "${PS3CHAIN}/common.mk" "-rf"
	[ -e "${PS3CHAIN}/common_pre.mk" ] && remove "${PS3CHAIN}/common_pre.mk" "-rf"
	echo "******* Cleaned :: src directories in ${SRC_DIR}"
}

# clean built directories
function clean_build() {
	echo "******* Cleaning :: build directories in ${BUILD_DIR}"
	[ -e "${BINUTILS_BUILDDIR}" ] && remove "${BINUTILS_BUILDDIR}" "-rf"
	[ -e "${GCC_BUILDDIR}" ] && remove "${GCC_BUILDDIR}" "-rf"
	[ -e "${NEWLIB_BUILDDIR}" ] && remove "${NEWLIB_BUILDDIR}" "-rf"
	[ -e "${CRT_BUILDDIR}" ] && remove "${CRT_BUILDDIR}" "-rf"
	[ -e "${GDB_BUILDDIR}" ] && remove "${GDB_BUILDDIR}" "-rf"
	[ -e "${BUILD_DIR}" ] && remove "${BUILD_DIR}" "-rf"
	echo "******* Cleaned :: build directories in ${BUILD_DIR}"
}

# clean all
function clean_toolchains() {
	echo "******* Cleaning :: toolchains ${PPU_DIR} and ${SPU_DIR}"
	[ -e "${PPU_DIR}" ] && remove "${PPU_DIR}" "-rf"
	[ -e "${SPU_DIR}" ] && remove "${SPU_DIR}" "-rf"
	[ -e "${PATCHES_DIR}" ] && remove "${PATCHES_DIR}" "-rf"
	echo "******* Cleaned :: toolchains ${PPU_DIR} and ${SPU_DIR}"
}

# download the necessary source tarballs
function download_src() {
	echo "******* Downloading :: tarballs to ${TAR_DIR}"
	make_dir "${TAR_DIR}"
	[ ! -e "${BINUTILS_TARBALL}" ] && download "${BINUTILS_URI}" "${TAR_DIR}/${BINUTILS_TARBALL}"
	[ ! -e "${GCC_TARBALL}" ] && download "${GCC_URI}" "${TAR_DIR}/${GCC_TARBALL}"
	[ ! -e "${NEWLIB_TARBALL}" ] && download "${NEWLIB_URI}" "${TAR_DIR}/${NEWLIB_TARBALL}"
	[ ! -e "${GMP_TARBALL}" ] && download "${GMP_URI}" "${TAR_DIR}/${GMP_TARBALL}"
	[ ! -e "${MPFR_TARBALL}" ] && download "${MPFR_URI}" "${TAR_DIR}/${MPFR_TARBALL}"
	[ ! -e "${MPC_TARBALL}" ] && download "${MPC_URI}" "${TAR_DIR}/${MPC_TARBALL}"
	[ ! -e "${GDB_TARBALL}" ] && download "${GDB_URI}" "${TAR_DIR}/${GDB_TARBALL}"
	echo "******* Downloaded :: tarballs to ${TAR_DIR}"
}

# setup src directories
function create_srcdirs() {
	echo "******* Extracting :: tarballs to ${SRC_DIR}"
	[ -e "${TAR_DIR}/${BINUTILS_TARBALL}" ] && extract "${TAR_DIR}/${BINUTILS_TARBALL}" "${SRC_DIR}"
	[ -e "${TAR_DIR}/${GCC_TARBALL}" ] && extract "${TAR_DIR}/${GCC_TARBALL}" "${SRC_DIR}"
	[ -e "${TAR_DIR}/${NEWLIB_TARBALL}" ] && extract "${TAR_DIR}/${NEWLIB_TARBALL}" "${SRC_DIR}"
	[ -e "${TAR_DIR}/${GMP_TARBALL}" ] && extract "${TAR_DIR}/${GMP_TARBALL}" "${SRC_DIR}"
	[ -e "${TAR_DIR}/${MPFR_TARBALL}" ] && extract "${TAR_DIR}/${MPFR_TARBALL}" "${SRC_DIR}"
	[ -e "${TAR_DIR}/${MPC_TARBALL}" ] && extract "${TAR_DIR}/${MPC_TARBALL}" "${SRC_DIR}"
	[ -e "${TAR_DIR}/${GDB_TARBALL}" ] && extract "${TAR_DIR}/${GDB_TARBALL}" "${SRC_DIR}"
	echo "******* Extracted :: tarballs to ${SRC_DIR}"
	echo "******* Symlinking :: gmp, mpfr, mpc to ${GCC_SRCDIR}"
	[ -e "${GMP_SRCDIR}" -a -e ${GCC_SRCDIR} -a ! -e ${GMP_GCCSRCDIR} ] && create_symlink "${GMP_SRCDIR}" "${GMP_GCCSRCDIR}"
	[ -e "${MPC_SRCDIR}" -a -e ${GCC_SRCDIR} -a ! -e ${MPC_GCCSRCDIR} ] && create_symlink "${MPC_SRCDIR}" "${MPC_GCCSRCDIR}"
	[ -e "${MPFR_SRCDIR}" -a -e ${GCC_SRCDIR} -a ! -e ${MPFR_GCCSRCDIR} ] && create_symlink "${MPFR_SRCDIR}" "${MPFR_GCCSRCDIR}"
	echo "******* Symlinked :: gmp, mpfr, mpc to ${GCC_SRCDIR}"
	echo "******* Copying :: crt to ${CRT_SRCDIR}"
	[ -e "${CRT_DIR}" -a ! -e "${CRT_SRCDIR}" ] && copy "${CRT_DIR}" "${CRT_SRCDIR}" "-r"
	echo "******* Copied :: crt to ${CRT_SRCDIR}"
# HACK1 start :: BUG ID 44455 this is a hack to fix this bug http://gcc.gnu.org/bugzilla/show_bug.cgi?id=44455
	echo "******* Copying :: (HACK1 gcc bug id 44455) gmp includes from ${GMP_SRCDIR} to ${GMP_GCCSRCDIR}"
	[ -e "${GCC_BUILDDIR}" ] && make_dir "${GCC_BUILDDIR}/gmp" || die "HACK1 could not make gmp build directory ${GCC_BUILDDIR}/gmp"
	[ -e "${GCC_BUILDDIR}/gmp" -a -f "${GMP_SRCDIR}/gmp-impl.h" ] && copy "${GMP_SRCDIR}/gmp-impl.h" "${GCC_BUILDDIR}/gmp/gmp-impl.h" || die "HACK1 no gmp-impl.h"
	[ -e "${GCC_BUILDDIR}/gmp" -a -f "${GMP_SRCDIR}/longlong.h" ] && copy "${GMP_SRCDIR}/longlong.h" "${GCC_BUILDDIR}/gmp/longlong.h" || die "HACK1 no longlong.h"
	echo "******* Copied :: (HACK1 gcc bug id 44455) gmp includes from ${GMP_SRCDIR} to ${GMP_GCCSRCDIR}"
# HACK1 end
}

# create the build directories
function create_builddirs() {
	echo "******* Creating :: build directories in ${BUILD_DIR}"
	[ ! -e "${BINUTILS_BUILDDIR}" ] && make_dir "${BINUTILS_BUILDDIR}" || die "could not make binutils build directory ${BINUTILS_BUILDDIR}"
	[ ! -e "${GCC_BUILDDIR}" ] && make_dir "${GCC_BUILDDIR}" || die "could not make gcc build directory ${GCC_BUILDDIR}"
	[ ! -e "${CRT_BUILDDIR}" ] && make_dir "${CRT_BUILDDIR}" || die "could not make crt build directory ${CRT_BUILDDIR}"
	[ ! -e "${GDB_BUILDDIR}" ] && make_dir "${GDB_BUILDDIR}" || die "could not make gdb build directory ${GDB_BUILDDIR}"
	[ ! -e "${NEWLIB_BUILDDIR}" ] && make_dir "${NEWLIB_BUILDDIR}" || die "could not make newlib build directory ${NEWLIB_BUILDDIR}"
	echo "******* Created :: build directories in ${BUILD_DIR}"
}

# export build variables
function export_buildvars() {
	PREFIX="${1}"
	FLAG="${2}"
	ARRAY_VARIABLES=( "CC" "GCC" "CXX" "LD" "AS" "AR" "RANLIB" "NM" "STRIP" "OBJDUMP" "OBJCOPY" )
	ARRAY_VALUES=( "gcc" "gcc" "g++" "ld" "as" "ar" "ranlib" "nm" "strip" "objdump" "objcopy" )
	counter=0
	echo "******* Exporting :: build variables for ${PREFIX}-* FLAG=${FLAG}"
	for arrayvariable in ${ARRAY_VARIABLES[@]}; do
		[ -n "${PREFIX}-${ARRAY_VALUES[${counter}]}" ] && export_var "${arrayvariable}_FOR_TARGET" "${PREFIX}-${ARRAY_VALUES[${counter}]}" ${FLAG}
		let counter+=1
	done
	echo "******* Exported :: build variables for ${PREFIX}-* FLAG=${FLAG}"
}

# create symbolic links
function create_symlinks() {
	TARGET="${1}"
	FOLDER="${2}"
	ARRAY_TOOLS=( "addr2line" "ar" "as" "c++" "c++filt" "cpp" "embedspu" "g++" "gcc" "gcc-${GCC_VER}" "gccbug" "gcov" "gdb" "gdbtui" "gprof" "ld" "nm" "objcopy" "objdump" "ranlib" "readelf" "size" "strings" "strip" )
	cd "${FOLDER}"
	echo "*** Creating :: symbolic links for ${TARGET} in ${FOLDER}"
	for tool in ${ARRAY_TOOLS[@]}; do
		[ ! -e "ppu-${tool}" -a -e "${TARGET}-${tool}" ] && create_symlink "${TARGET}-${tool}" "ppu-${tool}"
	done
	echo "*** Created :: symbolic links for ${TARGET} in ${FOLDER}"
	cd "${BUILDIT_DIR}"
}

# copy patches to PS3CHAIN build directory if they exist
function copy_patches() {
	echo "******* Copying :: patches from ${PATCHES_SRCDIR}"
	[ -e "${PATCHES_SRCDIR}" -a -d "${PATCHES_SRCDIR}" ] && copy "${PATCHES_SRCDIR}" "${PATCHES_DIR}" "-R" || [ -n "${DEBUG}" ] && echo "*** No patches to apply ..."
	echo "******* Copied :: patches from ${PATCHES_SRCDIR}"
}

# copy the make rules
function copy_makerules() {
	TARGET="${1}"
	MKDST="${2}"
	echo "******* Copying :: make rules to ${MKDST}"
	[ ! -d "${MKDST}/${TARGET}" ] && make_dir "${MKDST}/${TARGET}"
	[ -e "${MAKERULES_SRCDIR}/common.mk" -a ! -e "${MKDST}/common.mk" ] && copy "${MAKERULES_SRCDIR}/common.mk" "${MKDST}/common.mk"
	[ -e "${MAKERULES_SRCDIR}/common_pre.mk" -a ! -e "${MKDST}/common_pre.mk" ] && copy "${MAKERULES_SRCDIR}/common_pre.mk" "${MKDST}/common_pre.mk"
	[ -e "${MAKERULES_SRCDIR}/${TARGET}.mk" -a ! -e "${MKDST}/${TARGET}/${TARGET}.mk" ] && copy "${MAKERULES_SRCDIR}/${TARGET}.mk" "${MKDST}/${TARGET}/${TARGET}.mk"
	echo "******* Copied :: make rules to ${MKDST}"
}

# build binutils
function build_binutils() {
	TARGET="${1}"
	FOLDER="${2}"
	[ -n "${DEBUG}" ] && echo "*** Building :: binutils for ${TARGET} in ${BINUTILS_BUILDDIR}"
	(
		cd "${BINUTILS_BUILDDIR}" && \
		"${BINUTILS_SRCDIR}/configure" \
			--target="${TARGET}" \
			--prefix="${FOLDER}" \
			--disable-multilib \
			--disable-nls \
			--disable-shared \
			--disable-werror >> "${BINUTILS_OUT}" 2>&1 && \
		"${MAKE}" "${MAKEOPTS}" >> "${BINUTILS_OUT}" 2>&1 && \
		"${MAKE}" install >> "${BINUTILS_OUT}" 2>&1
	) || die "building binutils for target ${TARGET}"
	[ -n "${DEBUG}" ] && echo "*** Built :: binutils for ${TARGET} in ${BINUTILS_BUILDDIR}"
	cd "${BUILDIT_DIR}"
}

# build gcc
function build_gcc_stage1() {
	TARGET="${1}"
	FOLDER="${2}"
	CPUFLAG="${3}"
	[ -n "${DEBUG}" ] && echo "*** Building :: gcc stage 1 for ${TARGET} in ${GCC_BUILDDIR} with CPUFLAG=${CPUFLAG}"
	(
		cd "${GCC_BUILDDIR}" && \
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
			--enable-languages="c,c++" \
			--enable-checking=release \
			--with-newlib \
			${EXTRAFLAGS} \
			"${CPUFLAG}" >> "${GCC_OUT}" 2>&1 && \
		"${MAKE}" all-gcc "${MAKEOPTS}" >> "${GCC_OUT}" 2>&1 && \
		"${MAKE}" install-gcc >> "${GCC_OUT}" 2>&1
	) || die "building gcc for target ${TARGET}"
	[ -n "${DEBUG}" ] && echo "*** Built :: gcc stage 1 for ${TARGET} in ${GCC_BUILDDIR} with CPUFLAG=${CPUFLAG}"
	cd "${BUILDIT_DIR}"
}

# build newlib
function build_newlib() {
	TARGET="${1}"
	FOLDER="${2}"
	NEWLIB_TARGET="${3}"
	PREFIX="${FOLDER}/bin/${TARGET}"
	[ -n "${DEBUG}" ] && echo "*** Building :: ${TARGET} newlib for ${NEWLIB_TARGET} with stage 1 gcc in ${NEWLIB_BUILDDIR}"
	export_buildvars "${PREFIX}"
	(
		cd "${NEWLIB_BUILDDIR}" && \
		"${NEWLIB_SRCDIR}/configure" \
			--target="${NEWLIB_TARGET}" \
			--prefix="${FOLDER}" \
			--disable-multilib \
			--disable-nls \
			--disable-shared >> "${NEWLIB_OUT}" 2>&1 && \
		"${MAKE}" "${MAKEOPTS}" >> "${NEWLIB_OUT}" 2>&1 && \
		"${MAKE}" install >> "${NEWLIB_OUT}" 2>&1
	) || die "building newlib for target ${TARGET}"
	(
		if [ "${TARGET}" != "${NEWLIB_TARGET}" ]; then
			[ -n "${DEBUG}" ] && echo "*** Copying :: newlib lib/include from ${FOLDER}/${NEWLIB_TARGET} to ${FOLDER}/${TARGET}"
			copy "${FOLDER}/${NEWLIB_TARGET}/lib/." "${FOLDER}/${TARGET}/lib" "-rv" && \
			copy "${FOLDER}/${NEWLIB_TARGET}/include/." "${FOLDER}/${TARGET}/include" "-rv"
			[ -n "${DEBUG}" ] && echo "*** Copied :: newlib lib/include from ${FOLDER}/${NEWLIB_TARGET} to ${FOLDER}/${TARGET}"
			[ -n "${DEBUG}" ] && echo "*** Removing :: newlib ${FOLDER}/${NEWLIB_TARGET}"
			remove "${FOLDER}/${NEWLIB_TARGET}" "-rf"
			[ -n "${DEBUG}" ] && echo "*** Removed :: newlib ${FOLDER}/${NEWLIB_TARGET}"
		else
			[ -n "${DEBUG}" ] && echo "*** Copy :: newlib lib/include from ${FOLDER}/${NEWLIB_TARGET} to ${FOLDER}/${TARGET} not necessary ..."
		fi
	) || die "copying newlib for target ${TARGET}"
	export_buildvars "${PREFIX}" "-n"
	[ -n "${DEBUG}" ] && echo "*** Built :: ${TARGET} newlib for ${NEWLIB_TARGET} with stage 1 gcc in ${NEWLIB_BUILDDIR}"
	cd "${BUILDIT_DIR}"
}

# build crt
# http://gcc.gnu.org/ml/gcc/2008-03/msg00515.html
# http://osdir.com/ml/lib.newlib/2006-12/msg00037.html
function build_crt() {
	TARGET="${1}"
	FOLDER="${2}"
	[ -n "${DEBUG}" ] && echo "*** Building :: crt for ${TARGET} with ${FOLDER}/bin/${TARGET}-gcc (stage 1) in ${CRT_BUILDDIR} ..."
	(
		cd "${CRT_BUILDDIR}" && \
		"${FOLDER}/bin/${TARGET}-gcc" -c "${CRT_SRCDIR}/${TARGET}/crti.S" -o "${CRT_BUILDDIR}/crti.o" >> "${CRT_OUT}" 2>&1 && \
		"${FOLDER}/bin/${TARGET}-gcc" -c "${CRT_SRCDIR}/${TARGET}/crtn.S" -o "${CRT_BUILDDIR}/crtn.o" >> "${CRT_OUT}" 2>&1 && \
		"${FOLDER}/bin/${TARGET}-gcc" -c "${CRT_SRCDIR}/${TARGET}/crt0.S" -o "${CRT_BUILDDIR}/crt0.o" >> "${CRT_OUT}" 2>&1 && \
		"${FOLDER}/bin/${TARGET}-gcc" -c "${CRT_SRCDIR}/${TARGET}/crt1.c" -o "${CRT_BUILDDIR}/crt.o" >> "${CRT_OUT}" 2>&1 && \
		"${FOLDER}/bin/${TARGET}-ld" -r "${CRT_BUILDDIR}/crt0.o" "${CRT_BUILDDIR}/crt.o" -o "${CRT_BUILDDIR}/crt1.o" >> "${CRT_OUT}" 2>&1 && \

		[ -n "${DEBUG}" ] && echo "*** Copying :: crt lib/include to ${FOLDER}/${TARGET} ..."
		make_dir "${FOLDER}/${TARGET}/lib" && \
		make_dir "${FOLDER}/${TARGET}/include" && \
		copy "${CRT_BUILDDIR}/crt0.o" "${FOLDER}/${TARGET}/lib" "-f" && \
		copy "${CRT_BUILDDIR}/crt1.o" "${FOLDER}/${TARGET}/lib" "-f" && \
		copy "${CRT_BUILDDIR}/crti.o" "${FOLDER}/${TARGET}/lib" "-f" && \
		copy "${CRT_BUILDDIR}/crtn.o" "${FOLDER}/${TARGET}/lib" "-f" && \
		copy "${CRT_SRCDIR}/fenv.h" "${FOLDER}/${TARGET}/include" "-f"
		[ -n "${DEBUG}" ] && echo "*** Copied :: crt lib/include to ${FOLDER}/${TARGET} ..."
	) || die "building crt for target ${TARGET} in ${CRT_BUILDDIR} with ${TARGET}-gcc"
	[ -n "${DEBUG}" ] && echo "*** Built :: crt for ${TARGET} with ${TARGET}-gcc (stage 1) in ${CRT_BUILDDIR} ..."
	cd "${BUILDIT_DIR}"
}

# continue building/compiling gcc
function build_gcc_stage2() {
	TARGET="${1}"
	[ -n "${DEBUG}" ] && echo "*** Building :: gcc stage 2 for ${TARGET} in ${GCC_BUILDDIR}"
	(
		cd "${GCC_BUILDDIR}" && \
		"${MAKE}" all "${MAKEOPTS}" >> "${GCC_OUT}" 2>&1 && \
		"${MAKE}" install >> "${GCC_OUT}" 2>&1
	) || die "building gcc support libs for target ${TARGET}"
	[ -n "${DEBUG}" ] && echo "*** Built :: gcc stage 2 for ${TARGET} in ${GCC_BUILDDIR}"
	cd "${BUILDIT_DIR}"
}

# build gdb
function build_gdb() {
	TARGET="${1}"
	FOLDER="${2}"
	[ -n "${DEBUG}" ] && echo "*** Building :: gdb for ${TARGET} in ${GDB_BUILDDIR}"
	(
		cd "${GDB_BUILDDIR}" && \
		"${GDB_SRCDIR}/configure" \
			--target="${TARGET}" \
			--prefix="${FOLDER}" \
			--disable-multilib \
			--disable-nls \
			--disable-sim \
			--disable-werror >> "${GDB_OUT}" 2>&1 && \
		"${MAKE}" "${MAKEOPTS}" >> "${GDB_OUT}" 2>&1 && \
		"${MAKE}" install >> "${GDB_OUT}" 2>&1
	) || die "building gdb for target ${TARGET}"
	[ -n "${DEBUG}" ] && echo "*** Built :: gdb for ${TARGET} in ${GDB_BUILDDIR}"
	cd "${BUILDIT_DIR}"
}

#build the SPU chain
function build_spu() {
	echo "******* Building :: SPU binutils"
	[ "${BUILD_BINUTILS}" != "false" -a "${BUILD_BINUTILS}" != "FALSE" ] && build_binutils "${SPU_TARGET}" "${SPU_DIR}"
	echo "******* Building :: SPU GCC stage 1"
	[ "${BUILD_GCC1}" != "false" -a "${BUILD_GCC1}" != "FALSE" ] && build_gcc_stage1 "${SPU_TARGET}" "${SPU_DIR}"
	echo "******* Building :: SPU newlib"
	[ "${BUILD_NEWLIB}" != "false" -a "${BUILD_NEWLIB}" != "FALSE" ] && build_newlib "${SPU_TARGET}" "${SPU_DIR}" "${SPU_NEWLIB_TARGET}"
	echo "******* Building :: SPU GCC stage 2"
	[ "${BUILD_GCC2}" != "false" -a "${BUILD_GCC2}" != "FALSE" ] && build_gcc_stage2 "${SPU_TARGET}"
	echo "******* Building :: SPU GDB"
	[ "${BUILD_GDB}" != "false" -a "${BUILD_GDB}" != "FALSE" ] && build_gdb "${SPU_TARGET}" "${SPU_DIR}"
	cd "${BUILDIT_DIR}"
}

# build the PPU chain
function build_ppu() {
	echo "******* Building :: PPU binutils"
	[ "${BUILD_BINUTILS}" != "false" -a "${BUILD_BINUTILS}" != "FALSE" ] && build_binutils "${PPU_TARGET}" "${PPU_DIR}"
	echo "******* Building :: PPU GCC stage 1"
	[ "${BUILD_GCC1}" != "false" -a "${BUILD_GCC1}" != "FALSE" ] && build_gcc_stage1 "${PPU_TARGET}" "${PPU_DIR}" "--with-cpu=cell"
	echo "******* Building :: PPU newlib"
	[ "${BUILD_NEWLIB}" != "false" -a "${BUILD_NEWLIB}" != "FALSE" ] && build_newlib "${PPU_TARGET}" ${PPU_DIR} "${PPU_NEWLIB_TARGET}"
	echo "******* Building :: PPU CRT"
	[ "${BUILD_CRT}" != "false" -a "${BUILD_CRT}" != "FALSE" ] && build_crt "${PPU_TARGET}" "${PPU_DIR}"
	echo "******* Building :: PPU GCC stage 2"
	[ "${BUILD_GCC2}" != "false" -a "${BUILD_GCC2}" != "FALSE" ] && build_gcc_stage2 "${PPU_TARGET}"
	echo "******* Building :: PPU GDB"
	[ "${BUILD_GDB}" != "false" -a "${BUILD_GDB}" != "FALSE" ] && build_gdb "${PPU_TARGET}" "${PPU_DIR}"
	echo "******* Creating :: symbolic links"
	create_symlinks "${PPU_TARGET}" "${PPU_DIR}/bin"
	cd "${BUILDIT_DIR}"
}

# prepare the chain src and build directories for building
function prep_chain() {
	echo "******** PREP START :: preparing for ${1} build"
	download_src && \
	clean_build && \
	create_builddirs && \
	create_srcdirs && \
	copy_patches && \
	copy_makerules "${1}" "${2}"
	echo "******** PREP COMPLETE :: prepared for ${1} build"
}

# build the PPU chain and clean the build directories
function ppu_arg() {
	echo "******** BUILD START :: PPU toolchain building and installing"
	prep_chain "ppu" "${PS3CHAIN}" && \
	build_ppu && \
	clean_build
	echo "******** BUILD COMPLETE :: PPU toolchain built and installed"
}

# build the SPU chain and clean the build directories
function spu_arg() {
	echo "******** BUILD START :: SPU toolchain building and installing"
	prep_chain "spu" "${PS3CHAIN}" && \
	build_spu && \
	clean_build
	echo "******** BUILD COMPLETE :: SPU toolchain built and installed"
}

# build everything, then cleanup the src and build directories
function all_arg() {
	echo "******** BUILD START :: PPU/SPU building and installing"
	ppu_arg && \
	spu_arg
	echo "******** BUILD COMPLETE :: PPU/SPU built and installed"
}

# clean src directories
function cleanall_arg() {
	echo "******** CLEAN START :: cleaning all"
	clean_build
	clean_src
	clean_toolchains
	echo "******** CLEAN COMPLETE :: cleaned all"
}

#
# End of functions.
#

# evaluate what needs to be built
while true; do
	if [ "${#}" -eq "0" ]; then
		[ "${BUILDTYPE}" == "help" ] && usage
		echo "********** Completed :: ${BUILDTYPE} in ${PS3CHAIN}"
		exit 0
	fi
	#
	case "${BUILDTYPE}" in
		all)		all_arg ;; # build everything, then cleanup
		ppu)		ppu_arg ;; # build the PPU chain
		spu)		spu_arg ;; # build the SPU chain
		clean)		cleanall_arg ;; # clean up everything
		help)		usage ;; # print usage
		*)
			die "unknown build type ${1}" # fall-through error
			;;
	esac
	shift;
done

echo "Should never get here if you are reading this something went wrong {shrug} ..."
exit 1

#EOF
