distrib="uname -d"
version="uname -r"

echo $distrib

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
