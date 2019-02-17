

plugin simpleObject		cp_facadeElem_baie
name:"Baie"
classID:#(0x51488ca0, 0x39e98401)
category:"CP | Facade	| Element"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_baieElement_baie"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	--- Prédéfinitions ------------------
	local corriger_parametres
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	----- les composants -----------	
	local compo_menuis
	
	----- les classes de menuiserie ---------------------
	local menuis_classes
	
	
	
	
	
	parameters params_dimensions rollout:rol_global	(
		
		hauteur	 		type:#worldUnits 	ui:spn_hauteur 			default:250.
		
	)
	parameters params_general rollout:roll_parametres	(
		
		longueur 				type:#worldUnits 	ui:spn_longueur 				default:120.
		baie_hauteur			type:#worldUnits 	ui:spn_baie_hauteur			default:-50.
		profondeur	 			type:#worldUnits 	ui:spn_profondeur			default:15.
		allege_hauteur			type:#worldUnits 	ui:spn_allege_hauteur	default:100.
		
		tablette					type:#boolean 		ui:shk_tablette					default:true
		
		
	)	-----	fin parametres --------------------
	
	parameters params_menuiserie rollout:roll_menuiserie	(
		
		menuiserie_type			type:#integer 			ui:ddl_type_menuiserie				default:3
		menuiserie_objet			type:#maxObject		
		
	)
	parameters params_divers rollout:roll_divers	(
		
		nom	 							type:#string 			default:"Baie"
		
		------ options --------------
-- 		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		qualite							type:#integer 			ui:rdo_qualite				default:1
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_poignee					type:#integer 			ui:spn_matId_poignee	default:3
		matId_mur						type:#integer 			ui:spn_matId_mur		default:4
		
	)	-----	fin parametres --------------------
	
	
	parameters params_hasard --rollout:roll_hasard
	(
		hasard_seed					type:#integer 		/* 	ui:spn_hasard_seed	 */	default:123456
		
		fen_proba_ouv				type:#float 		/* 	ui:spn_fen_proba_ouv	 */	default:0.
		fen_ouvMax					type:#float 		/* 	ui:spn_fen_ouvMax	 */		default:0.
	)
	
	
	
	
	
	
	
	
	
	
	
	
	rollout rol_global  "Global"	(
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
	)
	
	rollout roll_parametres  "Paramètres"	(		
		
		group "Dimensions" (
-- 			checkbox	shk_etirable			"Etirable" 	
			spinner 	spn_longueur 			"Longueur" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_baie_hauteur 		"Hauteur" 			type:#worldunits 	range:[-1e20,1e20,0]
			spinner 	spn_profondeur			"Profondeur" 		type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_allege_hauteur 	"Allège" 		type:#worldunits 	range:[0,1e20,0]
		)
		
		group "Divers" (
			checkbox	shk_tablette			"Tablette" 	
-- 		)
-- 		group "Volets" (
			dropDownList	ddl_volet		"Volets"	 items:#("Aucun", "Battant", "Roulant")
		)
		
		fn actualiser =(
		)
		on roll_parametres	open 					do actualiser ()
	)
	
	
	rollout roll_menuiserie "Menuiserie" width:162 height:136
	(
		dropDownList ddl_type_menuiserie	""  align:#left
		
		
		
		fn actualiser = (
			
			local liste_nomsMenuis = #()
			for classe in menuis_classes do (
				local tmp_instance = createinstance 	classe
				append liste_nomsMenuis	tmp_instance.nom
			)
			ddl_type_menuiserie.items = liste_nomsMenuis
			
		)
		
		
		
		on roll_menuiserie open do actualiser ()
		on ddl_type_menuiserie		selected val	do (
			menuiserie_objet = createInstance menuis_classes[val ]
			redrawViews ()
		)
	)
	
	
	
	
	rollout roll_divers  "Divers"	(
	/* 	group "Qualité" (
			checkbox	shk_lowPoly				"Low poly" 		
		) */
		group "Qualité" (
			radioButtons rdo_qualite 			"" labels:#("Full", "Medium", "Low poly") align:#left
		)
		group "Material ID" (
			spinner spn_matId_menuis 			"Menuiseries" 		type:#integer 			range:[1,1000,1]
			spinner spn_matId_vitrage 			"Vitrage" 				type:#integer 			range:[1,1000,1]
			spinner spn_matId_poignee 			"Poignée" 				type:#integer 			range:[1,1000,1]
			spinner spn_matId_mur	 			"Mur" 					type:#integer 			range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------

	fn initialiser	=(
		
		----- initialiser la liste des menuiseries	-----------------
		fn classer_ordeAlphabetique 	classe1 	classe2 =		( 
			case of				(
				(classe1 as string < classe2 as string): -1
				(classe1 as string > classe2 as string): 1
				default: 0
			)
		)
		menuis_classes = for classe in GeometryClass.classes where matchPattern ( classe as string ) pattern:"cp_menuiserie*" collect classe
		qsort menuis_classes	 classer_ordeAlphabetique
		
		
		
		
		---- si pas encore de mnuiserie on applique la menuiserie par defaut	------------------
		if menuiserie_objet == undefined do (
			menuiserie_objet = createInstance menuis_classes[menuiserie_type ]			
		)
	)
	
	
	
	fn set_hasard	_fen_ouvMax	_fen_proba_ouv =(
		fen_ouvMax 		= _fen_ouvMax
		fen_proba_ouv 	= _fen_proba_ouv
	)
	fn get_longueur	=	longueur
	
	---- les composants ---------------------
	fn actualiser_composants	= with redraw off (
		
		if menuiserie_objet != undefined do (
			compo_menuis	=	copy menuiserie_objet
			compo_menuis.longueur		=	longueur
			local hauteur_menuis		=	if baie_hauteur <0 	then		hauteur + baie_hauteur - allege_hauteur
																				else		baie_hauteur
			compo_menuis.hauteur		=	hauteur_menuis
			compo_menuis.qualite		=	qualite
		)
		
	)  --- fin composants_actualiser  ------------------
	
	
	
	
	
	
		
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		--- Construction ---------------------------------------------------------------------------------------
		---- la BAIE	------------------
		local hauteur_baie_tmp 		= allege_hauteur + baie_hauteur
		if baie_hauteur <= 0 do hauteur_baie_tmp = hauteur +	baie_hauteur
		
		---- Allege -----
		local pt_1	=	[0,					0,					0]
		local pt_2	=	[longueur,			0,					0]
		local pt_3	=	[0,					0,					allege_hauteur]
		local pt_4	=	[longueur,			0,					allege_hauteur]
		
		----- tableau bas ------
		local pt_5	=	[longueur,			profondeur,		allege_hauteur]
		local pt_6	=	[0,					profondeur,		allege_hauteur]
		
		----- tableau gauche ------
		local pt_7	=	[0,					profondeur,		hauteur_baie_tmp]
		local pt_8	=	[0,					0,					hauteur_baie_tmp]
		
		----- tableau droit ------
		local pt_9	=	[longueur,			0,					hauteur_baie_tmp]
		local pt_10	=	[longueur,			profondeur,		hauteur_baie_tmp]
		
		----- Imposte ------
		local pt_11	=	[longueur,			0,					hauteur]
		local pt_12	=	[0,					0,					hauteur]
		
		local pts 	= #(pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10, pt_11, pt_12) 
		
		----- on crée  les faces ----------------------------------------------------
		local faces = #(	[1,2,4], [1,4,3],		[3,4,5], [3,5,6],		[3,6,7], [3,7,8],		[5,4,9], [5,9,10],				[7,10,8], [8,10,9],		[8,9,11], [8,11,12] )
		
		--- mat ID ------
		local matIDs	= for i in faces collect matId_mur
		
		--- on crée les vertex ---------
		setMesh 	mesh 	verts:pts	faces:faces	materialIDs:matIDs
		
		----- On clean le mesh 	--------------
		meshop.autoSmooth		mesh 	#{1..mesh.numfaces} 		10
		meshop.autoEdge 			mesh 	#{1..mesh.Edges.count}	10	
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box		tm:(scaleMatrix [2,2,2]	)
		
		
		
		
		---- la tablette	-------------------		
		if tablette do (
			local compo_tablette 		
			if qualite != 3 then 
				compo_tablette	= createInstance  cp_prim_boite	matId:matId_menuis		--	cp_prim_planVertical
			else 
				compo_tablette	= createInstance  cp_prim_boiteL	matId:matId_menuis		symetrie:false	horizontal:true
			
			compo_tablette.longueur 	= longueur
			compo_tablette.profondeur = profondeur + 5.
			compo_tablette.hauteur 	= 5.
			mgr_mesh.attacher		mesh		compo_tablette 	transf:[0, -5. , allege_hauteur - 4.  ]
		)
		
		
		
		---- la menuiserie	-------------------		
		if menuiserie_objet != undefined do 
			mgr_mesh.attacher		mesh		compo_menuis 	transf:[0,profondeur,allege_hauteur]
		
		
		
	)  ----- fin on buld mesh ---------------------------------------------------------------------
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		local pt_epaisseur
		
		on mousePoint click do
			case click of
			(
				1: (	
						pt_debut 		=  gridPoint
						nodeTM.translation = pt_debut
				)
				2: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= 	length 		( gridPoint - pt_debut )
					local norm_dir 		=	normalize 	(gridPoint - pt_debut )
					local angle_pts		=	acos			(dot  [1,0,0]  norm_dir)		
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
					pt_hauteur				=	gridPoint
					
					
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
	)
	
	
	
	
) ------- fin plugin ---------------------


