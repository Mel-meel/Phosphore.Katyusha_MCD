## Créé le 9/7/2023 ##

######################################################
#  ___         __    __  ___         __   ___  ____  #
#  |__| |  |  /  \  /    |__| |  |  /  \  |__| |     #
#  |    |--| |    | ---- |    |--| |    | |\   |--   #
#  |    |  |  \__/  ___/ |    |  |  \__/  | \  |___  #
#                                                    #
######################################################

##
# Fenêtre d'ajout d'un attribut à une entité ou une association
# Si l'ID d'un attribut est passé en paramètre, il s'agira alors de l'éditer
##
proc Katyusha_Interface_Objets_MCD_UML_ajout_attribut {objet {id "null"} {env "mcd"}} {
    global table_tmp
    global relation_tmp
    global classe_tmp
    global IMG
    global E_valeur_attribut
    global E_nom_attribut
    global E_type_attribut
    global E_nsigne_attribut
    global E_ctype_attribut
    global E_null_attribut
    global E_description_attribut
    global E_auto_attribut
    global E_pk_attribut
    global E_unique_attribut
    global E_acces_attribut
    
    set f ".fen_ajout_attribut"
    
    set lbackground [Katyusha_Configurations_couleurs "-lbackground"]
    
    # Détruit la fenêtre si elle existe déjà
    if {[winfo exists $f]} {
        destroy $f
    }
    # Si l'attribut est en édition
    if {$id != "null"} {
        if {$objet == "table"} {
            set attributs [dict get $table_tmp "attributs"]
        } elseif {$objet == "relation"} {
            set attributs [dict get $relation_tmp "attributs"]
        } elseif {$objet == "classe"} {
            set attributs [dict get $relation_tmp "attributs"]
        }
    }
    

    
    # Valeurs par défaut de l'attribut
    if {$id == "null"} {
        set E_valeur_attribut "null"
        set E_auto_attribut 0
        set E_nsigne_attribut 0
        set E_null_attribut 1
        set E_pk_attribut 0
        set E_type_attribut ""
        set E_ctype_attribut ""
        set E_acces_attribut "private"
        set E_description_attribut ""
        if {$objet == "table"} {
            set E_nom_attribut "Attribut_[expr [dict size [dict get $table_tmp attributs]] + 1]"
        } elseif {$objet == "relation"} {
            set E_nom_attribut "Attribut_[expr [dict size [dict get $relation_tmp attributs]] + 1]"
        } elseif {$objet == "classe"} {
            set E_nom_attribut "Attribut_[expr [dict size [dict get $classe_tmp attributs]] + 1]"
        }
        set E_unique_attribut 0
    } else {
        # Charge les données de l'attribut en édition
        set attribut [dict get $attributs $id]
        set E_nom_attribut "[dict get $attribut nom]"
        set E_type_attribut "[dict get $attribut type]"
        set E_nsigne_attribut "[dict get $attribut signe]"
        set E_ctype_attribut "[dict get $attribut complement_type]"
        set E_taille_attribut "[dict get $attribut taille]"
        set E_valeur_attribut "[dict get $attribut valeur]"
        set E_null_attribut "[dict get $attribut null]"
        set E_auto_attribut "[dict get $attribut auto]"
        set E_pk_attribut "[dict get $attribut pk]"
        set E_unique_attribut "[dict get $attribut unique]"
        set E_acces_attribut "[dict get $attribut acces]"
        set E_description_attribut ""
    }
    
    toplevel $f
    # Icone de la fenêtre
    wm iconphoto $f $IMG(logo)
    
    # Frame de titre
    ttk::frame $f.nom
        ttk::label $f.nom.l -text [phgt::mc "Propriétés de l'attribut"]
        pack $f.nom.l -fill x
    pack $f.nom -fill x -pady 10 -padx 50
    
    # Propriétés de l'attribut
    ttk::frame $f.prop
        # Nom de l'attribut
        ttk::frame $f.prop.nom
            ttk::label $f.prop.nom.l -text [phgt::mc "Nom de l'attribut : "] -width 40 -anchor w
            ttk::entry $f.prop.nom.e -textvariable E_nom_attribut
            pack $f.prop.nom.l $f.prop.nom.e -side left -fill x
        
        # Type de l'attribut
        ttk::frame $f.prop.type
            ttk::label $f.prop.type.l -text [phgt::mc "Type de l'attribut : "] -width 40 -anchor w
            ttk::combobox $f.prop.type.cb -values [Katyusha_SQL_liste_types]
            pack $f.prop.type.l $f.prop.type.cb -side left -fill x
            if {$id != "null"} {
                $f.prop.type.cb set $E_type_attribut
            }
        
        # L'attribut peut-l être unique
        ttk::frame $f.prop.signe
            ttk::label $f.prop.signe.l -text [phgt::mc "Cocher si l'attribut est non-signé : "] -width 40 -anchor w
            ttk::checkbutton $f.prop.signe.cb -onvalue 1 -offvalue 0 -variable E_nsigne_attribut
            pack $f.prop.signe.l $f.prop.signe.cb -side left -fill x
        
        # Complément du type de l'attribut
        ttk::frame $f.prop.ctype
            ttk::label $f.prop.ctype.l -text [phgt::mc "Complément du type de l'attribut : "] -width 40 -anchor w
            ttk::entry $f.prop.ctype.e -textvariable $E_ctype_attribut
            #pack $f.prop.ctype.l $f.prop.ctype.e -side left -fill x
        #pack $f.prop.ctype -fill x
        # Taille de l'attribut (0 pour la valeur par défaut du SGBD)
        ttk::frame $f.prop.taille
            ttk::label $f.prop.taille.l -text [phgt::mc "Taille de l'attribut : "] -width 40 -anchor w
            ttk::spinbox $f.prop.taille.sb -from 0 -to 255 -increment 1
            pack $f.prop.taille.l $f.prop.taille.sb -side left -fill x
        
        ttk::label $f.prop.info_taille -text [phgt::mc "Attention, tous les type ne possèdent pas de taille. Si c'est le cas, ce paramètre sera simplement ignoré.\nLaisser \"0\" pour utiliser la valeur par défaut du SGBD."] -foreground red -anchor w -justify left
        
        # Null?
        ttk::frame $f.prop.null
            ttk::label $f.prop.null.l -text [phgt::mc "Cocher si l'attribut peu être nul : "] -width 40 -anchor w
            ttk::checkbutton $f.prop.null.cb -onvalue 1 -offvalue 0 -variable E_null_attribut
            pack $f.prop.null.l $f.prop.null.cb -side left -fill x
        
        # Valeur par défaut
        ttk::frame $f.prop.valeur
            ttk::label $f.prop.valeur.l -text [phgt::mc "Valeur par défaut de l'attribut : "] -width 40 -anchor w
            ttk::entry $f.prop.valeur.e -textvariable E_valeur_attribut
            pack $f.prop.valeur.l $f.prop.valeur.e -side left -fill x
        
        # Incrémentation automatique?
        ttk::frame $f.prop.auto
            ttk::label $f.prop.auto.l -text [phgt::mc "Incrémentation automatique? : "] -width 40 -anchor w
            ttk::checkbutton $f.prop.auto.cb -onvalue 1 -offvalue 0 -variable E_auto_attribut
            pack $f.prop.auto.l $f.prop.auto.cb -side left -fill x
        
        # L'attribut peut-l être unique
        ttk::frame $f.prop.unique
            ttk::label $f.prop.unique.l -text [phgt::mc "Cocher si l'attribut est unique : "] -width 40 -anchor w
            ttk::checkbutton $f.prop.unique.cb -onvalue 1 -offvalue 0 -variable E_unique_attribut
            pack $f.prop.unique.l $f.prop.unique.cb -side left -fill x
        
        
        # Si l'attribut est en incrémentation automatique, il ne peut pas être null
        # TODO : Sortir le bind de là, c'est pas propre
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
        ttk::frame $f.prop.pk
            if {$env == "mcd"} {
                set texte [phgt::mc "Cocher si l'attribut est une clef primaire : "]
            } else {
                set texte [phgt::mc "Cocher si l'attribut est un identifiant : "]
            }
        
            ttk::label $f.prop.pk.l -text $texte -width 40 -anchor w
            ttk::checkbutton $f.prop.pk.cb -onvalue 1 -offvalue 0 -variable E_pk_attribut
            pack $f.prop.pk.l $f.prop.pk.cb -side left -fill x
        
        # Accès de l'attribut
        ttk::frame $f.prop.acces
            ttk::label $f.prop.acces.l -text [phgt::mc "Accès de l'attribut : "] -width 40 -anchor w
            ttk::combobox $f.prop.acces.cb -values [list "private" "public" "protected"]
            pack $f.prop.acces.l $f.prop.acces.cb -side left -fill x
            $f.prop.acces.cb set $E_acces_attribut
        
        pack $f.prop.nom $f.prop.type $f.prop.valeur $f.prop.pk -fill x
        
        if {$env == "mcd"} {
            pack $f.prop.signe $f.prop.taille $f.prop.info_taille $f.prop.null $f.prop.auto $f.prop.unique -fill x
        } else {
            pack $f.prop.acces
        }
        
    pack $f.prop -fill x -padx 20
    
    ttk::frame $f.commandes
        ttk::button $f.commandes.ok -text [phgt::mc "Valider"] -image $IMG(valider) -compound left -command "Katyusha_Interface_Objets_MCD_UML_commande_ajout_attribut $objet $id $env"
        ttk::button $f.commandes.ko -text [phgt::mc "Retour"] -image $IMG(retour) -compound left -command "destroy $f"
        pack $f.commandes.ok -side left -fill x -pady 10 -padx 50
        pack $f.commandes.ko -side right -fill x -pady 10 -padx 50
    pack $f.commandes -fill x
    
    # Titre le la présente fenêtre
    wm title $f [phgt::mc "Ajouter un attribut"]
    
    # Couleur de fond de la fenêtre
    $f configure -background $lbackground
    
    update
}

