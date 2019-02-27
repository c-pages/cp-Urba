



-------- manager de preset pour Batiment ----------------------------------------------------------------------------------
struct str_mgr_batiment_presets (
		
		------------ DEBUG	----------------------------------------------------------------------------------
-- 		m_debug = false,
		m_debug = true,		
-- 		m_dbgPrefix ="presets_MGR",
		m_dbgPrefix ="",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		
		
		------------ MEMBRES	----------------------------------------------------------------------------------
	private
		fichier_dossier 		= "$userScripts\\cp-Urba\\lib\\",
		fichier_categorie		= "cp_urba_batiment",		
		fichier_extension		= "bati",		
		fichier_type 			= fichier_categorie + "(*." + fichier_extension + ")|*." + fichier_extension + "|All|*.*|",
		
		----- parametres que l'on ne veut pas enregistrer (typiquement : la spline du batiment ) -------------
		params_a_ignorer =#("surface_node"),
		
		
		
		------------ FONCTIONS	----------------------------------------------------------------------------------
	private
		----------- divers ---------------------------------
		fn est_param_a_ignorer		_param_nom =(
			local result = false
			for param_a_ignorer in params_a_ignorer do
				if _param_nom as string == param_a_ignorer do result = true
			result
		),
		
		fn a_des_parametres	_obj	=(
			local result = false
			try (
				getpropNames 	_obj
				result = true
			) catch ()
			result
		),
		
		
		
		
		
		
		
		
		
		
		
	private
		------ les parametres, lecture / ecriture---------------------------------
		/* 	
		fn get_parameters_asNewObject_text		_node = (
			
			local txtResult 						= (classof	_node ) as string + " "
			local parametres_noms 			=  getpropNames 	_node
			
			for i = 1 to parametres_noms.count do (
				
				local param_nom 	= parametres_noms[i]
				local on_ignore 		= est_param_a_ignorer		param_nom
				
				
				if not	on_ignore 	do (
					
					local param_propriete 	= getProperty  _node 	param_nom 
					local param_class 		= classof	param_propriete
					
					case param_class of (
						ArrayParameter: (
								 	if param_propriete.count > 0 then (
										
										local a_params 			= 	a_des_parametres	param_propriete[1]
										
										--- si il a des parametres, alors c'est un plug, faut aller chercher les 'sous parametres' -----
										if a_params then (
											txtResult +=	param_nom as string  + ":#(\\\n"
											for j = 1 to param_propriete.count do (
												
												local sous_param 	=	 param_propriete[j]
												local classOf_item 	=	classOf sous_param
												
												txtResult +=	get_parameters_asText		sous_param
												
												if j != param_propriete.count then 
													txtResult +=	 ","
											)
											txtResult +=	")"
											
										---- sinon c'est juste un tableau de trucs de base ----------
										) else	txtResult +=	param_nom as string  + ":" + param_propriete as string 
										
									---- sinon, le tableau est vide ------------
									) else 	txtResult +=	param_nom as string  + ":#()"
									
								)
						string:	txtResult +=	param_nom as string  + ":\"" + param_propriete as string  + "\""
						default:	txtResult +=	param_nom as string  + ":" + param_propriete as string 
					) -- fin case param_class  ----
					
					--- fin de ligne -----
					if i != parametres_noms.count then 	txtResult +=	 "\\\n"
					else txtResult +=	 "\n"
					
				) --- fin if not	est_param_a_ignorer	 ----
			) -- fin for param_nom
			
			txtResult
			
		), 
		*/
		
		fn ajouter_maxObj_a_param		_param		=(
			
		),
		fn set_parameters_fromText		_cible 	_preset	= (
			
			format  "set_parameters_fromText	:\n\n"
			
			local stream 				= _preset as stringStream
			local param_aRemplir	=	undefined
			local compo_aRemplir	=	undefined
			
			while not eof stream do (
				
				local ligne 				= readLine  stream
				local param_nom 	= ( filterString  ligne "=" )[1]
				local param_value 	= ( filterString  ligne "=" )[2]
				
				
				
				---- le parametre est une LISTE DE MAXOBJECTS ---------
				if param_value == "maxObjs#(" then (
					debug "	---------------DEBUT Liste maxObjects -----------"
-- 					local param_parent = getProperty 	_cible		param_nom -- execute ( _cible + "." + param_nom )
-- 					debug "	param_parent" var:(param_parent as string)
					
					param_aRemplir = param_nom
					
					
				---- le parametre est la FIN de la LISTE DE MAXOBJECTS ---------
				) else	if param_nom ==  ")" then (
					debug "	---------------FIN Liste maxObjects -----------"
					
					param_aRemplir	=	undefined
					
					
				---- le parametre est un MAXOBJECTS ---------
				) else	if param_nom ==  "itemClasse" then (
					debug "	--------------- MAXOBJECT -----------"
					if param_aRemplir != undefined and compo_aRemplir != undefined do
					
					compo_aRemplir = 	createInstance	( execute param_value )
					
				----  parametre ordinaire ---------		
				) else (
					
					debug "param_nom" 		var:param_nom
					debug "param_value" 	var:param_value
					if compo_aRemplir != undefined then (
						setProperty 	compo_aRemplir		param_nom		( execute param_value )
					) else (
						setProperty 	_cible		param_nom		( execute param_value )
					)
-- 					try (
-- 	 				setProperty 	_cible		param_nom		( execute param_value )
-- 					)	catch ()
					
				)	--
				
			) --- while eof ---------
			
			
			
		),
		fn get_parameters_asText		_node = (
			
			local txtResult 						= ""
			local parametres_noms 			=  getpropNames 	_node
			
			for param_nom in parametres_noms where not est_param_a_ignorer	param_nom do (
				
				local param_propriete 	= getProperty  _node 	param_nom 
				local param_class 		= classof	param_propriete
				
				case param_class of (
					ArrayParameter: (
								if param_propriete.count > 0 then (
									
									local a_params 			= 	a_des_parametres	param_propriete[1]
									
									--- si il a des parametres, alors c'est un plug, faut aller chercher les 'sous parametres' -----
									if a_params then (
										txtResult +=	param_nom as string  + "=maxObjs#(\n"
										for i = 1 to param_propriete.count do (
											
											local sous_param 	=	 param_propriete[i]
											local classOf_item 	=	classOf sous_param
											
											txtResult +=  "itemClasse=" + classOf_item as string + "\n"											
											txtResult +=	get_parameters_asText		sous_param
											
										)
										txtResult +=	")\n"
										
									---- sinon c'est juste un tableau de trucs de base ----------
									) else	txtResult +=	param_nom as string  + "=" + param_propriete as string +  "\n"
									
								---- sinon, le tableau est vide ------------
								) else 	txtResult +=	param_nom as string  + "=#()\n"
								
							)
					string:	txtResult +=	param_nom as string  + "=\"" + param_propriete as string  + "\"\n"
					default:	txtResult +=	param_nom as string  + "=" + param_propriete as string +  "\n"
				) -- fin case param_class  ----
			) -- fin for param_nom
			
			txtResult
			
		),
		
		
		
		
		
		
		
	------- interface -------------------------------------
	public	
		fn enregistrer 		_node	fichier:		=(
			debug "enregistrer"
			if not doesFileExist fichier_dossier do makeDir  fichier_dossier
				
			
			local fichierCible 	
			if fichier == unsupplied then
				fichierCible 	=	getSaveFileName 	caption:					"Enregistrer" 			\
																filename:				fichier_dossier 		\
																types:					fichier_type			\
																historyCategory:		fichier_categorie
			else 	fichierCible	=	fichier
			
			
			
			if fichierCible != undefined do (
				
				---- creation du fichier----------
				local stream	
				if doesFileExist fichierCible do deleteFile  fichierCible
				stream	= createFile fichierCible
				close stream
				
				---- ecriture du fichier-----------
				local txt = get_parameters_asText			_node 
				stream = openFile fichierCible 	mode:"a"		
				format "%" 	txt 					to:stream
				close stream
				
			)
		),
		fn charger  	_node 		fichier:		= (
			debug "charger"
			
			local fichierCible 	
			if fichier == unsupplied then
					fichierCible 	=	getopenFileName 		caption:				"Charger" 				\
																	filename:			fichier_dossier 		\
																	types:				fichier_type			\
																	historyCategory:	fichier_categorie
			else 	fichierCible	=	fichier
			
			if fichierCible != undefined do (
				---- lecture du fichier -----------------
				local stream 	= openFile fichierCible mode:"r"
				local datas 	= ""			
				while not eof stream do (
					datas +=	readLine  stream
					datas +=	"\n"
				)
				close  stream
				
				set_parameters_fromText 	_node 	datas
			)
			
		)
		
		
		
		
		
) ---- fin struct preset --------------







mgr_preset_test = str_mgr_batiment_presets ()
clearListener ()




mgr_preset_test.enregistrer		$cp_batiment001	fichier:"C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\Batiments\\test preset 1.bati"
mgr_preset_test.charger		 	$cp_batiment002	fichier:"C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\Batiments\\test preset 1.bati"













