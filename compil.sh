# UNIX
# 64 bits
~/Logiciels/FreeWrap/linux64/freewrap ./Katyusha.tcl -f ./sources.txt -o ./KatyushaMCD_UNIX_x64 -9
tar -czvf ./OUT/KatyushaMCD_UNIX_x64_$1.tar.gz ./KatyushaMCD_UNIX_x64 ./gpl-3.0.txt
# 32 bits
~/Logiciels/FreeWrap/linux64/freewrap -w ~/Logiciels/FreeWrap/linux32/freewrap ./Katyusha.tcl -f ./sources.txt -o ./KatyushaMCD_UNIX_x32 -9
tar -czvf ./OUT/KatyushaMCD_UNIX_x32_$1.tar.gz ./KatyushaMCD_UNIX_x32 ./gpl-3.0.txt

# Conversion des fichiers de traduction pour éviter les problèmes d'accents sous windows
mv ./locale/fr.tcl ./locale/fr.o.tcl
mv ./locale/en.tcl ./locale/en.o.tcl
mv ./locale/de.tcl ./locale/de.o.tcl

iconv -f UTF-8 -t ISO-8859-1 locale/fr.o.tcl > ./locale/fr.tcl
iconv -f UTF-8 -t ISO-8859-1 locale/en.o.tcl > ./locale/en.tcl
iconv -f UTF-8 -t ISO-8859-1 locale/de.o.tcl > ./locale/de.tcl

# Windows
# 64 bits
wine ~/Logiciels/FreeWrap/win64/freewrap.exe ./Katyusha.tcl -f ./sources.txt -o ./KatyushaMCD_WIN_x64.exe -9 -i ./images/katyusha_mcd_icone.ico
zip -r ./OUT/KatyushaMCD_WIN_x64_$1.zip ./KatyushaMCD_WIN_x64.exe ./gpl-3.0.txt
# 32 bits
wine ~/Logiciels/FreeWrap/win64/freewrap.exe -w ~/Logiciels/FreeWrap/win32/freewrap.exe ./Katyusha.tcl -f ./sources.txt -o ./KatyushaMCD_WIN_x32.exe -9 -i ./images/katyusha_mcd_icone.ico
zip -r ./OUT/KatyushaMCD_WIN_x32_$1.zip ./KatyushaMCD_WIN_x32.exe ./gpl-3.0.txt

rm ./locale/fr.tcl
rm ./locale/en.tcl
rm ./locale/de.tcl

mv ./locale/fr.o.tcl ./locale/fr.tcl
mv ./locale/en.o.tcl ./locale/en.tcl
mv ./locale/de.o.tcl ./locale/de.tcl


# Sources
tar -czvf ./OUT/KatyushaMCD_SRC_$1.tar.gz ./Katyusha.tcl ./C/ ./packages/ ./libs ./images/ ./locale/ ./configs/ ./gpl-3.0.txt
