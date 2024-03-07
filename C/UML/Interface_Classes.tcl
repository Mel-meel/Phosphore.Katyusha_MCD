## Créé le 8/7/2020 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Si aucune classe n'est spécifiée en argument, il s'agira d'un ajout de classe.
# Si une classe est passée en argument, il s'agira alors de l'éditer.
# Pour un ajout, spécifier uniquement les coordonnées.
# Pour une édition, indiquer en coordonnées 0:0 et passer son id
##
proc Katyusha_UML_Interface_Classes_ajout_classe {x y {id "null"}} {
    global coords
    global IMG
    global classes
    global classe_tmp
    global id_attribut_graphique
    global E_nom_classe
    
    set lbackground [Katyusha_Configurations_couleurs "-lbackground"]
    
    set f ".fen_ajout_classe"
    
    # Initialise la table temporaire
    if {$id == "null"} {
        # Transfert des coordonnées
        set coords [list $x $y]
        set classe_tmp [Katyusha_UML_Classes_init_classe]
        dict set classe_tmp "coords" $coords
        set E_nom_classe [phgt::mc "Classe_%s" [list [expr [dict size $classes] + 1]]]
    } else {
        set classe [dict get $classes $id]
        set classe_tmp $classe
        set E_nom_classe [dict get $classe "nom"]
    }
    dict set classe_tmp "id" $id
    set id_attribut_graphique 0
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Frame de choix du nom de la table
    ttk::frame $f.nom
        ttk::label $f.nom.l -text [phgt::mc "Nom de la classe : "]
        ttk::entry $f.nom.e -textvariable E_nom_classe
        pack $f.nom.l $f.nom.e -side left
    pack $f.nom -pady 10 -padx 50
# TODO

    ttk::notebook $f.corps
        $f.corps add [Katyusha_UML_Interface_Classes_notebook_attributs "$f.corps" $id] -text [phgt::mc "Attributs"]
        $f.corps add [Katyusha_UML_Interface_Classes_notebook_methodes "$f.corps" $id] -text [phgt::mc "Méthodes"]
    pack $f.corps
    
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command "Katyusha_UML_Interface_Classes_ajout_classe_commande $id"
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command {
            if {[winfo exists .fen_ajout_attribut]} {
                destroy .fen_ajout_attribut
            }
            destroy .fen_ajout_classe
        }
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    
    # Titre le la présente fenêtre
    if {$id == "null"} {
        wm title $f [phgt::mc "Ajouter une classe"]
    } else {
        wm title $f [phgt::mc "Éditer la classe : %s" [list $E_nom_classe]]
    }
    
    # Couleur de fond de la fenêtre
    $f configure -background $lbackground
    
    # Mise à jour forcée de l'affichage graphique
    update
}

