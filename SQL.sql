-- Projet Entreprise de vente (32)
--
-- Dans le cadre de l'UV NA17
--
-- Vivien LECLERCQ - 28/05/2020

-- OPTIMISATION A LA FIN DU CODE ligne 731

BEGIN TRANSACTION;

-- SUPPRESSION DES ANCIENNES DONNEES

-- SUPPRESSION DES VUES

DROP VIEW IF EXISTS public.V_FactureMontantBrut;

DROP VIEW IF EXISTS public.V_TotalRemiseVendeur;
DROP VIEW IF EXISTS public.V_PanierMoyenGlobal;
DROP VIEW IF EXISTS public.V_PanierMoyen;
DROP VIEW IF EXISTS public.V_ProduitsAvecLePlusDePannes;
DROP VIEW IF EXISTS public.V_ProduitsLesPlusVendus;

DROP VIEW IF EXISTS public.V_MembreServiceAchat;
DROP VIEW IF EXISTS public.V_MembreServiceVente;
DROP VIEW IF EXISTS public.V_MembreSAV;
DROP VIEW IF EXISTS public.V_MembreEntreprise;

DROP VIEW IF EXISTS public.V_Personne;
DROP VIEW IF EXISTS public.V_Fournisseur;
DROP VIEW IF EXISTS public.V_Produit;

-- SUPPRESSION DES TABLES

DROP TABLE IF EXISTS public.BonDeCommandeProduit;
DROP TABLE IF EXISTS public.BonDeCommande;

DROP TABLE IF EXISTS public.Reparation;
DROP TABLE IF EXISTS public.TicketSAV;

DROP TABLE IF EXISTS public.FacturePersonneRemise;
DROP TABLE IF EXISTS public.Remise;

DROP TABLE IF EXISTS public.OccurrenceDeProduitEntreprise;
DROP TABLE IF EXISTS public.OccurrenceDeProduitFournisseur;

DROP TABLE IF EXISTS public.FacturePersonne;
DROP VIEW IF EXISTS public.V_FacturePersonne;
DROP TABLE IF EXISTS public.FactureFournisseur;

DROP TABLE IF EXISTS public.Produit;

DROP TABLE IF EXISTS public.Fournisseur;

DROP TABLE IF EXISTS public.MembreServiceAchat;
DROP TABLE IF EXISTS public.MembreServiceVente;
DROP TABLE IF EXISTS public.MembreSAV;

DROP TABLE IF EXISTS public.MembreEntreprise;

DROP TABLE IF EXISTS public.Personne;

-- SUPPRESSION DES ROLES

DROP ROLE IF EXISTS UserMembreEntreprise;
DROP ROLE IF EXISTS UserMembreServiceAchat;
DROP ROLE IF EXISTS UserMembreServiceVente;
DROP ROLE IF EXISTS UserMembreSAV;

-- CREATION DES TABLES

CREATE TABLE IF NOT EXISTS public.Personne(
  id_personne SERIAL PRIMARY KEY,
  personne_nom VARCHAR(50) NOT NULL,
  personne_prenom VARCHAR(50) NOT NULL,
  personne_date_de_naissance DATE NOT NULL,
  personne_email VARCHAR(100) NOT NULL,
  personne_adresse JSON NOT NULL,
--  facture JSON,
  CONSTRAINT personne_unique UNIQUE (personne_nom, personne_prenom, personne_date_de_naissance)
);

CREATE TABLE IF NOT EXISTS public.MembreEntreprise(
  id_personne INTEGER PRIMARY KEY NOT NULL,
  membre_entreprise_date_arrivee TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  membre_entreprise_date_depart TIMESTAMP,
  FOREIGN KEY (id_personne) REFERENCES public.Personne(id_personne),
  CONSTRAINT membre_entreprise_date CHECK (membre_entreprise_date_arrivee <  membre_entreprise_date_depart)
);

CREATE TABLE IF NOT EXISTS public.MembreServiceAchat(
  id_personne INTEGER PRIMARY KEY NOT NULL,
  membre_service_achat_date_arrivee TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  membre_service_achat_date_depart TIMESTAMP,
  FOREIGN KEY (id_personne) REFERENCES public.MembreEntreprise(id_personne),
  CONSTRAINT membre_service_achat_date CHECK (membre_service_achat_date_arrivee < membre_service_achat_date_depart)
);

CREATE TABLE IF NOT EXISTS public.MembreServiceVente(
  id_personne INTEGER PRIMARY KEY NOT NULL,
  membre_service_vente_date_arrivee TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  membre_service_vente_date_depart TIMESTAMP,
  FOREIGN KEY (id_personne) REFERENCES public.MembreEntreprise(id_personne),
  CONSTRAINT membre_service_vente_date CHECK (membre_service_vente_date_arrivee < membre_service_vente_date_depart)
);

CREATE TABLE IF NOT EXISTS public.MembreSAV(
  id_personne INTEGER PRIMARY KEY NOT NULL,
  membre_SAV_date_arrivee TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  membre_SAV_date_depart TIMESTAMP,
  FOREIGN KEY (id_personne) REFERENCES public.MembreEntreprise(id_personne),
  CONSTRAINT membre_SAV_date CHECK (membre_SAV_date_arrivee < membre_SAV_date_depart)
);

CREATE TABLE IF NOT EXISTS public.Fournisseur(
  id_fournisseur SERIAL PRIMARY KEY,
  fournisseur_nom VARCHAR(70) NOT NULL,
  fournisseur_adresse JSON NOT NULL
);

CREATE TABLE IF NOT EXISTS public.Produit(
  produit_reference VARCHAR(150) PRIMARY KEY NOT NULL,
  produit_description JSON NOT NULL,
  produit_prix_de_reference FLOAT NOT NULL,
  produit_consommation FLOAT NOT NULL,
  produit_marque VARCHAR(50) NOT NULL,
  produit_categorie JSON NOT NULL,
  CONSTRAINT produit_prix_de_reference_positif CHECK (produit_prix_de_reference > 0),
  CONSTRAINT produit_consommation_positif CHECK (produit_consommation > 0)
);

CREATE TABLE IF NOT EXISTS public.FactureFournisseur(
  id_facture SERIAL PRIMARY KEY,
  facture_montant FLOAT NOT NULL,
  facture_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  facture_payee SMALLINT NOT NULL,
  id_fournisseur INTEGER NOT NULL,
  id_membre_service_achat INTEGER NOT NULL,
  CONSTRAINT facture_montant_positif CHECK (facture_montant >= 0),
  CONSTRAINT facture_payee_valeurs CHECK (facture_payee = 0 OR facture_payee = 1),
  FOREIGN KEY (id_fournisseur) REFERENCES public.Fournisseur(id_fournisseur),
  FOREIGN KEY (id_membre_service_achat) REFERENCES public.MembreServiceAchat(id_personne)
);

CREATE TABLE IF NOT EXISTS public.FacturePersonne(
  id_facture SERIAL,
  id_personne INTEGER NOT NULL,
  facture_montant FLOAT NOT NULL,
  facture_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  facture_payee SMALLINT NOT NULL,
  id_membre_service_vente INTEGER NOT NULL,
  FOREIGN KEY (id_personne) REFERENCES Personne(id_personne),
  CONSTRAINT id_facture_unique UNIQUE (id_facture), -- là pour s'assurer que id_facture est une cle candidate --
  CONSTRAINT PK_FacturePersonne PRIMARY KEY (id_facture, id_personne),
  CONSTRAINT facture_montant_positif CHECK (facture_montant >= 0),
  CONSTRAINT facture_payee_valeurs CHECK (facture_payee = 0 OR facture_payee = 1),
  FOREIGN KEY (id_membre_service_vente) REFERENCES public.MembreServiceVente(id_personne)
);

