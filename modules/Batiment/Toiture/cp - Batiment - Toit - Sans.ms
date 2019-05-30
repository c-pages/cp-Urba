

plugin simpleObject		cp_batimentElem_toiture_sans
name:"Sans"
classID:#(0x23dc3da5, 0x7c3c45b6)
category:"CP | Bâtiment	| Element"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_batimentElem_toiture_sans"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local corriger_parametres , 	actualiser_composants 
	local	set_points
	local est_instance
	
	local sequence_tmp
	
	
	---- managers		 -------------------
	local mgr_mesh 			=	str_mgr_mesh ()
	local mgr_shape 			=	str_mgr_shape ()
-- 	local mgr_squelette		=	str_squelettisation ()
	
	
	
	parameters params_general rollout:roll_general	(
		
		----- global ---------------------
		points_surface					type:#point3Tab  	tabSizeVariable:true
-- 		pente		 					type:#float			 	ui:spn_pente				default:20.
-- 		decallage						type:#worldUnits		ui:spn_decallage			default:10.
		
-- 		debord_use						type:#boolean 		ui:shk_debord				default:true
-- 		debord_longueur				type:#worldUnits		ui:spn_debord_lg			default:30.
-- 		debord_hauteur				type:#worldUnits		ui:spn_debord_ht			default:20.
		
	)
	
	parameters params_divers rollout:roll_divers	(
		
		nom	 							type:#string 			default:"Toiture n pans"
		
		------ options --------------
-- 		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		qualite							type:#integer 			ui:rdo_qualite				default:1
		
		------ mat ID ----------
		matId_toiture					type:#integer 			ui:spn_toiture				default:5
		matId_corniche				type:#integer 			ui:spn_corniche			default:4
		
	)	-----	fin parametres --------------------
	
	
	rollout roll_points "Points" (
		pickButton pkbtn_pts	"pick shape" 
		
		on pkbtn_pts picked shp do (
			local shp_points = for i = 1 to numknots shp collect getKnotPoint  shp 1 i 
			set_points	shp_points
			
		)
	)
	
	
	rollout roll_general 			"Paramètres"		width:165	(
		/* 
		spinner spn_pente	 				"Pente (°)" 				type:#float range:[0,80,0]
		spinner spn_decallage 				"Decallage" 			type:#worldunits range:[0,1e20,0]
		
		group "Corniche" (
			checkbox	shk_debord			"Corniche"
			spinner spn_debord_lg 			"Longueur" 			type:#worldunits range:[0,1e20,0]
			spinner spn_debord_ht 			"Hauteur" 			type:#worldunits range:[0,1e20,0]
		)
		
		fn actualiser =(
			
			spn_debord_lg.indeterminate		=	not debord_use
			spn_debord_lg.enabled 				=	debord_use
			spn_debord_ht.indeterminate		=	not debord_use
			spn_debord_ht.enabled 				=	debord_use
		)
		
		
		on shk_debord changed state do actualiser ()
		 */
	)
	
	rollout roll_divers  			"Divers"			(
-- 		group "Qualité" (
-- 			checkbox	shk_lowPoly		"Low poly" 		
-- 		)
		group "Qualité" (
			radioButtons rdo_qualite 			"" labels:#("Full", "Medium", "Low poly", "Volume"	) align:#left
		)
		group "Material ID" (
			spinner spn_toiture 		"Toiture" 			type:#integer range:[1,1000,1]
			spinner spn_corniche 		"Corniche" 			type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	------------ FONCTIONS	----------------------------------------------------------------------------------
	fn initialiser =(
		mgr_mesh 			=	str_mgr_mesh ()
		mgr_squelette		=	str_squelettisation ()
	)
	
	---- les parametres ----------------
	fn corriger_parametres 	=(
		
-- 		--- rester dans les bonnes limites ------
-- 		if align_prof > profondeur do align_prof = profondeur
		
		/* 
		--- longueur de l'ensemble ----------
		local longueur_est_contrainte = true
		local longueur_contrainte = 0
		for elem_long in sequence_elem_long do
			if elem_long == 0 do longueur_est_contrainte	=	false
		if longueur_est_contrainte and sequence.count > 0  do (
			for elem_long in sequence_elem_long do (
				longueur_contrainte += elem_long
				longueur_contrainte += cadre_largeur
			)
			longueur_contrainte += cadre_largeur
			longueur = longueur_contrainte
		)
		 */
	)
	
	
	
	
	fn set_points _pts =(
		points_surface = for pt in _pts collect pt
	)
	
	
	
	--------------- comopsants ----------------------------------
	fn actualiser_composants	= with redraw off (

		
	)  --- fin composants_actualiser  -----------------------------------------------------------------------
	
	fn actualiser = (
		
		corriger_parametres ()		
		actualiser_composants()		
		if roll_parametres.open do	roll_parametres.actualiser ()		
		redrawViews ()
		
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		
		if points_surface.count > 0 do (
			
			
-- 			local pts_toiture 			= 	deepcopy points_surface
			/* 
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
			) */
			
			--- on place donc les points sur Z ---------------
-- 			pts_toiture.z 		= altitude_toiture
			
			local vert_debut 	=	 getNumVerts mesh + 1
					local vert_fin 		=	getNumVerts mesh  + points_surface.count
					
					meshop.setNumVerts  mesh 	vert_fin
					
					for i = 1 to points_surface.count do (
						local i_vert = vert_debut - 1 + i
						setVert mesh 	i_vert 		points_surface[ i ]
					)
					local verts_toiture = #{vert_debut..vert_fin} as array
					meshop.createPolygon  mesh verts_toiture 	smGroup:1 	matID:matId_toiture
			
		)
		
	)  ----- fin on buld mesh -----------------
	
	
	
	
	
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
						nodeTM.translation = gridPoint
						#stop
				)
			)
	
	) --- fin tool create ---------
	
	
	on update 	do initialiser ()
	on create  	do initialiser ()
	on load  	do initialiser ()
	
) --------- fin plugin --------------

























