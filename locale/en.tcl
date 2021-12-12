# English

# Initialisation du programme
set LOCALE(chargement_locale_ok) " # OK!"
set LOCALE(chargement_modules) "Loading modules........"
set LOCALE(chargement_module_tk_ok) " # OK!"
set LOCALE(chargement_module_tdbc_ok) " # OK!"
# Menu
set LOCALE(menu_katyusha) "Katyusha!"
set LOCALE(menu_fichier) "Project"
set LOCALE(menu_mcd) "MCD"
set LOCALE(menu_bdd) "Database"
set LOCALE(menu_code) "Code"
set LOCALE(menu_aide) "Help"
set LOCALE(menu_katyusha_pref) "Preferences"
set LOCALE(menu_katyusha_maj) "Updates"
set LOCALE(menu_mcd_nouveau) "New project"
set LOCALE(menu_sauver_sous) "Save project as ..."
set LOCALE(menu_sauver) "Save project"
set LOCALE(menu_charger) "Load a project"
set LOCALE(menu_recents) "Recents projects"
set LOCALE(recents_init) "remove the list"
set LOCALE(menu_prefs) "Project's preferences"
set LOCALE(menu_quitter) "Exit"
set LOCALE(menu_config_bdd) "Configure database"
set LOCALE(menu_connex_bdd) "Database connection"
set LOCALE(menu_gen_sql) "Generate SQL script"
set LOCALE(menu_gen_mcd) "Générer le MCD d'un script SQL"
set LOCALE(menu_mcd_entites) "Objects of the MCD"
set LOCALE(menu_mcd_ajout_table) "Add an entity"
set LOCALE(menu_mcd_edit_table) "Edit an entity"
set LOCALE(menu_mcd_sup_table) "Delete an entity"
set LOCALE(menu_mcd_ajout_relation) "Add a relation"
set LOCALE(menu_mcd_edit_relation) "Edit a relation"
set LOCALE(menu_mcd_sup_relation) "delete a relation"
set LOCALE(menu_mcd_exporter_svg) "Export to SVG"
set LOCALE(menu_mcd_imprimer) "Export to Post Script"
set LOCALE(menu_mcd_verifier) "Verify MCD integrity"
set LOCALE(menu_aide_a_propos) "About"
set LOCALE(menu_aide_license) "License"
set LOCALE(menu_code_generer_php_fonctions) "Generate PHP code"
set LOCALE(menu_code_generer_php_doctrine) "Generate PHP code for Doctrine ORM"
# Génération de code
set LOCALE(gen_code_php_fonctions_titre) "Generate the database access code for procedural PHP "
set LOCALE(gen_code_php_fonctions) "Procedural PHP code"
set LOCALE(gen_code_php_fonctions_prefix) "Prefix of functions  : "
set LOCALE(gen_code_php_fonctions_un_fichier) "All functions in one file : "
set LOCALE(gen_code_php_doctrine_titre) "Generate the database access code for Doctrine ORM"
set LOCALE(gen_code_php_doctrine) "PHP code object models for Doctrine"
set LOCALE(gen_code_php_doctrine_namespace) "Namespace : "
set LOCALE(gen_code_php_doctrine_prefix) "Class prefix : "
set LOCALE(gen_code_php_doctrine_un_fichier) "Toutes les classes dans un seul fichier : "
set LOCALE(gen_code_php_doctrine_attention) "Attention, la génération de code pour Doctrine est encore expérimentale!"
# Génération SQL
set LOCALE(selectionner_sgbd) "Sélectionner le DBMS cible :"
set LOCALE(generer_sql) "Generate SQL script"
set LOCALE(script_enregistre) "Script SQL enregistré automatiquement dans : "
set LOCALE(script_sql) "Script SQL"
# Erreurs MCD
set LOCALE(erreurs_mcd) "Errors of the MCD"
# Licence
set LOCALE(jai_compris) "I understand"
set LOCALE(licence) "License - GNU GPL v3.0"
# Interface principale
set LOCALE(ajouter_table) "Add an entity"
set LOCALE(ajouter_relation) "Add a relation"
set LOCALE(ajouter_heritage) "Add an heritage"
set LOCALE(ajouter_etiquette) "Add a label"
set LOCALE(ajouter_procedure) "Ajouter une procédure stockée"
set LOCALE(entites_de_la_base) "MCD's objects"
# Ajout d'une table
set LOCALE(ajouter_une_table) "Add an entity"
set LOCALE(editer_la_table) "Edit the entity"
set LOCALE(nom_table) "Entity's name : "
set LOCALE(liste_attributs_table) "Attributes of the entity"
set LOCALE(nom) "Name"
set LOCALE(type) "Type"
set LOCALE(taille) "Size"
set LOCALE(pk) "Primary key?"
set LOCALE(auto) "Auto incrementation?"
set LOCALE(valeur) "Default value"
set LOCALE(ajouter_une_ligne) "Add a line"
set LOCALE(nom_de_la_nouvelle_table) "Name of new entity :"
set LOCALE(le_nom_de_la_table_ne_peut_pas_etre_vide) "Entity's name can't be void"
set LOCALE(description_de_la_table) "Entity's description"
set LOCALE(ajouter_des_attributs) "Add attributs"
# Ajout d'une relation
set LOCALE(ajouter_une_relation) "Add a relation"
set LOCALE(editer_la_relation) "Edit the relation"
set LOCALE(nom_relation) "Relation's name : "
set LOCALE(liste_attributs_relation) "Attributes of the relation"

