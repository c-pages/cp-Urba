	
	
	
	
dossier_batMod = "$userScripts\\cp-Urba\\modules\\Batiment\\"


----- Manager de mesh ----------------
include	 "$userScripts\\cp-Urba\\modules\\Commun\\cp - mgr - Shapes.ms" 
include	 "$userScripts\\cp-Urba\\modules\\Commun\\cp - mgr - Mesh.ms" 
include	 "$userScripts\\cp-Urba\\modules\\Commun\\cp - mgr - Squelettisation.ms"

----- les primitives ---------------------
filein ( dossier_batMod + 	"Primitives\\cp - Primitive - Plan vertical.ms"	)
filein ( dossier_batMod + 	"Primitives\\cp - Primitive - Plan horizontal.ms"	)
filein ( dossier_batMod + 	"Primitives\\cp - Primitive - Boite.ms"	)
filein ( dossier_batMod + 	"Primitives\\cp - Primitive - Boite U.ms"	)
filein ( dossier_batMod + 	"Primitives\\cp - Primitive - Boite L.ms"	)

--- element de base menuiseries	-----------
filein ( dossier_batMod + 	"Facade\\Menuiseries\\Elements\\cp - Menuis element - Poignée.ms"	)
filein ( dossier_batMod + 	"Facade\\Menuiseries\\Elements\\cp - Menuis element - Cadre.ms"	)
filein ( dossier_batMod + 	"Facade\\Menuiseries\\Elements\\cp - Menuis element - Panneau.ms"	)
filein ( dossier_batMod + 	"Facade\\Menuiseries\\Elements\\cp - Menuis element - Chassis vitré.ms"	)
filein ( dossier_batMod + 	"Facade\\Menuiseries\\Elements\\cp - Menuis element - Meneau.ms"	)

------- elements de base  de facades	-----------
filein ( dossier_batMod + 	"Facade\\Menuiseries\\cp - Menuiserie - Fixe.ms"	)
filein ( dossier_batMod + 	"Facade\\Menuiseries\\cp - Menuiserie - Fenetre.ms"	)
filein ( dossier_batMod + 	"Facade\\Menuiseries\\cp - Menuiserie - Porte.ms"	)

----- les facades ----------
filein ( dossier_batMod + 	"Facade\\Composants\\cp - Facade Compo - Baie.ms"	)
filein ( dossier_batMod + 	"Facade\\Composants\\cp - Facade Compo - Mur.ms"	)
filein ( dossier_batMod + 	"Facade\\Composants\\cp - Facade Compo - Ensemble.ms"	)
filein ( dossier_batMod + 	"Facade\\Composants\\cp - Facade Compo - Balcon.ms"	)
filein ( dossier_batMod + 	"Facade\\Composants\\cp - Facade Compo - Groupe.ms"	)

------- les composant du batiment ----------
filein ( dossier_batMod + 	"Facade\\cp - Batiment - Façade.ms"	)
filein ( dossier_batMod + 	"Toiture\\cp - Batiment - Toit - n pans.ms"	)

