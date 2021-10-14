# UNIX
# 64 bits
~/Logiciels/FreeWrap/linux64/freewrap ./Katyusha.tcl -f ./sources.txt -o ./KatyushaMCD_UNIX_x64 -9
tar -czvf ./OUT/KatyushaMCD_UNIX_x64_$1.tar.gz ./KatyushaMCD_UNIX_x64 ./gpl-3.0.txt
# 32 bits
~/Logiciels/FreeWrap/linux64/freewrap -w ~/Logiciels/FreeWrap/linux32/freewrap ./Katyusha.tcl -f ./sources.txt -o ./KatyushaMCD_UNIX_x32 -9
tar -czvf ./OUT/KatyushaMCD_UNIX_x32_$1.tar.gz ./KatyushaMCD_UNIX_x32 ./gpl-3.0.txt

# Windows
# 64 bits
~/Logiciels/FreeWrap/linux64/freewrap -w ~/Logiciels/FreeWrap/win64/freewrap.exe ./Katyusha.tcl -f ./sources.txt -o ./KatyushaMCD_WIN_x64.exe -9 -i ./images/katyusha_mcd_icone.ico
zip -r ./OUT/KatyushaMCD_WIN_x64_$1.zip ./KatyushaMCD_WIN_x64.exe ./gpl-3.0.txt
# 32 bits
#wine ~/Logiciels/FreeWrap/win32/freewrap.exe ./Katyusha.tcl ./fonctions_interface.tcl ./C/C.tcl ./C/Images.tcl ./C/Splash.tcl ./C/INTERFACE_Entites.tcl ./C/INTERFACE_Etiquettes.tcl ./C/INTERFACE_Tables.tcl ./C/INTERFACE_Relations.tcl ./C/SQL_gen.tcl ./C/XML.tcl ./C/sauvegarde_charge.tcl ./C/entites.tcl ./C/Configurations.tcl ./C/verification_mcd.tcl ./C/Interface.tcl ./C/SQL.tcl ./C/Relations.tcl ./C/Etiquettes.tcl ./C/Tables.tcl ./C/Sauvegarde.tcl ./C/Charge.tcl ./C/MCD.tcl ./C/bind.tcl ./configs/defaut.conf ./configs/recents ./images/ajouter.a.png ./images/ajouter.png ./images/ajouter_etiquette.png ./images/ajouter_heritage.png ./images/ajouter_relation.png ./images/ajouter_table.png ./images/editer.png ./images/editer-x24.png ./images/editer-x32.png ./images/gen_sql-x32.png ./images/katyusha_mcd_icone.ico ./images/katyusha_mcd_icone.png ./images/katyusha_mcd_logo.png ./images/list-remove.png ./images/retour-x32.png ./images/splash.png ./images/supprimer.png ./images/valider-x32.png ./images/zoom-fit-best.png ./images/zoom-in.png ./images/zoom-original.png ./images/zoom-out.png ./locale/fr.tcl -i ./images/katyusha_mcd_icone.ico
wine ~/Logiciels/FreeWrap/win32/freewrap.exe ./Katyusha.tcl -f ./sources.txt -o ./KatyushaMCD_WIN_x32.exe -9 -i ./images/katyusha_mcd_icone.ico
zip -r ./OUT/KatyushaMCD_WIN_x32_$1.zip ./KatyushaMCD_WIN_x32.exe ./gpl-3.0.txt

# Sources
tar -czvf ./OUT/KatyushaMCD_SRC_$1.tar.gz ./Katyusha.tcl ./C/ ./images/ ./locale/ ./configs/ ./gpl-3.0.txt