proc Katyusha_UML_Interface_Classes_notebook_attributs {f id} {
    global IMG
    
    set background [Katyusha_Configurations_couleurs "-frame"]
    
    ##
    # Attributs de la classe
    ##
    ttk::frame $f.attributs
        # Commandes des attributs
        ttk::frame $f.attributs.commandes
            # Bouton d'ajout d'un nouvel attribut
            ttk::button $f.attributs.commandes.ajout -text "+" -image $IMG(ajouter) -command {Katyusha_Interface_Objets_MCD_UML_ajout_attribut "classe" "null" "uml"}
            # Bouton de supression d'un nouvel attribut
            ttk::button $f.attributs.commandes.supp -text "-" -image $IMG(supprimer) -command {Katyusha_UML_Interface_Objets_suppression_attribut "classe"}
            pack $f.attributs.commandes.ajout $f.attributs.commandes.supp -padx 10
        pack $f.attributs.commandes -side left -fill x
        
        ttk::frame $f.attributs.table_tete
            ttk::frame $f.attributs.table_tete.f
                ttk::label $f.attributs.table_tete.f.titre -text [phgt::mc "Liste des attributs de la classe"]
                pack $f.attributs.table_tete.f.titre -fill both -anchor center -padx 10 -pady 10 -expand 1
                ttk::frame $f.attributs.table_tete.f.tete
                    ttk::label $f.attributs.table_tete.f.tete.nom -text [phgt::mc "Nom"] -width 30 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.type -text [phgt::mc "Type"] -width 15 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.accces -text [phgt::mc "Accès"] -width 10 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.taille -text [phgt::mc "Taille"] -width 10 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.valeur -text [phgt::mc "Valeur\npar défaut"] -width 20 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.id -text [phgt::mc "Identifiant?"] -width 10 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.m -text "" -width 6 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.d -text "" -width 6 -background $background -relief solid
                    ttk::label $f.attributs.table_tete.f.tete.e -text "" -width 5 -background $background -relief solid
                    
                    pack $f.attributs.table_tete.f.tete.nom $f.attributs.table_tete.f.tete.type $f.attributs.table_tete.f.tete.accces $f.attributs.table_tete.f.tete.taille $f.attributs.table_tete.f.tete.valeur $f.attributs.table_tete.f.tete.id $f.attributs.table_tete.f.tete.m $f.attributs.table_tete.f.tete.d $f.attributs.table_tete.f.tete.e -fill both -expand 1 -side left
                pack $f.attributs.table_tete.f.tete -fill both -anchor w -expand 1
            pack $f.attributs.table_tete.f -fill both -anchor w -expand 1
        pack $f.attributs.table_tete -anchor w -expand 1
        
        # Attributs dans un canvas pour pouvoir utiliser une scrollbar
        canvas $f.attributs.c -background [dict get $STYLES "lbackground"] -highlightbackground [dict get $STYLES "graphics"]
        ttk::frame $f.attributs.c.f
            # Liste des attributs
            ttk::frame $f.attributs.c.f.liste

                ttk::frame $f.attributs.c.f.corps
                
                pack $f.attributs.c.f.corps -fill x
                    ##
                    # Ici viennent s'insérer les attributs
                    ##
                    # Si la classe est en édition, on affiche la liste des attributs déjà existants
                    if {$id != "null"} {
                        Katyusha_UML_Interface_Objets_MAJ_attributs $f.attributs.c $classe_tmp "classe"
                    }
            pack $f.attributs.c.f.liste -side left -fill x
        pack $f.attributs.c -side left -expand 1 -fill both
        $f.attributs.c create window 0 0 -anchor nw -window $f.attributs.c.f
        ttk::scrollbar $f.attributs.yscroll -command "$f.attributs.c yview"
        pack $f.attributs.yscroll -side right -fill y
        $f.attributs.c configure -scrollregion "0 0 1000 10000"
    pack $f.attributs -fill x -padx 10
    
    # Ajout de la commande de scroll du canvas des attributs ici, sinon erreur mais fonctionne.
    # À voir pour faire fonctionner correctement plus tard
    $f.attributs.c configure -yscrollcommand "$f.attributs.yscroll set"
    
    return $f.attributs
}