CREATE TABLE IF NOT EXISTS public.Remise(
  id_remise SERIAL PRIMARY KEY,
  id_personne INTEGER,
  id_membre_service_vente INTEGER,
  id_membre_SAV INTEGER,
  remise_montant FLOAT NOT NULL,
  remise_type VARCHAR(15) NOT NULL,
  remise_date_debut TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  remise_date_fin TIMESTAMP,
  remise_nombre_utilisations INTEGER,
  FOREIGN KEY (id_personne) REFERENCES public.Personne(id_personne),
  FOREIGN KEY (id_membre_service_vente) REFERENCES public.MembreServiceVente(id_personne),
  FOREIGN KEY (id_membre_SAV) REFERENCES public.MembreSAV(id_personne),
  CONSTRAINT remise_createur CHECK ((id_membre_service_vente IS NULL AND id_membre_SAV IS NOT NULL) OR (id_membre_service_vente IS NOT NULL AND id_membre_SAV IS NULL)),
  CONSTRAINT remise_montant_positif CHECK (remise_montant > 0),
  CONSTRAINT remise_type_valeurs CHECK (remise_type = 'avoir' OR remise_type = 'garantie' OR remise_type = 'promotion' OR remise_type = 'pourcentage'),
  CONSTRAINT remise_nombre_utilisations_valeurs CHECK (remise_nombre_utilisations >= 0 OR remise_nombre_utilisations IS NULL),
  CONSTRAINT remise_nombre_utilisations_valeurs_types CHECK ((remise_type = 'avoir' AND remise_nombre_utilisations IS NOT NULL) OR ( remise_type = 'garantie' AND remise_nombre_utilisations IS NOT NULL) OR (remise_type = 'promotion' AND remise_nombre_utilisations IS NULL) OR (remise_type = 'pourcentage' AND remise_nombre_utilisations IS NULL)),
  CONSTRAINT remise_date CHECK ((remise_date_fin IS NOT NULL AND (remise_date_debut <= remise_date_fin)) OR remise_date_fin IS NULL)
);

CREATE TABLE IF NOT EXISTS public.OccurrenceDeProduitEntreprise(
  occurrence_de_produit_numero_de_serie SERIAL PRIMARY KEY,
  produit_reference VARCHAR(150) NOT NULL,
  id_facture INTEGER,
  occurrence_de_produit_extension_de_garantie SMALLINT NOT NULL,
  occurrence_de_produit_montant_extension_de_garantie FLOAT,
  occurrence_de_produit_prix FLOAT NOT NULL,
  occurrence_de_produit_montant_installation_par_specialiste FLOAT,
  id_membre_service_achat INTEGER NOT NULL,
  FOREIGN KEY (produit_reference) REFERENCES public.Produit(produit_reference),
  FOREIGN KEY (id_facture) REFERENCES public.FacturePersonne(id_facture),
  CONSTRAINT occurrence_de_produit_extension_de_garantie_valeurs CHECK (occurrence_de_produit_extension_de_garantie = 0 OR occurrence_de_produit_extension_de_garantie = 1),
  CONSTRAINT occurrence_de_produit_montant_extension_de_garantie_positif CHECK (occurrence_de_produit_montant_extension_de_garantie IS NULL OR occurrence_de_produit_montant_extension_de_garantie > 0),
  CONSTRAINT occurrence_de_produit_prix_positif CHECK (occurrence_de_produit_prix > 0),
  CONSTRAINT occurrence_de_produit_montant_installation_par_specialiste_positif CHECK (occurrence_de_produit_montant_installation_par_specialiste IS NULL OR occurrence_de_produit_montant_installation_par_specialiste > 0),
  FOREIGN KEY (id_membre_service_achat) REFERENCES MembreServiceAchat(id_personne)
);

CREATE TABLE IF NOT EXISTS public.OccurrenceDeProduitFournisseur(
  occurrence_de_produit_numero_de_serie SERIAL PRIMARY KEY,
  produit_reference VARCHAR(150) NOT NULL,
  id_facture INTEGER,
  occurrence_de_produit_prix FLOAT NOT NULL,
  id_fournisseur INTEGER NOT NULL,
  FOREIGN KEY (produit_reference) REFERENCES public.Produit(produit_reference),
  FOREIGN KEY (id_facture) REFERENCES public.FactureFournisseur(id_facture),
  CONSTRAINT occurrence_de_produit_prix_positif CHECK (occurrence_de_produit_prix > 0),
  FOREIGN KEY (id_fournisseur) REFERENCES public.Fournisseur(id_fournisseur)
);

CREATE TABLE IF NOT EXISTS public.FacturePersonneRemise(
  id_facture INTEGER NOT NULL,
  id_remise INTEGER NOT NULL,
  FOREIGN KEY (id_facture) REFERENCES public.FacturePersonne(id_facture),
  FOREIGN KEY (id_remise) REFERENCES public.Remise(id_remise),
  CONSTRAINT PK_FacturePersonneRemise PRIMARY KEY (id_facture, id_remise)
);

CREATE TABLE IF NOT EXISTS public.TicketSAV(
  id_ticket_sav SERIAL PRIMARY KEY,
  id_facture INTEGER NOT NULL,
  occurrence_de_produit_numero_de_serie INTEGER NOT NULL,
  ticket_sav_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ticket_sav_statut VARCHAR(15) NOT NULL,
  ticket_sav_issue VARCHAR(15),
  id_membre_SAV INTEGER NOT NULL,
  FOREIGN KEY (id_facture) REFERENCES public.FacturePersonne(id_facture),
  FOREIGN KEY (occurrence_de_produit_numero_de_serie) REFERENCES public.OccurrenceDeProduitEntreprise(occurrence_de_produit_numero_de_serie),
  CONSTRAINT ticket_sav_statut_valeurs CHECK (ticket_sav_statut = 'done' OR ticket_sav_statut = 'in progress' OR ticket_sav_statut = 'todo'),
  CONSTRAINT ticket_sav_facture CHECK ((ticket_sav_statut = 'done' AND ticket_sav_issue IS NOT NULL) OR ticket_sav_issue IS NULL),
  CONSTRAINT ticket_sav_issue_valeurs CHECK (ticket_sav_issue = 'reparation' OR ticket_sav_issue = 'remise' OR ticket_sav_issue = 'retour' OR ticket_sav_issue IS NULL),
  FOREIGN KEY (id_membre_SAV) REFERENCES public.MembreSAV(id_personne)
);

CREATE TABLE IF NOT EXISTS public.Reparation(
  id_reparation SERIAL,
  id_ticket_sav INTEGER NOT NULL,
  reparation_date_entree TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reparation_date_sortie TIMESTAMP,
  reparaton_materiel_utilise VARCHAR(150) NOT NULL,
  reparaton_montant FLOAT NOT NULL,
  id_membre_service_vente INTEGER,
  id_facture INTEGER,
  CONSTRAINT id_reparation_unique UNIQUE (id_reparation), -- là pour s'assurer que id_reparation est une cle candidate --
  FOREIGN KEY (id_ticket_sav) REFERENCES public.TicketSAV(id_ticket_sav),
  CONSTRAINT PK_Reparation PRIMARY KEY(id_reparation, id_ticket_sav),
  CONSTRAINT reparation_date CHECK (reparation_date_sortie IS NULL OR (reparation_date_entree <= reparation_date_sortie)),
  CONSTRAINT reparaton_montant_positif CHECK (reparaton_montant > 0),
  FOREIGN KEY (id_membre_service_vente) REFERENCES public.MembreServiceVente(id_personne),
  FOREIGN KEY (id_facture) REFERENCES public.FacturePersonne(id_facture)
);

