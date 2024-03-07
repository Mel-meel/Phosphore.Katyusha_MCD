## Créé le 8/6/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Met à jour l'arbre des entités
##
proc Katyusha_MCD_Objets_maj_arbre_objets {} {
    global tables
    global relations
    global heritages
    global procedures
    global NOTEBOOK_MCD
    
    set foreground [Katyusha_Configurations_couleurs "-foreground"]
    
    set c "$NOTEBOOK_MCD.panel.arbre.c"
    set hauteur 20
    set x 20
    # Efface tout ce qui se trouve dans le canvas
    set entites [$c gettags "entite"]
    foreach e $entites {
        $c delete $e
    }
    # Affiche les tables
    $c create text [expr $x + 0] $hauteur -fill $foreground -justify left -text [phgt::mc "Entités"] -anchor w -tag "entite"
    set hauteur [expr $hauteur + 20]
    set x [expr $x + 20]
    foreach {id table} $tables {
        set nom [dict get $table "nom"]
        $c create text [expr $x + 0] $hauteur -fill $foreground -justify left -text "$id : $nom" -anchor w -tag "entite"
        set hauteur [expr $hauteur + 20]
    }
    # Saut de ligne
    set hauteur [expr $hauteur + 10]
    # Remet y à sa position initiale
    set x [expr $x - 20]
    # Affiche les relations
    $c create text [expr $x + 0] $hauteur -fill $foreground -justify left -text $[phgt::mc "Associations"] -anchor w -tag "entite"
    set hauteur [expr $hauteur + 20]
    set x [expr $x + 20]
    foreach {id relation} $relations {
        set nom [dict get $relation "nom"]
        #$c create rect [expr $x - 5] [expr $hauteur - 9] [expr (($x + (3.1 * [string length $nom])) * 1.5) + 5] [expr $hauteur + 9] -outline #F5F5F5 -fill #F5F5F5 -tag "entite"
        $c create text [expr $x + 0] $hauteur -fill $foreground -justify left -text "$id : $nom" -anchor w -tag "entite"
        set hauteur [expr $hauteur + 20]
    }
    # Saut de ligne
    set hauteur [expr $hauteur + 10]
    # Remet x à sa position initiale
    set x [expr $x - 20]
    # Affiche les héritages
    $c create text [expr $x + 0] $hauteur -fill $foreground -justify left -text [phgt::mc "Héritages"] -anchor w -tag "entite"
    set hauteur [expr $hauteur + 20]
    set x [expr $x + 20]
    foreach {id heritage} $heritages {
        set id_table [dict get $heritage "mere"]
        if {[dict exists $tables $id_table] == 1} {
            set nom_table [dict get [dict get $tables $id_table] "nom"]
        } else {
            set nom_table ""
        }
        #$c create rect [expr $x - 5] [expr $hauteur - 9] [expr (($x + (3.1 * [string length $nom])) * 1.5) + 5] [expr $hauteur + 9] -outline #F5F5F5 -fill #F5F5F5 -tag "entite"
        $c create text [expr $x + 0] $hauteur -fill $foreground -justify left -text "$id : Table mère '$nom_table'" -anchor w -tag "entite"
        set hauteur [expr $hauteur + 20]
    }
    # Saut de ligne
    set hauteur [expr $hauteur + 10]
    # Remet y à sa position initiale
    set x [expr $x - 20]
    $c configure -scrollregion [$c bbox all]
}

##
# Met à jour tout l'affichage graphique à partir des variables globales des tables, relations, héritages, ...
# TODO : tout
##
proc maj_canvas {} {

}


##
# Ajout d'un héritage entre plusieurs tables
# TODO : tout
##
proc ajout_heritage {x y} {
    global ID
    lappend graph [.mcd.canvas.c create polygon [list [expr $x - 40] [expr $y + 20] [expr $x + 40] [expr $y + 20] [expr $x - 0] [expr $y - 45]] -outline #FF7000 -fill #FFE3CD -tag [list heritage $ID]]
    set ID [expr $ID + 1]
    unset graph x y
    maj_arbre_entites
}

##
# Déplacement d'une entite
##
proc Katyusha_deplace_entite {type_entite x y tag} {
    global tables_graphique
    global relations_graphique
    global heritages_graphique
    
    set changed_x [expr $x - $atx]
    set changed_y [expr $y - $aty]
    if {$typ_entite == "table"} {
        for {set c 0} {$c < 4} {incr c} {
            .mcd.canvas.c move [lindex [dict get $tables_graphique $tag] $c] $changed_x $changed_y
        }
    }
    set atx $x
    set aty $y
    update
}

##
# Modifie l'attribut de l'entité passé en paramètre
# Si l'option graphique est à 1, l'affichage graphique sera modifié, 0 sinon
# Par défaut 1
##
proc Katyusha_Objets_modification_attribut {id_attribut nom type nsigne complement_type taille null valeur auto pk unique acces description objet {graphique 1}} {
    global relation_tmp
    global table_tmp
    
    if {$objet == "table"} {
        set attributs [dict get $table_tmp "attributs"]
    } elseif {$objet == "relation"} {
        set attributs [dict get $relation_tmp "attributs"]
    }
    
    dict set attribut "nom" $nom
    dict set attribut "type" $type
    dict set attribut "nsigne" $nsigne
    dict set attribut "complement_type" $complement_type
    dict set attribut "taille" $taille
    dict set attribut "null" $null
    dict set attribut "valeur" $valeur
    dict set attribut "auto" $auto
    dict set attribut "pk" $pk
    dict set attribut "unique" $unique
    dict set attribut "acces" $acces
    dict set attribut "description" ""
    
    # Modifie l'affichage graphique
    if {$graphique == 1} {
        set f ".fen_ajout_$objet"
        foreach element [list "nom" "type" "taille" "valeur" "auto" "pk"] {
            $f.attributs.c.f.corps.$id_attribut.$element configure -text [dict get $attribut $element]
        }
        
        update
    }
    
    dict set attributs $id_attribut $attribut
    
    if {$objet == "table"} {
        dict set table_tmp "attributs" $attributs
    } elseif {$objet == "relation"} {
        dict set relation_tmp "attributs" $attributs
    }
    
}

##
# Supprimme un attribut de l'entité passée en paramètre et la renvoie modifiée
##
proc Katyusha_Entites_suppression_attribut {entite id_attribut type_entite {graphique 1}} {
    set attributs [dict get $entite "attributs"]
    dict unset attributs $id_attribut
    dict set entite "attributs" $attributs
    
    if {$graphique == 1} {
        set f ".fen_ajout_$type_entite"
        destroy $f.attributs.c.f.corps.$id_attribut
    }
    
    return $entite
}

##
# Contrôle si une entité est correcte
##
proc Katyusha_Entites_controle_entite {entite} {
    global tables
    global relations
    
    set ok 1
    
    # Contrôle si le nom n'est pas déjà pris par une autre entité
    set nom [dict get $entite "nom"]
    
    # Cherche dans les tables
    foreach {k table} $tables {
        if {[dict get $table "nom"] == $nom} {
            set ok 0
        }
    }
    
    # Puis dans les relations
    foreach {k relation} $relations {
        if {[dict get $relation "nom"] == $nom} {
            set ok 0
        }
    }
    
    return $ok
}

##
# Créé un objet, soit une entité, soit une association depuis une classe UML
##
proc Katyusha_MCD_Objets_creer_objet_depuis_classe {id classe} {
    # Pour le moment, on créé uniquement des entités
    Katyusha_MCD_Entites_creer_entite_depuis_classe $id $classe
}