proc Katyusha_UML_Interface_Classes_notebook_methodes {f id} {
    global IMG
    
    set background [Katyusha_Configurations_couleurs "-frame"]
    
    ###
    # Méthodes de la classe
    ##
    ttk::frame $f.methodes
        # Commandes des attributs
        ttk::frame $f.methodes.commandes
            # Bouton d'ajout d'un nouvel attribut
            ttk::button $f.methodes.commandes.ajout -text "+" -image $IMG(ajouter) -command {Katyusha_UML_Interface_Objets_ajout_methode "classe"}
            # Bouton de supression d'un nouvel attribut
            ttk::button $f.methodes.commandes.supp -text "-" -image $IMG(supprimer) -command {Katyusha_UML_Interface_Objets_suppression_methode "classe"}
            pack $f.methodes.commandes.ajout $f.methodes.commandes.supp -padx 10
        pack $f.methodes.commandes -side left -fill x
        
        ttk::frame $f.methodes.table_tete
            ttk::frame $f.methodes.table_tete.f
                ttk::label $f.methodes.table_tete.f.titre -text [phgt::mc "Liste des méthodes de la classe"]
                pack $f.methodes.table_tete.f.titre -fill both -anchor center -padx 10 -pady 10 -expand 1
                ttk::frame $f.methodes.table_tete.f.tete
                    ttk::label $f.methodes.table_tete.f.tete.nom -text [phgt::mc "Nom"] -width 30 -background $background -relief solid
                    ttk::label $f.methodes.table_tete.f.tete.parametres -text [phgt::mc "Paramètres"] -width 30 -background $background -relief solid
                    ttk::label $f.methodes.table_tete.f.tete.type -text [phgt::mc "Type"] -width 10 -background $background -relief solid
                    ttk::label $f.methodes.table_tete.f.tete.acces -text [phgt::mc "Accès"] -width 10 -background $background -relief solid
                    ttk::label $f.methodes.table_tete.f.tete.m -text "" -width 6 -background $background -relief solid
                    ttk::label $f.methodes.table_tete.f.tete.d -text "" -width 6 -background $background -relief solid
                    ttk::label $f.methodes.table_tete.f.tete.e -text "" -width 5 -background $background -relief solid
                    
                    pack $f.methodes.table_tete.f.tete.nom $f.methodes.table_tete.f.tete.parametres $f.methodes.table_tete.f.tete.type $f.methodes.table_tete.f.tete.acces $f.methodes.table_tete.f.tete.m $f.methodes.table_tete.f.tete.d $f.methodes.table_tete.f.tete.e -fill both -expand 1 -side left
                pack $f.methodes.table_tete.f.tete -fill both -anchor w -expand 1
            pack $f.methodes.table_tete.f -fill both -anchor w -expand 1
        pack $f.methodes.table_tete -anchor w -expand 1
        
        # Attributs dans un canvas pour pouvoir utiliser une scrollbar
        canvas $f.methodes.c -background [dict get $STYLES "lbackground"] -highlightbackground [dict get $STYLES "graphics"]
        ttk::frame $f.methodes.c.f
            # Liste des attributs
            ttk::frame $f.methodes.c.f.liste
            
                ttk::frame $f.methodes.c.f.corps
                
                pack $f.methodes.c.f.corps -fill x
                    ##
                    # Ici viennent s'insérer les attributs
                    ##
                    # Si l'entité est en édition, on affiche la liste des attributs déjà existants
                    #if {$id != "null"} {
                    #    Katyusha_MCD_INTERFACE_Objets_MAJ_attributs $f.methodes.c.f.corps $table "entite"
                    #}
            pack $f.methodes.c.f.liste -side left -fill x
        pack $f.methodes.c -side left -expand 1 -fill both
        $f.methodes.c create window 0 0 -anchor nw -window $f.methodes.c.f
        ttk::scrollbar $f.methodes.yscroll -command "$f.methodes.c yview"
        pack $f.methodes.yscroll -side right -fill y
        $f.methodes.c configure -scrollregion "0 0 1000 10000"
    pack $f.methodes -fill x -padx 10
    
    # Ajout de la commande de scroll du canvas des attributs ici, sinon erreur mais fonctionne.
    # À voir pour faire fonctionner correctement plus tard
    $f.methodes.c configure -yscrollcommand "$f.methodes.yscroll set"
    
    return $f.methodes
}


##
# Action de la procédure Katyusha_UML_Interface_Classes_ajout_classe
##
proc Katyusha_UML_Interface_Classes_ajout_classe_commande {id} {
    global classe_tmp
    
    set f ".fen_ajout_classe"
    set id [dict get $classe_tmp "id"]
    dict set classe_tmp "nom" [$f.nom.e get]
    dict set classe_tmp "description" ""
    #set ok [Katyusha_Tables_controle_table $table_tmp]
    set ok 1
    if {$id == "null" && $ok == 1} {
        Katysha_UML_Classes_creer_classe $classe_tmp
        destroy $f
    } elseif {$id != "null" && $ok == 1} {
        Katysha_UML_Classes_modifier_classe $id $classe_tmp
        destroy $f
    }
}
