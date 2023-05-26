## Créé le 5/5/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################






##
# Met à jour l'affichage graphique des attributs de l'objet dans la fenêtre d'édition
##
proc Katyusha_MCD_INTERFACE_Objets_MAJ_attributs {f entite} {
    global IMG
    global LOCALE
    
    set attributs [dict get $entite "attributs"]
    foreach {id_attribut_graphique attribut} $attributs {
        #set nom_attribut_graphique [dict get $attribut "nom"]
        ttk::frame $f.$id_attribut_graphique
            ttk::label $f.$id_attribut_graphique.nom -text [dict get $attribut "nom"] -width 20 -background white -relief solid
            ttk::label $f.$id_attribut_graphique.type -text [dict get $attribut "type"] -width 20 -background white -relief solid
            ttk::label $f.$id_attribut_graphique.taille -text [dict get $attribut "taille"] -width 20 -background white -relief solid
            ttk::label $f.$id_attribut_graphique.valeur -text [dict get $attribut "valeur"] -width 20 -background white -relief solid
            ttk::label $f.$id_attribut_graphique.auto -text [dict get $attribut "auto"] -width 20 -background white -relief solid
            ttk::label $f.$id_attribut_graphique.pk -text [dict get $attribut "pk"] -width 20 -background white -relief solid
            ttk::button $f.$id_attribut_graphique.haut -text "Remonter" -image $IMG(fleche_haut) -command "Katyusha_MCD_Objets_deplacer_attribut $id_attribut_graphique [expr $id_attribut_graphique - 1]"
            ttk::button $f.$id_attribut_graphique.bas -text "Descendre" -image $IMG(fleche_bas) -command "Katyusha_MCD_Objets_deplacer_attribut $id_attribut_graphique [expr $id_attribut_graphique - 1]"
            ttk::button $f.$id_attribut_graphique.edit -text "Éditer" -image $IMG(editer) -command "INTERFACE_ajout_attribut table $id_attribut_graphique"
            pack $f.$id_attribut_graphique.nom $f.$id_attribut_graphique.type $f.$id_attribut_graphique.taille $f.$id_attribut_graphique.valeur $f.$id_attribut_graphique.auto $f.$id_attribut_graphique.pk $f.$id_attribut_graphique.haut $f.$id_attribut_graphique.bas $f.$id_attribut_graphique.edit -side left
        pack $f.$id_attribut_graphique -fill x
                        }
    # Mise à jour forcée de l'affichage graphique
    update
}

proc 

