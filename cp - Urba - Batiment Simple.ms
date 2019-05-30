


-------------- les fichiers à inclure ------------------------------------------------------------------------------------
--- pour debogage -----------
-- include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - Debug.ms" 

--- les fichiers necessaires au plug -----------
-- include	 "$userScripts\\cp-Urba\\Startup\\cp - Urba - Batiment - FileIn.ms" 






/* 	
---------- quelque variables et fonctions globales	----------------------------------------------------------------------------------------------
global 	urba_fn_afficheur_longueurs	--- fonction pour affichage viewport 
-- global	urba_clipboard_batiment		---	clipboard pour copier/coller des presets



 */

-------- pour changer les qualites des geometries si besoin, avant rendu, et remettre en qualite viewport apres --------------------------
---- PRERENDU	-----------
callbacks.removescripts 	id:	#urbaBatSimple_preRender

global batiments_asProxy =#()
txt_pre ="with redraw off (\n"
txt_pre +="	batiments_asProxy =#()\n"
txt_pre +="	for bat in objects where classof bat == cp_batiment and bat.renderable  and not bat.isHidden do (\n"
txt_pre +="		if bat.qualite_courante != bat.qualite_render do (\n	bat.qualite_courante = bat.qualite_render\n"
txt_pre +="			append	batiments_asProxy		bat\n"
txt_pre +="		) \n	)	\n )	\n	"
callbacks.addscript 	#preRender 	txt_pre 		id:#urbaBat_preRender

