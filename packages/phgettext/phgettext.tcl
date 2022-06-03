######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
#  Copyleft 2022 Projet Phosphore - AnaZaar
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
##

namespace eval phgt {
    namespace export -clear phgt
    variable sources
    variable traduction [dict create]
}

proc phgt::src {dossier langue_i} {
    variable sources
    
    set ok 0
    if {[file isdirectory $dossier] == 1} {
        set sources $dossier
        set ok 1
    } else {
        puts "!O $dossier"
    }
    
    if {$ok == 1} {
        if {[file exists "$sources/$langue_i.po"]} {
            set ok 1
        } else {
            set ok 0
        }
    } else {
        puts "!K $langue_i"
        set ok 0
    }

    if {$ok == 1} {
        set fp [open "$sources/$langue_i.po" r]
        set contenu [read $fp]
        close $fp
        if {$contenu != ""} {
            set curseur 0
            set etape 1
            set chaine_ouverte 0
            while {$curseur != -1} {
                # Première étape : recherche d'une clef
                if {$etape == 1} {
                    set curseur [string first "msgid" $contenu $curseur]
                    set etape 2
                # Deuxième étape : récupère la clef
                } elseif {$etape == 2} {
                    set res [phgt::_chaine $curseur $contenu]
                    set curseur [lindex $res 0]
                    set clef [lindex $res 1]
                    set etape 3
                } elseif {$etape == 3} {
                    set curseur [string first "msgstr" $contenu [expr $curseur + 1]]
                    set etape 4
                } elseif {$etape == 4} {
                    set res [phgt::_chaine $curseur $contenu]
                    set curseur [lindex $res 0]
                    set valeur [lindex $res 1]
                    set etape 1
                    dict set phgt::traduction [string map {"\\n" "\n" "\\t" "\t" "\\r" "\r"} $clef] [string map {"\\n" "\n" "\\t" "\t" "\\r" "\r"} $valeur]
                }
            }
        }
    }
}

proc phgt::_gettraduction {} {
    variable traduction
    
    return $traduction
}

proc phgt::_chaine {curseur contenu} {
    set curseur [string first "\"" $contenu [expr $curseur + 1]]
    set debut_chaine $curseur
    set chaine_ouverte 1
    
    while {[string range $contenu [expr [string first "\"" $contenu [expr $curseur + 1]] - 1] [expr [string first "\"" $contenu [expr $curseur + 1]] - 1]] == "\\"} {
        set curseur [string first "\"" $contenu [expr $curseur + 1]]
    }
    
    set fin_chaine [string first "\"" $contenu [expr $curseur + 1]]
    set chaine [string range $contenu [expr $debut_chaine + 1] [expr $fin_chaine - 1]]
    
    return [list $fin_chaine $chaine]
}

proc phgt::mc {clef {variables ""}} {
    # Si aucune clef ne correspond à celle spécifiée, on prend la clef passée en paramètre comme valeur
    if {[lsearch [dict keys $phgt::traduction] $clef] >= 0} {
        set valeur [dict get $phgt::traduction $clef]
    } else {
        set valeur $clef
    }
    
    if {[llength $variables] > 0} {
        # Remplace tous les %s par les variables de la liste
        foreach var $variables {
            set pos [string first "\%s" $valeur]
            set debut [string range $valeur 0 [expr $pos - 1]]
            set fin [string range $valeur [expr $pos + 2] [expr [string length $valeur] - 1]]
            set valeur "$debut$var$fin"
        }
    }
    
    # Renvoie, si tout s'est bien passé, la valeur correspondant à la clef dans le dictionnaire de traduction, ayant tous les %s remplacés par les variables de la liste
    return $valeur
}

package provide phgettext 0.0.3