##
# Fenêtre d'ajout d'un attribut à une entité ou une association
# Si l'ID d'un attribut est passé en paramètre, il s'agira alors de l'éditer
##
proc Katyusha_MCD_INTERFACE_Objets_ajout_attribut {entite {id "null"}} {
    global table_tmp
    global relation_tmp
    global LOCALE
    global IMG
    global E_valeur_attribut
    global E_nom_attribut
    global E_type_attribut
    global E_ctype_attribut
    global E_null_attribut
    global E_description_attribut
    global E_auto_attribut
    
    set f ".fen_ajout_attribut"
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    # Si l'attribut est en édition
    if {$id != "null"} {
        if {$entite == "table"} {
            set attributs [dict get $table_tmp "attributs"]
        } elseif {$entite == "relation"} {
            set attributs [dict get $relation_tmp "attributs"]
        }
    }
    

    
    # Valeurs par défaut de l'attribut
    if {$id == "null"} {
        set E_valeur_attribut "null"
        set E_auto_attribut 0
        set E_null_attribut 1
        set E_pk_attribut 0
        set E_type_attribut ""
        set E_ctype_attribut ""
        set E_description_attribut ""
        if {$entite == "table"} {
            set E_nom_attribut "Attribut_[expr [llength [dict get $table_tmp attributs]]]"
        } elseif {$entite == "relation"} {
            set E_nom_attribut "Attribut_[expr [llength [dict get $relation_tmp attributs]]]"
        }
    } else {
        # Charge les données de l'attribut en édition
        set attribut [dict get $attributs $id]
        set E_nom_attribut "[dict get $attribut nom]"
        set E_type_attribut "[dict get $attribut type]"
        set E_ctype_attribut "[dict get $attribut complement_type]"
        set E_taille_attribut "[dict get $attribut taille]"
        set E_valeur_attribut "[dict get $attribut valeur]"
        set E_null_attribut "[dict get $attribut null]"
        set E_auto_attribut "[dict get $attribut auto]"
        set E_pk_attribut "[dict get $attribut pk]"
        set E_description_attribut ""
    }
    
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Frame de titre
    ttk::frame $f.nom
        ttk::label $f.nom.l -text $LOCALE(prop_attribut)
        pack $f.nom.l -fill x
    pack $f.nom -fill x -pady 10 -padx 50
    
    # Propriétés de l'attribut
    ttk::frame $f.prop
        # Nom de l'attribut
        ttk::frame $f.prop.nom
            ttk::label $f.prop.nom.l -text $LOCALE(nom_attribut) -width 40 -anchor w
            ttk::entry $f.prop.nom.e -textvariable E_nom_attribut
            pack $f.prop.nom.l $f.prop.nom.e -side left -fill x
        pack $f.prop.nom -fill x
        # Type de l'attribut
        ttk::frame $f.prop.type
            ttk::label $f.prop.type.l -text $LOCALE(type_attribut) -width 40 -anchor w
            ttk::combobox $f.prop.type.cb -values [Katyusha_SQL_liste_types]
            pack $f.prop.type.l $f.prop.type.cb -side left -fill x
            if {$id != "null"} {
                $f.prop.type.cb set $E_type_attribut
            }
        pack $f.prop.type -fill x
        # Complément du type de l'attribut
        ttk::frame $f.prop.ctype
            ttk::label $f.prop.ctype.l -text $LOCALE(ctype_attribut) -width 40 -anchor w
            ttk::entry $f.prop.ctype.e -textvariable $E_ctype_attribut
            pack $f.prop.ctype.l $f.prop.ctype.e -side left -fill x
        pack $f.prop.ctype -fill x
        # Taille de l'attribut (0 pour la valeur par défaut du SGBD)
        ttk::frame $f.prop.taille
            ttk::label $f.prop.taille.l -text $LOCALE(taille_attribut) -width 40 -anchor w
            ttk::spinbox $f.prop.taille.sb -from 0 -to 255 -increment 1
            pack $f.prop.taille.l $f.prop.taille.sb -side left -fill x
        pack $f.prop.taille -fill x
        ttk::label $f.prop.info_taille -text $LOCALE(taille_info_attribut) -foreground red -anchor w -justify left
        pack $f.prop.info_taille -fill x
        # Null?
        ttk::frame $f.prop.null
            ttk::label $f.prop.null.l -text $LOCALE(null_attribut) -width 40 -anchor w
            ttk::checkbutton $f.prop.null.cb -onvalue 1 -offvalue 0 -variable E_null_attribut
            pack $f.prop.null.l $f.prop.null.cb -side left -fill x
        pack $f.prop.null -fill x
        # Valeur par défaut
        ttk::frame $f.prop.valeur
            ttk::label $f.prop.valeur.l -text $LOCALE(valeur_attribut) -width 40 -anchor w
            ttk::entry $f.prop.valeur.e -textvariable E_valeur_attribut
            pack $f.prop.valeur.l $f.prop.valeur.e -side left -fill x
        pack $f.prop.valeur -fill x
        # Incrémentation automatique?
        ttk::frame $f.prop.auto
            ttk::label $f.prop.auto.l -text $LOCALE(auto_attribut) -width 40 -anchor w
            ttk::checkbutton $f.prop.auto.cb -onvalue 1 -offvalue 0 -variable E_auto_attribut
            pack $f.prop.auto.l $f.prop.auto.cb -side left -fill x
        pack $f.prop.auto -fill x
        # Si l'attribut est en incrémentation utomatique, il ne peut pas être null
        bind $f.prop.auto.cb <Button-1> {
            global E_auto_attribut
            global E_null_attribut
            global E_valeur_attribut
            
            set f ".fen_ajout_attribut"
            
            if {$E_auto_attribut == 0} {
                set E_null_attribut 0
                $f.prop.null.cb configure -state disabled
                set E_valeur_attribut ""
                $f.prop.valeur.e configure -state disabled
                $f.prop.type.cb set "integer"
            } else {
                set E_null_attribut 1
                $f.prop.null.cb configure -state normal
                set E_valeur_attribut "null"
                $f.prop.valeur.e configure -state normal
            }
        }
        # Clef primaire?
        frame $f.prop.pk
            label $f.prop.pk.l -text $LOCALE(pk_attribut) -width 40 -anchor w
            checkbutton $f.prop.pk.cb -onvalue 1 -offvalue 0 -variable E_pk_attribut
            pack $f.prop.pk.l $f.prop.pk.cb -side left -fill x
        pack $f.prop.pk -fill x
    pack $f.prop -fill x -padx 20
    
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command "INTERFACE_COMMANDE_ajout_attribut $entite $id"
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command "destroy $f"
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    
    # Titre le la présente fenêtre
    wm title $f $LOCALE(ajouter_attribut)
    update
}

