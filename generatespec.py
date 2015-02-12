#!/usr/bin/env python
import GSASII, GSASIIpath
version = "%s.%s" % (GSASII.__version__,str(GSASIIpath.GetVersionNumber()))


spec_in= \
"""
Name:           gsasii
Version:        $version
Release:        1%{?dist}
Summary:        General Structure Analysis System-II

License:        All rights reserved
URL:            https://subversion.xor.aps.anl.gov/trac/pyGSAS
Source:         %{name}-$version.tar.gz

BuildRequires:  scons gcc-gfortran numpy-f2py
Prefix:         /opt/gsasii

Requires:       python >= 2.7
Requires:       wxPython
Requires:       python-matplotlib
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

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p %{buildroot}%{prefix}
cp -R %{_builddir}/%{name}/* %{buildroot}%{prefix}

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

from string import Template
handle = file('gsasii.spec', 'w')

spec = Template(spec_in).safe_substitute(version=version)
spec += getChangelog()
spec += getFiles()

handle.write(spec)