CREATE TABLE IF NOT EXISTS public.BonDeCommande(
  id_bon_de_commande SERIAL PRIMARY KEY,
  id_membre_service_vente INTEGER NOT NULL,
  id_membre_service_achat INTEGER,
  bon_de_commande_date_creation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  bon_de_commande_date_traitement TIMESTAMP,
  FOREIGN KEY (id_membre_service_vente) REFERENCES public.MembreServiceVente(id_personne),
  FOREIGN KEY (id_membre_service_achat) REFERENCES public.MembreServiceAchat(id_personne),
  CONSTRAINT bon_de_commande_date CHECK ((bon_de_commande_date_traitement IS NOT NULL AND (bon_de_commande_date_creation <= bon_de_commande_date_traitement)) OR bon_de_commande_date_traitement IS NULL)
);

CREATE TABLE IF NOT EXISTS public.BonDeCommandeProduit(
  id_bon_de_commande INTEGER NOT NULL,
  produit_reference VARCHAR(150) NOT NULL,
  bon_de_commande_produit_quantite INTEGER NOT NULL,
  FOREIGN KEY (id_bon_de_commande) REFERENCES public.BonDeCommande(id_bon_de_commande),
  FOREIGN KEY (produit_reference) REFERENCES public.Produit(produit_reference),
  CONSTRAINT PK_BonDeCommandeProduit PRIMARY KEY (id_bon_de_commande, produit_reference),
  CONSTRAINT bon_de_commande_produit_quantite_positif CHECK (bon_de_commande_produit_quantite > 0)
);

-- OPTIMISATION (explication à la fin de ce code)
CREATE INDEX IX_Remise_remise_type ON public.Remise (remise_type);
CREATE INDEX IX_OccurrenceDeProduitEntreprise_id_facture ON public.OccurrenceDeProduitEntreprise(id_facture);
CREATE INDEX IX_FacturePersonne_id_personne ON public.FacturePersonne (id_personne);

-- PROPRIETAIRE DES TABLES
ALTER TABLE public.BonDeCommandeProduit OWNER TO postgres;
ALTER TABLE public.BonDeCommande OWNER TO postgres;
ALTER TABLE public.Reparation OWNER TO postgres;
ALTER TABLE public.TicketSAV OWNER TO postgres;
ALTER TABLE public.FacturePersonneRemise OWNER TO postgres;
ALTER TABLE public.Remise OWNER TO postgres;
ALTER TABLE public.OccurrenceDeProduitEntreprise OWNER TO postgres;
ALTER TABLE public.OccurrenceDeProduitFournisseur OWNER TO postgres;
ALTER TABLE public.FacturePersonne OWNER TO postgres;
ALTER TABLE public.FactureFournisseur OWNER TO postgres;
ALTER TABLE public.Produit OWNER TO postgres;
ALTER TABLE public.Fournisseur OWNER TO postgres;
ALTER TABLE public.MembreServiceAchat OWNER TO postgres;
ALTER TABLE public.MembreServiceVente OWNER TO postgres;
ALTER TABLE public.MembreSAV OWNER TO postgres;
ALTER TABLE public.MembreEntreprise OWNER TO postgres;
ALTER TABLE public.Personne OWNER TO postgres;

-- Echec de mise en non relationnel de FacturePersonne :
-- Trop de références impossibles à représenter en PostgreSQL/JSON

--INSERT INTO public.FacturePersonne(id_personne, facture_montant, facture_payee, id_membre_service_vente) VALUES
--        (5, 96.03, 1, 7),
--        (3, 407.60, 1, 7),
--        (6, 984.74, 1, 7),
--        (1, 766.30, 1, 7),
--        (1, 430.20, 1, 7),
--        (1, 0.0, 1, 7);

--'{"id_facture": 1, "facture_montant": 96.03, "facture_payee": 1,"id_membre_service_vente": 7}'
--'{"id_facture": 2, "facture_montant": 407.60, "facture_payee": 1,"id_membre_service_vente": 7}'
--'{"id_facture": 3, "facture_montant": 984.74, "facture_payee": 1,"id_membre_service_vente": 7}'
--'{"id_facture": 4, "facture_montant": 766.30, "facture_payee": 1,"id_membre_service_vente": 7}'
--'{"id_facture": 5, "facture_montant": 430.20, "facture_payee": 1,"id_membre_service_vente": 7}'
--'{"id_facture": 6, "facture_montant": 0.0, "facture_payee": 1,"id_membre_service_vente": 7}'

-- Seule maniere trouvee pour ajouter un CURRENT_DATE trouvée
--json_build_array(json_build_object('id_facture', 4, 'facture_montant', 766.30, 'facture_date', CURRENT_TIMESTAMP, 'facture_payee', 1, 'id_membre_service_vente', 7), json_build_object('id_facture', 5, 'facture_montant', 460.20, 'facture_date', CURRENT_TIMESTAMP, 'facture_payee', 1, 'id_membre_service_vente', 7), json_build_object('id_facture', 6, 'facture_montant', 0.0, 'facture_date', CURRENT_TIMESTAMP, 'facture_payee', 1, 'id_membre_service_vente', 7))
--json_build_array(json_build_object('id_facture', 3, 'facture_montant', 984.74, 'facture_date', CURRENT_TIMESTAMP, 'facture_payee', 1, 'id_membre_service_vente', 7))


--INSERT INTO public.Personne(personne_nom, personne_prenom, personne_date_de_naissance, personne_email, personne_adresse, facture) VALUES
--        ('Leclercq', 'Vivien', '1999-12-14', 'vivien.leclercq@gmail.com', '62 rue du Val\n60000 Beauvais', json_build_array(json_build_object('id_facture', 4, 'facture_montant', 766.30, 'facture_date', CURRENT_TIMESTAMP, 'facture_payee', 1, 'id_membre_service_vente', 7), json_build_object('id_facture', 5, 'facture_montant', 460.20, 'facture_date', CURRENT_TIMESTAMP, 'facture_payee', 1, 'id_membre_service_vente', 7), json_build_object('id_facture', 6, 'facture_montant', 0.0, 'facture_date', CURRENT_TIMESTAMP, 'facture_payee', 1, 'id_membre_service_vente', 7))),
--        ('Martin', 'Robert', '1967-12-30', 'robert.martin@gmail.com', '230 Grande Rue\n60000 Beauvais', '[]'),
--        ('Robert', 'Charles', '1982-10-21', 'charles.robert@gmail.com', '36 rue du Sel\n59310 Seclin', json_build_array(json_build_object('id_facture', 2, 'facture_montant', 407.60, 'facture_date', CURRENT_TIMESTAMP, 'facture_payee', 1, 'id_membre_service_vente', 7))),
--        ('Huet', 'Alice', '1979-03-19', 'alice.huet@gmail.com', '12 boulevard des Chaussettes Mouillées\n60000 Beauvais', '[]'),
--        ('Morel', 'Jade', '2001-05-03', 'jade.morel@gmail.com', '12 rue de Dr Froma\n60000 Beauvais', json_build_array(json_build_object('id_facture', 1, 'facture_montant', 96.03, 'facture_date', CURRENT_TIMESTAMP, 'facture_payee', 1, 'id_membre_service_vente', 7))),
--        ('Lebrun', 'Martine', '1992-02-08', 'martine.lebrun@gmail.com', '3 impasse des Fossés\n06000 Nice', json_build_array(json_build_object('id_facture', 3, 'facture_montant', 984.74, 'facture_date', CURRENT_TIMESTAMP, 'facture_payee', 1, 'id_membre_service_vente', 7))),
--        ('Lemoine', 'Sylvain', '1978-08-10', 'sylvain.lemoine@gmail.com', '269 rue du Fromage\n60200 Compiègne', '[]'),
--        ('Vidal', 'Romane', '1984-11-24', 'romane.vidal@gmail.com', '92 rue de la Victoire\n80000 Amiens', '[]'),
--        ('Dubois', 'Patricia', '1998-06-29', 'patricia.dubois@gmail.com', '59 rue des Vignes\n60000 Beauvais', '[]');

