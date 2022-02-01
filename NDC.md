# Note de Clarification

URL du projet : https://gitlab.utc.fr/vilecler/na17p2

### Livrables

*   README.md (avec les noms des membres du groupe)
*   NDC au format markdown
*   MCD
*   MLD non-relationnel
*   BBD : base de données, données de test, questions
*   MongoDB (fichier Mongo.js à charger dans mongo avec **load('Mongo.js')**)

### Membres du groupe

*   LECLERCQ Vivien

### Objet du projet

Le projet "Entreprise de vente" a pour objectif de tracer précisément tous les achats effectués par les clients, afin d'améliorer tout son service après-vente. 

Les vues suivantes devront être crées : 
- **Vue produits les plus vendus :** permet d'établir un classement des produits les plus vendus par l'entreprise de vente
- **Vue produits avec le plus de pannes :** permet d'établir un classement des produits les plus en panne
- **Vue panier moyen :** permet d'obtenir le pannier moyen des clients de l'entreprise de vente
- **Vue total des remises effectuées par un vendeur :** permet d'obtenir pour chaque vendeur le nombre et le montant total de remises effectuées

### Liste des objets qui devront être gérés dans la base de données
*   Personne
*   Facture (lorsque le client règle une facture à l'entreprise de vente ou lorsque l'enteprise règle une facture à un fournisseur)
*   Categorie
*   SousCategorie
*   Produit
*   OccurenceDeProduit (vendu par l'Entreprise de vente ou un Fournisseur)
*   Fournisseur
*   TicketSAV
*   Reparation
*   BonDeCommande
*   Remise
*   MembreDeLEntreprise
*   MembreDuServiceAchat
*   MembreDuServiceVente
*   MembreDuSAV

### Liste des propriétés associées à chaque objet
##### Personne
- nom
- prenom
- dateDeNaissance
- email
- adresse
- **Contraintes**
    - **(nom, prenom, dateDeNaissance) doit être unique**

##### Facture
- montantTotal
- date
- payee
- **Contraintes**
    - **Le vendeur est soit l'entreprise soit le fournisseur**
    - **L'acheteur est soit l'entreprise soit le client**
    - **Le montant total est calculé à partir de la somme des produits contenus dans la facture et des remises dont dispose le client**
    - **Le montant total est positif**
    - **La date est la date où le(s) produit(s) a/ont été vendu(s)**
    - **La facture peut être payée ou non.**

##### Categorie
- nom
- **Contraintes**
    - **Le nom doit être unique**

##### SousCategorie
- nom
- **Contraintes**
    - **Le nom doit être unique**

##### Produit
- reference
- description
- prixDeReference
- consommation
- marque
- **Contraintes**
    - **La référence est donnée par la marque**
    - **Le prix de référence est donné par la marque**
    - **La consommation est la consommation énergétique annuelle du produit en kilowattheure (kWh/annum)**
    - **La consommation peut être nulle**
    - **Catégorie et sous-catégorie ne peuvent pas être identiques**

##### Occurence de produit
- numeroDeSerie
- montantDeLExtensionDeGarantie
- prix
- montantDeLInstallationParUnSpecialiste
- **Contraintes**
    - **Le montant de l'extension de garantie est positif**
    - **Le prix est positif**
    - **Le numéro de série est unique**
    - **Le montant de l'installation par un spécialiste est positif **
    - **Montant de l'extension de garantie peut être NULL (si pas d'extension de garantie)**
    - **Montant de l'installation par un spécialiste peut être NULL (si pas d'installation par un spécialiste)**

##### Fournisseur
- nom
- adresse

##### TicketSAV
- date
- statut
- issue
- **Contraintes**
    - **Le date est la date d'entrée du produit au SAV**
    - **Statut représente si le ticket a été traité ou s'il est en cours de traitement ou s'il a été traité**
    - **Issue prend les valeurs : retour client, reparation, remise ou NULL**
    - **Un ticket SAV non traité ou en cours de traitement a pour issue NULL**

##### Reparation
- dateEntree
- dateSortie
- materielUtilise
- montant
- **Contraintes**
    - **dateEntree < dateSortie **
    - **Le montant représente le coût total de la réparation**

##### BonDeCommande
- statut
- **Contraintes**
    - **Le statut indique si le bon de commande a été traité ou non**

##### Remise
- montantDeLaRemise
- type : {avoir, garantie, promotion, pourcentage}
- dateDebut : Date
- dateFin : Date
- nombreDUtilisations
- **Contraintes**
    - **Le montant de la remise doit être positif**
    - **La date de début doit être strictement inférieure à la date de fin**
    - **La date de fin peut être NULL**
    - **Le nombre d'utilisation doit être positif**
    - **Le nombre d'utilisation peut être nul**

