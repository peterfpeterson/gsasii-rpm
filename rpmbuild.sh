#!/bin/bash
##############################################################
# This script automates all of the nonsense associated with
# updating the svn checkout, creating the spec file, creating
# the tarball, and running rpmbuild.
##############################################################
# constants
SCRIPT_DIR=$(realpath `dirname ${0}`)
SVN_DIR=${SCRIPT_DIR}/gsasii-svn
SVN=`which svn`
PYTHON=`which python`
TAR_UNPACKED=${SCRIPT_DIR}/gsasii
URL="https://subversion.xray.aps.anl.gov/pyGSAS"
VERSION_FILE=${SCRIPT_DIR}/gsasii.version
RPM_BIN_DIR=${HOME}/rpmbuild/RPMS/x86_64

##############################################################
# script

if [ -d ${SVN_DIR} ]; then
  # cd ${SVN_DIR}
  echo "${SVN} update ${SVN_DIR}"
  ${SVN} update ${SVN_DIR}
  # cd -
else
  echo "mkdir -p ${SVN_DIR}"
  mkdir -p ${SVN_DIR}
  echo "${SVN} co ${URL}/trunk/ ${SVN_DIR} --non-interactive --trust-server-cert"
  ${SVN} co ${URL}/trunk/ ${SVN_DIR} --non-interactive --trust-server-cert
fi

echo "PYTHONPATH=${SVN_DIR} ${PYTHON} ${SCRIPT_DIR}/generatespec.py"
PYTHONPATH=${SVN_DIR} ${PYTHON} ${SCRIPT_DIR}/generatespec.py

GSAS_VERSION=$(cat ${VERSION_FILE})
echo "gsasii version ${GSAS_VERSION}"
TAR_FILE="gsasii-${GSAS_VERSION}.tar.gz"

if [ ! -f ${TAR_FILE} ]; then
  echo "creating tarball"
  rm -rf ${TAR_UNPACKED}
  mkdir -p ${TAR_UNPACKED}
  cp -R ${SVN_DIR}/* ${TAR_UNPACKED}

  rm -f ${TAR_UNPACKED}/PyOpenGL-3.0.2a5.zip
  # build from source during packaging
  rm -rf ${TAR_UNPACKED}/bin*
  # build during packaging
  rm -rf ${TAR_UNPACKED}/sphinxdocs/build/*
  # these currently require /Users/toby/build/cctbx_build/bin/python
  rm -f ${TAR_UNPACKED}/testinp/genhkltest.py
  rm -f ${TAR_UNPACKED}/testinp/gensgtbx.py
  rm -f ${TAR_UNPACKED}/testinp/gencelltests.py

  TAR_UNPACKED=$(basename ${TAR_UNPACKED})
  echo "tar czf ${TAR_FILE} ${TAR_UNPACKED}"
  tar czf ${TAR_FILE} ${TAR_UNPACKED}
fi

echo "rpmbuild -bb gsasii.spec --define \"_sourcedir ${SCRIPT_DIR}\""
rpmbuild -bb gsasii.spec --define "_sourcedir ${SCRIPT_DIR}"

echo "mv ${RPM_BIN_DIR}/gsasii-${GSAS_VERSION}*-*.*.*.rpm ${SCRIPT_DIR}"
mv ${RPM_BIN_DIR}/gsasii-${GSAS_VERSION}*-*.*.*.rpm ${SCRIPT_DIR}
