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
proc Katyusha_MCD_INTERFACE_Objets_MAJ_attributs {f objet type_objet} {
    global IMG
    
    set attributs [dict get $objet "attributs"]
    
    # Couleurs
    set background [Katyusha_Configurations_couleurs "-frame"]
    
    foreach {id_attribut_graphique attribut} $attributs {
        if {[winfo exists $f.f.corps]} {
            destroy $f.f.corps.$id_attribut_graphique
        }
        #set nom_attribut_graphique [dict get $attribut "nom"]
        ttk::frame $f.f.corps.$id_attribut_graphique
            ttk::label $f.f.corps.$id_attribut_graphique.nom -text [dict get $attribut "nom"] -width 30 -background $background -relief solid
            ttk::label $f.f.corps.$id_attribut_graphique.type -text [dict get $attribut "type"] -width 15 -background $background -relief solid
            ttk::label $f.f.corps.$id_attribut_graphique.signe -text "true" -width 10 -background $background -relief solid
            ttk::label $f.f.corps.$id_attribut_graphique.taille -text [dict get $attribut "taille"] -width 10 -background $background -relief solid
            ttk::label $f.f.corps.$id_attribut_graphique.valeur -text [dict get $attribut "valeur"] -width 20 -background $background -relief solid
            ttk::label $f.f.corps.$id_attribut_graphique.auto -text [dict get $attribut "auto"] -width 15 -background $background -relief solid
            ttk::label $f.f.corps.$id_attribut_graphique.pk -text [dict get $attribut "pk"] -width 10 -background $background -relief solid
            ttk::label $f.f.corps.$id_attribut_graphique.unique -text "" -width 10 -background $background -relief solid
            
            ttk::button $f.f.corps.$id_attribut_graphique.haut -text "Remonter" -width 6 -image $IMG(fleche_haut) -command "Katyusha_MCD_INTERFACE_Objets_deplacer_attribut $f $type_objet $id_attribut_graphique [expr $id_attribut_graphique - 1]"
            ttk::button $f.f.corps.$id_attribut_graphique.bas -text "Descendre" -width 6 -image $IMG(fleche_bas) -command "Katyusha_MCD_INTERFACE_Objets_deplacer_attribut $f $type_objet $id_attribut_graphique [expr $id_attribut_graphique + 1]"
            ttk::button $f.f.corps.$id_attribut_graphique.edit -text "Éditer" -width 5 -image $IMG(editer) -command "Katyusha_MCD_INTERFACE_Objets_ajout_attribut table $id_attribut_graphique"
            pack $f.f.corps.$id_attribut_graphique.nom $f.f.corps.$id_attribut_graphique.type $f.f.corps.$id_attribut_graphique.taille $f.f.corps.$id_attribut_graphique.signe $f.f.corps.$id_attribut_graphique.valeur $f.f.corps.$id_attribut_graphique.auto $f.f.corps.$id_attribut_graphique.pk $f.f.corps.$id_attribut_graphique.unique $f.f.corps.$id_attribut_graphique.haut $f.f.corps.$id_attribut_graphique.bas $f.f.corps.$id_attribut_graphique.edit -fill y -expand 1 -side left
        pack $f.f.corps.$id_attribut_graphique -fill x
    }
    
    $f configure -scrollregion [$f bbox all]
    
    # Mise à jour forcée de l'affichage graphique
    update
}

proc Katyusha_MCD_INTERFACE_Objets_deplacer_attribut {f type_objet id_ancien id_nouveau} {
    global table_tmp
    global relation_tmp
    
    if {$type_objet == "entite"} {
        set table_tmp [Katyusha_MCD_Objets_deplacer_attribut $table_tmp $id_ancien $id_nouveau]
        Katyusha_MCD_INTERFACE_Objets_MAJ_attributs $f $table_tmp $type_objet
    } elseif {$type_objet == "association"} {
        set relation_tmp [Katyusha_MCD_Objets_deplacer_attribut $relation_tmp $id_ancien $id_nouveau]
        Katyusha_MCD_INTERFACE_Objets_MAJ_attributs $f $relation_tmp $type_objet
    }
}

##
# Fenêtre de choix d'un attribut à supprimer pour le type d'objet passé en paramètre
##
proc Katyusha_MCD_INTERFACE_Objets_suppression_attribut {entite} {
    global table_tmp
    global relation_tmp
    global IMG
    
    set lbackground [Katyusha_Configurations_couleurs "-lbackground"]
    
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
    ttk::frame $f.nom
        ttk::label $f.nom.l -text [phgt::mc "Sélectionner un attribut à supprimer"]
        pack $f.nom.l -fill x
    pack $f.nom -fill x -pady 10 -padx 50
    ttk::combobox $f.cb -value $liste_attributs -width 50
    pack $f.cb
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command "Katyusha_MCD_INTERFACE_COMMANDE_Objets_suppression_attribut $entite"
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command {destroy .fen_supp_attribut}
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes
    
    # Titre le la présente fenêtre
    wm title $f [phgt::mc "Supprimer un attribut"]
    
    # Couleur de fond de la fenêtre
    $f configure -background $lbackground
    
    update
}

