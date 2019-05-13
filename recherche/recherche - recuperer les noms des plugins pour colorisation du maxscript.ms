(
	
	clearlistener ()
	
	------ recuperre le nom du plugin de chaque fichier --------------------------
	fn get_plugin_nom 	_fichier	= (
		local fichier_stream		=	openFile 	_fichier 	mode:"r"
		local plugin_nom
		local on_a_trouve = false
		while not on_a_trouve	or eof  fichier_stream		do (
			local ligne 	= readLine  fichier_stream
			local mots 	=  filterString ligne		" 	"
			if mots[1] == "plugin" do (
				plugin_nom =  mots[3]
				on_a_trouve = true
			)
		)
		close fichier_stream	
		plugin_nom
	) --- fin get_plugin_nom ----------
	
	
	
	
	
	---- on recupere le nm de tout mes plugins -------------------
	local dossier_batMod 	= "$userScripts\\cp-Urba\\modules\\Batiment\\"
	local fichiers_ms 			= getFiles (dossier_batMod + 	"*.ms") recurse:true
	local liste_des_plugins 	= for fichier in fichiers_ms collect	 get_plugin_nom	fichier

	
	
	
	----------- on ecrit le fichier properties --------------
-- 	format "liste_des_plugins	 --> %\n"	liste_des_plugins
	
	
	local texte_prop = "keywords12.$(file.patterns.MAXScript)="
	local compte = 1
	for plug_nom in liste_des_plugins do (
		texte_prop +=  plug_nom + " "
		compte += 1
		if compte > 5 and plug_nom != liste_des_plugins[liste_des_plugins.count] do (
			compte = 1
			texte_prop += "\\\n"
		)
	)
	texte_prop += "\n" + "style.MAXScript.23=fore:#60A030\n"
	
	
	
	local toFichier = true
	if tofichier then (
		--- to fichier  MXS_EditorUser.properties--------
		local fichier_propertiesPersos =  getdir #maxData + "MXS_EditorUser.properties"
		deleteFile  fichier_propertiesPersos
		local fichier_propertiesPersos_stream		=	openFile 	fichier_propertiesPersos 	mode:"a+"
		
		format "%" texte_prop	to:fichier_propertiesPersos_stream
		close fichier_propertiesPersos_stream
	) else	format "%" texte_prop
	
)







