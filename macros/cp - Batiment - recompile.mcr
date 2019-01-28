macroScript recompile_Batiment
category:"#CPages"
tooltip:"DEBUG: recompile le plugin Batiment"
buttonText:"Recomp. Bati."
(
	gc ()
	
	local selectBack = selection as array
	clearSelection()
	
	filein "$userScripts\\cp-Urba\\Startup\\cp - Urba - Batiment - Startup.ms"
	
	for nd in  selectBack do selectMore  nd
	
	format "RELOAD ok\n"
)