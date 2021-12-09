mkdir ./tmp
mkdir ./tmp/KatyushaMCD_$1-$2_i386
mkdir ./tmp/KatyushaMCD_$1-$2_i386/DEBIAN

echo "Package: KatyushaMCD
Version: $1.$2
Architecture: i386
Section: devel
Depends: tcl, wish
Maintainer: Anazaar
License: GPL-3
Files: /usr/share/common-licenses/GPL-3
Description: Katyusha! MCD permet de concevoir des bases de données pour différents SGBD en générant un script SQL à partir d'une modélisation graphique selon la méthode Merise.
Homepage: http://katyusha-mcd.projet-phosphore.anazaar.org" > ./tmp/KatyushaMCD_$1-$2_i386/DEBIAN/control

mkdir ./tmp/KatyushaMCD_$1-$2_i386/usr
mkdir ./tmp/KatyushaMCD_$1-$2_i386/usr/bin

echo "#!/bin/sh
tclsh /usr/share/Phosphore/KatyushaMCD/Katyusha.tcl \$1" > ./tmp/KatyushaMCD_$1-$2_i386/usr/bin/katyushamcd
chmod +x ./tmp/KatyushaMCD_$1-$2_i386/usr/bin/katyushamcd

mkdir ./tmp/KatyushaMCD_$1-$2_i386/usr/share
mkdir ./tmp/KatyushaMCD_$1-$2_i386/usr/share/Phosphore
mkdir ./tmp/KatyushaMCD_$1-$2_i386/usr/share/Phosphore/KatyushaMCD

cp ./Katyusha.tcl ./tmp/KatyushaMCD_$1-$2_i386/usr/share/Phosphore/KatyushaMCD/
cp ./gpl-3.0.txt ./tmp/KatyushaMCD_$1-$2_i386/usr/share/Phosphore/KatyushaMCD/

mkdir ./tmp/KatyushaMCD_$1-$2_i386/usr/share/applications
echo "[Desktop Entry]
Type=Application
Name=Katyusha! MCD
GenericName=SQL Merise
Exec=katyushamcd
Icon=/usr/share/Phosphore/KatyushaMCD/images/katyusha_mcd_icone.png
Terminal=false
Categories=Development;Engineering;
MimeType=text/x-mcd
Keywords=SQL; Merise;" > ./tmp/KatyushaMCD_$1-$2_i386/usr/share/applications/KatyushaMCD.desktop

cp -r ./C ./tmp/KatyushaMCD_$1-$2_i386/usr/share/Phosphore/KatyushaMCD/C
cp -r ./images ./tmp/KatyushaMCD_$1-$2_i386/usr/share/Phosphore/KatyushaMCD/images
cp -r ./libs ./tmp/KatyushaMCD_$1-$2_i386/usr/share/Phosphore/KatyushaMCD/libs
cp -r ./configs ./tmp/KatyushaMCD_$1-$2_i386/usr/share/Phosphore/KatyushaMCD/configs
cp -r ./locale ./tmp/KatyushaMCD_$1-$2_i386/usr/share/Phosphore/KatyushaMCD/locale
cp -r ./packages ./tmp/KatyushaMCD_$1-$2_i386/usr/share/Phosphore/KatyushaMCD/packages

chmod 755 -R ./tmp

dpkg-deb --build --root-owner-group ./tmp/KatyushaMCD_$1-$2_i386

mv ./tmp/KatyushaMCD_$1-$2_i386.deb ./OUT

rm -rf ./tmp