INSERT INTO public.Personne(personne_nom, personne_prenom, personne_date_de_naissance, personne_email, personne_adresse) VALUES
        ('Leclercq', 'Vivien', '1999-12-14', 'vivien.leclercq@gmail.com', '{"numero": 62, "rue": "rue du Val", "code_postal": 60000, "ville": "Beauvais"}'),
        ('Martin', 'Robert', '1967-12-30', 'robert.martin@gmail.com', '{"numero": 230, "rue": "Grande Rue", "code_postal": 60000, "ville": "Beauvais"}'),
        ('Robert', 'Charles', '1982-10-21', 'charles.robert@gmail.com', '{"numero": 36, "rue": "rue du Sel", "code_postal": 59310, "ville": "Seclin"}'),
        ('Huet', 'Alice', '1979-03-19', 'alice.huet@gmail.com', '{"numero": 12, "rue": "boulevard des Chaussettes Mouillées", "code_postal": 60000, "ville": "Beauvais"}'),
        ('Morel', 'Jade', '2001-05-03', 'jade.morel@gmail.com', '{"numero": 12, "rue": "rue du Dr Froma", "code_postal": 60000, "ville": "Beauvais"}'),
        ('Lebrun', 'Martine', '1992-02-08', 'martine.lebrun@gmail.com', '{"numero": 3, "rue": "impasse des Fossés", "code_postal": 6000, "ville": "Nice"}'),
        ('Lemoine', 'Sylvain', '1978-08-10', 'sylvain.lemoine@gmail.com', '{"numero": 269, "rue": "rue du Fromage", "code_postal": 60200, "ville": "Compiègne"}'),
        ('Vidal', 'Romane', '1984-11-24', 'romane.vidal@gmail.com', '{"numero": 92, "rue": "rue de la Victoire", "code_postal": 80000, "ville": "Amiens"}'),
        ('Dubois', 'Patricia', '1998-06-29', 'patricia.dubois@gmail.com', '{"numero": 59, "rue": "rue des Vignes", "code_postal": 60000, "ville": "Beauvais"}');


INSERT INTO public.MembreEntreprise(id_personne) VALUES
        (1),
        (3),
        (5),
        (7),
        (8);

INSERT INTO public.MembreServiceAchat(id_personne) VALUES
        (3);

INSERT INTO public.MembreServiceVente(id_personne) VALUES
        (7),
        (5);

INSERT INTO public.MembreSAV(id_personne) VALUES
        (1);


INSERT INTO public.Fournisseur(fournisseur_nom, fournisseur_adresse) VALUES
        ('Ali Baba', '{"numero": 10, "rue": "rue des Patates", "code_postal": 69000, "ville": "Lyon"}'),
        ('Amazon', '{"numero": 67, "rue": "boulevard du Général Leclerc", "code_postal": 92110, "ville": "Clichy"}'),
        ('Darty', '{"numero": 129, "rue": "avenue Galliéni", "code_postal": 93140, "ville": "Bondy"}'),
        ('Top achat', '{"numero": 2, "rue": "rue des Erables", "code_postal": 69570, "ville": "Limonest"}');

