#!/usr/bin/env python
from GSASII import __version__ as gsas_version
from GSASIIpath import GetVersionNumber as gsas_svn_number
version = "%s.%s" % (gsas_version,str(gsas_svn_number()))

spec_in= \
"""
Name:           gsasii
Version:        $version
Release:        1%{?dist}
Summary:        General Structure Analysis System-II

License:        All rights reserved
URL:            https://subversion.xor.aps.anl.gov/trac/pyGSAS
Source:         %{name}-$version.tar.gz

BuildRequires:  scons gcc-gfortran numpy-f2py make python-sphinx python-matplotlib-wx
Prefix:         /opt/gsasii

Requires:       python >= 2.7
Requires:       wxPython
Requires:       python-matplotlib
Requires:       python-matplotlib-wx
Requires:       numpy
Requires:       scipy
# pillow is new version of python imaging library
Requires:       python-pillow
Requires:       PyOpenGL

%description
Powder and single crystal diffraction Rietveld refinement

%define debug_packages  %{nil}
%define debug_package %{nil}

%prep
%setup -n %{name}

%build
cd fsource
scons
#cd ../doc
#make html

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p %{buildroot}%{prefix}
cp -R %{_builddir}/%{name}/* %{buildroot}%{prefix}
chmod 755 %{buildroot}%{prefix}/GSASII.py

%clean
exit 0

"""

def getChangelog():
    # svn log -l 10
    return """
%changelog

"""

def getFiles():
    return """
%files
%defattr(-,root,root,-)
%{prefix}

"""

handle = file('gsasii.version', 'w')
handle.write(version)
handle.close()

from string import Template
handle = file('gsasii.spec', 'w')

spec = Template(spec_in).safe_substitute(version=version)
spec += getChangelog()
spec += getFiles()

handle.write(spec)
handle.close()
