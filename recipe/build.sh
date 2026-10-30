#! /usr/bin/bash
set -e

MG=${PREFIX}/MG5_aMC

# The release tarball was packed on macOS and carries an AppleDouble
# ._MG5_aMC_v* entry next to the source directory, so conda-build doesn't strip
# the top-level directory and can't apply patches itself. Do it here.
cd MG5_aMC_v*/
# The same packing left an AppleDouble ._* file next to almost every file
find . -name '._*' -delete
# StdHEP needs the XDR symbols, which glibc no longer provides
patch -p1 < "${RECIPE_DIR}/add-libtirpc-to-nlo-extralibs-for-xdr.patch"
# Don't insist on recompiling CutTools when the gfortran build differs
patch -p1 < "${RECIPE_DIR}/remove-cuttools-compiler-requirement.patch"

# Drop files that aren't needed at runtime, and the prebuilt binary that ships
# in the tarball
rm -rf .github tests
rm -f .bzrignore .gitignore code-notes README UpdateNotes.txt vendor/DiscreteSampler/check

# Use the environment's perl rather than the system one
find . -type f -exec grep -Il '#!/usr/bin/perl -w' {} + | xargs -r sed -i 's|#!/usr/bin/perl -w|#!/usr/bin/env perl\nuse warnings;|g'

# -a keeps the symlinks in the tarball
mkdir -p "${MG}"
cp -a . "${MG}/"

# MG5_aMC links the code it generates against the one-loop libraries in
# vendor/ and HEPTools/. Build the copies it ships, as its own installer does,
# so the package is self-contained. Their makefiles call plain ar/ranlib.
mkdir -p "${SRC_DIR}/tools"
ln -sf "${AR}" "${SRC_DIR}/tools/ar"
ln -sf "${RANLIB}" "${SRC_DIR}/tools/ranlib"
export PATH="${SRC_DIR}/tools:${PATH}"

## CutTools (libcts.a, with its OneLOop, QCDLoop and mpfun90)
cd "${MG}/vendor/CutTools"
make FC="${FC}" FFLAGS="-fPIC -fno-automatic -O2 -funroll-all-loops ${FFLAGS}"
find . -name "*.o" -delete
cd -

## IREGI (libiregi.a, with its own OneLOop copy, QCDLoop and FF)
cd "${MG}/vendor/IREGI/src"
make -f makefile_ML5_lib FC="${FC}"
find . -name "*.o" -delete
cd -

## COLLIER, static, the way MG5_aMC's installer builds it into HEPTools
H=${MG}/HEPTools
mkdir -p "${SRC_DIR}/collier-src" "${H}/lib" "${H}/include"
tar xzf "${MG}/vendor/collier.tar.gz" -C "${SRC_DIR}/collier-src"
C=$(echo "${SRC_DIR}"/collier-src/COLLIER-*)
cmake -S "${C}" -B "${C}/build-static" -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_Fortran_COMPILER="${FC}" \
  -Dstatic=ON -DCMAKE_Fortran_FLAGS="-fPIC"
cmake --build "${C}/build-static" --parallel "${CPU_COUNT}"
cp "${C}/libcollier.a" "${H}/lib/"
cp "${C}"/modules/*.mod "${H}/include/"

## StdHEP has no package, so build the vendored copy with the conda flags
cd "${MG}/vendor/StdHEP"
sed -i "s|FFLAGS += -std=legacy|FFLAGS += -std=legacy -ffixed-line-length-none ${FFLAGS}|g" makefile
sed -i "s|CFLAGS += -Wno-implicit-function-declaration|CFLAGS += -Wno-implicit-function-declaration ${CFLAGS}|g" makefile
make all FC="${FC}" F77="${FC}" CC="${CC}" --jobs="${CPU_COUNT}"
make clean
cd -

# Configuration: set options in upstream's template. Compiler names are the
# host ones, so they're right at runtime. auto_update is off: an update would
# rewrite the installed package.
conf() { sed -i "s|^#\s*$1\s*=.*|$1 = $2|" "${MG}/input/mg5_configuration.txt"
         grep -q "^$1 = " "${MG}/input/mg5_configuration.txt"; }
conf fortran_compiler "${PREFIX}/bin/$(basename "${FC}")"
conf f2py_compiler_py3 "${PREFIX}/bin/f2py"
conf cpp_compiler "${PREFIX}/bin/$(basename "${CXX}")"
conf eps_viewer "${PREFIX}/bin/gs"
conf auto_update 0
conf automatic_html_opening False
conf lhapdf_py3 "${PREFIX}/bin/lhapdf-config"
conf fastjet "${PREFIX}/bin/fastjet-config"
conf eMELA "${PREFIX}/bin/eMELA-config"
# Ninja is not shipped: MG5_aMC uses CutTools, IREGI and COLLIER
conf ninja None
conf collier ./HEPTools/lib

mkdir -p "${PREFIX}/bin" "${PREFIX}/share/mg5_aMC"
ln -sf "${MG}/bin/mg5_aMC" "${PREFIX}/bin/mg5_aMC"
ln -sf "${MG}/proc_card.dat" "${PREFIX}/share/mg5_aMC/proc_card.dat"

# zzz- so these run last and their FFLAGS change isn't overwritten by the
# compiler activation scripts
for d in activate deactivate; do
  mkdir -p "${PREFIX}/etc/conda/${d}.d"
  for sh in sh csh fish; do
    cp "${RECIPE_DIR}/${d}.${sh}" "${PREFIX}/etc/conda/${d}.d/zzz-${PKG_NAME}-${d}.${sh}"
  done
done

# The first start writes MG5_aMC's generated files into the package
echo "exit" | "${PREFIX}/bin/mg5_aMC"