# Ajout d'un lien à une relation
set LOCALE(table_concernee_lien) "Please, select link's entity : "
set LOCALE(table_lien) "Entity"
set LOCALE(type_lien) "Type of link"
set LOCALE(relatif_lien) "Relatif?"
set LOCALE(pas_assez_table) "Not enough entities in the MCD."
# Ajout d'une étiquette
set LOCALE(ajouter_une_etiquette) "Add a label"
set LOCALE(editer_l_etiquette) "Edit the label :"
set LOCALE(nom_etiquette) "Name :"
set LOCALE(texte_etiquette) "Text of the label"
# Supprimer une entité
set LOCALE(sure_supprimer_entite) "Sure to delete this "
# Ajout d'un attribut à une table ou une étiquette
set LOCALE(ajouter_attribut) "Add an attribute"
set LOCALE(prop_attribut) "Properties of the attribute"
set LOCALE(nom_attribut) "Name : "
set LOCALE(type_attribut) "Type : "
set LOCALE(ctype_attribut) "Complement : "
set LOCALE(taille_attribut) "Size : "
set LOCALE(taille_info_attribut) "Warning, not all types have a size. If not, this parameter will be ignored. Let 0 to use default size."
set LOCALE(null_attribut) "Check is the attribute can be null : "
set LOCALE(valeur_attribut) "Default value : "
set LOCALE(auto_attribut) "Incrementation? : "
set LOCALE(pk_attribut) "Primary key? : "
# Supprimer un attribut
set LOCALE(supprimer_attribut) "Delete an attribute"
set LOCALE(supprimer_attribut_selection) "Select the attribute to delete"
set LOCALE(aucun_attribut_selectionne) "No attribute selected"
# Ajout d'un héritage
set LOCALE(pas_assez_table) "MCD must have minimum one entity to add an heritage"
set LOCALE(ajouter_un_heritage) "Ajouter un héritage"
set LOCALE(editer_l_heritage) "Éditer l'héritage : "
set LOCALE(table_mere) "Parent entity : "
set LOCALE(cliquer_choisir_table_mere) "Click to choose parent entity"
set LOCALE(liste_tables_filles) "List of all child entities"
# Ajout d'une table mère à l'héritage
set LOCALE(ajouter_table_mere) "Add a parent entity to the heritage"
set LOCALE(table_mere) "Parent entity : "
# Ajout d'une table fille à l'héritage
set LOCALE(ajouter_table_fille) "Add a child entity to the heritage"
set LOCALE(table_fille) "Child entity : "
# Suppression d'une table fille à un héritage
set LOCALE(supprimer_table_fille_selection) "Select a child entity to delete"
set LOCALE(supprimer_table_fille) "Delete a child entity"
set LOCALE(aucune_table_selectionne) "No entity selected"
# À propos
set LOCALE(TITRE_a_propos) "About Katyusha MCD"
set LOCALE(TEXTE_a_propos) "Katyusha MCD is a component of the Phosphore Project\nShared under GPL v3 license\nCopyleft (c) 2019 - 2021\n Mélanie Verdon Avizou"
# Supression entité
set LOCALE(sure_suppression_table) "Sure to delete this entity?"
set LOCALE(sure_suppression_relation) "Sure to delete this relation?"
# Préférences
set LOCALE(prefs_titre) "Preferences of Katyusha MCD"
set LOCALE(prefs_choix_langue) "Language : "
set LOCALE(prefs_taille_fenetre) "Window size (auto for automatic configuration) : "
set LOCALE(prefs_taille_fenetre_alerte) "Warning, automatic configuration don't work well with multiple screens."
set LOCALE(prefs_nom_bdd_defaut) "Database's default name : "
set LOCALE(prefs_sgbd_defaut) "Default DBMS : "
set LOCALE(prefs_taille_canvas) "Canvas size : "
set LOCALE(prefs_alerte_configs_redemarrage) "Katyusha MCD must be reboot to active all changes."
set LOCALE(prefs_titre_choix_props_att) "Choose what to show inside MCD's objects"
set LOCALE(prefs_pk) "Primary key"
set LOCALE(prefs_nom) "Name"
set LOCALE(prefs_type) "Type"
set LOCALE(prefs_taille) "Attribut's size"
set LOCALE(prefs_null) "If attribut can be null"
set LOCALE(prefs_defaut) "Default value"
# Configurations BDD
set LOCALE(config_mcd_titre) "Project's configuration"
set LOCALE(nom_projet) "Project's name : "
set LOCALE(liste_sgbd) "Liste of DBMS : "
# Sauvegarde
set LOCALE(mcd_sauv_sous) "MCD saved as : "
# Véréfication du MCD
set LOCALE(relation_min_2_liens_1) "The relation "
set LOCALE(relation_min_2_liens_2) " must have 2 links minimum."
set LOCALE(entite_mere_est_aussi_fille_1) "In the heritage "
set LOCALE(entite_mere_est_aussi_fille_2) " parent entity can't be child entity too."
set LOCALE(plusieurs_entites_nom) "More than one entity named "

# Général
set LOCALE(valider) "Ok"
set LOCALE(retour) "Return"
set LOCALE(editer) "Edit"
set LOCALE(supprimer) "Delete"
set LOCALE(mcd_correcte) "MCD correct"
set LOCALE(tables) "Entities"
set LOCALE(relations) "Relations"
set LOCALE(etiquettes) "Labels"
set LOCALE(heritages) "Heritages"
set LOCALE(attention_os) "Warning! Your private life is in danger!!"