proc Katyusha_MCD_INTERFACE_COMMANDE_Objets_suppression_attribut {entite} {
    global table_tmp
    global relation_tmp
    
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
        set ok [tk_messageBox -icon error -message [phgt::mc "Aucun attribut n'a été sélectionné"] -type ok]
    }
    
    # Mise à jour de l'affichage graphique
    update
}

##
# Confirme pour supprimer l'objet sélectionné
##
proc Katyusha_MCD_INTERFACE_Objets_suppression_objet {type_entite id_entite} {
    set rep [tk_messageBox -message [phgt::mc "Sure?"] -type "yesno"]
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
# Affiche la liste de tous les objets du MCD
# TODO : l'édition des coordonnées, corriger les bugs et grosse mise à jour nécessaire
##
proc INTERFACE_liste_objets {} {
    global relations
    global tables
    global IMG
    global LOCALE
    
    set f ".fen_liste_entites"
    
    set lbackground [Katyusha_Configurations_couleurs "-lbackground"]
    
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
    ttk::frame $f.nom
        ttk::label $f.nom.l -text "Liste des entités du MCD"
        pack $f.nom.l
    pack $f.nom -pady 10 -padx 50
    ##
    # Liste des entités
    ##
    ttk::frame $f.liste
        # Entités
        ttk::frame $f.liste.tables
            ttk::label $f.liste.tables.l -text [phgt::mc "Entités"]
            ttk::listbox $f.liste.tables.lb -listvariable $liste_tables -height 20 -selectmode browse -yscrollcommand [list $f.liste.st set]
            ttk::frame $f.liste.tables.commandes
                ttk::button $f.liste.tables.commandes.ajout -text "+" -image $IMG(ajouter) -command "INTERFACE_ajout_table 100 100"
                ttk::button $f.liste.tables.commandes.supp -text "-" -image $IMG(supprimer) -command {
                    global tables
                    if {[dict size $tables] > 0} {
                        foreach {k table} $tables {
                            set nom_table [dict get $table "nom"]
                            lappend liste_tables "$k : $nom_table"
                        }
                        INTERFACE_COMMANDE_supprimer_entite "table" $liste_tables
                    }
                }
                ttk::button $f.liste.tables.commandes.edit -text "/" -image $IMG(editer) -command {
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
        ttk::scrollbar $f.liste.st -orient vertical -command [list $f.liste.tables.lb yview]
        foreach {k table} $tables {
            set nom_table [dict get $table "nom"]
            $f.liste.tables.lb insert end "$k : $nom_table"
        }
        # Associations
        ttk::frame $f.liste.relations
            ttk::label $f.liste.relations.l -text "Relations"
            ttk::listbox $f.liste.relations.lb -listvariable $liste_relations -height 20 -selectmode browse -yscrollcommand [list $f.liste.sr set]
            ttk::frame $f.liste.relations.commandes
                ttk::button $f.liste.relations.commandes.ajout -text "+" -image $IMG(ajouter) -command "INTERFACE_ajout_relation 100 100"
                ttk::button $f.liste.relations.commandes.supp -text "-" -image $IMG(supprimer) -command {
                    global relations
                    if {[dict size $relations] > 0} {
                        foreach {k relation} $relations {
                            set nom_relation [dict get $relation "nom"]
                            lappend liste_relations "$k : $nom_relation"
                        }
                        INTERFACE_COMMANDE_supprimer_entite "relation" $liste_relations
                    }
                }
                ttk::button $f.liste.relations.commandes.edit -text "/" -image $IMG(editer) -command {
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
        ttk::scrollbar $f.liste.sr -orient vertical -command [list $f.liste.relation.lb yview]
        foreach {k relation} $relations {
            set nom_relation [dict get $relation "nom"]
            $f.liste.relations.lb insert end "$k : $nom_relation"
        }
        pack $f.liste.tables $f.liste.st $f.liste.relations $f.liste.sr -side left -fill y -padx 10 -pady 10
    pack $f.liste
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text $LOCALE(valider) -image $IMG(valider) -compound left -command "destroy $f"
        pack $f.commandes.ok -fill x -padx 50 -pady 10
    pack $f.commandes
    
    # Titre le la présente fenêtre
    wm title $f "Liste des entités du MCD"
    
    # Couleur de fond de la fenêtre
    $f configure -background $lbackground
    
    update
}

proc Katyusha_MCD_INTERFACE_COMMANDE_supprimer_objet {type_entite liste} {
    global tables
    global relations
    
    set f ".fen_liste_entites"
    set entite [$f.liste.$type_entite\s.lb curselection]
    set id_entite [lindex [split [lindex $liste $entite] " : "] 0]
    
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
    
    if {$type_entite == "table"} {
        Katyusha_MCD_INTERFACE_Entite_ajout_entite 0 0 $id_entite
    } elseif {$type_entite == "relation"} {
        Katyusha_MCD_INTERFACE_Association_ajout_association 0 0 $id_entite
    } elseif {$type_entite == "etiquette"} {
        INTERFACE_Etiquette_ajout 0 0 $id_entite
    }
    update
}