INSERT INTO public.Produit(produit_reference, produit_description, produit_prix_de_reference, produit_consommation, produit_marque, produit_categorie) VALUES
        ('Brandt B5006UHD', '{"produit_description_short": "Télévision LED UHD 4K", "produit_description_long": "Cette télévision 4K est faite pour vous ! Avec sa résolution UHD et la technologie LED vous disposerez d une image incroyable."}', 449.99, 126, 'Brandt', '{"souscategorie_nom": "TV", "categorie_nom": "Loisirs"}'),
        ('Philips 43PFS5503', '{"produit_description_short": "Télévision LED UHD 4K", "produit_description_long": "Cette télévision 4K est faite pour vous ! Avec sa résolution UHD et la technologie LED vous disposerez d une image incroyable."}', 334.67, 110, 'Philips', '{"souscategorie_nom": "TV", "categorie_nom": "Loisirs"}'),
        ('Philips The One 65PUS7354', '{"produit_description_short": "Télévision LED", "produit_description_long": "Cette télévision est faite pour vous ! Le technologie LED vous permet une basse consommation."}', 669.99, 89, 'Philips', '{"souscategorie_nom": "TV", "categorie_nom": "Loisirs"}'),
        ('Asus TUF505DT-BQ437T', '{"produit_description_short": "Ordinateur portable Gamer", "produit_description_long": "Endin un ordinateur gamer de qualité à très bon prix."}', 879.67, 254, 'Asus', '{"souscategorie_nom": "Ordinateur", "categorie_nom": "Informatique"}'),
        ('HP 15-DC1066NF', '{"produit_description_short": "Ordinateur portable Gamer", "produit_description_long": "Ce PC portable Gamer haut de gamme vous permettre de jouer aux meilleurs jeux facilement et en haute résolution."}', 1469.99, 367, 'HP', '{"souscategorie_nom": "Ordinateur", "categorie_nom": "Informatique"}'),
        ('Acer PH315-52-56SX', '{"produit_description_short": "Ordinateur portable Gamer", "produit_description_long": "Ce PC portable Gamer haut de gamme vous permettre de jouer aux meilleurs jeux facilement et en haute résolution."}', 1439.87, 112, 'Acer', '{"souscategorie_nom": "Ordinateur", "categorie_nom": "Informatique"}'),
        ('Asus Vivobook R509JA-EJ032T', '{"produit_description_short": "Ordinateur portable", "produit_description_long": "Ce PC portable est fait pour vos actions de bureautique. Haut de gamme il tiendra longtemps et sera efficace."}', 799.99, 112, 'Asus', '{"souscategorie_nom": "Ordinateur", "categorie_nom": "Informatique"}'),
        ('Samsung RB31FERNCSA', '{"produit_description_short": "Réfrigérateur congélateur en bas", "produit_description_long": "Un congélateur assez grand pour pouvoir cacher un corps à l intérieur."}', 549.99, 306, 'Samsung', '{"souscategorie_nom": "Réfrigérateur", "categorie_nom": "Electroménager"}'),
        ('Beko RCNA340K20S SILVER', '{"produit_description_short": "Réfrigérateur congélateur en bas", "produit_description_long": ""}', 334.67, 304, 'Beko', '{"souscategorie_nom": "Réfrigérateur", "categorie_nom": "Electroménager"}'),
        ('Proline PSBS92IX', '{"produit_description_short": "Réfrigérateur congélateur en bas", "produit_description_long": ""}', 549.00, 287, 'Proline', '{"souscategorie_nom": "Réfrigérateur", "categorie_nom": "Electroménager"}'),
        ('LG GBB61DSJZN', '{"produit_description_short": "Télévision LED UHD 4K", "produit_description_long": "Encore une télivision 4K UHC, pas très originale mais au moins c est une LG."}', 699.99, 298, 'LG', '{"souscategorie_nom": "Réfrigérateur", "categorie_nom": "Electroménager"}'),
        ('LG 55C9', '{"produit_description_short": "Télévision LED UHD 4K", "produit_description_long": "Encore une télévision mais peu chère cette fois."}', 334.67, 112, 'LG', '{"souscategorie_nom": "TV", "categorie_nom": "Loisirs"}'),
        ('Proline PLCH104', '{"produit_description_short": "Congélateur coffre", "produit_description_long": "Un énorme congélateur pour congeler"}', 159.90, 168, 'Proline', '{"souscategorie_nom": "Congélateur", "categorie_nom": "Electroménager"}'),
        ('Proline DW 486 WHITE', '{"produit_description_short": "Lave-vaisselle bon marché", "produit_description_long": "Un lave-vaisselle pour vous éviter de faire la vaisselle, parce que la vaisselle c est long à faire."}', 159.90, 258, 'Proline', '{"souscategorie_nom": "Lave-vaisselle", "categorie_nom": "Electroménager"}'),
        ('Thomson TDW 6047 WH', '{"produit_description_short": "Lave-vaisselle haut de gamme", "produit_description_long": "Un lave-vaisselle très cher qui fera la vaisselle à votre place."}', 349.90, 266, 'Thomson', '{"souscategorie_nom": "Lave-vaisselle", "categorie_nom": "Electroménager"}'),
        ('Canon PIXMA TS8251', '{"produit_description_short": "Imprimante à jet d encre", "produit_description_long": "Cette imprimante est bon marché mais après vous devrez acheter beaucoup de cartouches d encre/"}', 109.90, 158, 'Canon', '{"souscategorie_nom": "Imprimante", "categorie_nom": "Informatique"}'),
        ('HP LaserJet Pro M283FDW', '{"produit_description_short": "Imprimante laser", "produit_description_long": "Une très bonne imprimante laser pour imprimer vos cours chez vous et ne plus aller au Polar."}', 159.90, 168, 'HP', '{"souscategorie_nom": "Imprimante", "categorie_nom": "Informatique"}'),
        ('Dyson CYCLONE V10 ABSOLUTE', '{"produit_description_short": "Aspirateur balai", "produit_description_long": "Un aspirateur cher, très cher. Après tout c est un aspirateur. Avez-vous besoin de mettre autant d argent juste pour aspirateur ?"}', 499.90, 108, 'Dyson', '{"souscategorie_nom": "Aspirateur", "categorie_nom": "Electroménager"}'),
        ('Rowenta RO7455EA', '{"produit_description_short": "Aspiratteur avec sac", "produit_description_long": "Un aspirateur avez sac comme ça vous devrez acheter des sacs et polluer la planète."}', 199.90, 117, 'Rowenta', '{"souscategorie_nom": "Aspirateur", "categorie_nom": "Electroménager"}'),
        ('Irobot ROOMBA I7', '{"produit_description_short": "Aspirateur robot", "produit_description_long": "Un aspirateur robot comme ça vous n aurez même plus besoin de passer l aspirateur."}', 599.90, 268, 'Irobot', '{"souscategorie_nom": "Aspirateur", "categorie_nom": "Electroménager"}'),
        ('Hoover HF122PTA', '{"produit_description_short": "Aspirateur balai", "produit_description_long": "Un aspirateur balai... En fait c est un aspirateur qui ressemble un peu à un balai du coup on appelle ça comme ça."}', 159.00, 1303, 'Hoover', '{"souscategorie_nom": "Aspirateur", "categorie_nom": "Electroménager"}'),
        ('Miele NEW Compact C2 Silence E', '{"produit_description_short": "Aspirateur avec sac", "produit_description_long": ""}', 249.99, 181, 'Miele', '{"souscategorie_nom": "Aspirateur", "categorie_nom": "Electroménager"}');


INSERT INTO public.FactureFournisseur(facture_montant, facture_payee, id_fournisseur, id_membre_service_achat) VALUES
        (1369.99, 1, 2, 3),
        (1510.09, 0, 2, 3),
        (609.34, 1, 4, 3),
        (709.60, 1, 3, 3),
        (699.69, 1, 1, 3),
        (2237.33, 1, 1, 3);

INSERT INTO public.OccurrenceDeProduitFournisseur(produit_reference, id_facture, occurrence_de_produit_prix, id_fournisseur) VALUES
        ('HP 15-DC1066NF', NULL, 1369.99, 2),
        ('HP 15-DC1066NF', NULL, 1369.99, 2),
        ('HP 15-DC1066NF', 1, 1369.99, 2),
        ('HP 15-DC1066NF', NULL, 1369.99, 2),
        ('HP 15-DC1066NF', 2, 1369.99, 2),
        ('HP 15-DC1066NF', NULL, 1369.99, 2),
        ('HP 15-DC1066NF', NULL, 1369.99, 2),
        ('HP 15-DC1066NF', NULL, 1369.99, 2),
        ('HP 15-DC1066NF', NULL, 1369.99, 2),
        ('HP 15-DC1066NF', NULL, 1369.99, 2),
        ('HP 15-DC1066NF', NULL, 1369.99, 3),
        ('HP 15-DC1066NF', 6, 1369.99, 1),
        ('HP 15-DC1066NF', NULL, 1369.99, 4),
        ('HP 15-DC1066NF', NULL, 1369.99, 2),
        ('HP 15-DC1066NF', NULL, 1369.99, 2),
        ('Proline PLCH104', NULL, 140.10, 1),
        ('Proline PLCH104', NULL, 140.10, 2),
        ('Proline PLCH104', 2, 140.10, 2),
        ('LG 55C9', NULL, 314.67, 3),
        ('LG 55C9', 6, 314.67, 1),
        ('LG 55C9', NULL, 314.67, 3),
        ('LG 55C9', 3, 304.67, 4),
        ('LG 55C9', 3, 304.67, 4),
        ('LG 55C9', NULL, 304.67, 4),
        ('Asus Vivobook R509JA-EJ032T', 5, 699.69, 1),
        ('Asus Vivobook R509JA-EJ032T', NULL, 799.99, 2),
        ('Asus Vivobook R509JA-EJ032T', 4, 709.60, 3),
        ('Philips 43PFS5503', NULL, 334.67, 1),
        ('Philips 43PFS5503', NULL, 334.67, 1),
        ('Philips 43PFS5503', NULL, 334.67, 2),
        ('Philips 43PFS5503', NULL, 334.67, 2),
        ('Philips 43PFS5503', 6, 334.67, 1),
        ('Philips 43PFS5503', NULL, 334.67, 4),
        ('Philips 43PFS5503', NULL, 334.67, 3),
        ('Philips 43PFS5503', NULL, 334.67, 1),
        ('Canon PIXMA TS8251', NULL, 109.0, 1),
        ('Canon PIXMA TS8251', NULL, 109.0, 1),
        ('Canon PIXMA TS8251', NULL, 99.0, 3),
        ('Canon PIXMA TS8251', NULL, 87.0, 2),
        ('Canon PIXMA TS8251', 6, 109.0, 1),
        ('Canon PIXMA TS8251', NULL, 109.0, 1),
        ('Canon PIXMA TS8251', 6, 109.0, 1),
        ('Canon PIXMA TS8251', NULL, 109.0, 1);

