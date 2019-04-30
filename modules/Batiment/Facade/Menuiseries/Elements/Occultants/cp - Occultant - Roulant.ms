

plugin simpleObject		cp_occultant_voletsRoulants
name:"Volets roulants"
classID:#(0xc67e155, 0x501193e7)
category:"CP | Menuiserie	| Element | Occultant"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_occultant_voletRoulant"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	parameters params_general rollout:roll_general	
	(
		----- global ----------------
		longueur 				type:#worldUnits 	/* ui:spn_longueur  	*/		default:0.
		profondeur	 		type:#worldUnits 		/* ui:spn_profondeur	*/		default:0.
		hauteur	 				type:#worldUnits 	/* ui:spn_hauteur  	*/		default:0.
		
		nom	 					type:#string 			default:"Volet roulant"
		
		position_coffre			type:#integer 		ui:rdBtn_coffre				default:1
		position_enroulement	type:#integer 		ui:rdBtn_enroulement	default:1
	)
	
	parameters params_divers rollout:roll_divers
	(
		------ mat ID ----------
-- 		low_poly					type:#boolean 		ui:shk_lowPoly				default:false
		matId					type:#integer 			ui:spn_matId				default:1
		qualite					type:#integer 			ui:rdo_qualite				default:1
		
	)	-----	fin parametres --------------------
	
	rollout roll_general  "Paramètres"
	(
		
		group "Coffre" (
			radioButtons rdBtn_coffre		""	columns:1 	labels:#("Sous linteau", "En façade", "Integré" )
-- 			spinner spn_longueur 			"longueur" 			type:#worldunits range:[0,1e20,0]
-- 			spinner spn_hauteur 			"Hauteur" 				type:#worldunits range:[0,1e20,0]
-- 			spinner spn_profondeur 		"Profondeur" 			type:#worldunits range:[0,1e20,0]
		)
		group "Enroulement" (
			radioButtons rdBtn_enroulement		""	columns:1 	labels:#("Intérieur", "Extérieur" )
		)
	)
	rollout roll_divers  "Divers" (
		/* group "Qualité" (
			checkbox	shk_lowPoly		"Low poly"
		) */
		group "Qualité" (
			radioButtons rdo_qualite 		"" 	columns:1 labels:#("Full", "Medium", "Low poly") align:#left
		)
		group "Material ID" (
			spinner spn_matId			 	"Menuiseries" 			type:#integer range:[1,1000,1]
		)
		
	) ---- fin rollout	----------
	
	
	

	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		--- Construction ---------------------------------------------------------------------------------------
		--- le coffre ----
		local compo_coffre
		case qualite	of (
			1:	compo_coffre	=	 createInstance  cp_prim_boite				matId:matId
			2:	compo_coffre	=	 createInstance  cp_prim_boiteU				matId:matId
			3:	compo_coffre	=	 createInstance  cp_prim_boiteL				matId:matId
		)
		compo_coffre.longueur		=	longueur
		compo_coffre.hauteur			=	hauteur
		compo_coffre.profondeur	=	profondeur
		
		mgr_mesh.attacher		mesh		compo_coffre
		
		
		
		
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box		tm:(scaleMatrix [2,2,2]	)
		
		
	)  ----- fin on build mesh -----------------
	
	
	
	
	
	------------ TOOLS	-----------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		local pt_epaisseur
		
		on mousePoint click do
			case click of
			(
				1: (	pt_debut 	=  gridPoint
						nodeTM.translation = pt_debut
				)
				4: #stop
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
					
					pt_profondeur	=	gridPoint
				)
				3:	(
					profondeur 				= 	length ( gridPoint - pt_profondeur )
					pt_hauteur				=	gridPoint
				)
				4:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
				)
			)		
	) --- fin tool create ---------
	
	
	
	
)	------- fin plugin ------------------------------------










