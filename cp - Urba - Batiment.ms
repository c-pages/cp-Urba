


-------------- les fichiers à inclure ------------------------------------------------------------------------------------
--- pour debogage -----------
include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - Debug.ms" 
--- les fichiers necessaires au plug -----------
include	 "$userScripts\\cp-Urba\\Startup\\cp - Urba - Batiment - FileIn.ms" 





	
---------- quelque variables et fonctions globales	----------------------------------------------------------------------------------------------
global 	urba_fn_afficheur_longueurs	--- fonction pour affichage viewport 
global	urba_clipboard_batiment		---	clipboard pour copier/coller des presets





-------- pour changer les qualites des geometries si besoin, avant rendu, et remettre en qualite viewport apres --------------------------
---- PRERENDU	-----------
callbacks.removescripts 	id:	#urbaBat_preRender

global batiments_asProxy =#()
txt_pre ="with redraw off (\n"
txt_pre +="	batiments_asProxy =#()\n"
txt_pre +="	for bat in objects where classof bat == cp_batiment and bat.renderable  and not bat.isHidden do (\n"
txt_pre +="		if bat.qualite_courante != bat.qualite_render do (\n	bat.qualite_courante = bat.qualite_render\n"
txt_pre +="			append	batiments_asProxy		bat\n"
txt_pre +="		) \n	)	\n )	\n	"
callbacks.addscript 	#preRender 	txt_pre 		id:#urbaBat_preRender