-- MONTANT = (SOMME(PRIX_PRODUITS) - REMISES DIRECTES) - REMISE POURCENTAGE

INSERT INTO public.FacturePersonne(id_personne, facture_montant, facture_payee, id_membre_service_vente) VALUES
        (5, 96.03, 1, 7),
        (3, 407.60, 1, 7),
        (6, 984.74, 1, 7),
        (1, 766.30, 1, 7),
        (1, 430.20, 1, 7),
        (1, 0.0, 1, 7);

INSERT INTO public.OccurrenceDeProduitEntreprise(produit_reference, id_facture, occurrence_de_produit_extension_de_garantie, occurrence_de_produit_montant_extension_de_garantie, occurrence_de_produit_prix, occurrence_de_produit_montant_installation_par_specialiste, id_membre_service_achat) VALUES
        ('Brandt B5006UHD', 2, 1, 50, 430.20, 10, 3),
        ('Brandt B5006UHD', 5, 0, 50, 430.20, 10, 3),
        ('Brandt B5006UHD', NULL, 0, 50, 430.20, 10, 3),
        ('Brandt B5006UHD', NULL, 0, 50, 430.20, 10, 3),
        ('Brandt B5006UHD', 3, 0, 50, 430.20, 10, 3),
        ('Brandt B5006UHD', NULL, 0, 50, 430.20, 10, 3),
        ('Brandt B5006UHD', NULL, 0, 50, 430.20, 10, 3),
        ('LG 55C9', NULL, 0, NULL, 314.67, NULL, 3),
        ('LG 55C9', NULL, 0, NULL, 314.67, NULL, 3),
        ('LG 55C9', NULL, 0, NULL, 314.67, NULL, 3),
        ('Canon PIXMA TS8251', 1, 0, NULL, 109.0, NULL, 3),
        ('Canon PIXMA TS8251', NULL, 0, NULL, 109.0, NULL, 3),
        ('Canon PIXMA TS8251', NULL, 0, NULL, 109.0, NULL, 3),
        ('Canon PIXMA TS8251', NULL, 0, NULL, 109.0, NULL, 3),
        ('Canon PIXMA TS8251', NULL, 0, NULL, 109.0, NULL, 3),
        ('Canon PIXMA TS8251', NULL, 0, NULL, 109.0, NULL, 3),
        ('Samsung RB31FERNCSA', NULL, 0, 50, 594.99, NULL, 3),
        ('Samsung RB31FERNCSA', NULL, 0, 50, 594.99, NULL, 3),
        ('Samsung RB31FERNCSA', NULL, 0, 50, 594.99, NULL, 3),
        ('Samsung RB31FERNCSA', NULL, 0, 50, 594.99, NULL, 3),
        ('Samsung RB31FERNCSA', NULL, 0, 50, 594.99, NULL, 3),
        ('Samsung RB31FERNCSA', NULL, 0, 50, 594.99, NULL, 3),
        ('Samsung RB31FERNCSA', 3, 1, 50, 594.99, NULL, 3),
        ('Samsung RB31FERNCSA', NULL, 0, 50, 594.99, NULL, 3),
        ('Thomson TDW 6047 WH', NULL, 0, NULL, 349.90, NULL, 3),
        ('Thomson TDW 6047 WH', NULL, 0, NULL, 349.90, NULL, 3),
        ('Thomson TDW 6047 WH', NULL, 0, NULL, 349.90, NULL, 3),
        ('Thomson TDW 6047 WH', NULL, 0, NULL, 349.90, NULL, 3),
        ('Acer PH315-52-56SX', NULL, 0, NULL, 1439.87, NULL, 3),
        ('Acer PH315-52-56SX', NULL, 0, NULL, 1439.87, NULL, 3),
        ('Acer PH315-52-56SX', NULL, 0, NULL, 1439.87, NULL, 3),
        ('Acer PH315-52-56SX', NULL, 0, NULL, 1439.87, NULL, 3),
        ('Acer PH315-52-56SX', NULL, 0, NULL, 1439.87, NULL, 3),
        ('Acer PH315-52-56SX', NULL, 0, NULL, 1439.87, NULL, 3),
        ('Acer PH315-52-56SX', NULL, 0, NULL, 1439.87, NULL, 3),
        ('Asus Vivobook R509JA-EJ032T', NULL, 0, NULL, 799.99, NULL, 3),
        ('Asus Vivobook R509JA-EJ032T', 4, 0, NULL, 799.99, NULL, 3),
        ('Asus Vivobook R509JA-EJ032T', NULL, 0, NULL, 799.99, NULL, 3),
        ('Asus Vivobook R509JA-EJ032T', NULL, 0, NULL, 799.99, NULL, 3),
        ('Asus Vivobook R509JA-EJ032T', NULL, 0, NULL, 799.99, NULL, 3),
        ('Asus Vivobook R509JA-EJ032T', NULL, 0, NULL, 799.99, NULL, 3);

INSERT INTO public.Remise(id_personne, id_membre_service_vente, id_membre_SAV, remise_montant, remise_type, remise_date_fin, remise_nombre_utilisations) VALUES
        (NULL, 7, NULL, 10.00, 'promotion', NULL, NULL),
        (NULL, 7, NULL, 3, 'pourcentage', NULL, NULL),
        (1, NULL, 1, 430.20, 'avoir', NULL, 1),
        (2, NULL, 1, 299.99, 'garantie', NULL, 0);

INSERT INTO public.FacturePersonneRemise(id_facture, id_remise) VALUES
        (1, 1),
        (1, 2),
        (2, 1),
        (2, 2),
        (3, 1),
        (3, 2),
        (4, 1),
        (4, 2),
        (6, 4);

INSERT INTO public.TicketSAV(id_facture, occurrence_de_produit_numero_de_serie, ticket_sav_statut, ticket_sav_issue, id_membre_SAV) VALUES
        (5, 2, 'done', 'remise', 1),
        (3, 5, 'done', 'retour', 1),
        (4, 37, 'done', 'reparation', 1),
        (2, 1, 'done', 'reparation', 1),
        (3, 5, 'in progress', NULL, 1);

INSERT INTO public.Reparation(id_ticket_sav, reparation_date_entree, reparation_date_sortie, reparaton_materiel_utilise, reparaton_montant, id_membre_service_vente, id_facture) VALUES
        (3, '2020-05-28 04:05:06', '2020-05-29 16:05:06', 'Ciseaux', 299.99, 7, 6),
        (5, '2020-05-26 04:05:06', NULL, 'Pâte à fixe', 199.99, NULL, NULL);

INSERT INTO public.BonDeCommande(id_membre_service_vente, id_membre_service_achat, bon_de_commande_date_creation, bon_de_commande_date_traitement) VALUES
        (7, 3, '2020-05-28 04:05:06', '2020-05-29 16:05:06'),
        (7, 3, '2020-05-24 04:05:06', '2020-05-27 19:05:06'),
        (7, 3, CURRENT_TIMESTAMP, NULL);

INSERT INTO public.BonDeCommandeProduit(id_bon_de_commande, produit_reference, bon_de_commande_produit_quantite) VALUES
        (1, 'HP 15-DC1066NF', 3),
        (1, 'Asus Vivobook R509JA-EJ032T', 1),
        (2, 'LG 55C9', 3),
        (3, 'Rowenta RO7455EA', 10);


-- CREATION DES VUES
-- PostgreSQL/JSON

