# na17p2

Deuxième projet de l'UV NA17.

## Sujet : Entreprise de vente (32) ##

Une petite entreprise de vente de matériel technologique et électroménager souhaite changer son image de marque et se doter d'une nouvelle base de données permettant de tracer précisément tous les achats effectués par les clients, afin d'améliorer tout son service après-vente.

### Hypothèses ###
- l'entreprise vend des produits de différentes marques ;
- chaque action donne lieu à une facturation, que ce soit une vente, une réparation ou une reprise d'un objet ;
- chaque intervention du SAV se solde de trois manières différentes : le produit est irréparable et rendu au client (aucun frais) ou alors une offre de reprise peut-être faite, ou alors si c'est réparable l'entreprise peut effectuer la réparation ;
- différents services sont présents : le service vente, le service réparation et le service achat ;
- les clients peuvent être des particuliers ou des professionnels ;
- chaque produit vendu peut être un appareil, mais aussi une pièce détaché (le SAV se sert d'ailleurs des pièces détachés pour effectuer les réparations) ;
- pour chaque produit (appareil, accessoire, pièce détachée, etc.), il faut établir des relations de compatibilités avec les autres.

### Besoins ###
- chaque produit doit posséder une référence (souvent celle proposée par la marque), une description, un prix de référence (proposée par la marque), et parfois une consommation ; et il est classé dans une catégorie et une sous-catégorie de produits ;
- pour chaque produit, il faut spécifier s'il peut donner lieu à une extension de garantie (qui passe alors de 2 à 5 ans) ;
- chaque occurrence de produit possède un propre numéro de série et un prix affiché ;
- un fournisseur propose un ensemble de produits (ainsi plusieurs fournisseurs peuvent proposer le même produit), mais chaque occurrence du produit ne provient évidemment que d'un seul fournisseur ;
- la facturation est toujours réalisée par un membre du service vente ;
- le SAV est géré par un membre du service SAV : il crée le ticket de prise en charge et note la date (pour contrôler la garantie du produit) ;
- le SAV choisi ensuite de prendre en charge ou non la réparation, ou si c'est irréparable, de rendre le produit au client ou de proposer une remise sur un achat suite à la reprise du produit défectueux ;
- pour une réparation, nous avons besoin de connaître le temps passé ainsi que le matériel utilisé, ce qui servira a établir la facture (si nécessaire) ;
- lors d'une vente, il faut préciser si l'installation doit être effectué par un spécialiste (auquel cas un supplément sera à régler) ;
- le service vente peut émettre un bon de commande pour demander un achat de produits et réapprovisionner les stocks ;
- dans ce cas, c'est le service achat qui se charge de la négociation (qui ne concerne pas notre BDD), et valide au final un achat avec une quantité de produits et le prix unitaire final ;
- sur chaque facture, il peut y avoir des remises différentes appliquées sur chaque produit acheté ;
- nous avons besoin de pouvoir retrouver différentes statistiques, comme par exemple les produits les plus vendus, ceux qui ont le plus de pannes, le panier moyen, le total des remises effectuées par un vendeur, etc.