---- POST RENDU	-----------
callbacks.removescripts 	id:#urbaBatSimple_postRender
txt_post ="	for bat in batiments_asProxy do (\n"
txt_post +="			if bat.qualite_courante != bat.qualite_viewport do bat.qualite_courante = bat.qualite_viewport\n"
txt_post +="		)\n"
callbacks.addscript 	#postRender 	txt_post 		id:#urbaBatSimple_postRender





	
--------------- le plugin himself ------------------------------------------------------------------------------------
plugin simpleObject		cp_batimentSimple
name:"Bâtiment Simple"
classID:#(0x2d4f9648, 0x70b169d4)
category:"CP | Urba"
-- invisible:true
(
	
	
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_batimentSimple"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local basculer_editeurFacade, ajouter_facade, retirer_facade, dupliquer_facade,  monter_facade, descendre_facade, renommer_facade, actualiser_shape
	local ajouter_etage_spe, supprimer_etage_spe
	local afficher_longueurs
	local roll_editeur_facade
	local preset_copier,	preset_coller, preset_enregistrer, preset_charger
	
	local definir_toiture, optimiser
	
	local facade_courante
	
	
	--- rollout ---
	local roll_sequence
	
	
	----- les points de la surface------------------------
	local pts_surface
	
	
	---- managers ----------
	local mgr_shp 			= str_mgr_shape ()
	local mgr_mesh 		= str_mgr_mesh ()
	local mgr_presets 	= str_mgr_batiment_presetsXML ()
	
	
	
-- 	parameters param_etages/*  rollout:roll_etages */	(
		
		------- Etages			------------------
-- 		etages_nbre					type: #integer				default:1			ui:spn_etages_nbres	 				animatable:false		invisibleInTV:true
-- 		etages_hauteur_global		type: #worldUnits 		default:250.	 	ui:spn_etages_hauteur	 			animatable:false		invisibleInTV:true
-- 		
-- 		dalle_epaisseur				type: #worldUnits 		default:20.	 		/* ui:spn_dalle_epaisseur */	 			animatable:false		invisibleInTV:true
-- 		soubassement_hauteur	type: #worldUnits 		default:100.	 	/* ui:spn_soubassement_hauteur */	animatable:false		invisibleInTV:true
		
		
-- 	)
	
	parameters param_general rollout:roll_general	(
		------- Surface		------------------
		surface_node					type:#node 			 	ui:btn_pick_perimetre		animatable:false		invisibleInTV:true
		
		------- Optimisations		------------------
		optimisation							type:#boolean			default:true		ui:chk_optimisation		animatable:false		invisibleInTV:true
		
		optim_aplanir					type:#boolean			default:true		/* ui:chk_aplanir	 */	animatable:false		invisibleInTV:true
		optim_souder					type:#boolean			default:true		/* ui:chk_souder */		animatable:false		invisibleInTV:true
		optim_orthonormer			type:#boolean			default:false		/* ui:chk_ortho	 */		animatable:false		invisibleInTV:true
		optim_aligner					type:#boolean			default:false		/* ui:chk_aligner */		animatable:false		invisibleInTV:true
		optim_projeter				type:#boolean			default:false		/* ui:chk_projeter */		animatable:false		invisibleInTV:true
		
		------- Seuils		------------------
		optim_aplanir_seuil			type:#float				default:20.			/* ui:spn_aplanir */		animatable:false		invisibleInTV:true
		optim_souder_seuil			type:#float				default:30.			/* ui:spn_souder */		animatable:false		invisibleInTV:true
		optim_ortho_seuil			type:#float				default:100.		/* ui:spn_ortho	 */	animatable:false		invisibleInTV:true
		optim_aligner_seuil			type:#float				default:50.			/* ui:spn_aligner	 */	animatable:false		invisibleInTV:true
		
		
		
		
		
		
		------- Etages			------------------
		etages_nbre					type: #integer				default:1			ui:spn_etages_nbres	 				animatable:false		invisibleInTV:true
		etages_hauteur_global		type: #worldUnits 		default:250.	 	ui:spn_etages_hauteur	 			animatable:false		invisibleInTV:true
		
		dalle_epaisseur				type: #worldUnits 		default:20.	 		/* ui:spn_dalle_epaisseur */	 			animatable:false		invisibleInTV:true
		soubassement_hauteur	type: #worldUnits 		default:100.	 	/* ui:spn_soubassement_hauteur */	animatable:false		invisibleInTV:true
		
		
		------- Etages	 specifiques		------------------
		etages_spe_min				type: #intTab					tabSizeVariable:true
		etages_spe_max				type: #intTab					tabSizeVariable:true
		etages_spe_hauteur			type: #worldUnitsTab			tabSizeVariable:true
		
	)
	
	parameters param_facades rollout:roll_facades	(
		facades							type:#maxObjectTab	tabSizeVariable:true
		
-- 		affichage_longueurs		type:#boolean 		/* ui:ckb_afficher_longueur	 */			default:true
-- 		editeur_facade_ouvert		type:#boolean 		 ui:btn_editer_facade	 			default:false
		
	)
	
	parameters params_divers rollout:roll_divers	(
		
		------ options --------------
-- 		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		qualite_courante				type:#integer 			default:1
		qualite_viewport				type:#integer 			ui:rdo_qualite_viewport				default:1
		qualite_render				type:#integer 			ui:rdo_qualite_render				default:1
		
		------ mat ID ----------
		matId_menuis				type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_huisserie				type:#integer 			ui:spn_matId_huisserie	default:3
		matId_mur						type:#integer 			ui:spn_matId_mur		default:4
		
		on qualite_viewport set val do qualite_courante = val
			
	)	-----	fin parametres --------------------
	
	parameters params_hasard rollout:roll_hasard	(
		hasard_seed					type:#integer 			ui:spn_hasard_seed		default:123456
		
		fen_proba_ouv				type:#float 			ui:spn_fen_proba_ouv		default:0.
		fen_ouvMax					type:#float 			ui:spn_fen_ouvMax			default:0.
	)
	
	parameters param_toiture  rollout:roll_toiture (		
		toiture_type				type:#integer 			ui:ddl_toiture_type		default:1
		toiture						type:#maxObject	
		
		on toiture_type set val do definir_toiture		toiture_type
	)
	
	
	
	
	
	
	
	----------------- Rollouts -------------------------------------------------------------------
	rollout roll_presets 			"Presets" 		rolledUp:true		(


		button btn_enregistrer "Enregistrer" 	pos:[88,2] width:85 height:16 align:#left
		button btn_charger 	"Charger" 		pos:[5,2] width:85 height:16 align:#left
		button btn_coller 		"Coller" 			pos:[88,17] width:85 height:16 align:#left
		button btn_copier 		"Copier" 			pos:[5,17] width:85 height:16 align:#left
		
		
		fn actualiser =(
			btn_coller.enabled 			= urba_clipboard_batiment != ""
		)

		
		
		
		on roll_presets open do actualiser ()
		on btn_copier pressed do	(
				preset_copier ()
				actualiser()
			)
		on btn_coller pressed do	(
				preset_coller ()
				actualiser()
			)
		on btn_enregistrer pressed do
			preset_enregistrer ()
		on btn_charger pressed do
			preset_charger ()
		
	) 	---- fin rollout Presets ---------------------------
	
	rollout roll_affichage "Affichage" width:180 height:57
	(
		
		groupBox 'grp1' "Viewport" pos:[4,7] width:169 height:46 align:#left
		checkbutton 'ckb_afficher_longueur' "Long" pos:[12,26] width:38 height:21 across:4 align:#left
		checkbutton 'ckb_autre_1' "" pos:[49,26] width:38 height:21 align:#left
		checkbutton 'ckb_autre_2' "" pos:[86,26] width:38 height:21 align:#left
		checkbutton 'ckb_autre_3' "" pos:[122,26] width:38 height:21 align:#left
		
		on ckb_afficher_longueur changed state do
			afficher_longueurs state
	)
	
	
	
	
	
	
	rollout roll_general "Général" width:180 height:296
	(
		
		
		----------- spline ---------------------------------------
		fn shape_filt 		obj = superclassof obj == shape
		
		GroupBox 'grp_tracé' "Tracé" pos:[3,4] width:169 height:60 align:#left
		pickbutton 'btn_pick_perimetre' "Sélectionner le tracé" pos:[13,21] width:150 height:20 filter:shape_filt autoDisplay:true align:#left
		checkbox 'chk_optimisation' "Optimiser" pos:[13,44] width:87 height:15 across:2 align:#left
		
		
		
		------------------- etages ----------------------------------------
		GroupBox 'grp_etages' "Etages" pos:[3,77] width:169 height:60 align:#left
		spinner 'spn_etages_nbres' "" pos:[89,96] width:75 height:16 range:[0,1000,1] type:#integer align:#left
		spinner 'spn_etages_hauteur' "" pos:[89,111] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		label 'lbl_nombre' "Nombre:" pos:[19,96] width:67 height:14 align:#left		
		label 'lbl_hauteur' "Hauteur:" pos:[19,111] width:67 height:14 align:#left
		
		
		
		
		
		---- etages spe -----------------
		GroupBox 'grp_etagesSpecifique' "Etages spécifiques" pos:[3,149] width:169 height:139 align:#left	
		button 'btn_etages_nouveau' "Nouveau" pos:[19,171] width:70 height:16 toolTip:"Ajouter	étages spécifiques" across:2 align:#left
		button 'btn_etages_supprimer' "Supprimer" pos:[92,171] width:70 height:16 toolTip:"Supprimer étages spécifiques" align:#left
		listbox 'lbx_etages_specifiques' "" pos:[19,190] width:146 height:4 align:#left
		label 'lbl_etage_specifiques' "Etages :" pos:[19,249] width:45 height:19 across:4 align:#left 
		spinner 'spn_etageMin_specifiques' "" pos:[89,249] width:35 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left 
		label 'lbl_etageMax_specifiques' ">" pos:[124,249] width:7 height:16 align:#left 
		spinner 'spn_etageMax_specifiques' "" pos:[129,249] width:35 height:16 range:[0,1e+13,0] type:#integer align:#left
		label 'lbl_hauteur_specifiques' "Hauteur :" pos:[19,264] width:55 height:18 across:2 align:#left
		spinner 'spn_hauteur_specifiques' "" pos:[89,264] width:75 height:16 range:[0,1e+13,0] type:#worldunits align:#left
		
		
		
		
		
		
		
		
		
		fn actualiser =(
			
			--- la liste box ------
			local liste_etages =#()
			for i = 1 to  etages_spe_min.count do 
				append liste_etages ( etages_spe_min[i] as string + " > " + etages_spe_max[i] as string + " : " + etages_spe_hauteur[i] as string + "cm." )			
			lbx_etages_specifiques.items = liste_etages
			
			---- les valeurs --------
			if lbx_etages_specifiques.selection != 0 then (
				local selec = lbx_etages_specifiques.selection
				
				btn_etages_supprimer.enabled 			= true
				lbl_etage_specifiques.enabled 			= true
				lbl_etageMax_specifiques.enabled 		= true
				lbl_hauteur_specifiques.enabled 		= true
				
				spn_etageMin_specifiques.enabled 		= true
				spn_etageMax_specifiques.enabled 	= true
				spn_hauteur_specifiques.enabled 		= true
				
				spn_etageMin_specifiques.indeterminate 	= false
				spn_etageMax_specifiques.indeterminate 	= false
				spn_hauteur_specifiques.indeterminate 		= false
				
				spn_etageMin_specifiques.value 		= etages_spe_min[selec] 
				spn_etageMax_specifiques.value 	= etages_spe_max[selec] 
				spn_hauteur_specifiques.value 		= etages_spe_hauteur[selec] 
				
			) else (
				
				btn_etages_supprimer.enabled 		= false
				lbl_etage_specifiques.enabled 		= false
				lbl_etageMax_specifiques.enabled 	= false
				lbl_hauteur_specifiques.enabled 	= false
				
				spn_etageMin_specifiques.enabled 	= false
				spn_etageMax_specifiques.enabled = false
				spn_hauteur_specifiques.enabled 	= false
				
				spn_etageMin_specifiques.indeterminate 	= true
				spn_etageMax_specifiques.indeterminate 	= true
				spn_hauteur_specifiques.indeterminate 		= true
				
			)
			
		) ---- fin actualiser --------------------------------------
		
		
		
		
		on roll_general open do actualiser ()
		
		on chk_optimisation changed state do
			optimiser state
		
		on btn_etages_nouveau pressed do		(
				ajouter_etage_spe	()
				actualiser ()
			)
		on btn_etages_supprimer pressed do		(
			supprimer_etage_spe		lbx_etages_specifiques.selection
			actualiser ()
		)
		on lbx_etages_specifiques selected sel do
			actualiser ()
		on spn_etageMin_specifiques changed val do		(
			local selec = lbx_etages_specifiques.selection			
			etages_spe_min[selec] = val
			if etages_spe_max[selec] < val do
				etages_spe_max[selec] = val
			actualiser ()
		)
		on spn_etageMax_specifiques changed val do		(
			local selec = lbx_etages_specifiques.selection			
			etages_spe_max[selec] = val
			if etages_spe_min[selec] > val do
				etages_spe_min[selec] = val
			actualiser ()
		)
		on spn_hauteur_specifiques changed val do		(
			local selec = lbx_etages_specifiques.selection			
			etages_spe_hauteur[selec] = val
			actualiser ()
			redrawViews ()
		)
		
	) ---- fin rollout --------------------------------
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	rollout roll_facades "Facades" width:202 height:890
	(
		
		----- les facades ---------------------
		button 'btn_ajouter' "Nouv." pos:[3,5] width:45 height:16 across:4 align:#left
		button 'btn_retirer' "Supp." pos:[91,5] width:45 height:16 align:#left
		button 'btn_dupliquer' "Dupl." pos:[47,5] width:45 height:16 across:4 align:#left
		button 'btn_monter' "/\\" pos:[135,5] width:19 height:16 align:#left
		button 'btn_descendre' "\/" pos:[153,5] width:19 height:16 align:#left
		listbox 'lbx_facades' "" pos:[3,22] width:170 height:5 align:#left
		
		
		------ les propriété des facades ------------------------
		edittext 'edTxt_nom' "" pos:[-1,97] width:174 height:17 align:#left
		
		
		
		---- les contraintes --------------
		GroupBox 'grp_contraintes' "Contraintes" pos:[3,118] width:168 height:145 align:#left		
		
		
		label 'lbl_etages' "Etages:" pos:[13,134] width:55 height:16 align:#left
		label 'lbl_facades' "Façades:" pos:[13,221] width:78 height:14 align:#left
		spinner 'spn_etages_min' "" pos:[29,148] width:50 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
		label 'lbl9' ">" pos:[83,149] width:12 height:15 align:#left
		checkbutton 'chk_etages_min' "" pos:[14,148] width:16 height:16 toolTip:"Etage minimum." align:#left
		spinner 'spn_etages_max' "" pos:[108,148] width:50 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
		checkbutton 'chk_etages_max' "" pos:[93,148] width:16 height:16 toolTip:"Etage maximum." align:#left
		label 'lbl_longueur' "Longueurs:" pos:[13,163] width:55 height:16 align:#left
		spinner 'spn_longueur_min' "" pos:[29,177] width:50 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		label 'lbl29' ">" pos:[83,178] width:12 height:15 align:#left
		checkbutton 'chk_longueur_min' "" pos:[14,177] width:16 height:16 toolTip:"Longueur de façade minimum." align:#left
		spinner 'spn_longueur_max' "" pos:[108,177] width:50 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		checkbutton 'chk_longueur_max' "" pos:[93,177] width:16 height:16 toolTip:"Longueur de façade maximum." align:#left
		checkbutton 'ckb_mur_nord' "N." pos:[13,205] width:38 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Façades nord" across:4 align:#left
		checkbutton 'ckb_mur_sud' "S." pos:[50,205] width:38 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Façades sud" align:#left
		checkbutton 'ckb_mur_est' "E." pos:[87,205] width:38 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Façades est" align:#left
		checkbutton 'ckb_mur_ouest' "O." pos:[123,205] width:38 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Façades Ouest" align:#left		
		
		
		dropdownList 'ddl_murs' "" pos:[13,234] width:150 height:21 items:#("Tous", "Pignons", "Gouttereaux") toolTip:"Pignons ou gouttereaux" align:#left
		label 'lbl_orientation' "Orientation:" pos:[13,192] width:78 height:14 align:#left
		
		local bouttons = #(grp_contraintes, edTxt_nom, /* ddl_repartition,  */lbl_etages, lbl_facades, spn_etages_min, lbl9, chk_etages_min, spn_etages_max , chk_etages_max, lbl_longueur, spn_longueur_min, lbl29, chk_longueur_min, spn_longueur_max, chk_longueur_max, ckb_mur_nord, ckb_mur_sud, ckb_mur_est, ckb_mur_ouest, ddl_murs, lbl_orientation )
		
		
		
		
		------------ FONCTIONS -------------
		fn actualiser =(
			
			
			---- l'affichage des facades -------------------
			local elements_noms 	= #()
			for i = 1 to facades.count do (
				local elem_nom = facades[i].nom
				append elements_noms	( i as string + " |  " + elem_nom )
			)	
			lbx_facades.items 		=  for elem_nom in elements_noms collect elem_nom
			
			
			---- les boutons ------
			btn_retirer.enabled 				= lbx_facades.selection != 0
			btn_dupliquer.enabled 			= lbx_facades.selection != 0
			btn_monter.enabled 				= lbx_facades.selection > 1
			btn_descendre.enabled 			= lbx_facades.selection < facades.count and lbx_facades.selection != 0
			
			bouttons.enabled					= lbx_facades.selection != 0
			
			if lbx_facades.selection != 0 then (
				
				
				facade_courante = facades[ lbx_facades.selection ]
				
				edTxt_nom.text = facade_courante.nom
				
				
				if facade_courante.longueur_max_use do
					spn_longueur_max.value		= 		facade_courante.longueur_max				
				if facade_courante.longueur_min_use do
					spn_longueur_min.value		= 		facade_courante.longueur_min				
				if facade_courante.etages_max_use do
					spn_etages_max.value			= 		facade_courante.etages_max				
				if facade_courante.etages_min_use do
					spn_etages_min.value			= 		facade_courante.etages_min
				
				
				chk_longueur_max.state 		= 		facade_courante.longueur_max_use
				chk_longueur_min.state 		= 		facade_courante.longueur_min_use
				chk_etages_max.state 			= 		facade_courante.etages_max_use
				chk_etages_min.state 			= 		facade_courante.etages_min_use
				
				ckb_mur_nord.state 				= 		facade_courante.mur_nord
				ckb_mur_sud.state 				= 		facade_courante.mur_sud
				ckb_mur_est.state 				= 		facade_courante.mur_est
				ckb_mur_ouest.state 				= 		facade_courante.mur_ouest
				
				ddl_murs.selection					=		facade_courante.murs
				
				
				spn_longueur_max.enabled	= 		chk_longueur_max.state
				spn_longueur_min.enabled		= 		chk_longueur_min.state
				spn_etages_max.enabled		= 		chk_etages_max.state
				spn_etages_min.enabled		= 		chk_etages_min.state
				
				spn_longueur_max.Indeterminate	= 		not	chk_longueur_max.state
				spn_longueur_min.Indeterminate	= 		not	chk_longueur_min.state
				spn_etages_max.Indeterminate		= 		not	chk_etages_max.state
				spn_etages_min.Indeterminate		= 		not	chk_etages_min.state
				
				
				
			) else (
			
				facade_courante= undefined
			
				edTxt_nom.text = ""
-- 				ddl_repartition.selection 		=  0
				
				spn_longueur_max.Indeterminate	= 		true
				spn_longueur_min.Indeterminate	= 		true
				spn_etages_max.Indeterminate		= 		true
				spn_etages_min.Indeterminate		= 		true
			)
			
			
-- 			debug"lbx_facades.selection" var:lbx_facades.selection
			
			
			---- le rollout de la sequence ---------------		
-- 			if  lbx_facades.selection == 0 then facade_courante= undefined
-- 				else	facade_courante	= facades[ lbx_facades.selection ]
-- 			roll_sequence.actualiser ()
			
		) --- fin actualiser -----------
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		on roll_facades open do
			actualiser ()
		on btn_ajouter pressed do
			ajouter_facade ()
		on btn_retirer pressed do
			retirer_facade			lbx_facades.selection
		on btn_dupliquer pressed do
			dupliquer_facade		lbx_facades.selection
		on btn_monter pressed do
			monter_facade		lbx_facades.selection
		on btn_descendre pressed do
			descendre_facade	lbx_facades.selection
		on lbx_facades selected sel 	do
			actualiser ()
		on lbx_facades doubleClicked _id 	do
			actualiser ()
		on lbx_facades rightClick _id 	do
		(
					lbx_facades.selection = _id
					actualiser ()
				)
		on edTxt_nom changed txt 			do
			renommer_facade		lbx_facades.selection 	txt
		on spn_etages_min changed val 		do
		(
					facade_courante.etages_min = val
					actualiser ()
				)
		on chk_etages_min changed state 		do
		(
					facade_courante.etages_min_use = state
					actualiser ()
				)
		on spn_etages_max changed val 	do
		(
					facade_courante.etages_max = val
					actualiser ()
				)
		on chk_etages_max changed state 	do
		(
					facade_courante.etages_max_use = state
					actualiser ()
				)
		on spn_longueur_min changed val 	do
		(
					facade_courante.longueur_min = val
					actualiser ()
				)
		on chk_longueur_min changed state 	do
		(
					facade_courante.longueur_min_use = state
					actualiser ()
				)
		on spn_longueur_max changed val 	do
		(
					facade_courante.longueur_max = val
					actualiser ()
				)
		on chk_longueur_max changed state 	do
		(
					facade_courante.longueur_max_use = state
					actualiser ()
				)
		on ckb_mur_nord changed state 	do
		(
					facade_courante.mur_nord = state
					actualiser ()
				)
		on ckb_mur_sud changed state 	do
		(
					facade_courante.mur_sud = state
					actualiser ()
				)
		on ckb_mur_est changed state 	do
		(
					facade_courante.mur_est = state
					actualiser ()
				)
		on ckb_mur_ouest changed state 		do
		(
					facade_courante.mur_ouest = state
					actualiser ()
				)
		on ddl_murs selected val 		do
		(
					facade_courante.murs = val
					actualiser ()
				)
	)
	
	
	
	
	
	
	
	
	
	rollout roll_sequence "Séquence de la façade" width:180 height:806
	(
		
		
		
		
		dropdownList 'ddl_repartition' "" pos:[3,1] width:170 height:21 items:#("Répartir", "Centrer", "Aligner à gauche", "Aligner à droite", "Espacer") align:#left toolTip:"Type de répartition du motif de la séquence."

		----- les elements de facades ------
		dotNetControl 'tv_elementsFacade' "treeview" pos:[3,39] width:168 height:90 align:#left
		label 'lbl_elements' "Eléments :" pos:[7,24] width:78 height:14 align:#left
		dotNetControl 'tv_motif' "treeview" pos:[4,151] width:168 height:143 align:#left
		checkbutton 'ckb_dupliquer' "Dup." pos:[3,295] width:42 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Dupliquer" across:4 align:#left
		checkbutton 'ckb_instancier' "Inst." pos:[45,295] width:42 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Instancier" align:#left
		checkbutton 'ckb_rendreUnique' "Uni." pos:[86,295] width:42 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Renddre Unique" align:#left
		checkbutton 'ckb_supprimer' "Sup." pos:[127,295] width:42 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Supprimer" align:#left
		label 'lbl_motif' "Motif de la séquence :" pos:[7,136] width:153 height:14 align:#left
		
		
		---- propriete element ------------
		subRollout 'subRoll_param' "" pos:[3,317] width:168 height:160 align:#left
		dotNetControl 'btn_resize' "System.Windows.Forms.Button" pos:[3,480] width:168 height:10 align:#left
		
		
		
		local boutons = #( /* tv_elementsFacade, */ lbl_elements, tv_motif, ckb_dupliquer, ckb_instancier, ckb_rendreUnique, ckb_supprimer, lbl_motif, subRoll_param, btn_resize )
		
		
		
		
		
		
		
		---------- Treeview -----------------------------------------------------------------------------
		fn vider_TVs = (
			tv_elementsFacade.Nodes.Clear()
			tv_motif.Nodes.Clear()
		)
		------- treeview -------------------------
		fn ajouter_TV_element	_item_aAjouter	_itemParent	_tag:"" 	_ForeColor:((dotNetClass "System.Drawing.Color").fromARGB 	255	255	255)		=(
			
			local nv_node 			=	_itemParent.Nodes.add 		_item_aAjouter
			nv_node.ForeColor 	= _ForeColor
			nv_node.tag 				= _tag
		
			nv_node
		)
		
		
		fn initialiser_tv = (
			
			
-- 			show tv_elementsFacade
			
			
			---- elements ----
			tv_elementsFacade.borderstyle 			= (dotnetclass "System.Windows.Forms.BorderStyle").None
			tv_elementsFacade.LabelEdit 				= false 
			tv_elementsFacade.allowdrop 			= false
			tv_elementsFacade.HideSelection 		= false
-- 			tv_elementsFacade.ShowRootLines	 	= true
			tv_elementsFacade.ShowLines   			= true
-- 			tv_elementsFacade.HotTracking   		= true
			tv_elementsFacade.BackColor 			= (dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
			tv_elementsFacade.ForeColor 				= (dotNetClass "System.Drawing.Color").fromARGB 	255	255	255
			tv_elementsFacade.LineColor 				= (dotNetClass "System.Drawing.Color").fromARGB 	255	255	255
			tv_elementsFacade.DrawMode 			= (dotnetclass "TreeViewDrawMode.OwnerDrawText")
			
			tv_elementsFacade.indent					= 24
			
			
			---- sequence motif ----
			tv_motif.borderstyle 			= (dotnetclass "System.Windows.Forms.BorderStyle").None
			tv_motif.LabelEdit 				= false 
			tv_motif.allowdrop 			= true
			tv_motif.HideSelection 		= false
-- 			tv_motif.ShowRootLines	 	= true
			tv_motif.ShowLines   			= true
-- 			tv_motif.HotTracking   		= true
			tv_motif.BackColor 			= (dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
			tv_motif.ForeColor 			= (dotNetClass "System.Drawing.Color").fromARGB 	255	255	255
			tv_motif.LineColor 				= (dotNetClass "System.Drawing.Color").fromARGB 	255	255	255
			tv_motif.DrawMode 			= (dotnetclass "TreeViewDrawMode.OwnerDrawText")
			
			tv_motif.indent					= 24
			
			---- le bouton resize -----------------------
			btn_resize.FlatStyle	=		(dotNetClass "System.Windows.Forms.FlatStyle").flat	
			btn_resize.BackColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
			btn_resize.ForeColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
		)
		
		----- UI	divers ----------------------------------------------------------------------------------------------------
		
		------ recuperre le nom du plugin de chaque fichier --------------------------
		fn get_plugin_nom 	_fichier	= (
			local fichier_stream		=	openFile 	_fichier 	mode:"r"
			local plugin_nom
			local on_a_trouve = false
			while not on_a_trouve	or eof  fichier_stream		do (
				local ligne 	= readLine  fichier_stream
				local mots 	=  filterString ligne		" 	:\""
				if mots[1] == "name" do (
					plugin_nom =  /* toLower  */mots[2]
					on_a_trouve = true
				)
			)
			close fichier_stream	
			plugin_nom
		) --- fin get_plugin_nom ----------
		
		
		fn get_plugin 	_fichier	= (
			local fichier_stream		=	openFile 	_fichier 	mode:"r"
			local plugin_nom
			local on_a_trouve = false
			while not on_a_trouve	or eof  fichier_stream		do (
				local ligne 	= readLine  fichier_stream
				local mots 	=  filterString ligne		" 	"
				if mots[1] == "plugin" do (
					plugin_nom = /*  toLower  */  mots[3]
					on_a_trouve = true
				)
			)
			close fichier_stream	
			plugin_nom
		) --- fin get_plugin_nom ----------
		
		
		
		
		fn actualiser_TV 	=(
			
			vider_TVs ()
			
			-------------------- ELEMENTS ------------------------------------------
			
-- 			if roll_facades.lbx_facades.selection != 0 do (
				
				----- les dossiers -----------------------------------------
				local chemins_elements = getDirectories 	"$userScripts\\cp-Urba\\modules\\Batiment\\Facade\\ElementsDeFacade\\*"
				local dossier_elements = #()
				for chemin in chemins_elements do (				
					local tab_chemin = filterString chemin "\\"
					
					--- le dossier -----
					nd_dossier = ajouter_TV_element	tab_chemin[tab_chemin.count]		tv_elementsFacade  \
																							_ForeColor:((dotNetClass "System.Drawing.Color").fromARGB 	200	200	200)
					
					--- les plugins -----
					local fichiers = getFiles ( chemin + "*.ms" )
					for fichier in fichiers do 
						ajouter_TV_element	( get_plugin_nom 	fichier )		nd_dossier	_tag:( get_plugin 	fichier )	
					
				)
-- 			)
			
		) --- fin actualiser -----------
		
		fn actualiser =(
			debug "facade_courante" var:facade_courante
-- 			if facade_courante != undefined do 
			roll_sequence.boutons.enabled		= 		facade_courante != undefined 	--lbx_facades.selection != 0
			
			if facade_courante != undefined 	then (
				ddl_repartition.enabled = true
				ddl_repartition.selection 		= facade_courante.repartition 
			)else (
				ddl_repartition.enabled = false
				ddl_repartition.selection 		= 0
			)
		)
		
		
		
		
		----- Gestion du resize du subRollout -----------------------
		local resize_enCours 			= false
		local pos_initial					=	[0,0]
		local subRoll_hauteur_init		=	0
		local btnResize_pos_init		=	[0,0]
		local roll_hauteur_init			=	[0,0]
		fn resize_init	=(
			resize_enCours 				= true
			pos_initial						=	mouse.pos
			subRoll_hauteur_init		= 	subroll_param.height
			btnResize_pos_init			=	btn_resize.pos
			roll_hauteur_init			=	roll_sequence.height
		)
		fn resizer =(
			if resize_enCours do (
				local changement_ht 	= 		mouse.pos.y - pos_initial.y
				local subRoll_nvl_ht 		=    	subRoll_hauteur_init		+ 	changement_ht
				
				
-- 					roll_sequence.height		=	roll_hauteur_init 	+ 	changement_ht
				debug""
				debug""
				debug""
				debug "changement_ht" var:changement_ht
				debug "btnResize_pos_init" var:btnResize_pos_init
				debug "subRoll_hauteur_init" var:subRoll_hauteur_init
				debug "roll_hauteur_init" var:roll_hauteur_init
				
				
				if subRoll_nvl_ht >	50 do (
					
-- 				if changement_ht > 0 do subRoll_nvl_ht	+=	corrig_ht
-- 				if changement_ht < 0 do subRoll_nvl_ht	-=	corrig_ht
					
					
					subroll_param.height		=	subRoll_nvl_ht
					btn_resize.pos.y			=	btnResize_pos_init.y		+	changement_ht
					roll_sequence.height		=	roll_hauteur_init 	+ 	changement_ht
						
					local corrig_ht = 12
					if changement_ht > 0 do roll_sequence.height	+=	corrig_ht/2
					if changement_ht < 0 do roll_sequence.height	-=	corrig_ht
						
-- 					roll_sequence.height		=	btn_resize.pos.y 	+ 	150
-- 					roll_sequence.height		=	roll_hauteur_init 	+ 	subRoll_nvl_ht
				)
				
				
				debug""
				debug "btn_resize.pos.y" var:btn_resize.pos.y
				debug "roll_sequence.height	" var:roll_sequence.height	
				
				
			)
		)
		------------ le bouton resize -----------------------
		on btn_resize mouseDown 		do 	resize_init		()
		on btn_resize mouseMove 		do	resizer ()
		on btn_resize mouseUp 			do	resize_enCours = false
		on btn_resize MouseLeave 		do	resize_enCours = false
		
		
		
		
		
		
		
		on roll_sequence open do
		(
			initialiser_tv ()
			actualiser_TV ()
			actualiser ()
		)
		
		
		on ddl_repartition 	selected	 val 		do (
			facade_courante.repartition = val
			actualiser ()
		)
	)
	
	
	
	
	
	rollout roll_toiture "Toiture" width:180 height:203
	(
		
		
		dropdownList 'ddl_toiture_type' "" pos:[5,3] width:165 height:21 items:#("Sans", "Terrasse", "1 pan", "2 pans", "n pans") align:#left
		subRollout 'subRoll_param' "" pos:[5,25] width:165 height:1 align:#left
		
-- 		dotNetControl 'btn_resize' "System.Windows.Forms.Button" pos:[5,188] width:165 height:10 align:#left
		
		fn actualiser = (
			
			--- les parametres de l'element (le subrollout)  ---------------			
			--- on retire les vieux rollouts --------
			if subroll_param.rollouts.count > 0 do 
				for subRoll in subroll_param.rollouts  do
					removeSubRollout subroll_param	subRoll
				
			---- on ajoute le nouveau -----------------
			if ddl_toiture_type.selection > 1 then (
				addSubRollout 	subroll_param		toiture.roll_general
				
				subroll_param.height		=	toiture.roll_general.height -  14
				roll_toiture.height			=	subroll_param.height + ddl_toiture_type.height + 7
			) else (
				subroll_param.height		= 0
				roll_toiture.height			=	 36
				
			)
		)
		/* 
		----- Gestion du resize du subRollout -----------------------
		local resize_enCours 			= false
		local pos_initial					=	[0,0]
		local subRoll_hauteur_init		=	0
		local btnResize_pos_init		=	[0,0]
		local roll_hauteur_init			=	[0,0]
		fn resize_init	=(
					resize_enCours 				= true
					pos_initial						=	mouse.pos
					subRoll_hauteur_init		= 	subroll_param.height
					btnResize_pos_init			=	btn_resize.pos
					roll_hauteur_init			=	roll_toiture.height
-- 					debug "pos_initial"	var:pos_initial
				)
		fn resizer =(
			if resize_enCours do (
				local changement_ht 	= mouse.pos.y - pos_initial.y
				local subRoll_nvl_ht 		= subRoll_hauteur_init 		+ 	changement_ht
				
				if subRoll_nvl_ht >	50 do (
					
					subroll_param.height		=	subRoll_nvl_ht
					btn_resize.pos.y			=	btnResize_pos_init.y		+	changement_ht
					roll_toiture.height			=	roll_hauteur_init 			+ 	changement_ht
				)
			)
		)
		------------ le bouton resize -----------------------
		on btn_resize mouseDown 		do 	resize_init		()
		on btn_resize mouseMove 		do	resizer ()
		on btn_resize mouseUp 			do	resize_enCours = false
		on btn_resize MouseLeave 		do	resize_enCours = false
		 */
		
		
		
		
		
		on roll_toiture open do
		(
					actualiser ()
					/* 
					---- le bouton resize -----------------------
					btn_resize.FlatStyle	=		(dotNetClass "System.Windows.Forms.FlatStyle").flat	
					btn_resize.BackColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
					btn_resize.ForeColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
			 */
				)
		on ddl_toiture_type selected val		do
			actualiser()
		
	)
	
	
	
	
	
	rollout roll_divers  "Divers"	(
		
		 group "Qualité" (
			label lbl_viewport 	"Viewport"  align:#left	 across:2
			label lbl_render 		"Render"   align:#left
			radioButtons rdo_qualite_viewport	""  labels:#("Full", "Medium","Low poly", "Volume") align:#left 	across:2
			radioButtons rdo_qualite_render 		"" labels:#("Full", "Medium", "Low poly", "Volume") align:#left
		) 
		group "Material ID" (
			spinner spn_matId_menuis 		"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 		"Vitrage" 				type:#integer range:[1,1000,1]
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
	
	
	
	--- rollout a propos -------------------------
	include	 "$userScripts\\cp-Urba\\modules\\Commun\\cp - Urba - rollout - A propos.ms" 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	------------------ FONCTIONS -----------------------------------------------------------------------------------------------------
	
	-------------- Initialisation -------------------------
	fn initialiser =(
		mgr_shp 				= str_mgr_shape ()
		mgr_mesh 			= str_mgr_mesh ()
)
	
	
	------------- actualiser --------------------------
	fn actualiser_shape =(
		if surface_node != undefined then (
			
			---- on place le batiment sur le shape ----------
			local this_node 		= (refs.dependents this)[1]
			
			this_node.transform	=	surface_node.transform
			
			----- on scanne le shape ---------
			pts_surface = mgr_shp.scanner_points	surface_node
			
			
			--- on gere les OPTIMISATIONS  ----
			if optim_souder			do	mgr_shp.souder				&pts_surface		optim_souder_seuil
			if optim_orthonormer	do	mgr_shp.orthonormer		&pts_surface		optim_ortho_seuil
			if optim_aplanir			do	mgr_shp.aplanir				&pts_surface		optim_aplanir_seuil
			if optim_aligner			do	mgr_shp.aligner				&pts_surface		optim_aligner_seuil
			if optim_projeter			do	mgr_shp.projeter				&pts_surface
			
			
			
		) else (
			pts_surface =#()
		)
	)
	fn actualiser =(
-- 		corriger_parametres ()		
-- 		actualiser_composants()		
		if roll_facades.open do	roll_facades.actualiser ()		
		redrawViews ()
	)
	
	
	fn optimiser 	_state =(
		optim_aplanir			= _state
		optim_souder			= _state
		optim_orthonormer	= _state
		optim_aligner			= _state
		optim_projeter			= _state
	)
	
	
	--------- viewport --------------------------------------------------------------------------	
	fn fn_afficheur_longueurs =(
		
		gw.setTransform (matrix3 1)
		
		if selection.count == 1 and classof $ == cp_batimentSimple do (
			local nd	 = $
			
-- 			local bat 				= nd.core.get_bat_edition ()
-- 			
-- 			if bat != undefined do (
-- 			local fcd				= nd.core.get_facade_enEdition 	()
			
			local surface_pts 	= 	nd.pts_surface
			
				
			local ptID = 0 
			while ptID <  surface_pts.count do (
				ptID += 1
				
				local ptID_suivant = ptID + 1
				if ptID_suivant > surface_pts.count do ptID_suivant = 1
					
				local vec_sousBassmt		=	[0,0,1] * nd.soubassement_hauteur
				local vec_dalle				=	[0,0,1] * nd.dalle_epaisseur
				local vec_decallage			=	[0,0,1] * 50

				local pt 						= surface_pts[ptID] 	*  nd.transform 
				local pt_suivant 			= surface_pts[ptID_suivant] *  nd.transform  
				local longueur_facade 	= ( (floor ( ( distance pt pt_suivant ) * 10 ) ) / 10 )
				local txt_affichage 		= "  " + longueur_facade as string + " cm"
				
				local col_valid 			= yellow
				local col_nonValid 	= [ 100, 100 , 100 ]
				local col_divers 		= white
				
				---- les longueurs------
				local color_affichage 	 = col_divers
				local longueur_valid 	= true
				if fcd != undefined do			(
					
					local lg_min_fcd = amax #(  fcd.params.longueurMin , fcd.params.get_longueur () )
					
					if longueur_facade < lg_min_fcd do
						longueur_valid = false
					
					if fcd.params.longueurMax_use and longueur_facade >  fcd.params.longueurMax do
						longueur_valid = false
				)
				if longueur_valid then (
					color_affichage 	 = col_valid
					gw.setColor	#line		col_valid
				) else (
					color_affichage 	 = col_nonValid
					gw.setColor	#line		col_nonValid
				)
				
				
				local vec_affichage_lgs = 	vec_sousBassmt 	+ vec_dalle + vec_decallage
				local pt_milieu_facade 	= ( (pt + pt_suivant) /2 )  - vec_affichage_lgs
				gw.polyline #( pt - vec_affichage_lgs , pt_suivant - vec_affichage_lgs )	false
-- 						gw.Marker 	( pt - vec_affichage_lgs  )		#xMarker   color:color_affichage
				gw.Marker pt_milieu_facade		#smallCircle   color:color_affichage
				gw.text 	( pt_milieu_facade	 /* - [0,0,100] */ )	txt_affichage  	color:color_affichage
				
			
			)
		
		)
		gw.updateScreen() 
	)
	fn afficher_longueurs 	state	=(
		
-- 		if urba_fn_afficheur_longueurs  == undefined do 	
		
		unregisterRedrawViewsCallback 					urba_fn_afficheur_longueurs
		
			urba_fn_afficheur_longueurs	= fn_afficheur_longueurs
		
		case state of (
			true:		registerRedrawViewsCallback 			urba_fn_afficheur_longueurs 	
			false:		unregisterRedrawViewsCallback 		urba_fn_afficheur_longueurs
		)
		
-- 		redrawviews ()
		forceCompleteRedraw ()
		
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	---------------- les presets-------------------------------------
	fn preset_copier = (
		mgr_presets.copier	this
	)
	fn preset_coller = (
		mgr_presets.coller	this		
	)
	fn preset_enregistrer = (
		mgr_presets.enregistrer this
	)
	fn preset_charger = (
		mgr_presets.charger	this
	)
	
	
	
	
	
	
	--------------- etages ----------------------------------	
	fn	ajouter_etage_spe	=(
		
		append	etages_spe_min			0
		append	etages_spe_max			0
		append	etages_spe_hauteur		250.
		
		actualiser()
	)
	fn supprimer_etage_spe 	_id =(
		deleteItem etages_spe_min		_id
		deleteItem etages_spe_max		_id
		deleteItem etages_spe_hauteur	_id
		
		actualiser()
	)
	
	
	
	
	--------------- facades ----------------------------------
	/* 
	fn basculer_editeurFacade 	_etat			=(
		
		
		----- rollout editeur ---------------------
		rollout roll_editeur_facade "Editeur de façade"	 height:700	 width:410	--	width:480	--	width:500
		(
			
			local facade_cible
			local batiment_parent
			
			editText 	edTxt_nom		 	"" 	pos:[10,7] width:190		
			
			subRollout 'subroll_1' "" pos:[10,27] width:190		height:280 align:#left	
			subRollout 'subroll_2' "" pos:[210,7] width:190		height:300 align:#left
			subRollout 'subroll_3' "" pos:[410,7] width:190		height:300 align:#left
			subRollout 'subroll_4' "" pos:[610,7] width:190		height:300 align:#left
			
			fn resize_rollout	=(
				
				subroll_1.height	=	roll_editeur_facade.height - 20
				subroll_2.height	=	roll_editeur_facade.height - 20
				subroll_3.height	=	roll_editeur_facade.height - 20
				subroll_4.height	=	roll_editeur_facade.height - 20
				
				if subroll_2.rollouts.count == 0 then
					roll_editeur_facade.width = 210
				else if subroll_3.rollouts.count == 0 then
					roll_editeur_facade.width = 410
				else 	if subroll_4.rollouts.count == 0 then
					roll_editeur_facade.width = 610
				else
					roll_editeur_facade.width = 810
				
			)
			
			fn actualiser 	facade:		=(
				
				for subRoll in subroll_1.rollouts  do	removeSubRollout subroll_1	subRoll
				for subRoll in subroll_2.rollouts  do	removeSubRollout subroll_2	subRoll
				for subRoll in subroll_3.rollouts  do	removeSubRollout subroll_3	subRoll
				
				facade.roll_editeur_facade	=	roll_editeur_facade				
				facade_cible			=	facade
				
				edTxt_nom.text		=	facade.nom
				
				addSubRollout 	subroll_1		facade.roll_contraintes
				addSubRollout 	subroll_1		facade.roll_repartition
				addSubRollout 	subroll_1		facade.roll_sequence
				
			)
			
			on roll_editeur_facade open do
				resize_rollout  ()
			on roll_editeur_facade close do (
				facade_cible.roll_editeur_facade = undefined
				batiment_parent.editeur_facade_ouvert = false
			)
			
			on roll_editeur_facade resized val do
				resize_rollout  ()
			on edTxt_nom changed val do (
				facade_cible.nom = val
				batiment_parent.actualiser() 
			)
			
		)
		
		
		
		
		
		
		
		
		case _etat of (
			true: (
				
				createDialog		roll_editeur_facade			style:#( #style_titlebar , #style_border , #style_sysmenu, #style_resizing) 	lockWidth:true
				roll_editeur_facade.batiment_parent	=	this
				
				local	id_facade_select 	= 	roll_facades.lbx_facades.selection				
				roll_editeur_facade.actualiser 	facade:facades[ id_facade_select ]
				
			)
			false: destroyDialog  roll_editeur_facade
		)
		
	)
	 */
	
	fn ajouter_facade					 			=(
		
		local	id_elem_select 	= 	roll_facades.lbx_facades.selection
		local	id_elem_insert		= 	id_elem_select + 1
		
		local nvl_facade			= createinstance		cp_batimentElem_facade
		
		if id_elem_select != 0 and id_elem_select	!= facades.count	then	
			insertItem nvl_facade					facades 					id_elem_insert
		else		
			append facades						nvl_facade
		
		---- actualisations -----------
		actualiser ()
		
		if roll_facades.open do	(
			roll_facades.lbx_facades.selection = id_elem_insert 
			roll_facades.actualiser ()	
		)
		
	)
	fn retirer_facade			_id	 				=(
		
		deleteItem facades 				_id
		
		---- actualisations -----------
		actualiser ()
		
		if roll_facades.open do	(
			roll_facades.lbx_facades.selection -= 1 
			roll_facades.actualiser ()	
		)
		
	)
	fn dupliquer_facade					_id	 				=(
		
		local nvl_facade			=  copy facades[_id]
		
		if _id	!= facades.count	then	
			insertItem nvl_facade					facades 					(_id + 1 )
		else		
			append facades						nvl_facade

		nvl_facade.nom += " - copie"
		---- actualisations -----------
		actualiser ()
		
		if roll_facades.open do	(
			roll_facades.lbx_facades.selection += 1 
			roll_facades.actualiser ()	
		)
		
	)
	fn monter_facade		_id 					=(
		
		local elem_temp 		= facades[ _id ]
		deleteItem 	facades 				_id
		insertItem 	elem_temp			facades  					(	_id - 1 )
		
		---- actualisations -----------
		actualiser ()
		
		if roll_facades.open do	(
			roll_facades.lbx_facades.selection -=  1
			roll_facades.actualiser ()	
		)
	)
	fn	descendre_facade	_id 					=(
		
		local elem_temp 		= facades[ _id ]
		deleteItem 	facades 				_id
		if _id == facades.count then 
			append facades 				elem_temp
		else 
			insertItem 	elem_temp		facades  					(	_id + 1 )
		
		---- actualisations -----------
		actualiser ()
		
		if roll_facades.open do	(
			roll_facades.lbx_facades.selection +=  1
			roll_facades.actualiser ()	
		)
	)
	fn renommer_facade 	_id 	_nv_nom	=(
		facades[ _id ].nom = _nv_nom
		---- actualisations -----------
		actualiser ()
	)
	
	
	----- gestion des facades ----------------------------------------------------
	fn get_facades_pourMur		_id_pt	 		=(
		
		local result		= #()
		
		local etages_aRemplir	= #{1..etages_nbre + 1}
		
		local pt 			= pts_surface[ _id_pt ]
		local pt_suivant 	= if _id_pt != pts_surface.count then pts_surface[ _id_pt + 1 ] else pts_surface[ 1 ]
		/* 
		--- si rendu en volume --------------------------
		if qualite_courante == 4 then (
			
			
			
			
		---- si pas en volume, alors Pour chaque etages------------------
		) else (
			 */
			---- on calcul la hauteur de la facade ----------
			local hauteur_facade_total = 0
		
		
		
			for etage_courant = 0 to etages_nbre do (
				local facade_trouve 			= false
				local facade_pasDeResultat	=	facades.count == 0
				local id_facade = 1
				
				
				---- la hauteur des étages, normal ou specifique -----------------
				local on_est_sur_etage_spe	=	false
				local hauteur_etage 			=	etages_hauteur_global
				for i = 1 to  etages_spe_min.count do (
					local etageSpe_min 		= etages_spe_min[i]
					local etageSpe_max 		= etages_spe_max[i]
					local etageSpe_ht 		= etages_spe_hauteur[i]
					if not on_est_sur_etage_spe and etageSpe_min <= etage_courant and etageSpe_max >= etage_courant	do (
						on_est_sur_etage_spe = true
						hauteur_etage	=	etageSpe_ht
					)
				)
				
	-- 			local qualite = qualite_viewport
				
		--- si PAS rendu en volume --------------------------
		if qualite_courante != 4 then (
				while not facade_trouve	and not facade_pasDeResultat  do (
					
					local facade_aTester = copy facades[ id_facade ]
					
					if facade_aTester.est_facadeValide		pt		pt_suivant		etage_courant 		etages_nbre		then (
					
						facade_aTester.longueur				=	distance	pt	pt_suivant
						facade_aTester.hauteur				=	hauteur_etage
						facade_aTester.qualite				=	qualite_courante
						facade_aTester.fen_ouvMax		=	fen_ouvMax
						facade_aTester.fen_proba_ouv	=	fen_proba_ouv
						
						facade_aTester.matId_menuis	=	matId_menuis
						facade_aTester.matId_vitrage		=	matId_vitrage
						facade_aTester.matId_huisserie	=	matId_huisserie
						facade_aTester.matId_mur			=	matId_mur
						
						
						append 	result		facade_aTester
						facade_trouve = true
						
					)
					
					id_facade +=1
					if id_facade > facades.count and not facade_trouve  do
						facade_pasDeResultat = true
					
				)
				
				if facade_pasDeResultat do (
					
					local compo_planV		=	createInstance	cp_prim_planVertical
					compo_planV.longueur	=	distance	pt	pt_suivant
					compo_planV.hauteur	=	hauteur_etage
					compo_planV.matId		=	matId_mur
					
					append 	result		compo_planV
					
				)
			)else (
				hauteur_facade_total	+=	hauteur_etage + dalle_epaisseur
			)
				
				
			) ---- fin for etages ------------
			
		if qualite_courante == 4 do (
			
			
					local compo_planV		=	createInstance	cp_prim_planVertical
					compo_planV.longueur	=	distance	pt	pt_suivant
					compo_planV.hauteur	=	hauteur_facade_total
					compo_planV.matId		=	matId_mur
					
					append 	result		compo_planV
		)
			
-- 		)
		result
		
	) ---- fin choisir facade ------------
	
	
	
	
	
	--------- toiture ----------------------------------
	fn definir_toiture		_id_type 	=(
-- 		debug "definir_toiture" var:_id_type
		case _id_type of (
			1:		toiture 		= createInstance		cp_batimentElem_toiture_sans
			5:		toiture 		= createInstance		cp_batimentElem_toiture_nPans
			default:		toiture		=	undefined
		)
-- 		debug "toiture" var:toiture
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	------------  Construction du mesh --------------------------
	on buildMesh do	(
		
-- 		debug "buildMesh"
		
		
		local chrono_debut = timestamp ()
		
		seed	hasard_seed
		
		--- on vide le mesh ----------
		delete mesh
		
		---- si on a une surface ----------------------
		if surface_node != undefined do (
			
			actualiser_shape ()		
			
			
			
			
			
			
			---le repere de hauteur --------
			local hauteur_courante = 0
			
			----- 1 ) les Facades ----------------------------------------------------------------------------------------------------------------------
			---- Pour chaque segment de la surface ----------------------------
			for i = 1 to pts_surface.count do (
				
				local pt 			= pts_surface[i]
				local pt_suivant 	= if i != pts_surface.count then pts_surface[i + 1] else pts_surface[1]
				
				local angle_facade 		=	mgr_shp.get_angle_oriente 	(pt_suivant - pt )
				local transf_facade 		= rotateZmatrix	angle_facade	*	transMatrix pt
				
				
				---- le soubassement --------
				local compo_planV		=	createInstance	cp_prim_planVertical
				compo_planV.longueur	=	distance	pt	pt_suivant
				compo_planV.hauteur	=	soubassement_hauteur				
				compo_planV.matId		=	matId_mur
				mgr_mesh.attacher		mesh		compo_planV	transf:( transf_facade * transMatrix [0,0, -(soubassement_hauteur + dalle_epaisseur ) ] )
				
				
				
				if qualite_courante == 4 then (
					
					local depose_etage 				= 	transf_facade* transMatrix [0,0, -dalle_epaisseur  ]
					local facades_murCourant		=	get_facades_pourMur	i	
					
					---- la facade ----
					local fcd 				= facades_murCourant[1]
					mgr_mesh.attacher		mesh		fcd	transf:depose_etage
					
				
				) else (
				
					
					
					----- les facades ---------------------
					local depose_etage 				= 	transf_facade* transMatrix [0,0, -dalle_epaisseur  ]
					local facades_murCourant		=	get_facades_pourMur	i	
					
					for i = 1 to facades_murCourant.count do (
						
						---- l'epaisseur de la dalle --------
						local compo_planV		=	createInstance	cp_prim_planVertical
						compo_planV.longueur	=	distance	pt	pt_suivant
						compo_planV.hauteur	=	dalle_epaisseur		
						compo_planV.matId		=	matId_mur		
						mgr_mesh.attacher		mesh		compo_planV	transf:depose_etage
						
						---- maj depose-----
						depose_etage *= transMatrix [0,0,dalle_epaisseur]
						
						
						
						---- la facade ----
						local fcd 				= facades_murCourant[i]
						mgr_mesh.attacher		mesh		fcd	transf:depose_etage
						
						---- maj depose-----
						depose_etage 		*=  transMatrix [0,0,  fcd.hauteur ]
						
					)
					
				)
				/* 
				---- la derniere dalle --------
				local compo_planV		=	createInstance	cp_prim_planVertical
				compo_planV.longueur	=	distance	pt	pt_suivant
				compo_planV.hauteur	=	dalle_epaisseur		
				compo_planV.matId		=	matId_mur		
				mgr_mesh.attacher		mesh		compo_planV	transf:depose_etage
				 */
				
				
			) ---- fin des facades ------------------
			
			----- 2 ) la toiture ----------------------------------------------------------------------------------------------------------------------
			local pts_toiture 			= 	deepcopy pts_surface
			
			--- calcul de l'altitude du toit ---------
			local altitude_toiture	=	0
			for etage_courant = 0 to etages_nbre do (
				
				if etage_courant != etages_nbre do
					altitude_toiture += dalle_epaisseur
				
				---- la hauteur des étages, normal ou specifique -----------------
				local on_est_sur_etage_spe	=	false
				local hauteur_etage 			=	etages_hauteur_global
				for i = 1 to  etages_spe_min.count do (
					local etageSpe_min 		= etages_spe_min[i]
					local etageSpe_max 	= etages_spe_max[i]
					local etageSpe_ht 		= etages_spe_hauteur[i]
					if not on_est_sur_etage_spe and etageSpe_min <= etage_courant and etageSpe_max >= etage_courant	do (
						on_est_sur_etage_spe = true
						hauteur_etage	=	etageSpe_ht
					)
				)
				altitude_toiture += hauteur_etage
			)
			
			--- on place donc les points sur Z ---------------
			pts_toiture.z 		= altitude_toiture
			
			
			
			case toiture_type of (
				
				1: (	-----Aucune-----------------------------
					
					/* 
					local vert_debut 	=	 getNumVerts mesh + 1
					local vert_fin 		=	getNumVerts mesh  + pts_toiture.count
					
					meshop.setNumVerts  mesh 	vert_fin
					
					for i = 1 to pts_toiture.count do (
						local i_vert = vert_debut - 1 + i
						setVert mesh 	i_vert 		pts_toiture[ i ]
					)
					local verts_toiture = #{vert_debut..vert_fin} as array
					meshop.createPolygon  mesh verts_toiture 	smGroup:1 	matID:matId_mur
					 */
					
					local compo_toiture 			= copy toiture
					compo_toiture.set_points	pts_toiture
					compo_toiture.qualite		=	qualite_courante
					mgr_mesh.attacher		mesh		compo_toiture	transf:[0,0,0 ]
				)
					
				5:(	---------- n pans ----------------------
				
					local compo_toiture = copy toiture
					compo_toiture.set_points		pts_toiture
					compo_toiture.qualite	=	qualite_courante
					mgr_mesh.attacher		mesh		compo_toiture	
					
				)
				
				
			) ---- fin case toiture_type	-------
			
			
			
			
		) --- fin if surface ---------------------
		
		local chrono_fin = timeStamp()
-- 		debug  "build mesh" var:( ((chrono_fin - chrono_debut) / 1000.0) as string + "s.")
		displayTempPrompt 		( "Construction du mesh : " + ((chrono_fin - chrono_debut) / 1000.0) as string + "s.")  5000
		
	) --------- fin on build mesh --------------------------
	
	
	
	
	
	
	
	
	
	
	
	
	
	tool create	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		on mousePoint click do
			case click of
			(
				1: (	
						nodeTM.translation = gridPoint
						#stop
				)
			)
		
	) ----- fin tool create -------------
	
	
	on update 	do initialiser ()
	on create  	do initialiser ()
	on load  		do initialiser ()
	
) --------- fin plugin --------------------------------------------------------------------