CREATE VIEW public.V_Personne AS
	(SELECT
		id_personne,
		personne_nom,
		personne_prenom,
		personne_date_de_naissance,
		personne_email,

		personne_adresse->>'numero' AS personne_adresse_numero,
		personne_adresse->>'rue' AS personne_adresse_rue,
		personne_adresse->>'code_postal' AS personne_adresse_code_postal,
		personne_adresse->>'ville' AS personne_adresse_ville

		FROM public.Personne);

CREATE VIEW public.V_Fournisseur AS
	(SELECT
		id_fournisseur,
		fournisseur_nom,

		fournisseur_adresse->>'numero' AS fournisseur_adresse_numero,
		fournisseur_adresse->>'rue' AS fournisseur_adresse_rue,
		fournisseur_adresse->>'code_postal' AS fournisseur_adresse_code_postal,
		fournisseur_adresse->>'ville' AS fournisseur_adresse_ville
		FROM public.Fournisseur);

CREATE VIEW public.V_Produit AS
	(SELECT
		produit_reference,
		produit_description->>'produit_description_short' AS produit_description_short,
		produit_description->>'produit_description_long' AS produit_description_long,
		produit_prix_de_reference,
		produit_consommation,
		produit_marque,
		produit_categorie->>'souscategorie_nom' AS souscategorie_nom,
		produit_categorie->>'categorie_nom' AS categorie_nom

		FROM public.Produit);

    -- EN LIEN AVEC L'HERITAGE PAR REFERENCE DE Personne

CREATE VIEW public.V_MembreEntreprise AS
  (SELECT public.V_Personne.id_personne, personne_nom, personne_prenom, personne_date_de_naissance, personne_email, personne_adresse_numero, personne_adresse_rue, personne_adresse_code_postal, personne_adresse_ville, membre_entreprise_date_arrivee, membre_entreprise_date_depart FROM public.MembreEntreprise
    INNER JOIN public.V_Personne ON  public.MembreEntreprise.id_personne = public.V_Personne.id_personne);

CREATE VIEW public.V_MembreServiceAchat AS
	(SELECT public.V_Personne.id_personne, public.V_Personne.personne_nom, public.V_Personne.personne_prenom, public.V_Personne.personne_date_de_naissance, public.V_Personne.personne_email, public.V_Personne.personne_adresse_numero, public.V_Personne.personne_adresse_rue, public.V_Personne.personne_adresse_code_postal, public.V_Personne.personne_adresse_ville, membre_entreprise_date_arrivee, membre_entreprise_date_depart, membre_service_achat_date_arrivee, membre_service_achat_date_depart FROM public.MembreServiceAchat
		INNER JOIN public.V_MembreEntreprise ON public.V_MembreEntreprise.id_personne = public.MembreServiceAchat.id_personne
		INNER JOIN public.V_Personne ON  V_MembreEntreprise.id_personne = public.V_Personne.id_personne);

CREATE VIEW public.V_MembreServiceVente AS
	(SELECT public.V_Personne.id_personne, public.V_Personne.personne_nom, public.V_Personne.personne_prenom, public.V_Personne.personne_date_de_naissance, public.V_Personne.personne_email, public.V_Personne.personne_adresse_numero, public.V_Personne.personne_adresse_rue, public.V_Personne.personne_adresse_code_postal, public.V_Personne.personne_adresse_ville, membre_entreprise_date_arrivee, membre_entreprise_date_depart, membre_service_vente_date_arrivee, membre_service_vente_date_depart FROM public.MembreServiceVente
		INNER JOIN public.V_MembreEntreprise ON public.V_MembreEntreprise.id_personne = public.MembreServiceVente.id_personne
		INNER JOIN public.V_Personne ON  V_MembreEntreprise.id_personne = public.V_Personne.id_personne);

CREATE VIEW public.V_MembreSAV AS
	(SELECT public.V_Personne.id_personne, public.V_Personne.personne_nom, public.V_Personne.personne_prenom, public.V_Personne.personne_date_de_naissance, public.V_Personne.personne_email, public.V_Personne.personne_adresse_numero, public.V_Personne.personne_adresse_rue, public.V_Personne.personne_adresse_code_postal, public.V_Personne.personne_adresse_ville, membre_entreprise_date_arrivee, membre_entreprise_date_depart, membre_sav_date_arrivee, membre_sav_date_depart FROM public.MembreSAV
		INNER JOIN public.V_MembreEntreprise ON public.V_MembreEntreprise.id_personne = public.MembreSAV.id_personne
		INNER JOIN public.V_Personne ON  public.V_MembreEntreprise.id_personne = public.V_Personne.id_personne);

-- EN LIEN AVEC LE SUJET

CREATE VIEW public.V_ProduitsLesPlusVendus AS
	(SELECT nombre_de_ventes,
	   produit_reference,
	   produit_description->>'produit_description_short' AS produit_description_short,
	   produit_description->>'produit_description_long' AS produit_description_long,
	   produit_prix_de_reference,
	   produit_consommation,
	   produit_marque,
	   produit_categorie->>'souscategorie_nom' AS souscategorie_nom,
	   produit_categorie->>'categorie_nom' AS categorie_nom FROM
		(SELECT count(*) AS nombre_de_ventes, public.Produit.produit_reference, produit_description, produit_prix_de_reference, produit_consommation, produit_marque, produit_categorie FROM public.OccurrenceDeProduitEntreprise
			INNER JOIN public.Produit ON public.Produit.produit_reference = public.OccurrenceDeProduitEntreprise.produit_reference
		WHERE id_facture IS NOT NULL
		GROUP BY public.Produit.produit_reference) AS request
			ORDER BY nombre_de_ventes DESC);

CREATE VIEW public.V_ProduitsAvecLePlusDePannes AS
	(SELECT nombre_de_pannes,
	   produit_reference,
	   produit_description->>'produit_description_short' AS produit_description_short,
	   produit_description->>'produit_description_long' AS produit_description_long,
	   produit_prix_de_reference,
	   produit_consommation,
	   produit_marque,
	   produit_categorie->>'souscategorie_nom' AS souscategorie_nom,
	   produit_categorie->>'categorie_nom' AS categorie_nom FROM
		(SELECT count(*) AS nombre_de_pannes, Produit.produit_reference, produit_description, produit_prix_de_reference, produit_consommation, produit_marque, produit_categorie FROM public.TicketSAV
			INNER JOIN public.OccurrenceDeProduitEntreprise ON public.OccurrenceDeProduitEntreprise.occurrence_de_produit_numero_de_serie = public.TicketSAV.occurrence_de_produit_numero_de_serie
			INNER JOIN public.Produit ON public.OccurrenceDeProduitEntreprise.produit_reference = public.Produit.produit_reference
		GROUP BY public.Produit.produit_reference) AS request
			ORDER BY nombre_de_pannes DESC);

CREATE VIEW V_PanierMoyen AS
	(SELECT montant_total, nombre_de_factures, panier_moyen, V_Personne.id_personne, V_Personne.personne_nom, V_Personne.personne_prenom, V_Personne.personne_date_de_naissance, V_Personne.personne_email, V_Personne.personne_adresse_numero, V_Personne.personne_adresse_rue, V_Personne.personne_adresse_code_postal, V_Personne.personne_adresse_ville FROM
		(SELECT SUM(facture_montant) AS montant_total, count(*) AS nombre_de_factures, avg(facture_montant) AS panier_moyen, public.FacturePersonne.id_personne FROM public.FacturePersonne
			GROUP BY id_personne) AS request
			INNER JOIN public.V_Personne ON request.id_personne = public.V_Personne.id_personne
				ORDER BY panier_moyen DESC);