proc INTERFACE_COMMANDE_ajout_attribut {entite {id "null"}} {
    global E_auto_attribut
    global E_pk_attribut
    global E_null_attribut
    global E_description_attribut
    
    set f ".fen_ajout_attribut"
    
    if {$entite == "table"} {
        set ok [Katyusha_Tables_controle_attribut [$f.prop.nom.e get] [$f.prop.type.cb get] [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_description_attribut]
        if {$ok == 1} {
            if {$id == "null"} {
                Katyusha_Tables_ajout_attribut [$f.prop.nom.e get] [$f.prop.type.cb get] [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_description_attribut
            } else {
                Katyusha_Tables_modification_attribut $id [$f.prop.nom.e get] [$f.prop.type.cb get] [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_description_attribut
            }
            destroy $f
        }
    } elseif {$entite == "relation"} {
        set ok [Katyusha_Tables_controle_attribut [$f.prop.nom.e get] [$f.prop.type.cb get] [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_description_attribut]
        if {$ok == 1} {
            if {$id == "null"} {
                Katyusha_Relations_ajout_attribut [$f.prop.nom.e get] [$f.prop.type.cb get] [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_description_attribut
            } else {
                Katyusha_Relations_modification_attribut $id [$f.prop.nom.e get] [$f.prop.type.cb get] [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_description_attribut
            }
            destroy $f
        }
    }
    
    unset E_auto_attribut
    unset E_null_attribut
    unset E_pk_attribut
}

##
# Fenêtre de choix d'un attribut à supprimer pour le type d'entité passé en paramètre
##
proc INTERFACE_suppression_attribut {entite} {
    global table_tmp
    global relation_tmp
    global LOCALE
    global IMG
    
    set f ".fen_supp_attribut"
    set defaut_valeur "null"
    set liste_attributs [list]
    
    if {$entite == "table"} {
        set attributs [dict get $table_tmp "attributs"]
    } elseif {$entite == "relation"} {
        set attributs [dict get $relation_tmp "attributs"]
    }
    
    # Construit la liste des attributs
    foreach {k attribut} $attributs {
        lappend liste_attributs "$k : $attribut"
    }
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Frame de titre
    frame $f.nom
        label $f.nom.l -text $LOCALE(supprimer_attribut_selection)
        pack $f.nom.l -fill x
    pack $f.nom -fill x -pady 10 -padx 50
    ttk::combobox $f.cb -value $liste_attributs -width 50
    pack $f.cb
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command "INTERFACE_COMMANDE_suppression_attribut $entite"
        button $f.commandes.ko -text $LOCALE(retour) -image $IMG(retour) -compound left -command {destroy .fen_supp_attribut}
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes
    
    # Titre le la présente fenêtre
    wm title $f $LOCALE(supprimer_attribut)
    update
}

proc INTERFACE_COMMANDE_suppression_attribut {entite} {
    global table_tmp
    global relation_tmp
    global LOCALE
    
    set f ".fen_supp_attribut"
    # Récupère la valeur de la listbox de choix de l'attribut à supprimer
    set attribut_dict [$f.cb get]
    
    # Si l'attribut n'est pas vide, on considère pour le moment qu'il existe bien dans la liste
    # liste des attributs de l'entité
    # TODO : contrôler la validité de l'attribut à supprimer
    if {$attribut_dict != ""} {
        set id_attribut [lindex [split $attribut_dict " : "] 0]

        if {$entite == "table"} {
            set attributs [dict get $table_tmp "attributs"]
            set table_tmp [Katyusha_Tables_suppression_attribut_table $table_tmp $id_attribut]
        } elseif {$entite == "relation"} {
            set attributs [dict get $relation_tmp "attributs"]
            set relation_tmp [Katyusha_Relations_suppression_attribut_relation $relation_tmp $id_attribut]
        }
        
        # Destruction de l'affichage de l'attribut supprimmé
        destroy .fen_ajout_$entite.attributs.corps.[lsearch $attributs $attribut_dict]
        # Destruction de la fenêtre de choix
        destroy $f
    } else {
        set ok [tk_messageBox -icon error -message $LOCALE(aucun_attribut_selectionne) -type ok]
    }
    
    # Mise à jour de l'affichage graphique
    update
}

##
# Confirme pour supprimer l'objet sélectionné
##
proc INTERFACE_suppression_entite {type_entite id_entite} {
    global LOCALE
    
    set rep [tk_messageBox -message "$LOCALE(sure_supprimer_entite)$type_entite" -type "yesno"]
    if {$rep == "yes"} {
        if {$type_entite == "table"} {
            suppression_table $id_entite
        } elseif {$type_entite == "relation"} {
            suppression_relation $id_entite
        } elseif {$type_entite == "etiquette"} {
            Etiquettes_supression_etiquette $id_entite
        } elseif {$type_entite == "heritage"} {
            Heritages_supression_heritage $id_entite
        }
    }
}

##
# Affiche la liste de toutes les entités du MCD
# TODO : l'édition des coordonnées, corriger les bugs
##
proc INTERFACE_liste_entites {} {
    global relations
    global tables
    global IMG
    global LOCALE
    
    set f ".fen_liste_entites"
    
    set liste_tables [list]
    set liste_relations [list]
    

        foreach {k relation} $relations {
            set nom_relation [dict get $relation "nom"]
            lappend liste_relations "$k : $nom_relation"
        }
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Frame de choix du nom de la table
    frame $f.nom
        label $f.nom.l -text "Liste des entités du MCD"
        pack $f.nom.l
    pack $f.nom -pady 10 -padx 50
    ##
    # Liste des entités
    ##
    frame $f.liste
        # Tables
        frame $f.liste.tables
            label $f.liste.tables.l -text "Tables"
            listbox $f.liste.tables.lb -listvariable $liste_tables -height 20 -selectmode browse -yscrollcommand [list $f.liste.st set]
            frame $f.liste.tables.commandes
                button $f.liste.tables.commandes.ajout -text "+" -image $IMG(ajouter) -command "INTERFACE_ajout_table 100 100"
                button $f.liste.tables.commandes.supp -text "-" -image $IMG(supprimer) -command {
                    global tables
                    if {[dict size $tables] > 0} {
                        foreach {k table} $tables {
                            set nom_table [dict get $table "nom"]
                            lappend liste_tables "$k : $nom_table"
                        }
                        INTERFACE_COMMANDE_supprimer_entite "table" $liste_tables
                    }
                }
                button $f.liste.tables.commandes.edit -text "/" -image $IMG(editer) -command {
                    global tables
                    if {[dict size $tables] > 0} {
                        foreach {k table} $tables {
                            set nom_table [dict get $table "nom"]
                            lappend liste_tables "$k : $nom_table"
                        }
                        INTERFACE_COMMANDE_editer_entite "table" $liste_tables
                    }
                }
                pack $f.liste.tables.commandes.ajout $f.liste.tables.commandes.supp $f.liste.tables.commandes.edit -side left
            pack $f.liste.tables.l $f.liste.tables.lb $f.liste.tables.commandes -fill x
        scrollbar $f.liste.st -orient vertical -command [list $f.liste.tables.lb yview]
        foreach {k table} $tables {
            set nom_table [dict get $table "nom"]
            $f.liste.tables.lb insert end "$k : $nom_table"
        }
        # Relations
        frame $f.liste.relations
            label $f.liste.relations.l -text "Relations"
            listbox $f.liste.relations.lb -listvariable $liste_relations -height 20 -selectmode browse -yscrollcommand [list $f.liste.sr set]
            frame $f.liste.relations.commandes
                button $f.liste.relations.commandes.ajout -text "+" -image $IMG(ajouter) -command "INTERFACE_ajout_relation 100 100"
                button $f.liste.relations.commandes.supp -text "-" -image $IMG(supprimer) -command {
                    global relations
                    if {[dict size $relations] > 0} {
                        foreach {k relation} $relations {
                            set nom_relation [dict get $relation "nom"]
                            lappend liste_relations "$k : $nom_relation"
                        }
                        INTERFACE_COMMANDE_supprimer_entite "relation" $liste_relations
                    }
                }
                button $f.liste.relations.commandes.edit -text "/" -image $IMG(editer) -command {
                    global relations
                    if {[dict size $relations] > 0} {
                        foreach {k relation} $relations {
                            set nom_relation [dict get $relation "nom"]
                            lappend liste_relations "$k : $nom_relation"
                        }
                        INTERFACE_COMMANDE_editer_entite "relation" $liste_relations
                    }
                }
                pack $f.liste.relations.commandes.ajout $f.liste.relations.commandes.supp $f.liste.relations.commandes.edit -side left
            pack $f.liste.relations.l $f.liste.relations.lb $f.liste.relations.commandes -fill x
            pack $f.liste.relations.l $f.liste.relations.lb -fill x
        scrollbar $f.liste.sr -orient vertical -command [list $f.liste.relation.lb yview]
        foreach {k relation} $relations {
            set nom_relation [dict get $relation "nom"]
            $f.liste.relations.lb insert end "$k : $nom_relation"
        }
        pack $f.liste.tables $f.liste.st $f.liste.relations $f.liste.sr -side left -fill y -padx 10 -pady 10
    pack $f.liste
    frame $f.commandes
        button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command "destroy $f"
        pack $f.commandes.ok -fill x -padx 50 -pady 10
    pack $f.commandes
    
    # Titre le la présente fenêtre
    wm title $f "Liste des entités du MCD"
    update
}

proc INTERFACE_COMMANDE_supprimer_entite {type_entite liste} {
    global tables
    global relations
    
    set f ".fen_liste_entites"
    set entite [$f.liste.$type_entite\s.lb curselection]
    set id_entite [lindex [split [lindex $liste $entite] " : "] 0]
    puts $id_entite
    
    if {$type_entite == "table"} {
        suppression_table $id_entite
    } elseif {$type_entite == "relation"} {
        suppression_relation $id_entite
    }
    update
}

proc INTERFACE_COMMANDE_editer_entite {type_entite liste} {
    global tables
    global relations
    global etiquettes
    
    set f ".fen_liste_entites"
    set entite [$f.liste.$type_entite\s.lb curselection]
    set id_entite [lindex [split [lindex $liste $entite] " : "] 0]
    puts $entite
    
    if {$type_entite == "table"} {
        INTERFACE_ajout_table 0 0 $id_entite
    } elseif {$type_entite == "relation"} {
        INTERFACE_ajout_relation 0 0 $id_entite
    } elseif {$type_entite == "etiquette"} {
        INTERFACE_Etiquette_ajout 0 0 $id_entite
    }
    update
}
