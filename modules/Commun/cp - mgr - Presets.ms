

-------- variable portant le clipboard copier-coller des presets batiments --------------
global 	urba_clipboard_batiment


-------- manager de preset pour Batiment ----------------------------------------------------------------------------------
struct str_mgr_batiment_presetsXML (
		
		------------ DEBUG	----------------------------------------------------------------------------------
-- 		m_debug = false,
		m_debug = true,		
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
		
		xmlPresets,
		
		----- parametres que l'on ne veut pas enregistrer (typiquement : la spline du batiment ) -------------
		params_a_ignorer 	= #("surface_node"),
		
		
		
		------------ FONCTIONS	----------------------------------------------------------------------------------
	private
		----------- divers ---------------------------------
		fn est_param_a_ignorer		_param_nom =(
			local result = false
			for param_a_ignorer in params_a_ignorer do
				if _param_nom as string == param_a_ignorer do result = true
			result
		),
		
		
		
		
		
		
	private
		fn enregistrer_parametre_dansNodeXML		_node	_xmlNode =(
			
			local parametres_noms 			=  getpropNames 	_node
			
			for param_nom in parametres_noms  where not est_param_a_ignorer	param_nom  do (
			
				local param_propriete 	= getProperty  _node 	param_nom 
				local param_class 		= classof	param_propriete
				
				case param_class of (
					ArrayParameter: (
								
								--- si c'est un plug -----
								if param_propriete.count > 0  and isMSPlugin	param_propriete[1] then (
									
									--- on creer le parametre ----- 
									local nv_nodeXML_param	=	xmlPresets.CreateElement		param_nom
									_xmlNode.appendChild 	nv_nodeXML_param
									
									for i = 1 to param_propriete.count do (
										
										--- on creer le l'item  ----- 
										local nv_nodeXML_item	=	xmlPresets.CreateElement		"item"
										nv_nodeXML_param.appendChild 	nv_nodeXML_item
										nv_nodeXML_item.SetAttribute 	"class"		( param_propriete[i] as string )
										
										enregistrer_parametre_dansNodeXML		param_propriete[i]		nv_nodeXML_item
										
									)
									 
								---- sinon c'est juste un tableau de trucs de base ----------
								) else	_xmlNode.SetAttribute 	param_nom		( param_propriete as string )
									
							) --- fin ArrayParameter -----
							
					default:	(
						
						if isMSPlugin	param_propriete  then (
							
							--- on creer le parametre ----- 
							local nv_nodeXML_param	=	xmlPresets.CreateElement		param_nom
							_xmlNode.appendChild 	nv_nodeXML_param
							
							--- on creer l'item  ----- 
							local nv_nodeXML_item	=	xmlPresets.CreateElement		"item"
							nv_nodeXML_param.appendChild 	nv_nodeXML_item
							nv_nodeXML_item.SetAttribute 	"class"		( param_propriete as string )
							
							enregistrer_parametre_dansNodeXML		param_propriete		nv_nodeXML_item
							
						) else 	_xmlNode.SetAttribute 	param_nom		( param_propriete as string )
						
					) ---- fin default ----
				) -- fin case param_class  ----
			) --- fin for param_nom	-------
		),
		
		
		fn charger_parametre_depuisNodeXML		_node	_xmlNode =(
			
			---- on charge les attributs --------------
			for i = 0 to _xmlNode.Attributes.count - 1 do (
				local attrib = _xmlNode.Attributes.itemOf[i]
				
				if attrib.name != "class" do (
					
					local prop_base 	= getProperty	_node	attrib.name
					case classOf prop_base of (
						string:	setProperty 	_node		attrib.name		attrib.value
						default:	setProperty 	_node		attrib.name		( execute attrib.value )
					)
					
				)
			)
			
			---- on charge les élements --------------
			for i = 0 to _xmlNode.ChildNodes.count - 1 do (
				
				local childNode 	= _xmlNode.ChildNodes.itemOf[i]				
				local prop_base 	= getProperty	_node	childNode.name
				
				---- soit on a un simple plugin comme parametre	-----
				if classof  prop_base == ArrayParameter then (	---- soit on a un tableau de plugins	-----
					
					local items_aAjouter = #()
					
					for i = 0 to childNode.ChildNodes.count - 1 do (
						
						---- on creer le plugin de l'item -----
						local childNodeItem 		= childNode.ChildNodes.itemOf[i]
						local classItem 			= childNodeItem.GetAttribute "class"						
						local nv_item				=	createInstance	(execute classItem )
						
						----- on charge ses parametres-----
						nv_item = charger_parametre_depuisNodeXML	nv_item		childNodeItem
						
						append	items_aAjouter	nv_item
						
					)
					
					---- et on ajoute le tableau a notre plug parent -------
					setProperty	_node	childNode.name	items_aAjouter
					
				) else (
					
					---- on creer le plugin de l'item -----
					local childNodeItem 		= childNode.FirstChild		
					local classItem 			= childNodeItem.GetAttribute "class"					
					local nv_item				=	createInstance	(execute classItem )
					
					----- on charge ses parametres-----
					nv_item = charger_parametre_depuisNodeXML	nv_item		childNodeItem
					
					---- et on l'ajoute a notre plug parent -------
					setProperty	_node	childNode.name	nv_item
					
				) 
				
			)
			
			_node
			
		),
		
		
		
		
	------- interface -------------------------------------
	public	
		fn enregistrer 		_node	fichier:		=(
			
			--- le dossier -----
			if not doesFileExist fichier_dossier do makeDir  fichier_dossier
			
			---- le fichier -----
			local fichierCible
			if fichier == unsupplied then
				fichierCible 	=	getSaveFileName 	caption:					"Enregistrer" 			\
																	filename:				fichier_dossier 		\
																	types:					fichier_type			\
																	historyCategory:		fichier_categorie
			else 	fichierCible	=	fichier
			
			
			---- l'enregistrement --------
			if fichierCible != undefined do (
				
				---- On creer le xml et son root 	-----------
				xmlPresets 			= dotNetObject "system.xml.xmlDocument"
				local xmlRoot		=	xmlPresets.CreateElement "Batiment"
				xmlPresets.appendChild xmlRoot
				
				---- parametres	-----
				enregistrer_parametre_dansNodeXML		_node	xmlRoot
				
				---- sauvegarder le fichier xml -----------
				xmlPresets.save 		fichierCible
				
			)
			
		),
		
		
		fn charger  	_node 		fichier:		= (
			
			local fichierCible 	
			if fichier == unsupplied then
					fichierCible 	=	getopenFileName 		caption:				"Charger" 				\
																			filename:			fichier_dossier 		\
																			types:				fichier_type			\
																			historyCategory:	fichier_categorie
			else 	fichierCible	=	fichier
			
			if fichierCible != undefined do (
				
				---- On charge le fichier xml 	-----------
				xmlPresets 			= dotNetObject "system.xml.xmlDocument"
				xmlPresets.load 		fichierCible
				
				---- on chope le premier noeud ----------
				local root_node = xmlPresets.FirstChild
				
				charger_parametre_depuisNodeXML		_node	root_node 
				
			)
			
			
		),
		
		
		fn copier 	_node	=(
			
			---- On creer le xml et son root 	-----------
			xmlPresets 			= dotNetObject "system.xml.xmlDocument"
			local xmlRoot		=	xmlPresets.CreateElement "Batiment"
			xmlPresets.appendChild xmlRoot
			
			---- parametres	-----
			enregistrer_parametre_dansNodeXML		_node	xmlRoot
			
			urba_clipboard_batiment = copy xmlPresets
			
			
			
			--- debug -------
			urba_clipboard_batiment.save  "C:\\temp\\test.bati"
			ShellLaunch "C:\\temp\\test.bati" ""
			
		),
		
		
		fn coller 	_node	=(
			
				local root_node = urba_clipboard_batiment.FirstChild
				charger_parametre_depuisNodeXML		_node	root_node 
		)
		
		
) ------------- fin struct -------------------














