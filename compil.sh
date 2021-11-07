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
wine ~/Logiciels/FreeWrap/win32/freewrap.exe ./Katyusha.tcl -f ./sources.txt -o ./KatyushaMCD_WIN_x32.exe -9 -i ./images/katyusha_mcd_icone.ico
zip -r ./OUT/KatyushaMCD_WIN_x32_$1.zip ./KatyushaMCD_WIN_x32.exe ./gpl-3.0.txt

# Sources
tar -czvf ./OUT/KatyushaMCD_SRC_$1.tar.gz ./Katyusha.tcl ./C/ ./images/ ./locale/ ./configs/ ./gpl-3.0.txt
