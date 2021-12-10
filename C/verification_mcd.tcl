## Créé le 21/6/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Vérifie les relations
# Renvoie 0 si il y a une ou plusieurs erreur(s)
# Sinon, 1
##
proc Katyusha_verification_mcd_relations {relations} {
    set ok 1
    set errs [list]
    
    # Parcours les relations à la recherche d'une erreur
    foreach {k relation} $relations {
        set C_relation [Katyusha_verification_mcd_relation $relation]
        set errs [concat $errs [lindex $C_relation 1]]
        if {[lindex $C_relation 0] == 0} {
            set ok 0
        }
    }
    return [list $ok $errs]
}

proc Katyusha_verification_mcd_relation {relation} {
    global LOCALE
    
    set ok 1
    set errs [list]
    # Vérifie que la relation possède au moins 2 liens
    set nliens [dict size [dict get $relation "liens"]]
    if {$nliens < 2} {
        set ok 0
        lappend errs "$LOCALE(relation_min_2_liens_1)\"[dict get $relation nom]\"$LOCALE(relation_min_2_liens_2)"
    }
    
    return [list $ok $errs]
}

##
# Vérifie les tables
# Renvoie 0 si il y a une ou plusieurs erreur(s)
# Sinon, 1
##
proc Katyusha_verification_mcd_tables {tables} {
    set ok 1
    set errs [list]
    
    # Parcours les tables à la recherche d'une erreur
    foreach {k table} $tables {
        set C_table [Katyusha_verification_mcd_table $table]
        set errs [concat $errs [lindex $C_table 1]]
        if {[lindex $C_table 0] == 0} {
            set ok 0
        }
    }
    return [list $ok $errs]
}

proc Katyusha_verification_mcd_table {table} {
    set ok 1
    set errs [list]
    # Vérifie que la table possède au moins un attribut
    #set nattributs [dict size [dict get $table "attributs"]]
    #if {$nattributs < 1} {
    #    set ok 0
    #    lappend errs "La table \"[dict get $table nom]\" ne possède aucun attribut."
    #}
    
    return [list $ok $errs]
}

##
# Vérifie les héritages
# Renvoie 0 si il y a une ou plusieurs erreur(s)
# Sinon, 1
##
proc Katyusha_Verification_MCD_heritages {heritages} {
    set ok 1
    set errs [list]
    
    # Parcours les tables à la recherche d'une erreur
    foreach {k heritage} $heritages {
        set C_heritage [Katyusha_Verification_MCD_heritage $k $heritage]
        set errs [concat $errs [lindex $C_heritage 1]]
        if {[lindex $C_heritage 0] == 0} {
            set ok 0
        }
    }
    return [list $ok $errs]
}

proc Katyusha_Verification_MCD_heritage {id heritage} {
    global LOCALE
    
    set ok 1
    set errs [list]
    # Vérifie que la table mère ne sois pas aussi une table fille
    set mere [dict get $heritage "mere"]
    foreach {k fille} [dict get $heritage "filles"] {
        if {$fille == $mere} {
            set ok 0
            lappend errs "$LOCALE(entite_mere_est_aussi_fille_1)\"$k\"$LOCALE(entite_mere_est_aussi_fille_2)"
        }
    }
    
    return [list $ok $errs]
}

##
# Vérifie les noms de toutes les entités, aucun ne doit être en double
##
proc Katyusha_Verification_MCD_noms_entites {tables relations} {
    global LOCALE
    
    set ok 1
    set errs [list]
    
    # Servira à enregistrer tous les noms des entites
    set noms [list]
    # Balayage des noms des tables
    foreach {k table} $tables {
        set nom [dict get $table "nom"]
        lappend noms $nom
    }
    # Balayage des noms des relations
    foreach {k relation} $relations {
        set nom [dict get $relation "nom"]
        lappend noms $nom
    }
    # Balayages de la liste des noms à la recherche de doublons
    foreach nom $noms {
        set c [llength [lsearch -all $noms $nom]]
        if {$c >= 2} {
            set ok 0
            lappend errs "$LOCALE(plusieurs_entites_nom)\"$nom\"."
        }
    }
    
    return [list $ok $errs]
}

##
# Fonction principale de la vérification de l'intégrité et de la cohérence du MCD
##
proc Katyusha_verification_mcd {} {
    global tables
    global relations
    global heritages
    
    set ok 1
    set errs [list]
    
    set C_noms_entites [Katyusha_Verification_MCD_noms_entites $tables $relations]
    set errs [concat $errs [lindex $C_noms_entites 1]]
    set C_tables [Katyusha_verification_mcd_tables $tables]
    set errs [concat $errs [lindex $C_tables 1]]
    set C_relations [Katyusha_verification_mcd_relations $relations]
    set errs [concat $errs [lindex $C_relations 1]]
    set C_heritages [Katyusha_Verification_MCD_heritages $heritages]
    set errs [concat $errs [lindex $C_heritages 1]]
    
    if {[lindex $C_tables 0] == 0 || [lindex $C_relations 0] == 0 || [lindex $C_noms_entites 0] == 0 || [lindex $C_heritages 0] == 0} {
        set ok 0
    }
    puts $errs
    return [list $ok $errs]
}
