## Define error code
E_NOTROOT=87 # Non-root exit error.

distrib="uname -d"
version="uname -r"


# Pour Debian
if [ "$distrib" = "*Debian*" ] ; then
    paquets="tcl tk tcl8.6-tdbc tcl8.6-tdbc-mysql tcl8.6-tdbc-sqlite tcl8.6-tdbc-odbc"
    apt-get install -y $paquets
    # Spécificité de Debian 9.*
    if [ "$version" = "*9*" ] ; then
        ln -s ./libmariadbclient.so.18 ./libmysql.so.15
    fi
fi

# Pour Ubuntu
if [ "$distrib" = "*Ubuntu*" ] ; then
    paquets="tcl tk tcl8.6-tdbc tcl8.6-tdbc-mysql tcl8.6-tdbc-sqlite tcl8.6-tdbc-odbc"
    apt-get install -y $paquets
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    bin=/usr/bin
    opt=/opt
elif [[ "$OSTYPE" == "darwin"* ]]; then
    bin=/usr/bin
    opt=/usr/share/opt
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    bin=/usr/bin
    opt=/usr/share/opt
else
    bin=/usr/bin
    opt=/opt
fi


if [ -w $opt ]; then
    echo "Privileges are dones"
else
    echo "Root privileges are needed for this installation"
fi


mkdir $opt/Katyusha_MCD

cp ./latests.tar.gz $opt/Katyusha_MCD

tar xvf $opt/Katyusha_MCD/latest.tar.gz

echo "#!/bin/sh
tclsh $opt/Katyusha_MCD/Katyusha.tcl \$1" > $bin/katyushamcd
chmod +x $bin/katyushamcd

# Fichier desktop
echo "[Desktop Entry]
Type=Application
Name=Katyusha! MCD
GenericName=SQL Merise and UML
Exec=katyushamcd
Icon=$opt/KatyushaMCD/images/katyusha_mcd_icone.png
Terminal=false
Categories=Development;Engineering;
MimeType=text/x-mcd
Keywords=SQL; Merise; UML; Devleppment;" > $opt/Katyusha_MCD/Katyusha_MCD.desktop

# Création d'entré dans le menu
cp $opt/Katyusha_MCD/Katyusha_MCD.desktop ~/.local/share/application/Katyusha_MCD.desktop
