# CP - Urba V0.4.1
Suite de plugins pour 3DSmax  |  Maxscript  | Pour réalisation de bout de villes, bâtiments, surfaces pour rues, trottoire, gazon etc.

Version validée pour passer à version plus simple et plus claire du batiment.

#### Auteur :

 Christophe Pagès |  contact@c-pages.fr  |   [c-pages.fr](http://c-pages.fr)  | [git](https://github.com/c-pages/cp-Urba)

 ###### En cours de développement :

 - __Batiment__ : Objet paramétrique.

     Permet de créer des bâtiments à partir d'un shape "contour", façades et toitures.

 - __Quartier__ : Objet paramétrique, n'est pas rendu, organise des _Batiments_.
M
     Permet de construire et manipuler des quartiers entiers de batiments, en fonction de certaines contraintes (surface du shape, largeur, orientation ...), tel preset de batiment à utiliser ou pas ( 'garage',  'immeuble de bureau', 'pavillon brique normand', ...).
 - __Terrain__ : Objet paramétrique.

     Générateur de terrain utilisant d'un coté un ou plusieurs objects servant de relief, et de l'autre un ou plusieurs shapes délimitant des surfaces (ex: création d'une voire, route + trottoires). Voir si il y a moyen d'utiliser base de donnée SIG en ligne pour importer des reliefs.

 - __OSM importer__ : Utilitaire

     Permet d'importer depuis OpenStreetMap des cartes, pour utiliser les contours pour nos _Batiments_.


 ----------



 ### Version blender
 Passage du plugin en phython pour intégration à Blender par Dindoune el amigo dit Bruno ! | [git](https://github.com/dindoun) | [dindoun.lautre.net](http://www.dindoun.lautre.net/)


----------
 ### Installation 3ds max

1.  Copier le dossier _'cp-Urba'_ dans _'C:\Users\\...\AppData\Local\Autodesk\3dsMax\20xx - 64bit\ENU\scripts\'_

    ...     : le nom du User;
    20xx    : la version de 3ds max

    On doit avoir au final l'arbo suivante :  _'C:\Users\\...\AppData\Local\Autodesk\3dsMax\20xx - 64bit\ENU\scripts\cp-Urba\'_.

2.  Pour qu'il charge le plug au démarrage de max : Copier les fichiers du dossier _'cp-Urba\Startup\'_ dans _'C:\Users\\...\AppData\Local\Autodesk\3dsMax\20xx - 64bit\ENU\scripts\startup\'_,
3.  Pour avoir un bouton qui recompile le script (programation) :

    a. Ouvrir le fichier 'cp-Urba\macros\cp - Batiment - recompile.mcr' dans l'éditeur de max, puis l'executer (ctrl+E), ou executer le script directement (menu: scripting\run script).

    b. Il faut customiser l'interface : menu : Customize\Customize User Interface.

    c. Dans l'onglet 'Toolbars', group 'Main UI', Category '#CPages', glisser l'action 'DEBUG: recompile le plugin Batiment' dans l'interface de max.

----------
 ### Utilisation 3ds max

Il suffit de créer un objet 'Batiment' dans la scène, accessible dans 'create', puis la category "CP | Urba", puis de lui assigner une spline.


 ----------
### TODO | CP - Urba V0.4.1


#### __Bâtiment__
  - [x] Gestion des hauteurs d'étages spécifiques. (07/02/2019)
  - [x] Prise en compte des contrainte d'orientation cardinale des façades.
  - [x] Mise au propre des menuiseries.
  - [x] Prise en compte de 3 niveaux de détails des géometries (full, medium et low) + Volume !!.
  - [x] Début de l'intégration des presets, il y a questionnement sur enregistrement ou plutot sur la lecture des parametres des maxObjects inclus dans des parametres (tableau) de nos preset a sauvegarder...
  - [x] Gestion des Presets (enregistrer, charger, copier, coller) version XML est opérationnel !!
  - [x] Façade, duplication de facade
  - [ ] Toitures à 1 pan, toiture à 2 pans
  - [ ] donc il faut trouver les goutereaux et pignons (cf squeletisation)
  - [ ] les occultations des baies (volets roulant, battants et stores bans)
  - [ ] façades : Les chaînages
  - [ ] façades : trouver le moyen de faire des corniches (comment les placer sur Z ?)
  - [ ] façades : portiques/porches ?
  - [ ] façades : repartiion mode espacement.
  - [ ] Toitures : integration d'elements secondaire (chien assis, lucarnes, cheminets, locaux techniques, ...)
  - [ ] Toiture, deboguer la squeletisation, y'a un fichier max avec un exemple du bug dans recherche/3D. c'est un decalage sur Z d'un point.
  - [ ] Peut etre essayer d'integrer l'editeur de facades dans l'interface principal du Batiment ... ?
  - [ ] Facades : gerer la connexion entre deux baies pour creer une baie avec differents hauteur d'allège par exemple.
  - [ ] creations des dalles a chaques etages.
  - [ ] a voir comment on pourrait creer des murs interieurs (cf squeletisation)



#### __Terrain__
  - [ ]  .


##### Importeur de reliefs
- [ ] .


#### __OSM__
 - [ ] .
 ----------
### Todo:

#### __Terrain__
  - [ ]  .


##### Importeur de reliefs
- [ ] Créer un importeur de terrain utilisant model de terrain en ligne ?
- [ ] DEM/DTM Data base. ex:https://asterweb.jpl.nasa.gov/gdem.asp



#### __Bâtiment__
  - [ ] .

#### __OSM__
 - [ ] .
_____________________________
### Historique des versions:




----------

Merci à Dindoune el amigo dit Bruno pour ces bons tuyaux ! | [git](https://github.com/dindoun) | [dindoun.lautre.net](http://www.dindoun.lautre.net/)
