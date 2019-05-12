	
dossier_batMod = "$userScripts\\cp-Urba\\modules\\Batiment\\"


----- Manager de mesh ----------------
include	 "$userScripts\\cp-Urba\\modules\\Commun\\cp - mgr - Shapes.ms" 
include	 "$userScripts\\cp-Urba\\modules\\Commun\\cp - mgr - Mesh.ms" 
include	 "$userScripts\\cp-Urba\\modules\\Commun\\cp - mgr - Squelettisation.ms"

----- Presets ----------------
include	 "$userScripts\\cp-Urba\\modules\\Commun\\cp - mgr - Presets.ms" 

----- les primitives ---------------------
fichiers_ms = getFiles (dossier_batMod + 	"Primitives\\*.ms")
for fichier_ms in fichiers_ms do filein	fichier_ms

--- element de base menuiseries	-----------
fichiers_ms = getFiles (dossier_batMod + 	"Facade\\Menuiseries\\Elements\\*.ms")
for fichier_ms in fichiers_ms do filein	fichier_ms	
	
------- menuiseries-----------
fichiers_ms = getFiles (dossier_batMod + 	"Facade\\Menuiseries\\*.ms")
for fichier_ms in fichiers_ms do filein	fichier_ms
	
------- occultants-----------
fichiers_ms = getFiles (dossier_batMod + 	"Facade\\Menuiseries\\Elements\\Occultants\\*.ms")
for fichier_ms in fichiers_ms do filein	fichier_ms
	
------- garde_corps-----------
fichiers_ms = getFiles (dossier_batMod + 	"Facade\\Menuiseries\\Elements\\Garde-corps\\*.ms")
for fichier_ms in fichiers_ms do filein	fichier_ms
	
----- les facades ----------
fichiers_ms = getFiles (dossier_batMod + 	"Facade\\Composants\\*.ms")
for fichier_ms in fichiers_ms do filein	fichier_ms
	
------- les composant du batiment ----------
filein ( dossier_batMod + 	"Facade\\cp - Batiment - Façade.ms"	)
filein ( dossier_batMod + 	"Toiture\\cp - Batiment - Toit - n pans.ms"	)

