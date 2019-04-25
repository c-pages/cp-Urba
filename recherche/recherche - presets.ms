



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
		/* 
		fn ajouter_maxObj_a_param		_param		=(
			
		),
		fn set_parameters_fromTextBACK		_cible 	_preset	= (
			
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
-- 					if compo_aRemplir != undefined then (
-- 						setProperty 	compo_aRemplir		param_nom		( execute param_value )
-- 					) else (
-- 						setProperty 	_cible		param_nom		( execute param_value )
-- 					)
-- 					try (
-- 	 				setProperty 	_cible		param_nom		( execute param_value )
-- 					)	catch ()
					
				)	--
				
			) --- while eof ---------
			
			
			
		),
		
		 */
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
											txtResult +=  "FINitemClasse\n"		
											
										)
										txtResult +=	")\n"
										
									---- sinon c'est juste un tableau de trucs de base ----------
									) else	txtResult +=	param_nom as string  + "=" + param_propriete as string +  "\n"
									
								---- sinon, le tableau est vide ------------
								) else 	txtResult +=	param_nom as string  + "=#()\n"
								
							)
					string:	txtResult +=	param_nom as string  + "=\"" + param_propriete as string  + "\"\n"
					default:	(
						
						local a_params 	= 	a_des_parametres	param_propriete
						
						if a_params then (
							
							txtResult +=	param_nom as string  + ":itemClasse=" + param_propriete as string +  "\n"
-- 							txtResult +=	"\n" + param_nom as string  + "=" --+ param_propriete as string  + "\"\n"
-- 							txtResult +=  "itemClasse=" + param_class as string + "\n"											
							txtResult +=	get_parameters_asText		param_propriete
							txtResult +=  "FINitemClasse\n"
							
						) else (
						
							txtResult +=	param_nom as string  + "=" + param_propriete as string +  "\n"
						)
						
					)
				) -- fin case param_class  ----
			) -- fin for param_nom
			
			txtResult
			
		),
		
		/* 
		fn set_parameters_fromText		_cible 	_preset		pos:	= (
			
			format  "set_parameters_fromText	:\n\n"
			
			local stream 				= _preset as stringStream
			local param_aRemplir	=	undefined
			local compo_aRemplir	=	undefined
			local onContinue			=	true
			
			if pos != unsupplied do seek  stream	pos
			
			while not eof stream or onContinue	do (
				
				local ligne 				= readLine  stream
				local param_nom 	= ( filterString  ligne "=" )[1]
				local param_value 	= ( filterString  ligne "=" )[2]
				
				debug "param_nom" 		var:param_nom
				debug "param_value" 	var:param_value
				
				---- le parametre est une LISTE DE MAXOBJECTS ---------
				if param_value == "maxObjs#(" then (
					
					debug "	---------------DEBUT Liste maxObjects -----------"
-- 					local param_parent = getProperty 	_cible		param_nom -- execute ( _cible + "." + param_nom )
-- 					debug "	param_parent" var:(param_parent as string)
					
-- 					param_aRemplir = execute ( classof (getProperty 	_cible		param_nom ) as string )
-- 					debug "	---------------param_aRemplir -----------" var:param_aRemplir
					
					
				---- le parametre est la FIN de la LISTE DE MAXOBJECTS ---------
				) else	if param_nom ==  ")" then (
					debug "	---------------FIN Liste maxObjects -----------"
					
					param_aRemplir	=	undefined
					
					
				---- le parametre est un MAXOBJECTS ---------
				) else	if param_nom ==  "itemClasse" then (
					
					debug "	--------------- MAXOBJECT -----------"
					
-- 					if param_aRemplir != undefined and compo_aRemplir != undefined do (
					
-- 						param_aRemplir = execute ( classof (getProperty 	_cible		param_nom ) as string )
-- 						debug "	---------------param_aRemplir -----------" var:param_aRemplir
						
						
						compo_aRemplir = 	createInstance	( execute param_value )
						
						debug "********stream" 		var:( filePos stream )
						set_parameters_fromText		compo_aRemplir 	stream pos:( filePos stream )
						
						
						param_aRemplir = compo_aRemplir
-- 					)
					
				---- FIN d'un  MAXOBJECTS ---------
				) else	if param_nom ==  "FINitemClasse" then (
					
					compo_aRemplir = undefined
					onContinue = false
					
				----  parametre ordinaire ---------		
				) else (
					
					if compo_aRemplir != undefined then (
-- 						setProperty 	compo_aRemplir		param_nom		( execute param_value )
-- 					) else (
-- 						setProperty 	_cible		param_nom		( execute param_value )
					)
-- 					try (
-- 	 				setProperty 	_cible		param_nom		( execute param_value )
-- 					)	catch ()
					
				)	--
				
			) --- while eof ---------
			
			
			
		),
		
		fn get_composant	_paramsText		=(
			
			
		),
		 */
		
		
		
		
		
		
		
		
		
		fn remplir_parametres		_params_strg		_plug		= (
			debug "************** remplir_parametres *******************"
			debug "_params_strg" var:_params_strg
			debug "************** **************** *******************"
			
			
			local params_strm	=	_params_strg as stringStream
			local nv_plug			= 	_plug
			
			/* 
			---- on créer le plugin	---------------
			local plug_ligne 		= readLine  params_strm
			local plug_value 		= ( filterString  param_ligne "=" )[2]	
			local plug_courant	=	createInstance	(execute param_value )
			*/
			
			
			----- On remplie les parametres du plug	---------------
			local onContinue	= true
			while onContinue and not eof params_strm	do (
				
				local param_ligne 	= readLine  params_strm
				local param_nom 	= ( filterString  param_ligne "=" )[1]
				local param_value 	= ( filterString  param_ligne "=" )[2]
				
				debug "param_nom" 		var:param_nom
				debug "param_value" 		var:param_value
				
				
				/* 
				case param_value of (
					
					---- le parametre est un MAXOBJECTS ---------
					"itemClasse": (
						
					)
					---- FIN d'un  MAXOBJECTS ---------
					"FINitemClasse": (
						
					)
					---- le parametre est une LISTE DE MAXOBJECTS ---------
					"maxObjs#(": (
						
					)
					---- le parametre est la FIN de la LISTE DE MAXOBJECTS ---------
					")": (
						
					)
					----  parametre ordinaire ---------		
					default: (
						
					)
					
				) ----- fin remplissage des parametres ------------
				*/
				
				
				
				---- le parametre est un MAXOBJECTS ---------
				if matchPattern param_nom pattern:"*:itemClasse*"		then (
					
					debug "	-----	le parametre est un MAXOBJECTS "
					
					---- on créer le plugin	---------------
					nv_plug	=	createInstance	( execute param_value )
					
					debug "********>>>>>>>>>>>> nv_plug"	var:nv_plug
					
					
					---- on recoupe le stream --------
					st 			= params_strm as string
					ss_pos 		= filePos  params_strm
					st_sub 		= substring st	( ss_pos + 1 ) 	( st.count - ss_pos )
					
					
					
					
					local retour	=  remplir_parametres		st_sub		nv_plug	
-- 					param_value	=	retour[1]
					debug "********>>>>>>>>>>>> retour[1]"	var:retour[1]
					
					local str_pos_avirer 	= findString param_nom ":itemClasse"
					local paramNomTemp 	= substring param_nom 1  (str_pos_avirer - 1 )
					setProperty 	_plug		paramNomTemp		retour[1]
					
					
					
					
					if retour[2].count > 0 then 
						params_strm	=	retour[2]  as stringStream
					else 
						onContinue = false
					
					
					
-- 					debug"ss_sub : " var:st_sub
					
				---- le parametre est une LISTE DE MAXOBJECTS ---------
				) else	if param_value == "maxObjs#(" then (
					
					debug "	-----	le parametre est une LISTE DE MAXOBJECTS "
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
				---- le parametre est la FIN de la LISTE DE MAXOBJECTS ---------
				) else	if param_nom ==  ")" then (
				
					debug"	-----	le parametre est la FIN de la LISTE DE MAXOBJECTS"
					
				---- FIN d'un  MAXOBJECTS ---------
				) else	if param_nom ==  "FINitemClasse" then (
					
-- 					debug "	-----	FIN d'un  MAXOBJECTS "
					onContinue = false
					
				----  parametre ordinaire ---------		
				) else (
					
					debug "	-----	parametre ordinaire "
					
					setProperty 	_plug		param_nom		( execute param_value )
					
				) ----- fin remplissage des parametres ------------
				
			) --- fin du while	------------
			
			
			
			--- on renvoie ------
			st 			= params_strm as string
			ss_pos 		= filePos  params_strm
			st_sub 		= substring st	( ss_pos + 1 ) 	( st.count - ss_pos )
			
			#( nv_plug, st_sub )
			
		), ---- fin fn remplir_parametres	---------------------


		
		
		
		
		
		
		
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
				
