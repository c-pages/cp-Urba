
plugin simpleObject		cp_facadeElem_balcon
name:"Balcon"
classID:#(0x5b4e91a1, 0x66f01359)
category:"CP | Facade	| Element"
-- invisible:true
(
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_facadeElem_balcon"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local corriger_parametres , assigner_gardeCorps, init_liste_gardeCorps
	local liste_gardeCorps =#()
	
	
	--- composant ---
	local compo_gardeCorps
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	---- la sequence à construire issue de la sequence	------------------------
	local sequence_aConstruire
	
	--------------- PARAMETERES  ----------------------------------------------------------------------------------------------------------------------
	parameters params_parameters rollout:roll_parametres	(
		
		nom	 					type:#string 		/* 	ui:edTxt_nom	 */				default:"Balcon"
		
		longueur 				type:#worldUnits 	/* ui:spn_longueur 	 */			default:0.
		hauteur	 				type:#worldUnits 	/* ui:spn_hauteur  */			default:0.
		dalle_epaisseur 		type:#worldUnits /* 	ui:spn_dalle_epaisseur	 */		default:20.
		dalle_porteAFaux	 	type:#worldUnits 	ui:spn_dalle_porteAFaux 	default:60.
		profondeur	 			type:#worldUnits 	ui:spn_profondeur 			default:60.
		
		
		elements				type:#maxObjectTab		tabSizeVariable:true
		
		gardeCorps_objet		type:#maxObject		
	)
	parameters params_divers rollout:roll_divers	(
		
		------ options --------------
		qualite							type:#integer 			ui:rdo_qualite				default:1
		
		est_ouvrable					type:#boolean 					default:false
		
		------ mat ID ----------
		matId_huisserie				type:#integer 			ui:spn_matId_huisserie	default:3
		matId_mur						type:#integer 			ui:spn_matId_mur		default:4
		
	)	-----	fin parametres --------------------
	parameters params_hasard rollout:roll_hasard	(
		hasard_seed					type:#integer 			ui:spn_hasard_seed		default:123456
		
		fen_proba_ouv				type:#float 			ui:spn_fen_proba_ouv		default:0.
		fen_ouvMax					type:#float 			ui:spn_fen_ouvMax			default:0.
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	--------------- ROLLOUTS  ----------------------------------------------------------------------------------------------------------------------
	rollout roll_parametres 				"Paramètres"	(
		
-- 		local liste_gardeCorps = #()
		
		
		group  "Dimensions" (
			spinner 	spn_dalle_porteAFaux 		"Porte-à-faux" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_profondeur 		"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
		)
		group "Garde corps" (
			dropDownList	ddl_gardeCorps	""	items:#("Aucun", "Simple", "Bareaudage")
		)
		
		fn actualiser =(
			/* 
			--- on fait la liste des occultants -----------
			liste_gardeCorps = #()
			local liste_gardeCorps_noms= #( "- aucun -")			
			for classe_gardeCorps in GeometryClass.classes where classe_gardeCorps.category == #'CP | Menuiserie	| Element | Garde Corps' do (
				append liste_gardeCorps_noms 		classe_gardeCorps.name
				append liste_gardeCorps 				classe_gardeCorps
			)
			 */
			
			init_liste_gardeCorps ()
			
			--- qu'on  affiche dans le menu deroulant -------
			local liste_gardeCorps_noms= #( "- aucun -")			
			for classe_gardeCorps in GeometryClass.classes where classe_gardeCorps.category == #'CP | Menuiserie	| Element | Garde Corps' do 
				append liste_gardeCorps_noms 		classe_gardeCorps.name
			ddl_gardeCorps.items = for classe_gardeCorps in liste_gardeCorps_noms collect  ( classe_gardeCorps )
			
			---- puis on selectionne le bon  ------------
			if gardeCorps_objet == undefined then ddl_gardeCorps.selection = 1 else 
				ddl_gardeCorps.selection = ( findItem	liste_gardeCorps	( classof gardeCorps_objet ) ) + 1
			
		)
		
		
		on roll_parametres	open do actualiser ()
		on ddl_gardeCorps selected arg do	assigner_gardeCorps arg
			
			/*  (
			if arg == 1 then 
				gardeCorps_objet = undefined
			else 
				gardeCorps_objet = createInstance liste_gardeCorps[ arg - 1 ] 
			redrawviews  ()
		) */
		
		
	)
	rollout roll_divers  "Divers"	(
		
		group "Qualité" (
			radioButtons rdo_qualite 			"" labels:#("Full", "Medium", "Low poly") align:#left
		)
		group "Material ID" (
			spinner spn_matId_huisserie 	"Huisserie" 				type:#integer range:[1,1000,1]
			spinner spn_matId_mur 			"Mur" 					type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	rollout roll_hasard  "Hasard"	(
		
		spinner spn_hasard_seed 			"Seed" 					type:#integer		 range:[0,1e20,0]
		
		group "Fenetres" (
			spinner spn_fen_proba_ouv 		"Proba (%)" 			type:#float			 range:[0,100,0]
			spinner spn_fen_ouvMax 			"Max (°)" 		type:#float			 range:[0,180,0]
		)
	
	)
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn init_liste_gardeCorps =(
		
		if liste_gardeCorps.count == 0 do (
			liste_gardeCorps = #()
			local liste_gardeCorps_noms= #( "- aucun -")			
			for classe_gardeCorps in GeometryClass.classes where classe_gardeCorps.category == #'CP | Menuiserie	| Element | Garde Corps' do
				append liste_gardeCorps 				classe_gardeCorps
		)
		
	)
	
	
	fn initialiser =(
		
		--- on fait la liste des occultants -----------
		init_liste_gardeCorps ()
		
	)
	
	fn get_longueur	=	(
		local result_longueur = 0
		for elem in elements do
			result_longueur += elem.get_longueur ()
		result_longueur
	) 
	fn set_hasard	_fen_ouvMax	_fen_proba_ouv =(
		
		
		fen_ouvMax 		= _fen_ouvMax
		fen_proba_ouv 	= _fen_proba_ouv
		for elem in elements do
			elem.set_hasard	_fen_ouvMax	_fen_proba_ouv
	)
	
	fn assigner_gardeCorps	_index =(
		
		init_liste_gardeCorps ()
		
		if _index == 1 then 
				gardeCorps_objet = undefined
			else 
				gardeCorps_objet = createInstance liste_gardeCorps[ _index - 1 ] 
			redrawviews  ()
	)	
	
	
	
	
	
	
	fn actualiser_composants	= with redraw off (
		
		
		--------	la sequence du balcon ------------
		sequence_aConstruire 				= 	#()
		for elem in elements do (
			
			--- le composant ----------------
			local compo_temp 			= 	copy elem				
			compo_temp.hauteur			=	hauteur
			compo_temp.qualite			=	qualite
			compo_temp.set_hasard	fen_ouvMax	fen_proba_ouv 
			append sequence_aConstruire		compo_temp
			
		) --- fin for sequence ------------------
		
		
		
		
		----------- le garde corps -----------
		if gardeCorps_objet != undefined do (
			
			compo_gardeCorps					= copy gardeCorps_objet
			compo_gardeCorps.longueur 		= longueur
			compo_gardeCorps.hauteur 		= 100.
			compo_gardeCorps.profondeur 	= profondeur
			
		)
		
		
	)  --- fin actualiser_composants  ------------------
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		
		--- Construction ---------------------------------------------------------------------------------------		
		local compo_dalle				= 	createInstance 	cp_prim_boite	matId:matId_mur
		compo_dalle.hauteur 			= 	dalle_epaisseur
		compo_dalle.profondeur		=	dalle_porteAFaux
		compo_dalle.longueur		=	get_longueur()
		mgr_mesh.attacher		mesh		compo_dalle			transf:[0,-dalle_porteAFaux ,-dalle_epaisseur]
		
		---- la sequence	-----		
		local depos_composant = [ 0, 0, 0 ]
		for i = 1 to	sequence_aConstruire.count do (
			
			---- le composant -----
			local composant 		= sequence_aConstruire [i]
			mgr_mesh.attacher		mesh		composant	transf:( depos_composant + [0,profondeur,0] )
			
			depos_composant.x += composant.get_longueur()
			
		)
		
		
		
		--- les element pour la loggia , si besoin	---------
		if profondeur > 0 do (
			--- sol ------
			local compo_mur			= 	createInstance 	cp_prim_planHorizontal	matId:matId_mur
			compo_mur.longueur 	=	get_longueur()
			compo_mur.profondeur 	=	profondeur			
			mgr_mesh.attacher		mesh		compo_mur		--transf:( rotateZMatrix	90 )
			
			--- plafond ----
			mgr_mesh.attacher		mesh		compo_mur		transf:( ( rotateYMatrix	180  )	*	transMatrix	[get_longueur(), 0, hauteur ] )
			
			
			--- mur G  ------
			local compo_mur			= 	createInstance 	cp_prim_planVertical		matId:matId_mur
			compo_mur.longueur 	=	profondeur
			compo_mur.hauteur	 	=	hauteur			
			mgr_mesh.attacher		mesh		compo_mur		transf:( rotateZMatrix	90 )
			
			
			--- mur D ----
			mgr_mesh.attacher		mesh		compo_mur		transf:( ( rotateZMatrix	-90  )	*	transMatrix	[get_longueur(), profondeur, 0 ] )
			
			
		)
		
		
		
		
		---- le garde corps -------------
		if gardeCorps_objet != undefined do 
			mgr_mesh.attacher		mesh		compo_gardeCorps 	--transf:[0,0,allege_hauteur]
		
		
	)	---- fin buildMesh --------------
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		on mousePoint click do
			case click of
			(
				1: (	pt_debut 	=  gridPoint
						nodeTM.translation = pt_debut
				)
				2: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= length ( gridPoint - pt_debut )
					local norm_dir 		=	normalize (gridPoint - pt_debut )
					local angle_pts		=	acos(dot  [1,0,0]  norm_dir)		
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
				)
			)
	) --- fin tool create ---------
	
	------ events ----------------------------------------------------------
	on create do (
		initialiser ()
	)
	on load do (
		initialiser ()
	)
	on update do (
		initialiser ()
	)/* 
	on clone _orig do (
		initialiser ()
	) */
	
	
) ---- fin du plugin --------------------------