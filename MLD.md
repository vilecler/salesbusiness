# MLD #

## Plan du document ##
- Liste des relations
- Liste des contraintes
- Choix d'héritages
- Vues
- Liste des relations avec leurs contraintes respectives *(afin d'offrir un second choix de présentation en fonction des préférences de chacun)*
- Normalisation

## Liste des relations ##
Les relations provenant d'une association ont été nommée à partir des deux relations qu'elles associent. Par exemple, l'association N:M entre FacturePersonne et Remise est nommée FacturePersonneRemise.

- **Personne**(#id_personne:integer, personne_nom:string, personne_prenom:string, personne_date_de_naissance:date, personne_email:string, personne_adresse:Adresse)
- **FacturePersonne**(#id_facture:integer, #id_personne=>Personne.id_personne, facture_montant_total:float, facture_date:date, facture_payee:{0,1}, id_membre_service_vente=>MembreServiceVente.id_personne)
    - FacturePersonne est une composition de Personne mais à causes des différentes références à id_facture de FacturePersonne et des trop nombreuses contraintes, il est impossible d'utiliser JSON
- **FacturePersonneRemise**(#id_facture=>FacturePersonne.id_personne, #id_remise=>Remise.id_remise)
- **FactureFournisseur**(#id_facture:integer, facture_montant_total:float, facture_date:date, facture_payee:{0,1}, id_fournisseur=>Fournisseur.id_fournisseur, id_membre_service_achat=>MembreServiceAchat.id_personne)
- **Produit**(#produit_reference:string, produit_description:Description, produit_prix_de_reference:float, produit_consommation:float, produit_marque:string, produit_categorie:Categorie)
- **OccurrenceDeProduitEntreprise**(#occurrence_de_produit_numero_de_serie:int, produit_reference=>Produit.produit_reference, id_facture=>FacturePersonne.id_facture, occurrence_de_produit_extension_de_garantie:integer, occurrence_de_produit_montant_extension_de_garantie:float, occurrence_de_produit_prix:float, occurrence_de_produit_montant_installation_par_specialiste:float, id_membre_service_achat=>MembreDuServiceAchat.id_personne)
- **OccurrenceDeProduitFournisseur**(#occurrence_de_produit_numero_de_serie:int, produit_reference=>Produit.produit_reference, id_facture=>FactureFournisseur.id_facture, occurrence_de_produit_prix:float, id_fournisseur=>Fournisseur.id_fournisseur)
- **Fournisseur**(#id_fournisseur:integer, fournisseur_nom:string, fournisseur_adresse:Adresse)
- **TicketSAV**(#id_ticket_sav:integer, id_facture=>FacturePersonne.id_facture, occurrence_de_produit_numero_de_serie=>OccurrenceDeProduitEntreprise.occurrence_de_produit_numero_de_serie, ticket_sav_date:date, ticket_sav_statut:{done, in progress, todo}, ticket_sav_issue:{retour, reparation, remise, NULL}, id_membre_SAV=>MembreDuSAV.id_personne)
- **Reparation**(#id_reparation:integer, #id_ticket_sav=>TicketSAV.id_ticket_sav, reparation_date_entree:date, reparation_date_sortie:date, reparaton_materiel_utilise:string, reparaton_montant:float, id_membre_service_vente=>MembreServiceVente.id_personne, id_facture=>FacturePersonne.id_facture)
    - La facturation doit se faire par un membre du service de vente, il y a un décalage dans le temps entre le moment où le SAV répare et où le service de vente facture (même sous garantie). Pour s'y retrouver, on doit savoir quelles réparations ont été facturées.
    - Reparation est une composition de TicketSAV mais à cause de la référence à id_facture et des nombreuses contraintes il sera impossible d'utiliser du JSON pour représenter cette classe
- **BonDeCommande**(#id_bon_de_commande:integer, id_membre_service_vente=>MembreServiceVente.id_personne, id_membre_service_achat=>MembreServiceAchat.id_personne, bon_de_commande_date_creation:date, bon_de_commande_date_traitement:date)
- **BonDeCommandeProduit**(#id_bon_de_commande=>BonDeCommande.id_bon_de_commande, #produit_reference=>Produit.produit_reference, bon_de_commande_produit_quantite:integer)
- **Remise**(#id_remise:integer, id_personne=>Personne.id_personne, id_membre_service_vente=>MembreServiceVente.id_personne, id_membre_SAV=>MembreDuSAV.id_personne, remise_montant:float, remise_type:{avoir, garantie, promotion, pourcentage}, remise_date_debut:date, remise_date_fin:date, remise_nombre_utilisations:integer)
- **MembreDeLEntreprise**(#id_personne=>Personne.id_personne, membre_entreprise_date_arrivee: date, membre_entreprise_date_depart:date)
- **MembreDuServiceAchat**(#id_personne=>MembreDeLEntreprise.id_personne, membre_service_achat_date_arrivee:date, membre_service_achat_date_depart:date)
- **MembreDuServiceVente**(#id_personne=>MembreDeLEntreprise.id_personne, membre_service_vente_date_arrivee:date, membre_service_vente_date_depart:date)
- **MembreDuSAV**(#id_personne=>MembreDeLEntreprise.id_personne, membre_SAV_date_arrivee:date, membre_SAV_date_depart:date)

## Liste des Contraintes : ##
On considère tous les attributs comme NOT NULL, sinon il le sera spécifié.  
Les contraintes de clé étrangère sont déjà représentées dans la relation.

- **Personne**
    - id_personne UNIQUE
    - (personne_nom, personne_prenom, personne_dateDeNaissance) UNIQUE
    - personne_adresse est une composition de type Adresse de Personne, on pourra utiliser du JSON pour représenter cet attribut
- **FacturePersonne**
    - id_facture UNIQUE
    - facture_montant_total >= 0
    - facture_payee = 0 OR facture_payee = 1
- **FactureFournisseur**
    - id_facture UNIQUE
    - facture_montant_total >= 0
    - facture_payee = 0 OR facture_payee = 1
- **Produit**
    - produit_reference UNIQUE
    - produit_prix_de_reference > 0
    - produit_consommation > 0
    - produit_description est une composition de type Description de Produit, on pourra utiliser du JSON pour représenter cet attribut
    - Puisqu'une sous catégorie est une composition d'une catégorie et qu'il existe une relation 1:N entre un produit et une sous catégorie, on peut stocker la catégorie et la sous catégorie au sein d'un même attribut JSON.
- **OccurrenceDeProduitEntreprise**
    - occurrence_de_produit_numero_de_serie > 0
    - occurrence_de_produit_numero_de_serie UNIQUE
    - id_facture peut être NULL (si le produit n'est pas encore vendu)
    - occurrence_de_prouit_extension_de_garantie = 0 OR occurrence_de_prouit_extension_de_garantie = 1
    - occurrence_de_produit_montant_extension_de_garantie > 0
    - occurrence_de_produit_montant_extension_de_garantie peut être NULL (si pas d'extension de garantie)
    - occurrence_de_produit_prix > 0
    - occurrence_de_produit_montant_installation_par_specialiste > 0
    - occurrence_de_produit_montant_installation_par_specialiste peut être NULL (si pas d'installation par un spécialiste)
    - id_membre_service_vente peut être NULL (s'il n'a pas encore été vendu par un client)
- **OccurrenceDeProduitFournisseur**
    - occurrence_de_produit_numero_de_serie > 0
    - occurrence_de_produit_numero_de_serie UNIQUE
    - id_facture peut être NULL (si le produit n'est pas encore vendu)
    - occurrence_de_produit_prix > 0
- **Fournisseur**
    - id_fournisseur UNIQUE
    - fournisseur_adresse est une composition de type Adresse de Fournisseur, on pourra utiliser du JSON pour représenter cet attribut
- **TicketSAV**
   - id_ticket_sav UNIQUE
   - id_facture peut être NULL (si aucune facture facture n'a encore été faite)
   - ticket_sav_statut = done OR ticket_sav_statut = in progress OR ticket_sav_statut = todo
   - (ticket_sav_statut = done AND id_facture != NULL) OR (id_facture = NULL)
   - ticket_sav_issue = retour OR ticket_sav_issue = reparation OR ticket_sav_issue = remise OR ticket_sav_issue = NULL
- **Reparation**
    - id_reparation UNIQUE
    - id_ticket_sav UNIQUE
    - reparation_date_sortie > reparation_date_entree
    - reparaton_montant > 0
    - id_membre_service_vente peut être NULL (quand la réparation n'a pas encore été facturée, elle DOIT être facturée par un membre du service vente)
- **BonDeCommande**
    - id_bon_de_commande UNIQUE
    - id_membre_service_achat peut être NULL (quand le bon de commande n'a pas encore été traité)
    - bon_de_commande_date_creation <= bon_de_commande_date_traitement
    - bon_de_commande_date_traitement peut être NULL (lorsqu'il n'a pas encore été traité)
- **BonDeCommandeProduit**
    - bon_de_commande_produit_quantite > 0 
- **Remise**
    - id_remise UNIQUE
    - id_personne peut être NULL (quand elle ne concerne pas un client en particulier)
    - id_membre_SAV peut être NULL (quand elle n'est pas créée par un membre du SAV)
    - id_membre_service_vente peut être NULL (quand elle n'est pas créée par un membre du service vente)
    - id_membre_SAV = NULL XOR id_membre_service_vente = NULL
    - remise_montant > 0
    - remise_type = avoir OR remise_type = garantie OR remise_type = promotion OR remise_type = pourcentage
    - ((remise_type = 'avoir' AND remise_nombre_utilisations IS NOT NULL) OR ( remise_type = 'garantie' AND remise_nombre_utilisations IS NOT NULL) OR (remise_type = 'promotion' AND remise_nombre_utilisations IS NULL) OR (remise_type = 'pourcentage' AND remise_nombre_utilisations IS NULL))
    - remise_date_debut <= remise_date_fin
    - remise_date_fin peut être NULL (quand la remise n'a pas de date de fin, qu'elle est valable à vie)
    - remise_nombre_utilisations (peut être NULL si aucune limite)
- **MembreDeLEntreprise**
    - membre_entreprise_date_depart peut être NULL (quand le membre de l'entrepris n'a pas quitté l'entreprise)
- **MembreDuServiceAchat**
    - membre_service_achat_date_depart peut être NULL (quand le membre de l'entreprise n'a pas quitté le service)
    - membre_service_achat_date_arrivee < membre_service_achat_date_depart
- **MembreDuServiceVente**
    - membre_service_vente_date_depart peut être NULL (quand le membre de l'entreprise n'a pas quitté le service)
    - membre_service_vente_date_arrivee < membre_service_vente_date_depart
- **MembreDuSAV**
    - membre_SAV_date_depart peut être NULL (quand le membre de l'entreprise n'a pas quitté le service)
    - membre_SAV_date_arrivee < membre_SAV_date_depart
- **Héritage par référence de MembreDeLEntreprise**
    - Intersection( Projection(MembreDuServiceAchat, id_membre_entreprise), Projection(MembreDuServiceVente, id_membre_entreprise), Projection(MembreDuSAV, id_membre_entreprise) ) = {} 

## Choix d'héritages : ##
- Pour Facture, on observe que cette classe est abstraite et possède deux classes filles FacturePersonne et FactureFournisseur. C'est un héritage exclusif.
    - L'héritage par classe mère n'est pas adapté ici car il faudrait, lorsque l'on parle d'une Facture, que l'on teste le type dont il s'agit (Facture.type) à partir de la clé primaire de Facture. Ce n'est pas une chose simple en relationnelle.
    - L'héritage par référence n'est pas adapté car la classe Facture est abstraite
- Pour OccurrenceDeProduit, on observe que cette classe est abstraite et possède deux classes filles OccurrenceDeProduitEntreprise et OccurrenceDeProduitFournisseur. C'est un héritage exclusif.
    - De plus l'association entre Produit et OccurrenceDeProduit peut être représenté en ajoutant une clé étrangère au niveau de chaque classe fille.
    - L'héritage par classe mère n'est pas adapté ici car il faudrait, lorsque que l'on parle d'une OccurrenceDeProduit, que l'on teste le type dont il s'agit (OccurrenceDeProduit.type) à partir de la clé primaire de OccurrenceDeProduit. Ce n'est pas une chose que nous savons faire de façon simple en relationnelle.
    - L'héritage par référence n'est pas adapté ici car la classe OccurrenceDeProduit est abstraite
- Pour Personne/MembreDeLEntreprise/MembreDuSAV+MembreDuServiceAchat+MembreDuServiceVente, on choisit un hériatage par classe fille car aucune classe n'est abstraite et chacune possède des relations avec d'autres classes. 
    - L'héritage par classe fille est impossible car les classes Personne et MembreDeLEntreprise ne sont pas abstraites
    - L'héritage par classe mère n'est pas adapté car il faudrait tester à la fois le type de Personne et le type de membre d'entreprise (seulement si le type de personne est membre de l'entreprise). Le fait d'exprimer ces contraintes sur Personne.type et Personne.typeMembreDEntreprise n'est pas simple en relationnel.

## Liste des relations + contraintes ##
Les relations provenant d'une association ont été nommée à partir des deux relations qu'elles associent. Par exemple, l'association N:M entre FacturePersonne et Remise est nommée FacturePersonneRemise.

- **Personne**(#id_personne:integer, personne_nom:string, personne_prenom:string, personne_date_de_naissance:date, personne_email:string, personne_adresse:Adresse)
    - id_personne UNIQUE
    - (personne_nom, personne_prenom, personne_dateDeNaissance) UNIQUE
    - personne_adresse est une composition de type Adresse de Personne, on pourra utiliser du JSON pour représenter cet attribut
- **FacturePersonne**(#id_facture:integer, #id_personne=>Personne.id_personne, facture_montant_total:float, facture_date:date, facture_payee:{0,1}, id_membre_service_vente=>MembreServiceVente.id_personne)
    - id_facture UNIQUE
    - facture_montant_total >= 0
    - facture_payee = 0 OR facture_payee = 1
- **FacturePersonneRemise**(#id_facture=>FacturePersonne.id_personne, #id_remise=>Remise.id_remise)
- **FactureFournisseur**(#id_facture:integer, facture_montant_total:float, facture_date:date, facture_payee:{0,1}, id_fournisseur=>Fournisseur.id_fournisseur, id_membre_service_achat=>MembreServiceAchat.id_personne)
    - id_facture UNIQUE
    - facture_montant_total >= 0
    - facture_payee = 0 OR facture_payee = 1
- **Produit**(#produit_reference:string, produit_description:Description, produit_prix_de_reference:float, produit_consommation:float, produit_marque:string, produit_categorie:Categorie)
    - produit_reference UNIQUE
    - produit_prix_de_reference > 0
    - produit_consommation > 0
    - produit_description est une composition de type Description de Produit, on pourra utiliser du JSON pour représenter cet attribut
    - Puisqu'une sous catégorie est une composition d'une catégorie et qu'il existe une relation 1:N entre un produit et une sous catégorie, on peut stocker la catégorie et la sous catégorie au sein d'un même attribut JSON.
- **OccurrenceDeProduitEntreprise**(#occurrence_de_produit_numero_de_serie:int, produit_reference=>Produit.produit_reference, id_facture=>FacturePersonne.id_facture, occurrence_de_produit_extension_de_garantie:integer, occurrence_de_produit_montant_extension_de_garantie:float, occurrence_de_produit_prix:float, occurrence_de_produit_montant_installation_par_specialiste:float, id_membre_service_achat=>MembreDuServiceAchat.id_personne)
    - occurrence_de_produit_numero_de_serie > 0
    - occurrence_de_produit_numero_de_serie UNIQUE
    - id_facture peut être NULL (si le produit n'est pas encore vendu)
    - occurrence_de_prouit_extension_de_garantie = 0 OR occurrence_de_prouit_extension_de_garantie = 1
    - occurrence_de_produit_montant_extension_de_garantie > 0
    - occurrence_de_produit_montant_extension_de_garantie peut être NULL (si pas d'extension de garantie)
    - occurrence_de_produit_prix > 0
    - occurrence_de_produit_montant_installation_par_specialiste > 0
    - occurrence_de_produit_montant_installation_par_specialiste peut être NULL (si pas d'installation par un spécialiste)
    - id_membre_service_vente peut être NULL (s'il n'a pas encore été vendu par un client)
- **OccurrenceDeProduitFournisseur**(#occurrence_de_produit_numero_de_serie:int, produit_reference=>Produit.produit_reference, id_facture=>FactureFournisseur.id_facture, occurrence_de_produit_prix:float, id_fournisseur=>Fournisseur.id_fournisseur)
    - occurrence_de_produit_numero_de_serie > 0
    - occurrence_de_produit_numero_de_serie UNIQUE
    - id_facture peut être NULL (si le produit n'est pas encore vendu)
    - occurrence_de_produit_prix > 0
- **Fournisseur**(#id_fournisseur:integer, fournisseur_nom:string, fournisseur_adresse:Adresse)
    - id_fournisseur UNIQUE
    - fournisseur_adresse est une composition de type Adresse de Fournisseur, on pourra utiliser du JSON pour représenter cet attribut
- **TicketSAV**(#id_ticket_sav:integer, id_facture=>FacturePersonne.id_facture, occurrence_de_produit_numero_de_serie=>OccurrenceDeProduitEntreprise.occurrence_de_produit_numero_de_serie, ticket_sav_date:date, ticket_sav_statut:{done, in progress, todo}, ticket_sav_issue:{retour, reparation, remise, NULL}, id_membre_SAV=>MembreDuSAV.id_personne)
   - id_ticket_sav UNIQUE
   - id_facture peut être NULL (si aucune facture facture n'a encore été faite)
   - ticket_sav_statut = done OR ticket_sav_statut = in progress OR ticket_sav_statut = todo
   - (ticket_sav_statut = done AND id_facture != NULL) OR (id_facture = NULL)
   - ticket_sav_issue = retour OR ticket_sav_issue = reparation OR ticket_sav_issue = remise OR ticket_sav_issue = NULL
- **Reparation**(#id_reparation:integer, #id_ticket_sav=>TicketSAV.id_ticket_sav, reparation_date_entree:date, reparation_date_sortie:date, reparaton_materiel_utilise:string, reparaton_montant:float, id_membre_service_vente=>MembreServiceVente.id_personne, id_facture=>FacturePersonne.id_facture)
    - id_reparation UNIQUE
    - id_ticket_sav UNIQUE
    - reparation_date_sortie > reparation_date_entree
    - reparaton_montant > 0
    - id_membre_service_vente peut être NULL (quand la réparation n'a pas encore été facturée, elle DOIT être facturée par un membre du service vente)
- **BonDeCommande**(#id_bon_de_commande:integer, id_membre_service_vente=>MembreServiceVente.id_personne, id_membre_service_achat=>MembreServiceAchat.id_personne, bon_de_commande_date_creation:date, bon_de_commande_date_traitement:date)
    - id_bon_de_commande UNIQUE
    - id_membre_service_achat peut être NULL (quand le bon de commande n'a pas encore été traité)
    - bon_de_commande_date_creation <= bon_de_commande_date_traitement
    - bon_de_commande_date_traitement peut être NULL (lorsqu'il n'a pas encore été traité)
- **BonDeCommandeProduit**(#id_bon_de_commande=>BonDeCommande.id_bon_de_commande, #produit_reference=>Produit.produit_reference, bon_de_commande_produit_quantite:integer)
    - bon_de_commande_produit_quantite > 0 
- **Remise**(#id_remise:integer, id_personne=>Personne.id_personne, id_membre_service_vente=>MembreServiceVente.id_personne, id_membre_SAV=>MembreDuSAV.id_personne, remise_montant:float, remise_type:{avoir, garantie, promotion, pourcentage}, remise_date_debut:date, remise_date_fin:date, remise_nombre_utilisations:integer)
    - id_remise UNIQUE
    - id_personne peut être NULL (quand elle ne concerne pas un client en particulier)
    - id_membre_SAV peut être NULL (quand elle n'est pas créée par un membre du SAV)
    - id_membre_service_vente peut être NULL (quand elle n'est pas créée par un membre du service vente)
    - id_membre_SAV = NULL XOR id_membre_service_vente = NULL
    - remise_montant > 0
    - remise_type = avoir OR remise_type = garantie OR remise_type = promotion OR remise_type = pourcentage
    - ((remise_type = 'avoir' AND remise_nombre_utilisations IS NOT NULL) OR ( remise_type = 'garantie' AND remise_nombre_utilisations IS NOT NULL) OR (remise_type = 'promotion' AND remise_nombre_utilisations IS NULL) OR (remise_type = 'pourcentage' AND remise_nombre_utilisations IS NULL))
    - remise_date_debut <= remise_date_fin
    - remise_date_fin peut être NULL (quand la remise n'a pas de date de fin, qu'elle est valable à vie)
    - remise_nombre_utilisations (peut être NULL si aucune limite)
- **MembreDeLEntreprise**(#id_personne=>Personne.id_personne, membre_entreprise_date_arrivee: date, membre_entreprise_date_depart:date)
    - membre_entreprise_date_depart peut être NULL (quand le membre de l'entrepris n'a pas quitté l'entreprise)
- **MembreDuServiceAchat**(#id_personne=>MembreDeLEntreprise.id_personne, membre_service_achat_date_arrivee: date, membre_service_achat_date_depart: date)
    - membre_service_achat_date_depart peut être NULL (quand le membre de l'entreprise n'a pas quitté le service)
    - membre_service_achat_date_arrivee < membre_service_achat_date_depart
- **MembreDuServiceVente**(#id_personne=>MembreDeLEntreprise.id_personne, membre_service_vente_date_arrivee: date, membre_service_vente_date_depart: date)
    - membre_service_vente_date_depart peut être NULL (quand le membre de l'entreprise n'a pas quitté le service)
    - membre_service_vente_date_arrivee < membre_service_vente_date_depart
- **MembreDuSAV**(#id_personne=>MembreDeLEntreprise.id_personne, membre_SAV_date_arrivee: date, membre_SAV_date_depart:date)
    - membre_SAV_date_depart peut être NULL (quand le membre de l'entreprise n'a pas quitté le service)
    - membre_SAV_date_arrivee < membre_SAV_date_depart

## Normalisation ##

#### Introduction ####

Afin de ne pas surcharger ce document on pourra noter que :
* A → B
* A → C  
Est la même chose que :  
* A → B, C

Les clés candidates ont été renseignées.


#### Présentation ####
- Personne.**id_personne** → personne_nom, personne_prenom, personne_date_de_naissance, personne_email, personne_adresse
- (Personne.**personne_nom**, Personne.personne_prenom, Personne.personne_date_de_naissance) → personne_email, personne_adresse (clé candidate)
- MembreDeLEntreprise.**id_personne** → personne_nom,  id_membre_entreprise, membre_entreprise_date_arrivee, membre_entreprise_date_depart
- MembreDuServiceAchat.**id_personne** →  membre_service_achat_date_arrivee, membre_service_achat_date_depart
- MembreDuServiceVente.**id_personne** → membre_service_vente_date_arrivee, membre_service_vente_date_depart
- MembreDuSAV.**id_personne** → membre_SAV_date_arrivee, membre_SAV_date_depart
- Produit.**produit_reference** → produit_description, produit_prix_de_reference, produit_consommation, produit_marque, produit_categorie
- OccurrenceDeProduitEntreprise.**occurrence_de_produit_numero_de_serie** → produit_reference, id_facture, occurrence_de_produit_extension_de_garantie, occurrence_de_produit_montant_extension_de_garantie, occurrence_de_produit_prix, occurrence_de_produit_montant_installation_par_specialiste, id_membre_service_achat
- OccurrenceDeProduitFournisseur.**occurrence_de_produit_numero_de_serie** → produit_reference, id_facture, occurrence_de_produit_prix, id_fournisseur
- Fournisseur.**id_fournisseur** → fournisseur_nom, fournisseur_adresse
- FacturePersonne.**id_facture** → facture_montant_total, facture_date, facture_payee, id_personne, id_membre_service_vente (clé candidate)
- (FacturePersonne.**id_facture**, FacturePersonne.**id_personne**) → facture_montant_total, facture_date, facture_payee, id_personne, id_membre_service_vente
- FactureFournisseur.**id_facture** → facture_montant_total, facture_date, facture_payee, id_fournisseur, id_membre_service_achat
- BonDeCommande.**id_bon_de_commande** → id_membre_service_vente, id_membre_service_achat, bon_de_commande_date_creation, bon_de_commande_date_traitement, remise_date_fin
- (BonDeCommandeProduit.**id_bon_de_commande**, Produit.**produit_reference**) → bon_de_commande_produit_quantite
- Remise.**id_remise** → id_personne, id_membre_service_vente, id_membre_SAV, remise_montant, remise_type, remise_date_debut, remise_nombre_utilisations
- TicketSAV.**id_ticket_sav** → id_facture, occurrence_de_produit_numero_de_serie, ticket_sav_date, ticket_sav_statut, ticket_sav_issue, id_membre_SAV
- Reparation.**id_reparation** → id_ticket_sav, reparation_date_entree, reparation_date_sortie, reparaton_materiel_utilise, id_membre_service_vente, id_facture (clé candidate)
- (Reparation.**id_reparation**, Reparation.**id_ticket_sav**) → reparation_date_entree, reparation_date_sortie, reparaton_materiel_utilise, id_membre_service_vente, id_facture

Chaque relation vérifie :
* **1NF** : Tous les attributs sont atomiques et toutes les tables ont au moins une clé
* **2NF** : Tous les attributs n'appartenant pas à une clé candidate ne dépendent pas d'une partie seulement d'une clé candidate
* **3NF** : Tous les attributs n'appartenant pas à une clé candidate ne dépendent que des clés candidates
* **BCNF** : Les DFE exprimées ci-dessus sont toutes de la formes : K → A où K est une clé candidate et A un ou plusieurs attributs
 
De cette manière nous pouvons affirmer que la base de données n'est pas redondante.