

plugin simpleObject		cp_menuiserie_fixe
name:"Fixe"
classID:#(0x17beccdd, 0x1eb11699)
category:"CP | Menuiserie"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_menuiserie_fixe"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pr� d�claration -----------
	local corriger_parametres 
	
	--- composant ---
	local compo_vitrage
	local compo_cadre
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	
	parameters params_global rollout:roll_global	(
		hauteur	 				type:#worldUnits 	ui:spn_hauteur 			default:0.
		menuis_profondeur	 			type:#worldUnits 	ui:spn_profondeur		default:5.
		
		cadre						type:#boolean 		ui:shk_cadre				default:true
		menuis_epaisseur		type:#worldUnits 	ui:spn_cadre_ep			default:5.
	)
	parameters params_general rollout:roll_parametres	(
		
		longueur 				type:#worldUnits 	ui:spn_longueur 			default:0.
		
		----- les menuiseries 	-----------------------
		vitrage_epaisseur				type:#worldUnits 	default:1.
		
		----- Divisions		 ---------------------
		div_profondeur	 			type:#worldUnits 	default:3.
		div_largeur	 					type:#worldUnits 	ui:spn_div_largeur			default:2.
		div_montants_nbr		 	type:#integer		 	ui:spn_div_montants_nbr	default:0.
		div_traverses_nbr			type:#integer		 	ui:spn_div_traverses_nbr	default:0.
		div_calage_verti	 			type:#worldUnits	 	ui:spn_div_calage_verti		default:0.
		
	)	-----	fin parametres --------------------
	parameters params_divers rollout:roll_divers	(
		
		
		nom	 							type:#string 			default:"Fixe"
		
		------ options --------------
		qualite							type:#integer 			ui:rdo_qualite				default:1
		
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
		est_ouvrable					type:#boolean 					default:false
		
	)	-----	fin parametres --------------------
	
	
	
	
	
	rollout roll_global  "Global"	(
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_profondeur 		"menuis_profondeur" 			type:#worldunits 	range:[0,1e20,0]
		group "cadre" (
			checkbox	shk_cadre				"Cadre"
			spinner 	spn_cadre_ep 			"Epaisseur" 			type:#worldunits 	range:[0,1e20,0]
		)
		
	)
	rollout roll_parametres  "Fixe"	(
		spinner 	spn_longueur 			"Longueur" 				type:#worldunits 	range:[0,1e20,0]
		group "Divisions" (	
			spinner		spn_div_largeur			 "Largeur" 		type:#worldunits		range:[0,1e20,0]
			spinner 	spn_div_montants_nbr	 "Montants" 	type:#integer			range:[0,1e20,0]
			spinner		spn_div_traverses_nbr	 "Traverses" 	type:#integer			range:[0,1e20,0]
			spinner 	spn_div_calage_verti 	"Align. vert." 	type:#worldunits		range:[-1e20,1e20,0]
		)
	)
	rollout roll_divers  "Divers"	(
		
		group "Qualit�" (
			radioButtons rdo_qualite 			"" labels:#("Full", "Medium", "Low poly") align:#left
		)
		group "Material ID" (
			spinner spn_matId_menuis 		"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 		"Vitrage" 				type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	

	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn	est_ouvrant 	= false
	fn get_longueur	=	longueur
	fn set_hasard	_fen_ouvMax	_fen_proba_ouv =()
	
		fn actualiser_composants	= with redraw off (
		
		if compo_vitrage 	== undefined					do	compo_vitrage		= createInstance  	cp_menuisElem_panneau
		if cadre and compo_cadre 	== undefined	do	compo_cadre		= createInstance  	cp_menuisElem_cadre
		
		-----	le vitrage 	-------------
		compo_vitrage.longueur						=	if cadre then longueur - menuis_epaisseur*2 else longueur
		compo_vitrage.hauteur							=	if cadre then hauteur  - menuis_epaisseur*2 else hauteur
		
		compo_vitrage.vitrage_epaisseur	 		= vitrage_epaisseur
		compo_vitrage.div_montants_nbr 			= div_montants_nbr
		compo_vitrage.div_traverses_nbr 			= div_traverses_nbr
		compo_vitrage.div_largeur				 		= div_largeur
		compo_vitrage.div_profondeur			 	= menuis_profondeur	--	div_profondeur		
		compo_vitrage.div_calage_verti		 		= div_calage_verti		
		
-- 		compo_vitrage.low_poly			 			= low_poly		
		compo_vitrage.qualite			 				= qualite		
		compo_vitrage.matId_menuis	 				= matId_menuis
		compo_vitrage.matId_vitrage	 				= matId_vitrage
		
		
		-----	le cadre 	-------------
		if cadre do	(
			compo_cadre.longueur						=	longueur
			compo_cadre.hauteur						=	hauteur
			compo_cadre.profondeur					=	menuis_profondeur
			compo_cadre.menuis_epaisseur			=	menuis_epaisseur
			compo_cadre.travBasse					=	true
			compo_cadre.travBasse_hauteur			=	menuis_epaisseur
			
			compo_cadre.qualite			 				= qualite		
			compo_cadre.matId_menuis	 			= matId_menuis
		)
		
		
	)  --- fin actualiser_composants  ------------------

	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		--- le vitrage --------		
		local calage_X = if cadre 			then menuis_epaisseur else 0
		local calage_Y = if qualite != 3	then menuis_profondeur / 2 else 0
		local calage_Z = if cadre 			then menuis_epaisseur else 0
		mgr_mesh.attacher		mesh		compo_vitrage 	transf:[calage_X, calage_Y , calage_Z ]
		
		
		---- le cadre -------
		if cadre do	
			mgr_mesh.attacher		mesh		compo_cadre	-- 	transf:[calage_X, calage_Y , calage_Z ]
		
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
						pt_debut 		=  gridPoint
						nodeTM.translation = pt_debut
				)
				3: #stop
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
				3:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
				)
					
			)		
	) --- fin tool create ---------
	
	/* 
	on load  		do format "LOAD FIXE\n"
	on create 		do format "CREATE FIXE\n"
	on update 	do format "UPDATE FIXE\n"
	 */
) ------- fin plugin ---------------------


