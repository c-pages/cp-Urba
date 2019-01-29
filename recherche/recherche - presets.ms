



-------- manager de preset pour Batiment ----------------------------------------------------------------------------------
struct str_mgr_batiment_presets (
		
		------------ DEBUG	----------------------------------------------------------------------------------
-- 		m_debug = false,
		m_debug = true,		
		m_dbgPrefix ="presets_MGR",
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
		
		
		
		------------ FONCTIONS	----------------------------------------------------------------------------------
	private
		fn a_des_parametres	_obj	=(
			local result = false
			try (
				getpropNames 	_obj
				result = true
			) catch ()
			result
		),
		
		fn est_param_a_ignorer		_param_nom =(
			local result = false
			if _param_nom as string == "surface_node" do result = true
			result
		),
		
	public
		fn get_parameters_asText		_node = (
			
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
					if i != parametres_noms.count then 
						txtResult +=	 "\\\n"
					else txtResult +=	 "\n"
					
				) --- fin if not	est_param_a_ignorer	 ----
			) -- fin for param_nom
			
			txtResult
			
		),
		/* fn get_parameters_asTextBACK		_node = (
			
			local txtResult 						= ""
			local parametres_noms 			=  getpropNames 	_node
			
			for param_nom in parametres_noms do (
				
				local param_propriete 	= getProperty  _node 	param_nom 
				local param_class 		= classof	param_propriete
				
				case param_class of (
					ArrayParameter: (
								if param_propriete.count > 0 then (
									
									local a_params 			= 	a_des_parametres	param_propriete[1]
									
									--- si il a des parametres, alors c'est un plug, faut aller chercher les 'sous parametres' -----
									if a_params then (
										txtResult +=	param_nom as string  + "=#(\n"
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
					default:	txtResult +=	param_nom as string  + "=" + param_propriete as string +  "\n"
				) -- fin case param_class  ----
			) -- fin for param_nom
			
			txtResult
			
		), */
		
		
		fn set_parameters_fromText		_node 	_preset	= (
			
			
		),
		
		
		
		
		fn enregistrer 		_node	=(
			if not doesFileExist fichier_dossier do makeDir  fichier_dossier
			local fichierCible 	=	getSaveFileName 	caption:					"Enregistrer" 			\
																	filename:				fichier_dossier 		\
																	types:					fichier_type			\
																	historyCategory:		fichier_categorie
			
			if fichierCible != undefined do (
				
				---- creation du fichier----------
				local stream	
				if doesFileExist fichierCible do deleteFile  fichierCible
				stream	= createFile fichierCible
				close stream
				
				---- ecriture du fichier-----------
				stream = openFile fichierCible 	mode:"a"		
				local txt = get_parameters_asText			_node 
				format "%" 	txt 					to:stream
				close stream
			)
		)

) ---- fin struct preset --------------




-- $.category




mgr_preset_test = str_mgr_batiment_presets ()



clearListener ()
-- mgr_preset_test.get_parameters_asText		 $cp_batiment001

mgr_preset_test.enregistrer		 $cp_batiment001













