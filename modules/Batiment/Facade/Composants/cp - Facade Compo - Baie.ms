

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
	local compo_menuis, compo_imposte
	
	
	
	
	
	
	parameters params_dimensions rollout:rol_global	(
		
		hauteur	 		type:#worldUnits 	ui:spn_hauteur 			default:250.
		
		menuis_epaisseur		type:#worldUnits 	ui:spn_menuis_largeur				default:7.
		menuis_profondeur	type:#worldUnits 	ui:spn_menuis_profondeur			default:5.
	)
	parameters params_general rollout:roll_parametres	(
		
		longueur 					type:#worldUnits 	ui:spn_longueur 				default:120.
		baie_hauteur				type:#worldUnits 	ui:spn_baie_hauteur			default:-50.
		profondeur	 			type:#worldUnits 	ui:spn_profondeur				default:15.
		allege_hauteur			type:#worldUnits 	ui:spn_allegePleine			default:100.
		
		tablette						type:#boolean 						default:true
		
		menuiserie_objet			type:#maxObject		
		
		
	)	-----	fin parametres --------------------
	
	parameters params_imposte rollout:roll_imposte	(
		
		imposte_use				type:#boolean 			ui:chck_imposte_use				default:false
		imposte_hauteur		type:#worldUnits 		ui:spn_imposte_hauteur			default:210.
		imposte_montants		type:#integer 			ui:spn_imposte_montants		default:0
		imposte_traverses		type:#integer 			ui:spn_imposte_traverses		default:0
		
		imposte_arc_use		type:#boolean 			ui:chck_imposte_arc_use		default:false
		imposte_arc_rayon		type:#worldUnits 		ui:spn_imposte_arc_rayon		default:250.
		
		imposte_objet			type:#maxObject		
		
	)
	parameters params_divers rollout:roll_divers	(
		
		nom	 							type:#string 			default:"Baie"
		
		------ options --------------
		qualite							type:#integer 			ui:rdo_qualite				default:1
		
		------ mat ID ----------
		matId_menuis				type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage				type:#integer 			ui:spn_matId_vitrage	default:2
		matId_poignee				type:#integer 			ui:spn_matId_poignee	default:3
		matId_mur					type:#integer 			ui:spn_matId_mur		default:4
		
	)	-----	fin parametres --------------------
	
	
	parameters params_hasard --rollout:roll_hasard
	(
		hasard_seed					type:#integer 		/* 	ui:spn_hasard_seed	 */	default:123456
		
		fen_proba_ouv				type:#float 		/* 	ui:spn_fen_proba_ouv	 */	default:0.
		fen_ouvMax					type:#float 		/* 	ui:spn_fen_ouvMax	 */		default:0.
	)
	
	
	
	
	
	
	
	
	
	
	rollout roll_parametres	 "Baie" width:268 height:221
	(
		edittext 'edt_nom' "" pos:[5,2] width:170 height:17 align:#left
		
		GroupBox 'grp_dimensions' "Dimensions" pos:[5,22] width:170 height:90 align:#left
		
		label 'lbl_longueur' "Longueur:" pos:[20,42] width:60 height:19 align:#left
		spinner 'spn_longueur' "" pos:[90,42] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		label 'lbl_hauteur' "Hauteur:" pos:[20,57] width:55 height:19 align:#left
		spinner 'spn_baie_hauteur' "" pos:[90,57] width:75 height:16 range:[-1e+20,1e+20,0] type:#worldunits align:#left
		label 'lbl_profondeur' "Profondeur:" pos:[20,72] width:69 height:19 align:#left
		spinner 'spn_profondeur' "" pos:[90,72] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		label 'lbl_allegePleine' "Allège pleine:" pos:[20,87] width:75 height:19 align:#left
		spinner 'spn_allegePleine' "" pos:[90,87] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		
		
		
		GroupBox 'grp_occultation' "Occultation" pos:[5,120] width:170 height:46 align:#left
		
		dropdownList 'ddl_occultation' "" pos:[15,139] width:150 height:21 align:#left
	)
	
	
	
	
	rollout rol_global "Global" width:162 height:106
	(
		spinner 'spn_hauteur' "Hauteur" pos:[42,7] width:70 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		
		spinner 'spn_menuis_largeur' "" pos:[90,29] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		label 'lbl_largeur' "Largeur:" pos:[20,29] width:67 height:16 align:#left
		spinner 'spn_menuis_profondeur' "" pos:[90,44] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		label 'lbl_menuis_profondeur' "Profondeur:" pos:[20,44] width:67 height:16 align:#left
	)
	
	
	rollout roll_menuiserie "Menuiserie" 
	(
		
		subrollout		subRoll_param	""		pos:[0,0]	height:320	width:179 align:#left
		
		fn actualiser = (
			
			addSubRollout 	subRoll_param		menuiserie_objet.roll_parametres
			
		)
		on roll_menuiserie open do actualiser ()
	)
	
	
	rollout roll_imposte "Imposte" width:162 height:106
	(
		
		checkbox 'chck_imposte_use' "Imposte" pos:[18,1] width:69 height:16 align:#left		
		
		label 'lbl_imposte_hauteur' "Hauteur:" pos:[20,17] width:60 height:19 align:#left
		spinner 'spn_imposte_hauteur' "" pos:[90,17] width:75 height:16 range:[-1e+20,1e+20,0] type:#worldunits align:#left
		label 'lbl_imposte_montants' "Montants:" pos:[20,32] width:55 height:19 align:#left
		spinner 'spn_imposte_montants' "" pos:[90,32] width:75 height:16 range:[-1e+20,1e+20,0] type:#integer align:#left
		label 'lbl_imposte_traverses' "Traverses:" pos:[20,47] width:69 height:19 align:#left
		spinner 'spn_imposte_traverses' "" pos:[90,47] width:75 height:16 range:[0,1e+20,0] type:#integer align:#left
		
		checkbox 'chck_imposte_arc_use' "Arc" pos:[18,65] width:69 height:16 align:#left
		label 'lbl_imposte_rayon' "Rayon:" pos:[20,81] width:60 height:19 align:#left
		spinner 'spn_imposte_arc_rayon' "" pos:[90,81] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		
		fn actualiser	=(
			lbl_imposte_hauteur.enabled 					= imposte_use
			spn_imposte_hauteur.enabled 				= imposte_use
			spn_imposte_hauteur.indeterminate		= not imposte_use
			
			lbl_imposte_montants.enabled 				= imposte_use
			spn_imposte_montants.enabled 				= imposte_use
			spn_imposte_montants.indeterminate		= not imposte_use
			lbl_imposte_traverses.enabled 				= imposte_use
			spn_imposte_traverses.enabled 				= imposte_use
			spn_imposte_traverses.indeterminate		= not imposte_use
			
			chck_imposte_arc_use.enabled 				= imposte_use
			lbl_imposte_rayon.enabled 					= imposte_use and imposte_arc_use
			spn_imposte_arc_rayon.enabled 			= imposte_use and imposte_arc_use
			spn_imposte_arc_rayon.indeterminate	= not imposte_use or not imposte_arc_use
			
		)
		
		
		on roll_imposte	open do actualiser()
		
		on chck_imposte_use		changed state  do actualiser()
		on chck_imposte_arc_use	changed state  do actualiser()
		
	)
	
	
	rollout roll_divers  "Divers"	(
		
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
		
		
		---- si pas encore de mnuiserie on applique la menuiserie par defaut	------------------
		if menuiserie_objet == undefined do 
			menuiserie_objet = createInstance cp_menuiserie_ensemble		
		
		if imposte_objet == undefined do
			imposte_objet = createInstance cp_menuiserie_fixe
	)
	
	
	
	fn set_hasard	_fen_ouvMax	_fen_proba_ouv =(
		fen_ouvMax 		= _fen_ouvMax
		fen_proba_ouv 	= _fen_proba_ouv
	)
	fn get_longueur	=	longueur
	
	---- les composants ---------------------
	fn actualiser_composants	= with redraw off (
		
		
		------ la menuiserie principale	------------------------------------
		local hauteur_menuis			
		if menuiserie_objet != undefined do (

			compo_menuis					=	copy menuiserie_objet
			compo_menuis.longueur		=	longueur
			
			---- la hauteur de la menuiseire princpale, en fonction de l'imposte, de valeurs de hauteur négatives,etc ... ------------
			if not imposte_use then (
				hauteur_menuis		=	if baie_hauteur <=0 	then		hauteur + baie_hauteur - allege_hauteur
																				else		baie_hauteur - allege_hauteur
			) else (
				hauteur_menuis		=	if imposte_hauteur <=0 	then		(
					if baie_hauteur <=0 	then		hauteur + baie_hauteur + imposte_hauteur - allege_hauteur
													else		baie_hauteur + imposte_hauteur - allege_hauteur
					
				)	else		imposte_hauteur - allege_hauteur
				
				--- max et min	---------------
				if hauteur_menuis < 0 do hauteur_menuis = 0 
				local hauteur_max = if baie_hauteur <=0 	then		hauteur + baie_hauteur - allege_hauteur					
																				else		baie_hauteur - allege_hauteur
				if hauteur_menuis >hauteur_max do hauteur_menuis = hauteur_max
			)
			
			compo_menuis.hauteur		=	hauteur_menuis
			compo_menuis.qualite		=	qualite
			
			
			compo_menuis.menuis_epaisseur		= menuis_epaisseur
			compo_menuis.menuis_profondeur	= menuis_profondeur
		)
		
		------ l'imposte	------------------------------------------------
		if imposte_use do (
			if imposte_objet == undefined do
				imposte_objet = createInstance cp_menuiserie_fixe
			
			compo_imposte 				= copy imposte_objet
			compo_imposte.longueur	=	longueur
			compo_imposte.hauteur 	=	if baie_hauteur <=0 	then		hauteur + baie_hauteur - hauteur_menuis	 - allege_hauteur					
																						else		baie_hauteur - hauteur_menuis - allege_hauteur
			
			compo_imposte.div_montants_nbr		=	imposte_montants
			compo_imposte.div_traverses_nbr		=	imposte_traverses
			compo_imposte.qualite						=	qualite
			
			compo_imposte.menuis_epaisseur		= menuis_epaisseur
			compo_imposte.menuis_profondeur	= menuis_profondeur
			compo_imposte.div_largeur				=	menuis_epaisseur / 1.5
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
		local hauteur_baie_tmp 		= /* allege_hauteur +  */baie_hauteur
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
		local pt_8	=	[0,					0,						hauteur_baie_tmp]
		
		----- tableau droit ------
		local pt_9	=	[longueur,			0,						hauteur_baie_tmp]
		local pt_10	=	[longueur,			profondeur,	hauteur_baie_tmp]
		
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
		
		--- l'imposte	------------
		if imposte_use do 
			mgr_mesh.attacher		mesh		compo_imposte 	transf:[0,profondeur,allege_hauteur + compo_menuis.hauteur]
		
		
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
