#!/usr/bin/env python
import GSASII, GSASIIpath
version = "%sr%s" % (GSASII.__version__,str(GSASIIpath.GetVersionNumber()))


spec_in= \
"""
Name:           gsasii
Version:        $version
Release:        1%{?dist}
Summary:        General Structure Analysis System-II

License:        All rights reserved
URL:            https://subversion.xor.aps.anl.gov/trac/pyGSAS
Source:         %{name}-$version.tar.gz

BuildRequires:  scons numpy-f2py
Prefix:         /usr/local/gsasii

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

%prep
%setup -n %{name}

%build
cd fsource
scons

%install
#rm -rf $RPM_BUILD_ROOT
#mkdir -p %{buildroot}%{_bindir}
#install -m 755 %{_builddir}/%{name}/finddata %{buildroot}%{_bindir}/finddata
#mkdir -p %{buildroot}%{_sysconfdir}/bash_completion.d
#install -m 644 %{_builddir}/%{name}/finddata.bashcomplete %{buildroot}%{_sysconfdir}/bash_completion.d/finddata.bashcomplete

%clean
#exit 0
"""
"""
%files
#%defattr(-,root,root,-)
#%doc README.md
#%doc LICENSE.txt
#%{_bindir}/finddata
#%{_sysconfdir}/bash_completion.d/finddata.bashcomplete

"""

def getChangelog():
    # svn log -l 10
    return """
%changelog"""

from string import Template
handle = file('gsasii.spec', 'w')

spec = Template(spec_in).safe_substitute(version=version)
spec += getChangelog()

handle.write(spec)
