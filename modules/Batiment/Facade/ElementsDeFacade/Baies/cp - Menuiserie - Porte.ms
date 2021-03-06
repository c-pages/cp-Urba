

plugin simpleObject		cp_menuiserie_porte
name:"Porte"
classID:#(0x23dc3da5, 0x2b0eb201)
category:"CP | Menuiserie"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_menuiserie_porte"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	--- Pr�d�finitions ------------------
	local corriger_parametres
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	----- les composants -----------	
	local	compo_cadre,	compo_ouvrant_vitree,	compo_ouvrant_plein, compo_ouvrant_1 , compo_ouvrant_2, 	compo_poignee
	
	
	
	parameters params_dimensions rollout:rol_global	(
		hauteur	 		type:#worldUnits 	ui:spn_hauteur 			default:0.
		menuis_profondeur	 			type:#worldUnits 	ui:spn_profondeur		default:5.
		
		cadre						type:#boolean 		ui:shk_cadre				default:true
		menuis_epaisseur		type:#worldUnits 	ui:spn_cadre_ep			default:5.
		travBasse				type:#boolean 		ui:shk_traverse_B		default:false
	)
	parameters params_general rollout:roll_parametres	(
		
		longueur 		type:#worldUnits 	ui:spn_longueur 			default:0.
		
		----- les menuiseries -----------
		vitrage_epaisseur				type:#worldUnits 	default:1.
		
		----- ouvrants ---------------------
		ouvrant_travBasse_ht	 	type:#worldUnits 	default:10.
		div_profondeur	 			type:#worldUnits 	default:3.
		
		ouvrant_double				type:#boolean 		ui:shk_double								default:false
		ouvrant_tierce_pourcent	type:#float		 		ui:spn_tierce_pourcent					default:50.
		
		ouvrant_vitree					type:#boolean 		ui:shk_vitree								default:true		
		ouvrant_cadre_larg		 	type:#worldUnits 	ui:spn_ouvrant_cadre_larg				default:7.	
		ouvrant_cadre_travB_ht	type:#worldUnits 	ui:spn_ouvrant_cadre_travB_ht		default:12.		
		
		div_largeur	 					type:#worldUnits 	ui:spn_div_largeur			default:2.
		div_montants_nbr		 	type:#integer		 	ui:spn_div_montants_nbr				default:0.
		div_montants_nbr_2		 	type:#integer		 	ui:spn_div_montants_nbr_2			default:0.
		div_traverses_nbr			type:#integer		 	ui:spn_div_traverses_nbr				default:0.
		div_calage_verti	 			type:#worldUnits	 	ui:spn_div_calage_verti					default:0.
		
		symetrie							type:#boolean 		ui:shk_symetrie							default:false
		ouvert_angle_1				type:#float 			/* ui:spn_angle_1	 */						default:0.
		ouvert_angle_2				type:#float 			/* ui:spn_angle_2	 */						default:0.
		
		
		---- Poign�es ---------------------
		poignee_1_use				type:#boolean 		ui:shk_poignee_1							default:true
		poignee_2_use				type:#boolean 		ui:shk_poignee_2							default:true
		poignee_hauteur	 			type:#worldUnits 	default:90.
		poignee_align_x				type:#worldUnits 	default:1.
	
	)	-----	fin parametres --------------------
	parameters params_divers rollout:roll_divers	(
		
		nom	 							type:#string 			default:"Porte"
		
		------ options --------------
		qualite							type:#integer 			ui:rdo_qualite				default:1
		
		est_ouvrable					type:#boolean 					default:true
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_poignee					type:#integer 			ui:spn_matId_poignee	default:3
		
	)	-----	fin parametres --------------------
	
	
	parameters params_hasard --rollout:roll_hasard
	(
		hasard_seed					type:#integer 		/* 	ui:spn_hasard_seed	 */	default:123456
		
		fen_proba_ouv				type:#float 		/* 	ui:spn_fen_proba_ouv	 */	default:0.
		fen_ouvMax					type:#float 		/* 	ui:spn_fen_ouvMax	 */		default:0.
	)
	
	
	
	
	
	
	
	
	
	
	
	
	rollout rol_global  "Global"	(
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_profondeur 		"menuis_profondeur" 			type:#worldunits 	range:[0,1e20,0]
		
		group "cadre" (
			checkbox	shk_cadre				"Cadre"
			spinner 	spn_cadre_ep 			"Epaisseur" 			type:#worldunits 	range:[0,1e20,0]
			checkbox	shk_traverse_B		"Traverse basse"
		)
	)
	
	rollout roll_parametres  "Param�tres"	(		
		
		spinner 	spn_longueur 			"longueur" 				type:#worldunits 	range:[0,1e20,0]
		checkbox	shk_symetrie						"Inverser sens"		tooltip:"Inverser le sens d'ouverture de la porte"
		checkbox	shk_double							"Double"		width:47	
		spinner 	spn_tierce_pourcent 			"Tierc�e (%)" 					type:#float				range:[0,100,0] 
		
		group 	"Vitr�e" (	
			checkbox	shk_vitree							"Vitr�e"				
			spinner 	spn_ouvrant_cadre_larg	 	"Men. larg." 		type:#worldunits range:[0,1e20,0]
			spinner 	spn_ouvrant_cadre_travB_ht	 "Trav. B. ht." 			type:#worldunits range:[0,1e20,0]
		)
		group 	"Croisillons" (	
			spinner		spn_div_largeur			 	"Largeur" 		type:#worldunits		range:[0,1e20,0]
			spinner 	spn_div_montants_nbr		 "Montants 1" 	type:#integer				range:[0,1e20,0]
			spinner 	spn_div_montants_nbr_2	 "Montants 2" 	type:#integer			range:[0,1e20,0]
			spinner		spn_div_traverses_nbr	 	"Traverses" 	type:#integer				range:[0,1e20,0]
			spinner 	spn_div_calage_verti 		"Align. vert." 	type:#worldunits			range:[-1e20,1e20,0]
		)
		group 	"Options" (	
			checkbox	shk_poignee_1					"Poign�e 1"
			checkbox	shk_poignee_2					"Poign�e 2"
		)
		
		fn actualiser =(
			shk_symetrie.enabled = not ouvrant_double
			if ouvrant_double do shk_symetrie.triState = 2
			
			spn_ouvrant_cadre_larg.indeterminate			=	not ouvrant_double
			spn_ouvrant_cadre_larg.enabled 				=	ouvrant_double
			
			spn_tierce_pourcent.indeterminate			=	 not ouvrant_double
			spn_tierce_pourcent.enabled 					=	ouvrant_double
			spn_div_montants_nbr_2.indeterminate		=	not ouvrant_double	and 	not ouvrant_vitree
			spn_div_montants_nbr_2.enabled 				=	ouvrant_double and  ouvrant_vitree
			
			spn_ouvrant_cadre_larg.indeterminate			=	not ouvrant_vitree
			spn_ouvrant_cadre_larg.enabled 				=	ouvrant_vitree
			spn_ouvrant_cadre_travB_ht.indeterminate	=	not ouvrant_vitree
			spn_ouvrant_cadre_travB_ht.enabled 			=	ouvrant_vitree
			spn_div_montants_nbr.indeterminate			=	not ouvrant_vitree
			spn_div_montants_nbr.enabled 					=	ouvrant_vitree
			spn_div_traverses_nbr.indeterminate			=	not ouvrant_vitree
			spn_div_traverses_nbr.enabled 					=	ouvrant_vitree
			spn_div_calage_verti.indeterminate				=	not ouvrant_vitree
			spn_div_calage_verti.enabled 					=	ouvrant_vitree
			
			spn_div_largeur.indeterminate			=	not ouvrant_vitree
			spn_div_largeur.enabled 					=	ouvrant_vitree


			shk_poignee_2.enabled =  ouvrant_double
			if not ouvrant_double do shk_poignee_2.triState = 2
		)
		on roll_parametres	open 					do actualiser ()
		on shk_double 		changed state 	do actualiser ()
		on shk_vitree	 		changed state 	do actualiser ()
		on shk_tierce	 		changed state 	do actualiser ()
	)
	
	rollout roll_divers  "Divers"	(
		group "Qualit�" (
			radioButtons rdo_qualite 			"" labels:#("Full", "Medium", "Low poly") align:#left
		)
		group "Material ID" (
			spinner spn_matId_menuis 			"Menuiseries" 			type:#integer 			range:[1,1000,1]
			spinner spn_matId_vitrage 			"Vitrage" 				type:#integer 			range:[1,1000,1]
			spinner spn_matId_poignee 			"Poign�e" 				type:#integer 			range:[1,1000,1]
		)
		
	) 	---- fin rollout	-----------------------
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------

	fn set_hasard	_fen_ouvMax	_fen_proba_ouv =(
		fen_ouvMax 		= _fen_ouvMax
		fen_proba_ouv 	= _fen_proba_ouv
	)
	fn get_longueur	=	longueur
	
	---- les composants ---------------------
	fn actualiser_composants	= with redraw off (
		
		
		---- creation des composants ------------------
		if qualite != 3 then
			compo_ouvrant_plein	= 	createInstance  cp_prim_boite
		else
			compo_ouvrant_plein	= 	createInstance  cp_prim_planVertical
		
		
		if compo_ouvrant_vitree 		== undefined	do	compo_ouvrant_vitree	= 	createInstance  cp_menuisElem_chassisVitre
		if compo_poignee					== undefined	do	compo_poignee			= 	createInstance  cp_menuisElem_poignee
		
		if cadre and compo_cadre 	== undefined	do	compo_cadre		= createInstance  	cp_menuisElem_cadre
		
		local longueur_passage 	=   if cadre then longueur - menuis_epaisseur*2	else  longueur
		local hauteur_passage 		 = if cadre and travBasse	then hauteur  - menuis_epaisseur*2	
												else if cadre then  hauteur  - menuis_epaisseur
												else	hauteur
		
		
		
		
		---- maj ouvrant		----
		local ouvrant_longueur_tmp	=	if not ouvrant_double then  longueur_passage		else longueur_passage / 2 
	
		compo_ouvrant_vitree.longueur 					= ouvrant_longueur_tmp	
		compo_ouvrant_vitree.profondeur 				= menuis_profondeur / 2 
		compo_ouvrant_vitree.hauteur 					= hauteur_passage
		
		compo_ouvrant_vitree.cadre_largeur 			= ouvrant_cadre_larg
		compo_ouvrant_vitree.travBasse_hauteur		= ouvrant_cadre_travB_ht		
		
		compo_ouvrant_vitree.matId_menuis	 		= matId_menuis
		compo_ouvrant_vitree.matId_vitrage	 		= matId_vitrage		
		compo_ouvrant_vitree.div_montants_nbr 		= div_montants_nbr
		compo_ouvrant_vitree.div_traverses_nbr 		= div_traverses_nbr
		compo_ouvrant_vitree.div_largeur				= div_largeur
		compo_ouvrant_vitree.div_profondeur			= menuis_profondeur / 2
		compo_ouvrant_vitree.div_calage_verti		= div_calage_verti
		compo_ouvrant_vitree.vitrage_epaisseur		= vitrage_epaisseur
		compo_ouvrant_vitree.qualite			 			= qualite		
		
		--- plein ---		
		compo_ouvrant_plein.longueur	 				= ouvrant_longueur_tmp
		compo_ouvrant_plein.hauteur 					= hauteur_passage
		if qualite != 3 do
			compo_ouvrant_plein.profondeur 			= menuis_profondeur / 2 -- 		ouvrant_profondeur
		
		
		compo_ouvrant_1	=	 if ouvrant_vitree then compo_ouvrant_vitree else compo_ouvrant_plein
		
	
		if not ouvrant_double then (
			compo_ouvrant_1.longueur 				= longueur_passage
		) else (
			
			compo_ouvrant_1.longueur				=	if cadre then (longueur_passage 	*  ouvrant_tierce_pourcent / 100 ) /* - menuis_epaisseur  */else (longueur_passage 	*  ouvrant_tierce_pourcent / 100 )
			
			compo_ouvrant_2 							= copy compo_ouvrant_1
			compo_ouvrant_2.longueur 				=  if cadre then ( longueur_passage	* ( 100 - ouvrant_tierce_pourcent ) / 100 ) /* - menuis_epaisseur  */else	( longueur_passage	* ( 100 - ouvrant_tierce_pourcent ) / 100 ) 
			
			if ouvrant_vitree  do
				compo_ouvrant_2.div_montants_nbr 	=  div_montants_nbr_2
			
		)
		
		
		
		
		--- hasard	---------------
		local est_ouverte =   ( random 0.  100. ) < fen_proba_ouv 
		if est_ouverte 	then (
			
			ouvert_angle_1 = random 0.		fen_ouvMax
			ouvert_angle_2 = random 0.		fen_ouvMax		

		)
		
		
		-----	le cadre 	-------------
		if cadre do	(
			compo_cadre.longueur						=	longueur
			compo_cadre.hauteur						=	hauteur
			compo_cadre.profondeur					=	menuis_profondeur
			compo_cadre.menuis_epaisseur			=	menuis_epaisseur
			compo_cadre.travBasse_hauteur			=	menuis_epaisseur
			compo_cadre.travBasse					=	travBasse
			
			compo_cadre.qualite			 				= qualite		
			compo_cadre.matId_menuis	 			= matId_menuis
		)
		
		
		
	)  --- fin composants_actualiser  ------------------
	
	
	
	
	
	
		
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		
		----Donn�es ------------	
		local origine_ouv_1
		local rotate_ouv_1
		local recalle_ouv_1
		
		local origine_ouv_2
		local rotate_ouv_2
		local recalle_ouv_2
		
		local longueur_ouvrant_1 	= compo_ouvrant_1.longueur 
		local callage_montant_G 	= 	 if cadre then menuis_epaisseur else 0
		local callage_montant_D 	= callage_montant_G
		local ouvrant_pos_z 		= if cadre and travBasse then menuis_epaisseur else 0
		local ouvrant_profondeur = menuis_profondeur / 2
		local ouvrant_callage_y	= 	if qualite != 3 then	menuis_profondeur else 0
		
		
		if  symetrie and not ouvrant_double	then (
			if qualite != 3	then 
				origine_ouv_1	=	transMatrix	[ -longueur_ouvrant_1, - ouvrant_profondeur ,	ouvrant_pos_z ]	
			else
				origine_ouv_1	=	transMatrix	[ -longueur_ouvrant_1, 0 ,	ouvrant_pos_z ]	
			rotate_ouv_1	=	rotateZMatrix -ouvert_angle_1
			recalle_ouv_1	=	transMatrix	[longueur - callage_montant_G, ouvrant_callage_y ,	0 ]
		) else (
			if qualite != 3	then 
				origine_ouv_1	=	transMatrix	[ 0, -ouvrant_profondeur,	ouvrant_pos_z ]
			else
				origine_ouv_1	=	transMatrix	[ 0, 0,	ouvrant_pos_z ]
			rotate_ouv_1	=	rotateZMatrix 	ouvert_angle_1 
			recalle_ouv_1	=	transMatrix	[callage_montant_G,  ouvrant_callage_y,	0 ]
		)
		if  ouvrant_double do (			
			local longueur_ouvrant_2 	= compo_ouvrant_2.longueur 
			if qualite != 3	then 
				origine_ouv_2	=	transMatrix	[ -longueur_ouvrant_2, -ouvrant_profondeur ,	ouvrant_pos_z ]
			else
				origine_ouv_2	=	transMatrix	[ -longueur_ouvrant_2, 0 ,	ouvrant_pos_z ]
			rotate_ouv_2 	=  rotateZMatrix -ouvert_angle_2
			recalle_ouv_2	=	transMatrix	[longueur - callage_montant_D,  ouvrant_callage_y,	0 ]
		)
		
		
		
		---- 1er ouvrant ------------
		local transf_ouvrant_1	=	origine_ouv_1 * rotate_ouv_1 * recalle_ouv_1		
		mgr_mesh.attacher		mesh		compo_ouvrant_1 	transf:transf_ouvrant_1

		---- 2nd ouvrant	------------
		if  ouvrant_double do (
			local	transf_ouvrant_2 = origine_ouv_2 * rotate_ouv_2 * recalle_ouv_2		
			mgr_mesh.attacher		mesh		compo_ouvrant_2 	transf:transf_ouvrant_2
		)
		
		
		
		
		-------- poign�es -------------
		---- poign�e 1 et interieur 1 ------------------------
		if qualite != 3 do (
				
			local hauteur_min 			= 108
			local largeur_menuis_min	= 2.5
			
			if poignee_1_use /* and not low_poly  */and hauteur  > hauteur_min and ouvrant_cadre_larg > largeur_menuis_min	do (
				
				
				compo_poignee.qualite 			= qualite
				compo_poignee.matID			=	matId_poignee
				if   symetrie  and  not ouvrant_double  then (
					
					compo_poignee.symetrie 			= true
					compo_poignee.symetrie_sens 	= true
					compo_poignee_transf 				= 	transMatrix	[ -(longueur_ouvrant_1  - poignee_align_x) , -ouvrant_profondeur,	poignee_hauteur ]   * rotate_ouv_1 * recalle_ouv_1
					mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf
					
					if ouvrant_vitree do (
						compo_poignee.symetrie 			= false
						compo_poignee.symetrie_sens 	= true
						compo_poignee_transf 				= 	transMatrix	[ -(longueur_ouvrant_1  - poignee_align_x) , 0,	poignee_hauteur ]   * rotate_ouv_1 * recalle_ouv_1
						mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf	
					)
					
				)	else (
					
					compo_poignee.symetrie 			= true
					compo_poignee.symetrie_sens 	= false
					compo_poignee_transf 				=	transMatrix	[ longueur_ouvrant_1 - 4 - poignee_align_x , -ouvrant_profondeur,	poignee_hauteur ]  * rotate_ouv_1 * recalle_ouv_1
					mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf
					
					if ouvrant_vitree do (
						compo_poignee.symetrie 			= false
						compo_poignee.symetrie_sens 	= false
						compo_poignee_transf 				= 	transMatrix	[ longueur_ouvrant_1 - 4 - poignee_align_x , 0,	poignee_hauteur ]  * rotate_ouv_1 * recalle_ouv_1
						mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf	
					)
				) 
				
			)
			---- poign�e double porte ------------------------
			if   poignee_2_use and  ouvrant_double	do (
				
				compo_poignee.symetrie 			= true
				compo_poignee.symetrie_sens 	= true
				compo_poignee_transf 				= 	transMatrix	[ -longueur_ouvrant_2 + poignee_align_x , -ouvrant_profondeur,	poignee_hauteur ]   * rotate_ouv_2 * recalle_ouv_2
				mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf
				
				if ouvrant_vitree	do (
					compo_poignee.symetrie 			= false
					compo_poignee.symetrie_sens 	= true
					compo_poignee_transf 				= 	transMatrix	[- longueur_ouvrant_2 + poignee_align_x , 0,	poignee_hauteur ]   * rotate_ouv_2 * recalle_ouv_2
					mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf	
				)
		 	) --- if ouvrant_double --
			 
		) ---- fin poign�es- 
		
		
		
		---- le cadre -------
		if cadre do 
			mgr_mesh.attacher		mesh		compo_cadre	
		
		
		
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
						hauteur = 210
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
	
	
) ------- fin plugin ---------------------


