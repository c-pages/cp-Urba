

plugin simpleObject		cp_occultant_voletsBattants
name:"Volets battants"
classID:#(0xc67e155, 0x1eaca014)
category:"CP | Menuiserie	| Element | Occultant"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_occultant_voletsBattants"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	parameters params_general rollout:roll_general	
	(
		----- global ----------------
		longueur 				type:#worldUnits 	ui:spn_longueur 			default:0.
		profondeur	 			type:#worldUnits 	ui:spn_profondeur		default:3.
		hauteur	 				type:#worldUnits 	ui:spn_hauteur 			default:0.
		
		nom	 					type:#string 			default:"Volet battants"
		
	)
	
	parameters params_divers rollout:roll_divers
	(
		------ mat ID ----------
-- 		low_poly					type:#boolean 		ui:shk_lowPoly				default:false
		matId					type:#integer 			ui:spn_matId				default:1
		
		qualite					type:#integer 			ui:rdo_qualite					default:1
		ouverture_G			type:#float 			ui:spn_ouverture_G			default:180.
		ouverture_D			type:#float 			ui:spn_ouverture_D			default:180.
		
	)	-----	fin parametres --------------------
	
	rollout roll_general  "Paramètres"
	(
		spinner spn_longueur 			"longueur" 			type:#worldunits range:[0,1e20,0]
		spinner spn_hauteur 			"Hauteur" 				type:#worldunits range:[0,1e20,0]
		spinner spn_profondeur 		"Profondeur" 			type:#worldunits range:[0,1e20,0]
		
	)
	rollout roll_divers  "Divers" (
		/*
		group "Qualité" (
			checkbox	shk_lowPoly		"Low poly"
		) 
		*/
		group "Qualité" (
			radioButtons rdo_qualite 		"" labels:#("Full", "Medium", "Low poly") align:#left
		)
		group "Material ID" (
			spinner spn_matId			 	"Menuiseries" 			type:#integer range:[1,1000,1]
		)
		
		
		spinner spn_ouverture_G			 	"Ouverture G." 			type:#float range:[0.,180.,0.]
		spinner spn_ouverture_D			 	"Ouverture D." 			type:#float range:[0.,180.,0.]
		
	) ---- fin rollout	----------
	
	
	

	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		
		--- Construction ---------------------------------------------------------------------------------------		
		
		local ecart = 2.
		
		local compo_volet_G
		local compo_volet_D
		compo_volet_G	=	 createInstance  cp_prim_boite				matId:		matId			\
																							longueur:	( longueur /2 - ecart )		\
																							hauteur:		( hauteur	-	ecart ) \
																							profondeur:	profondeur
		
		compo_volet_D	=	 createInstance  cp_prim_boite				matId:		matId			\
																							longueur:	( longueur /2 - ecart )		\
																							hauteur:		( hauteur	-	ecart ) 		\
																							profondeur:	profondeur
		
		local transf_volet_G		=	transMatrix	[ ecart / 2	,0, ecart / 2  ] * rotateZMatrix -ouverture_G 
		local transf_volet_D		=	transMatrix	[ - longueur / 2 + ecart / 2	,0, ecart / 2 ] * rotateZMatrix ouverture_D * transMatrix	[ longueur  	,0, 0]	--transMatrix	[ longueur /2  +  ecart *3 / 2 	,0,0]	--	rotateZMatrix ouverture 	* transMatrix	[ longueur /2  + ecart / 2	,0,0]
		
		
		
		mgr_mesh.attacher		mesh		compo_volet_G	transf:transf_volet_G
		mgr_mesh.attacher		mesh		compo_volet_D 	transf:transf_volet_D
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box		tm:(scaleMatrix [2,2,2]	)
		
		
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
				1: (	pt_debut 	=  gridPoint
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
					
					pt_hauteur	=	gridPoint
				)
				3:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
				)
			)		
	) --- fin tool create ---------
	
	
	
	
)	------- fin plugin ------------------------------------