---- POST RENDU	-----------
callbacks.removescripts 	id:#urbaBat_postRender
txt_post ="	for bat in batiments_asProxy do (\n"
txt_post +="			if bat.qualite_courante != bat.qualite_viewport do bat.qualite_courante = bat.qualite_viewport\n"
txt_post +="		)\n"
callbacks.addscript 	#postRender 	txt_post 		id:#urbaBat_postRender





	
--------------- le plugin himself ------------------------------------------------------------------------------------
plugin simpleObject		cp_batiment
name:"Bâtiment"
classID:#(0x3ae67906, 0x740a62d7)
category:"CP | Urba"
-- invisible:true
(
	
	
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_batiment"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local basculer_editeurFacade, ajouter_facade, retirer_facade, dupliquer_facade,  monter_facade, descendre_facade, renommer_facade, actualiser_shape
	local ajouter_etage_spe, supprimer_etage_spe
	local afficher_longueurs
	local roll_editeur_facade
	
	local definir_toiture
	
	----- les points de la surface------------------------
	local pts_surface
	
	
	---- managers ----------
	local mgr_shp 	= str_mgr_shape ()
	local mgr_mesh 	= str_mgr_mesh ()
	
	
	
	parameters param_etages rollout:roll_etages	(
		
		------- Etages			------------------
		etages_nbre					type: #integer				default:1			ui:spn_etages_nbres	 				animatable:false		invisibleInTV:true
		etages_hauteur_global		type: #worldUnits 		default:250.	 	ui:spn_etages_hauteur	 			animatable:false		invisibleInTV:true
		
		dalle_epaisseur				type: #worldUnits 		default:20.	 		ui:spn_dalle_epaisseur	 			animatable:false		invisibleInTV:true
		soubassement_hauteur		type: #worldUnits 		default:100.	 	ui:spn_soubassement_hauteur	animatable:false		invisibleInTV:true
		
		
		------- Etages	 specifiques		------------------
		etages_spe_min				type: #intTab					tabSizeVariable:true
		etages_spe_max				type: #intTab					tabSizeVariable:true
		etages_spe_hauteur			type: #worldUnitsTab		tabSizeVariable:true
		
	)
	
	parameters param_surface rollout:roll_surface	(
		------- Surface		------------------
		surface_node					type:#node 			 	ui:btn_pick_perimetre		animatable:false		invisibleInTV:true
		
		------- Optimisations		------------------
		optim_aplanir					type:#boolean			default:true		ui:chk_aplanir		animatable:false		invisibleInTV:true
		optim_souder					type:#boolean			default:true		ui:chk_souder		animatable:false		invisibleInTV:true
		optim_orthonormer			type:#boolean			default:false		ui:chk_ortho			animatable:false		invisibleInTV:true
		optim_aligner					type:#boolean			default:false		ui:chk_aligner		animatable:false		invisibleInTV:true
		optim_projeter					type:#boolean			default:false		ui:chk_projeter		animatable:false		invisibleInTV:true
		
		------- Seuils		------------------
		optim_aplanir_seuil			type:#float				default:20.			ui:spn_aplanir		animatable:false		invisibleInTV:true
		optim_souder_seuil			type:#float				default:30.			ui:spn_souder		animatable:false		invisibleInTV:true
		optim_ortho_seuil				type:#float				default:100.		ui:spn_ortho		animatable:false		invisibleInTV:true
		optim_aligner_seuil			type:#float				default:50.			ui:spn_aligner		animatable:false		invisibleInTV:true
		
	)
	
	parameters param_facades rollout:roll_facades	(
		facades							type:#maxObjectTab	tabSizeVariable:true
		
-- 		affichage_longueurs		type:#boolean 		/* ui:ckb_afficher_longueur	 */			default:true
		editeur_facade_ouvert		type:#boolean 		 ui:btn_editer_facade	 			default:false
		
	)
	
	parameters params_divers rollout:roll_divers	(
		
		------ options --------------
-- 		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		qualite_courante				type:#integer 			default:1
		qualite_viewport				type:#integer 			ui:rdo_qualite_viewport				default:1
		qualite_render					type:#integer 			ui:rdo_qualite_render				default:1
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_huisserie					type:#integer 			ui:spn_matId_huisserie	default:3
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
	
	rollout roll_surface "Surface" width:180 height:160
	(
		
		fn shape_filt 		obj = superclassof obj == shape
		--- Surface ------
		pickbutton 'btn_pick_perimetre' "Pick shape" pos:[1,2] width:170 height:20 filter:shape_filt autoDisplay:true align:#left
		
		GroupBox 'grp1' "Optimiser" pos:[4,23] width:169 height:101 align:#left
			
		checkbox 'chk_souder' "Souder" pos:[13,42] width:57 height:15 across:2 align:#left
		spinner 'spn_souder' "" pos:[90,42] width:75 height:16 range:[0,10000,0] type:#worldunits align:#left
			
		checkbox 'chk_ortho' "Orthonorm." pos:[13,57] width:77 height:15 across:2 align:#left
		spinner 'spn_ortho' "" pos:[90,57] width:75 height:16 range:[0,100,0] type:#float align:#left
			
		checkbox 'chk_aplanir' "Aplanir" pos:[13,72] width:56 height:15 across:2 align:#left
		spinner 'spn_aplanir' "" pos:[90,72] width:75 height:16 range:[0,40,0] align:#left
			

		checkbox 'chk_aligner' "Aligner" pos:[13,87] width:56 height:15 across:2 align:#left
		spinner 'spn_aligner' "" pos:[90,87] width:75 height:16 range:[0,100,0] align:#left

		checkbox 'chk_projeter' "Projeter" pos:[13,102] width:61 height:15 align:#left  
  
  
		
	)
	
	rollout roll_etages "Etages" width:180 height:270
	(
		GroupBox 'grp_general' "Général" pos:[4,1] width:169 height:88 align:#left
		spinner 'spn_etages_nbres' "" pos:[90,20] width:75 height:16 range:[0,1000,1] type:#integer align:#left
		spinner 'spn_etages_hauteur' "" pos:[90,35] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
			
		spinner 'spn_dalle_epaisseur' "" pos:[90,50] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		spinner 'spn_soubassement_hauteur' "" pos:[90,65] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		GroupBox 'grp2' "Etages spécifiques" pos:[4,90] width:169 height:139 align:#left
	
			
		button 'btn_etages_nouveau' "Nouveau" pos:[20,112] width:70 height:16 toolTip:"Ajouter	étages spécifiques" across:2 align:#left
		button 'btn_etages_supprimer' "Supprimer" pos:[93,112] width:70 height:16 toolTip:"Supprimer étages spécifiques" align:#left
		listbox 'lbx_etages_specifiques' "" pos:[20,131] width:146 height:4 align:#left
			
		label 'lbl_etage_specifiques' "Etages :" pos:[20,190] width:45 height:19 across:4 align:#left 
 
 
 
 
 
		spinner 'spn_etageMin_specifiques' "" pos:[90,190] width:35 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left 
 
 
 
 
 
-- 			checkbutton 	ckb_etageMax_specifiques ">"  width:16 height:16 
		label 'lbl_etageMax_specifiques' ">" pos:[125,190] width:7 height:16 align:#left 
 
 
 
 
 
		spinner 'spn_etageMax_specifiques' "" pos:[130,190] width:35 height:16 range:[0,1e+13,0] type:#integer align:#left
		label 'lbl_hauteur_specifiques' "Hauteur :" pos:[20,205] width:55 height:18 across:2 align:#left
		spinner 'spn_hauteur_specifiques' "" pos:[90,205] width:75 height:16 range:[0,1e+13,0] type:#worldunits align:#left
		
		
		label 'lbl_nombre' "Nombre:" pos:[20,20] width:67 height:14 align:#left
			
		
		label 'lbl_hauteur' "Hauteur:" pos:[20,35] width:67 height:14 align:#left
		label 'lbl_dalle_ep' "Dalle ép.:" pos:[20,50] width:67 height:14 align:#left
		label 'lbl11' "Ss bas.:" pos:[20,65] width:67 height:14 align:#left
		
		
		
		
		
		
		
		
		fn actualiser =(
			
			--- la liste box ------
			local liste_etages =#()
			for i = 1 to  etages_spe_min.count do 
				append liste_etages ( etages_spe_min[i] as string + " > " + etages_spe_max[i] as string + " : " + etages_spe_hauteur[i] as string + "cm." )			
			lbx_etages_specifiques.items = liste_etages
			
			---- les valeurs --------
			if lbx_etages_specifiques.selection != 0 then (
				local selec = lbx_etages_specifiques.selection
				
				btn_etages_supprimer.enabled 		= true
				lbl_etage_specifiques.enabled 		= true
				lbl_etageMax_specifiques.enabled 	= true
				lbl_hauteur_specifiques.enabled 		= true
				
				spn_etageMin_specifiques.enabled 	= true
				spn_etageMax_specifiques.enabled 	= true
				spn_hauteur_specifiques.enabled 	= true
				
				spn_etageMin_specifiques.indeterminate 	= false
				spn_etageMax_specifiques.indeterminate 	= false
				spn_hauteur_specifiques.indeterminate 	= false
				
				spn_etageMin_specifiques.value 		= etages_spe_min[selec] 
				spn_etageMax_specifiques.value 	= etages_spe_max[selec] 
				spn_hauteur_specifiques.value 		= etages_spe_hauteur[selec] 
				
			) else (
				
				btn_etages_supprimer.enabled 		= false
				lbl_etage_specifiques.enabled 		= false
				lbl_etageMax_specifiques.enabled 	= false
				lbl_hauteur_specifiques.enabled 		= false
				
				spn_etageMin_specifiques.enabled 	= false
				spn_etageMax_specifiques.enabled 	= false
				spn_hauteur_specifiques.enabled 	= false
				
				spn_etageMin_specifiques.indeterminate 	= true
				spn_etageMax_specifiques.indeterminate 	= true
				spn_hauteur_specifiques.indeterminate 	= true
				
			)
			
		)
		
		
		
		
		on roll_etages open do
			actualiser ()
		on btn_etages_nouveau pressed do
		(
					ajouter_etage_spe	()
					actualiser ()
				)
		on btn_etages_supprimer pressed do
		(
					supprimer_etage_spe	lbx_etages_specifiques.selection
					actualiser ()
				)
		on lbx_etages_specifiques selected sel do
			actualiser ()
		on spn_etageMin_specifiques changed val do
		(
					local selec = lbx_etages_specifiques.selection			
					etages_spe_min[selec] = val
					if etages_spe_max[selec] < val do
						etages_spe_max[selec] = val
					actualiser ()
				)
		on spn_etageMax_specifiques changed val do
		(
					local selec = lbx_etages_specifiques.selection			
					etages_spe_max[selec] = val
					if etages_spe_min[selec] > val do
						etages_spe_min[selec] = val
					actualiser ()
				)
		on spn_hauteur_specifiques changed val do
		(
					local selec = lbx_etages_specifiques.selection			
					etages_spe_hauteur[selec] = val
					actualiser ()
					redrawViews ()
				)
	)
	
	rollout roll_facades "Facades"	(
		
		button 'btn_ajouter' "Nouv." pos:[3,3] width:45 height:19 across:4 align:#left
		button 'btn_retirer' "Supp." pos:[91,3] width:45 height:19 align:#left
		button 'btn_dupliquer' "Dupl." pos:[47,3] width:45 height:19 across:4 align:#left
		button 'btn_monter' "/\\" pos:[135,3] width:19 height:19 align:#left
		button 'btn_descendre' "\\/" pos:[153,3] width:19 height:19 align:#left
		listbox 'lbx_facades' "" pos:[3,22] width:170 height:5 align:#left
		edittext 'edTxt_nom' "" pos:[-1,94] width:174 height:17 align:#left
		
		checkbutton		btn_editer_facade		"Editeur de façade"	pos:[2,112] width:171 height:25 -- width:140 height:25
		
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
			
			edTxt_nom.enabled 				= lbx_facades.selection != 0
			edTxt_nom.text	 					= if lbx_facades.selection != 0	then	facades[  lbx_facades.selection ].nom	else ""
			
			btn_editer_facade.enabled 		= lbx_facades.selection != 0
			
			
		) --- fin actualiser -----------
		
		
		on roll_facades	open do actualiser ()
		
		
		----- Facades -----------------
		on lbx_facades 		selected sel 	do	actualiser ()		
		on lbx_facades	 rightClick 	_id 	do	(
			lbx_facades.selection = _id
			actualiser ()
		)	
		on lbx_facades	 doubleClicked  	_id 	do		basculer_editeurFacade 	true
			
		on btn_ajouter 		pressed 			do 	ajouter_facade ()
		on btn_retirer 		pressed 			do	retirer_facade			lbx_facades.selection 
		on btn_dupliquer 		pressed 			do	dupliquer_facade		lbx_facades.selection 
		on btn_monter 		pressed 			do	monter_facade		lbx_facades.selection 
		on btn_descendre 	pressed		 	do	descendre_facade	lbx_facades.selection 
	
		on edTxt_nom entered txt 			do 	renommer_facade		lbx_facades.selection 	txt
		
		on btn_editer_facade  changed state	do 	basculer_editeurFacade 	state
		
	) --- fin rollout facades-------------------------
	
	rollout roll_toiture "Toiture" width:180 height:203
	(
		
		
		dropdownList 'ddl_toiture_type' "" pos:[5,3] width:165 height:21 items:#("Sans", "Terrasse", "1 pan", "2 pans", "n pans") align:#left
		subRollout 'subRoll_param' "" pos:[5,25] width:165 height:160 align:#left
		
		dotNetControl 'btn_resize' "System.Windows.Forms.Button" pos:[5,188] width:165 height:10 align:#left
		
		fn actualiser = (
			
			--- les parametres de l'element (le subrollout)  ---------------			
			--- on retire les vieux rollouts --------
			if subroll_param.rollouts.count > 0 do 
				for subRoll in subroll_param.rollouts  do
					removeSubRollout subroll_param	subRoll
				
			local composant_actif 	
			---- on ajoute le nouveau -----------------
			if ddl_toiture_type.selection > 1 then (
				addSubRollout 	subroll_param		toiture.roll_general
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
					pos_initial						=	mouse.posUnscaled
					subRoll_hauteur_init		= 	subroll_param.height
					btnResize_pos_init			=	btn_resize.pos
					roll_hauteur_init			=	roll_toiture.height
					debug "pos_initial"	var:pos_initial
				)
		fn resizer =(
			if resize_enCours do (
				local changement_ht 	= mouse.posUnscaled.y - pos_initial.y
				local subRoll_nvl_ht 		= subRoll_hauteur_init 		+ 	changement_ht
				
				if subRoll_nvl_ht >	50 do (
					debug "mouse_pos"	var:mouse_pos
					debug "changement_ht"	var:changement_ht
					
					
					subroll_param.height		=	subRoll_nvl_ht
					btn_resize.pos.y			=	btnResize_pos_init.y		+	changement_ht
					roll_toiture.height			=	roll_hauteur_init 	+ 	changement_ht
				)
			)
		)
		------------ le bouton resize -----------------------
		on btn_resize mouseDown 		do 	resize_init		()
		on btn_resize mouseMove 		do	resizer ()
		on btn_resize mouseUp 			do	resize_enCours = false
		on btn_resize MouseLeave 		do	resize_enCours = false
		
		
		
		
		
		
		on roll_toiture open do
		(
					actualiser ()
					
					---- le bouton resize -----------------------
					btn_resize.FlatStyle	=		(dotNetClass "System.Windows.Forms.FlatStyle").flat	
					btn_resize.BackColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
					btn_resize.ForeColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
				)
		on ddl_toiture_type selected val		do
			actualiser()
		
	)
	
	rollout roll_divers  "Divers"	(
-- 		group "Qualité" (
-- 			checkbox	shk_lowPoly			"Low poly"
-- 		)
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
	
	
	
	
	
	--------- viewport --------------------------------------------------------------------------	
	fn fn_afficheur_longueurs =(
		
		gw.setTransform (matrix3 1)
		
		if selection.count == 1 and classof $ == cp_batiment do (
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
		
	)
	fn preset_coller = (
		
	)
	fn preset_enregistrer = (
		
	)
	fn preset_charger = (
		
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
			1:		toiture		=	undefined
			5:		toiture 		= createInstance		cp_batimentElem_toiture_nPans
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
					
					
					local vert_debut 	=	 getNumVerts mesh + 1
					local vert_fin 		=	getNumVerts mesh  + pts_toiture.count
					
					meshop.setNumVerts  mesh 	vert_fin
					
					for i = 1 to pts_toiture.count do (
						local i_vert = vert_debut - 1 + i
						setVert mesh 	i_vert 		pts_toiture[ i ]
					)
					local verts_toiture = #{vert_debut..vert_fin} as array
					meshop.createPolygon  mesh verts_toiture 	smGroup:1 	matID:matId_mur
					
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
-- 		debug  "build mesh " var:( ((chrono_fin - chrono_debut) / 1000.0) as string + "s.")
		
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
	
) --------- fin plugin ------------------------------------------------------------------------------------