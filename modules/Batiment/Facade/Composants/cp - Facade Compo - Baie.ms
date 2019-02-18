

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
		
		menuiserie_type			type:#integer 			ui:ddl_type_menuiserie				default:3
		menuiserie_objet			type:#maxObject		
		
	)	-----	fin parametres --------------------
	
	parameters params_menuiserie rollout:roll_menuiserie	(
		
		
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
	
	
	
	
	
	
	
	
	
	
	rollout roll_baie "Baie" width:268 height:221
	(
		edittext 'edt_nom' "" pos:[5,2] width:170 height:17 align:#left
		
		GroupBox 'grp_dimensions' "Dimensions" pos:[5,22] width:170 height:90 align:#left
		
		label 'lbl_longueur' "Longueur:" pos:[20,42] width:60 height:19 align:#left
		spinner 'spn_longueur' "" pos:[90,42] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		label 'lbl_hauteur' "Hauteur:" pos:[20,57] width:55 height:19 align:#left
		spinner 'spn_hauteur' "" pos:[90,57] width:75 height:16 range:[-1e+20,1e+20,0] type:#worldunits align:#left
		label 'lbl_profondeur' "Profondeur:" pos:[20,72] width:69 height:19 align:#left
		spinner 'spn_profondeur' "" pos:[90,72] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		label 'lbl_allegePleine' "Allège pleine:" pos:[20,87] width:75 height:19 align:#left
		spinner 'spn_allegePleine' "" pos:[90,87] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		
		
		
		GroupBox 'grp_occultation' "Occultation" pos:[5,120] width:170 height:46 align:#left
		
		dropdownList 'ddl_occultation' "" pos:[15,139] width:150 height:21 align:#left
	)
	
	
	
	rollout roll_menuiserie_2 "Menuiserie" width:188 height:285
	(
		button 'btn29' "Fixe" pos:[5,5] width:48 height:17 align:#left
		button 'btn30' "Fenêtre" pos:[52,5] width:48 height:17 align:#left
		button 'btn31' "Porte" pos:[99,5] width:48 height:17 align:#left
		
		dotNetControl 'tv_sequence' "treeview" pos:[5,25] width:141 height:89 align:#left
		
		button 'btn32' "Dup" pos:[150,25] width:25 height:17 align:#left	tooltip:"Dupliquer."
		button 'btn33' "Inst" pos:[150,41] width:25 height:17 align:#left	tooltip:"Instancier."
		button 'btn34' "Uni" pos:[150,57] width:25 height:17 align:#left	tooltip:"Rendre unique."
		button 'btn35' "Sup" pos:[150,73] width:25 height:17 align:#left	tooltip:"Supprimer."
		
		GroupBox 'grp45' "Elément" pos:[5,121] width:170 height:121 align:#left
		
		spinner 'spn99' "" pos:[90,141] width:75 height:16 range:[0,100,0] type:#worldunits align:#left
		label 'lbl95' "Longueur:" pos:[20,139] width:75 height:19 align:#left
		spinner 'spn100' "" pos:[90,156] width:75 height:16 range:[0,100,0] type:#integer align:#left
		label 'lbl96' "Montants:" pos:[20,155] width:75 height:19 align:#left
		spinner 'spn101' "" pos:[90,171] width:75 height:16 range:[0,100,0] type:#integer align:#left
		label 'lbl97' "Traverses:" pos:[20,169] width:75 height:19 align:#left
		
		checkbox 'chk75' "Inverser sens" pos:[18,188] width:104 height:16 align:#left
		checkbox 'chk74' "Double" pos:[18,202] width:133 height:16 align:#left
		checkbox 'chk76' "Vitrée" pos:[18,216] width:133 height:16 align:#left
		
		spinner 'spn119' "" pos:[90,250] width:85 height:16 range:[0,100,0] type:#worldunits align:#left
		spinner 'spn120' "" pos:[90,265] width:85 height:16 range:[0,100,0] type:#worldunits align:#left
		checkbox 'chk91' "Imposte:" pos:[10,249] width:76 height:16 align:#left
		checkbox 'chk92' "Allège:" pos:[10,263] width:60 height:16 align:#left
	)
	
	
	
	
	rollout rol_global  "Global"	(
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
	)
	
	rollout roll_parametres  "Baie"	(		
		
		group "Dimensions" (
-- 			checkbox	shk_etirable			"Etirable" 	
			spinner 	spn_longueur 			"Longueur" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_baie_hauteur 		"Hauteur" 			type:#worldunits 	range:[-1e20,1e20,0]
			spinner 	spn_profondeur			"Profondeur" 		type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_allege_hauteur 	"Allège" 		type:#worldunits 	range:[0,1e20,0]
		)
		group " Menuiserie" (
			dropDownList ddl_type_menuiserie	""  align:#left
		)
		group "Divers" (
			checkbox	shk_tablette			"Tablette" 	
			dropDownList	ddl_volet		"Volets"	 items:#("Aucun", "Battant", "Roulant")
		)
		
		fn actualiser =(
			
			
			--- le dropdownlist	--------------
			local liste_nomsMenuis = #()
			for classe in menuis_classes do (
				local tmp_instance = createinstance 	classe
				append liste_nomsMenuis	tmp_instance.nom
			)
			ddl_type_menuiserie.items = liste_nomsMenuis
			
		)
		on roll_parametres	open 					do actualiser ()
		on ddl_type_menuiserie		selected val	do (
			menuiserie_objet = createInstance menuis_classes[val ]
			redrawViews ()
			actualiser()
		)
	)
	
	
	rollout roll_menuiserie "Menuiserie" 
	(
-- 		dropDownList ddl_type_menuiserie	""  align:#left
		
		subrollout		subRoll_param	""		height:250	align:#left
		
		fn actualiser = (
			
			
			
			--- le subroll	--------------
			if subRoll_param.rollouts.count > 0 do 
				for subRoll in subRoll_param.rollouts  do
					removeSubRollout subRoll_param	subRoll
			
			addSubRollout 	subRoll_param		menuiserie_objet.roll_parametres
			
		)
		
		
		
		on roll_menuiserie open do actualiser ()
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
			local hauteur_menuis		=	if baie_hauteur <=0 	then		hauteur + baie_hauteur - allege_hauteur
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
