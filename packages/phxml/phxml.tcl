## Créé le 1/6/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

#########################################################################
# Phosphore Framework TCL                                               #
#                                                                       #
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#########################################################################

##
# Enregistre toute une arborescence XML dans des dictionnaires
##
proc BaseKalinka_XML_var {xml {var ""}} {
    set debut 0
    set res [dict create]
    while {[string first "<" $xml $debut] != -1} {
        # Cherche la balise d'ouverture de l'élément
        set debut [expr [string first "<" $xml $debut] + 1]
        set fin [expr [string first ">" $xml $debut] - 1]
        set balise_o [string range $xml $debut $fin]
        # Cherche la balise de fermeture de l'élément
        set debut_f [expr [string first "</$balise_o" $xml $debut] + 1]
        set fin_f [expr [string first ">" $xml $debut_f] - 1]
        set balise_f [string range $xml $debut_f $fin_f]
        # Contenu de la balise
        set contenu [string range $xml [expr $fin + 2] [expr $debut_f - 2]]
        # Si le contenu de la balise est du XML, il faut recommencer l'opération
        # avec le contenu, jusqu'à ce que tous les sous-éléments soit enregistrés
        # dans un dictionnaire
        if {[BaseKalinka_string_XML_ $contenu]} {
            dict set res $balise_o [BaseKalinka_XML_var $contenu]
        } else {
            dict set res $balise_o $contenu
        }
        set debut $fin_f
    }
    return $res
}

##
# Test si une chaine contient du XML
##
proc BaseKalinka_string_XML_ {chaine} {
    set res 0
    if {[Phosphore_string_balise_ $chaine]} {
        set res 1
    }
    return $res
}

##
# Transforme une arborescence de variable en XML
# !TOUT dans l'arborescence doit être sous forme de dictionnaire
##
proc BaseKalinka_var_XML {var {xml ""}} {
    foreach {k v} $var {
        if {[Phosphore_dict_ $v] == 1} {
            set xml_tmp [BaseKalinka_var_XML $v]
            set xml_tmp "<$k>\n$xml_tmp</$k>"
        } else {
            set xml_tmp "<$k>$v</$k>\n"
        }
        set xml "$xml$xml_tmp"
    }
    return $xml
}