-- 				set_parameters_fromText 		_node 	datas
				
				remplir_parametres		datas	_node
				
			)
			
		)
		
		
		
		
		
) ---- fin struct preset --------------







mgr_preset_test = str_mgr_batiment_presets ()
clearListener ()



mgr_preset_test.enregistrer		$cp_batiment001	fichier:"C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\Batiments\\test preset 1.bati"
-- mgr_preset_test.charger		 	$cp_batiment003	fichier:"C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\Batiments\\test preset 1.bati"

ShellLaunch "C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\Batiments\\test preset 1.bati" ""



/* 

 */




/* 


ss 			= stringstream "ABC\nDE\nPOPO"
st 			= ss as string
ss_count 	= st.count

ss_line 	= readLine ss
ss_pos 	= filePos  ss

st_sub 	= substring st	( ss_pos + 1 ) 	(ss_count - ss_pos )
ss_sub 	= st_sub as stringstream



 */





/*


--------------------------------------------------------------------------------------------------------
	Fonction remplissage des parametres d'un plug
		-	param_strg	<string>²&é"
--------------------------------------------------------------------------------------------------------

1	-	On recupère le string 	( param_strg ) en stream ( param_strm )
2	-	On creer l'objet plug courant
3	-	On lit chaque ligne du stream	( param_strm )
		a	-	On a un parametre classique
			--->	On rempli le parametere du plug courant
		b	-	On a un parametre contenant un ou plusieurs plugs enfant
			--->	On lance la fonction recursivement	avec la suite du string
					On recupere la suite du string
					On ajoute le plug courant dans le parametre du plug parent
		c	-	On a une fin de déclaration de plug
			--->	On renvois le plug courant et la suite du string




 */

