proc Katyusha_Interface_Objets_MCD_UML_commande_ajout_attribut {objet {id "null"} {env "mcd"}} {
    global E_nsigne_attribut
    global E_auto_attribut
    global E_pk_attribut
    global E_null_attribut
    global E_description_attribut
    global E_unique_attribut
    global E_acces_attribut
    
    set f ".fen_ajout_attribut"
    
    if {$objet == "table"} {
        set ok [Katyusha_Tables_controle_attribut [$f.prop.nom.e get] [$f.prop.type.cb get] $E_nsigne_attribut [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_unique_attribut $E_acces_attribut $E_description_attribut]
        if {$ok == 1} {
            if {$id == "null"} {
                Katyusha_Tables_ajout_attribut [$f.prop.nom.e get] [$f.prop.type.cb get] $E_nsigne_attribut [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_unique_attribut $E_acces_attribut $E_description_attribut
            } else {
                Katyusha_Tables_modification_attribut $id [$f.prop.nom.e get] [$f.prop.type.cb get] $E_nsigne_attribut [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_unique_attribut $E_acces_attribut $E_description_attribut
            }
            destroy $f
        }
    } elseif {$objet == "relation"} {
        set ok [Katyusha_Tables_controle_attribut [$f.prop.nom.e get] [$f.prop.type.cb get] $E_nsigne_attribut [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_unique_attribut $E_acces_attribut $E_description_attribut]
        if {$ok == 1} {
            if {$id == "null"} {
                Katyusha_Relations_ajout_attribut [$f.prop.nom.e get] [$f.prop.type.cb get] $E_nsigne_attribut [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_unique_attribut $E_acces_attribut $E_description_attribut
            } else {
                Katyusha_Relations_modification_attribut $id [$f.prop.nom.e get] [$f.prop.type.cb get] $E_nsigne_attribut [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_unique_attribut $E_acces_attribut $E_description_attribut
            }
            destroy $f
        }
    } elseif {$objet == "classe"} {
        set ok [Katyusha_UML_Objets_controle_attribut [$f.prop.nom.e get] [$f.prop.type.cb get] $E_nsigne_attribut [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_unique_attribut $E_acces_attribut $E_description_attribut]
        if {$ok == 1} {
            if {$id == "null"} {
                Katyusha_UML_Objets_ajout_attribut [$f.prop.nom.e get] [$f.prop.type.cb get] $E_nsigne_attribut [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_unique_attribut $E_acces_attribut $E_description_attribut "classe"
            } else {
                Katyusha_UML_Objets_modification_attribut $id [$f.prop.nom.e get] [$f.prop.type.cb get] $E_nsigne_attribut [$f.prop.ctype.e get] [$f.prop.taille.sb get] $E_null_attribut [$f.prop.valeur.e get] $E_auto_attribut $E_pk_attribut $E_unique_attribut $E_acces_attribut $E_description_attribut
            }
            destroy $f
        }
    }
}
