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
RPM_BIN_DIR=${HOME}/rpmbuild/RPMS/
ARCH=$(uname -m)
echo ${ARCH}

##############################################################
# script
echo "cd ${SCRIPT_DIR}"
cd ${SCRIPT_DIR}

if [ -f COPY_TO ]; then
  COPY_TO=$(cat COPY_TO)
else
  if [ "$#" -lt 1 ]; then
    echo "Should specify fully qualified scp destination"
    exit -1
  fi
fi
if [ "$#" -eq 1 ]; then
  COPY_TO="${1}"
fi
echo ${COPY_TO}
exit

if [ -d ${SVN_DIR} ]; then
  cd ${SVN_DIR}
  echo "${SVN} update ${SVN_DIR}"
  ${SVN} update ${SVN_DIR}
  cd -
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

# create the tarball
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

RPM=$(find ${RPM_BIN_DIR} -name gsasii-${GSAS_VERSION}-\*.\*.${ARCH}.rpm)

SCRIPT_DIR_RPM_EXISTS=$(find ${SCRIPT_DIR} -maxdepth 1 -name gsasii-${GSAS_VERSION}-\*.\*.${ARCH}.rpm | wc -l)
if [ "${SCRIPT_DIR_RPM_EXISTS}" -eq 0 ]; then
  # make the rpm if it doesn't exist
  if [ ! ${RPM} ]; then
    echo "rpmbuild -bb gsasii.spec --define \"_sourcedir ${SCRIPT_DIR}\""
    rpmbuild -bb gsasii.spec --define "_sourcedir ${SCRIPT_DIR}"
  fi

  # copy it into this directory
  RPM=$(find ${RPM_BIN_DIR} -name gsasii-${GSAS_VERSION}-\*.\*.${ARCH}.rpm)
  echo "cp ${RPM} ${SCRIPT_DIR}"
  cp ${RPM} ${SCRIPT_DIR}

  RPM=$(find ${SCRIPT_DIR} -maxdepth 1 -name gsasii-${GSAS_VERSION}-\*.\*.${ARCH}.rpm)
  echo "created ${RPM}"

  echo "scp ${RPM} ${COPY_TO}"
  scp ${RPM} ${COPY_TO}
else
  echo "rpm was not created - doing nothing"
fi