##### MembreDeLEentreprise
- nom
- prenom
- dateDeNaissance
- email
- adresse
- dateEntreeEntreprise
- dateSortieEntreprise
- **Contraintes**
    - **(nom, prenom, dateDeNaissance) doit être unique**
    - **dateEntree > dateSortie**

##### MembreDuServiceAchat
- nom
- prenom
- dateDeNaissance
- email
- adresse
- dateEntreeEntreprise
- dateSortieEntreprise
- dateEntreeService
- dateSortieService
- **Contraintes**
    - **(nom, prenom, dateDeNaissance) doit être unique**
    - **dateEntree < dateSortie**

##### MembreDuServiceVente
- nom
- prenom
- dateDeNaissance
- email
- adresse
- dateEntreeEntreprise
- dateSortieEntreprise
- dateEntreeService
- dateSortieService
- **Contraintes**
    - **(nom, prenom, dateDeNaissance) doit être unique**
    - **dateEntree < dateSortie**

##### MembreDuSAV
- nom
- prenom
- dateDeNaissance
- email
- adresse
- dateEntreeEntreprise
- dateSortieEntreprise
- dateEntreeService
- dateSortieService
- **Contraintes**
    - **(nom, prenom, dateDeNaissance) doit être unique**
    - **dateEntree < dateSortie**

On suppose que tous les attributs ne peuvent pas être nuls sauf si indiqués comme tels.

### Liste des utilisateurs (rôles) appelés à modifier et consulter les données
- Utilisateur membre du service vente
- Utilisateur membre du service achat
- Utilisateur membre du SAV

### Liste des fonctions que ces utilisateurs pourront effectuer
##### Utilisateur membre du service vente
- émission de bons de commande
- facturer un client
    - facturer une réparation (si le produit n'est plus garanti)
- supprimer des occurences de produit (une fois vendus)
- creer des remises

##### Utilisateur membre du service achat
- traiter un bon de commande
- payer un fournisseur (régler une facture)
- ajouter des occurences de produit (une fois achetés)

##### Utilisateur membre du SAV
- créer un ticket SAV
- choisir d'effectuer une réparation
- choisir de rendre le produit au client
- choisir d'effectuer une remise au client

### Liste des hypothèses faites à partir du sujet
- On considére que la garantie d'un produit est donnée par le fournisseur ou l'entreprise. On ne parle pas de garantie constructeur. C'est donc au fournisseur ou à l'entreprise de proposer une extension de garantie.
- Une extension de garantie est payante.
- Un client n'est pas obligé d'acheter l'extension de garantie.
- Il est facile de savoir si un produit est sous extension de garantie : l'extension de garantie est facturée sinon le produit est garantie 2 ans par défaut.
- Une facture avec un montant de 0.00€ peut exister (notamment lorsqu'un produit réparé est sous garantie).
- Un client ne vend pas de produits à l'entreprise.
- Le service réparation et le SAV sont la même chose.
- Il peut exister des sous-catégories avec le même nom mais elles n'appartiennent pas à la même catégorie.
- Un produit représente ce que peut vendre l'entreprise. Une occurence de produit représente les produits disponibles en rayon. Ainsi lorsqu'un produit n'a aucune occurence de produit, il est en rupture de stock.
- Lorsqu'un produit doit être installé par un spécialiste, le client n'a pas le choix, il doit payer ce supplément s'il veut acheter ce produit.
- Lorsque le SAV choisit de réparer un produit, il demande au service vente de facturer le client car "la facturation est toujours réalisée par un membre du service vente".
- Le client ne peut pas se rétracter d'une réparation, lorsqu'il dépose son produit au SAV il accepte de devoir payer la réparation si nécessaire.
- Un ticket SAV peut être composé de plusieurs réparations. En effet, il est possible que le réparateur effectue plusieurs opérations sur un produit avant de le rendre réparé au client.
- En cas de garantie, une réparation produit une relise du montant de la réparation au client en question.
- Les remises sont toujours utilisées lorsque disponibles.
- La remise ne peut être utilisée qu'une fois par facture.
- Il est possible de cumuler les remises.
- Les clients sont forcément des particuliers.
- Les clients sont des personnes.
- Les membres de l'entreprise sont des personnes.
- Il est possible d'être membre de l'entreprise sans être ni membre du SAV, ni membre du service vente, ni membre du service achat.
- Tous les membres de l'entreprise peuvent consulter les données de l'entreprise en revanche la modification, la suppression ou l'ajout de données dépend du rôle du membre dans l'entreprise.
- Lorsque le service achat commande des produits, il règle la facture aux fournisseurs seulement lorsqu'il a reçu les produits. Ainsi, il est possible de gérer les commandes en cours auprès des fournisseurs.
- Deux fournisseurs peuvent avoir le même nom.
- Chaque fournisseur possède une adresse (qui peut être utile pour la facturation).
- **Ces hypothèses s'ajoutent à celles du sujet.**