/* Script généré automatiquement par Katyusha MCD v0.4.0 pour mysql */


/* Table : projet */

CREATE TABLE projet (
    id INTEGER AUTO_INCREMENT NOT NULL, 
    nom VARCHAR(255) NOT NULL, 
    code_langue CHAR(3) NOT NULL, 
    PRIMARY KEY(id)
) ;


/* Table : utilisateur */

CREATE TABLE utilisateur (
    id INTEGER AUTO_INCREMENT NOT NULL, -- dshgdhsgcjgjshx
    pseudo VARCHAR(255) NOT NULL, 
    mdp VARCHAR(255) NOT NULL, 
    mail VARCHAR(255) NOT NULL, 
    est_admin BOOLEAN NOT NULL DEFAULT false, 
    PRIMARY KEY(id)
) ;


/* Table : phrase */

CREATE TABLE phrase (
    id INTEGER AUTO_INCREMENT NOT NULL, 
    texte TEXT NOT NULL, 
    code_langue CHAR(3) NOT NULL, 
    id_fichier INTEGER NOT NULL, 
    PRIMARY KEY(id)
) ;


/* Table : fichier */

CREATE TABLE fichier (
    id INTEGER AUTO_INCREMENT NOT NULL, 
    nom VARCHAR(255) NOT NULL, 
    id_projet INTEGER NOT NULL, 
    nom_motif VARCHAR(255) NOT NULL, 
    PRIMARY KEY(id)
) ;


/* Table : motif */

CREATE TABLE motif (
    nom VARCHAR(255) NOT NULL, 
    n_lignes INTEGER NOT NULL DEFAULT 1, 
    k_id VARCHAR(255), 
    v_id VARCHAR(255), 
    separateur VARCHAR(255) NOT NULL, 
    k_limiteur_debut VARCHAR(255), 
    k_limiteur_fin VARCHAR(255), 
    v_limiteur_debut VARCHAR(255), 
    v_limiteur_fin VARCHAR(255), 
    fin_ligne VARCHAR(255) NOT NULL, 
    PRIMARY KEY(nom)
) ;


/* Table : participe */

CREATE TABLE participe (
    role INTEGER NOT NULL DEFAULT 0, 
    id_projet INTEGER NOT NULL, 
    id_utilisateur INTEGER NOT NULL, 
    PRIMARY KEY(id_projet, id_utilisateur)
) ;


/* Table : relation_utilisateur_langue */

CREATE TABLE relation_utilisateur_langue (
    code_langue CHAR(3) NOT NULL, # Commentaire MySQL
    id_utilisateur INTEGER NOT NULL, 
    PRIMARY KEY(code_langue, id_utilisateur)
) ;





ALTER TABLE projet ADD CONSTRAINT FK_langue_code_langue_projet FOREIGN KEY (code_langue) REFERENCES langue(code) ;

ALTER TABLE phrase ADD CONSTRAINT FK_langue_code_langue_phrase FOREIGN KEY (code_langue) REFERENCES langue(code) ;

ALTER TABLE fichier ADD CONSTRAINT FK_projet_id_projet_fichier FOREIGN KEY (id_projet) REFERENCES projet(id) ;

ALTER TABLE phrase ADD CONSTRAINT FK_fichier_id_fichier_phrase FOREIGN KEY (id_fichier) REFERENCES fichier(id) ;

ALTER TABLE fichier ADD CONSTRAINT FK_motif_nom_motif_fichier FOREIGN KEY (nom_motif) REFERENCES motif(nom) ;

ALTER TABLE projet ADD CONSTRAINT FK_participe_id_projet_projet FOREIGN KEY (id_projet) REFERENCES participe(id) ;

ALTER TABLE utilisateur ADD CONSTRAINT FK_participe_id_utilisateur_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES participe(id) ;

ALTER TABLE langue ADD CONSTRAINT FK_relation_utilisateur_langue_code_langue_langue FOREIGN KEY (code_langue) REFERENCES relation_utilisateur_langue(code) ;

ALTER TABLE utilisateur ADD CONSTRAINT FK_relation_utilisateur_langue_id_utilisateur_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES relation_utilisateur_langue(id) ;


