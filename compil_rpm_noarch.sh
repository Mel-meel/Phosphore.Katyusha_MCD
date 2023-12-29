

tar -czvf ~/rpmbuild/SOURCES/KatyushaMCD-$1.$2.tar.gz ./Katyusha.tcl ./C/ ./images/ ./locale/ ./configs/ ./gpl-3.0.txt

echo "
Name:      KatyushaMCD
Version:   $1
Release:   $2
Summary:   Katysha? Katyusha!
BuildArch: noarch

License:   GPL-3
Source0:   KatyushaMCD-$1.$2.tar.gz

Requires:  tcl, tk

%description
Katyusha! MCD permet de concevoir des bases de données pour différents SGBD en générant un script SQL à partir d'une modélisation graphique selon la méthode Merise.

%install

%files
%defattr(-,root,root,-)
%{_datadir}/Phosphore/KatyushaMCD/
" > ~/rpmbuild/SPECS/katyusha.spec


rpmlint ~/rpmbuild/SPECS/katyusha.spec

rpmbuild -bs ~/rpmbuild/SPECS/katysha.spec

rpmbuild -bb ~/rpmbuild/SPECS/katysha.spec