CREATE VIEW public.V_PanierMoyenGlobal AS
	(SELECT avg(panier_moyen) AS panier_moyen_global FROM V_PanierMoyen);


-- PERMET DE SAVOIR LE MONTANT TOTAL DE REDUCTION QU'A PRODUIT UN MEMBRE DU SERVICE VENTE OU UN MUMBRE DU SAV
-- SI LA REDUCTION EST UN POURCENTAGE, ON CALCULE COMBIEN CE POURCENTAGE A GENERE DE REDUCTION

CREATE VIEW public.V_TotalRemiseVendeur AS
	((SELECT public.Remise.id_membre_service_vente, public.Remise.id_membre_SAV, sum(public.Remise.remise_montant) AS montant_total, remise_type FROM public.FacturePersonneRemise
		INNER JOIN public.Remise ON public.FacturePersonneRemise.id_remise = public.Remise.id_remise
		INNER JOIN public.FacturePersonne ON public.FacturePersonneRemise.id_facture = public.FacturePersonne.id_facture

			WHERE remise_type != 'pourcentage'

			GROUP BY public.Remise.id_membre_service_vente, public.Remise.id_membre_SAV, public.Remise.remise_type)

	UNION

	(SELECT id_membre_service_vente, id_membre_SAV, sum(remise_montant) AS montant_total, remise_type FROM

		(SELECT public.Remise.id_membre_service_vente, public.Remise.id_membre_SAV, ((facture_montant/(1 - (remise_montant/100))) - facture_montant) AS remise_montant, facture_montant, remise_type FROM public.FacturePersonneRemise
			INNER JOIN public.Remise ON public.FacturePersonneRemise.id_remise = public.Remise.id_remise
			INNER JOIN public.FacturePersonne ON public.FacturePersonneRemise.id_facture = public.FacturePersonne.id_facture

				WHERE remise_type = 'pourcentage') AS request

		GROUP BY id_membre_service_vente, id_membre_SAV, remise_type));


-- VUES UTILES

CREATE VIEW public.V_FactureMontantBrut AS
	(SELECT sum(occurrence_de_produit_prix) AS facture_montant_brut, id_facture FROM public.OccurrenceDeProduitEntreprise
		GROUP BY id_facture
		ORDER BY id_facture);

-- GESTION DES DROITS

CREATE ROLE UserMembreEntreprise;
CREATE ROLE UserMembreServiceAchat;
CREATE ROLE UserMembreServiceVente;
CREATE ROLE UserMembreSAV;

-- Il n'y a pas de secret dans l'entreprise tout le monde peut tout voir
-- En théorie il n'y a aucune suppression de données de la base. En revanche il peut arriver qu'un utilisateur se trompe lorsqu'il ajouter des données et qu'il veuille les supprimer directement d'où le DELETE.

GRANT SELECT
ON public.Personne, public.MembreEntreprise, public.MembreSAV, public.MembreServiceAchat, public.Fournisseur, public.Produit, public.FactureFournisseur, public.FacturePersonne, public.OccurrenceDeProduitEntreprise, public.OccurrenceDeProduitFournisseur, public.Remise, public.FacturePersonneRemise, public.TicketSAV, public.Reparation, public.BonDeCommande, public.BonDeCommandeProduit, public.V_MembreEntreprise, public.V_MembreServiceAchat, public.V_MembreServiceVente, public.V_MembreSAV, public.V_ProduitsLesPlusVendus, public.V_ProduitsAvecLePlusDePannes, public.V_PanierMoyen, public.V_PanierMoyenGlobal, public.V_TotalRemiseVendeur, public.V_FactureMontantBrut
TO UserMembreEntreprise, UserMembreServiceAchat, UserMembreServiceVente, UserMembreSAV;

-- Tout le monde peut ajouter des clients et les modifier
-- La gestion des membres de l'entreprise se fait par des membres de l'entreprise

GRANT INSERT, UPDATE, DELETE
ON public.Personne, public.MembreEntreprise, public.MembreServiceAchat, public.MembreServiceVente, public.MembreSAV
TO UserMembreEntreprise, UserMembreServiceAchat, UserMembreServiceVente, UserMembreSAV;

-- Tout le monde peut ajouter des fournisseurs et des produits

GRANT INSERT, UPDATE, DELETE
ON public.Fournisseur, public.Produit
TO UserMembreEntreprise, UserMembreServiceAchat, UserMembreServiceVente, UserMembreSAV;

-- Selon les droits du membre du service achat définis dans la NDC
-- Il peut regarder les produits dans le bon de commande mais il ne peut pas les modifier (d'où l'absence de BonDeCommandeProduit)
-- Il met à jour le bon de commande (il l'indique comme traité) seulement

GRANT INSERT, UPDATE, DELETE
ON public.FactureFournisseur, public.OccurrenceDeProduitFournisseur
TO UserMembreServiceAchat;

GRANT UPDATE ON public.BonDeCommande TO UserMembreServiceAchat;

-- Selon les droits du membre du service cente définis dans la NDC
-- Il facture les réparation mais ne réalise pas, il se contente de modifier les réparations déjà existantes en indiquant si elles ont été facturées.

GRANT INSERT, UPDATE, DELETE
ON public.FacturePersonne, public.OccurrenceDeProduitEntreprise, public.Remise, public.FacturePersonneRemise, public.BonDeCommande, public.BonDeCommandeProduit
TO UserMembreServiceVente;

GRANT UPDATE ON public.Reparation TO UserMembreServiceVente;

-- Selon les droits du membre du SAV définis dans la NDC

GRANT INSERT, UPDATE
ON public.Remise, public.TicketSAV, public.Reparation
TO UserMembreSAV;


-- OPTIMISATION
-- En lien avec les informations données sur cette page sur l'Optimisation SQL : https://sql.sh/optimisation

-- Utilisation d’une clé primaire (PRIMARY KEY) de type numérique avec une auto-incrémentation (AUTO_INCREMENT) (revient à utiliser SERIAL) fait
-- Stocker dans une nouvelle table les données textuelles qui sont trop répétées, et les lier avec une jointure. fait (mais inutile pour Produit.produit_reference)
-- Indexer les données qui sont utilisées dans WHERE, JOIN, ORDER BY et GROUP BY
--    indexation de Remise.remise_type -> CREATE INDEX IX_Remise_remise_type ON Remise (remise_type)
--    indexation de OccurrenceDeProduitEntreprise.id_facture -> CREATE INDEX IX_OccurrenceDeProduitEntreprise_id_facture ON OccurrenceDeProduitEntreprise(id_facture)
--    indexation de FacturePersonne.id_personne -> CREATE INDEX IX_FacturePersonne_id_personne ON FacturePersonne (id_personne)
-- Eviter les index pour les colonnes de type BLOB ou les champs de texte libre. fait
-- Utiliser un index de type UNIQUE pour les colonnes qui doivent contenir des données uniques et que vous souhaitez être sûr qu’il n’y aura pas de doublon superflu. fait
-- Eviter les lectures via “SELECT *” en privilégiant plutôt de lister uniquement les colonnes qui seront exploitées. fait
-- Eviter de compter une colonne (cf. “SELECT COUNT(colonne) FROM table) lorsqu’il faut compter le nombre d’enregistrement (cf. “SELECT COUNT(*) FROM table). fait

END TRANSACTION;
