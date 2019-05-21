

plugin simpleObject		cp_menuisElem_chassisVitre
name:"Chassis vitre"
classID:#(0x7bb20e92, 0x37f7c1e7)
category:"CP | Menuiserie	| Element"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_menuisElem_chassisVitre"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	
	--- Prédéfinitions ------------------
	local corriger_parametres
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	----- les composants -----------	
	local compo_cadre, compo_vitrage
	
	
	parameters params_general rollout:roll_general	
	(
		----- global ----------------
		longueur 						type:#worldUnits 	ui:spn_longueur 				default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur			default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 				default:0.
		
		----- cadre -------------
		cadre_use						type:#boolean 		ui:shk_cadre					default:true
		cadre_largeur	 				type:#worldUnits 	ui:spn_cadre_largeur		default:0.
		
		montant_G				type:#boolean 		ui:shk_montant_G		default:true
		montant_D				type:#boolean 		ui:shk_montant_D		default:true
		travBasse					type:#boolean 		ui:shk_traverse_B		default:true
		travBasse_hauteur		type:#worldUnits 	ui:spn_travBasse_ht		default:0.
		
		----- vitrage -------------
		vitrage_epaisseur				type:#worldUnits 	ui:spn_vitrage_ep			default:2.
		div_montants_nbr		 	type:#integer		 	ui:spn_div_montants_nbr	default:0
		div_traverses_nbr			type:#integer		 	ui:spn_div_traverses_nbr	default:0
		div_calage_verti	 			type:#worldUnits	 	ui:spn_div_calage_verti		default:0.
		div_largeur	 					type:#worldUnits 	ui:spn_div_largeur			default:4.
		div_profondeur	 			type:#worldUnits 	ui:spn_div_profondeur		default:4.
		
	)
	
	parameters params_divers rollout:roll_divers
	(
		------ options --------------
		qualite							type:#integer 			ui:rdo_qualite				default:1
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
	)	-----	fin parametres --------------------
	
	
	rollout roll_general  "Paramètres"
	(
		spinner	 	spn_longueur 			"Longueur" 					type:#worldunits range:[0,1e20,0]
		spinner 	spn_profondeur 		"Profondeur" 				type:#worldunits range:[0,1e20,0]
		spinner 	spn_hauteur 			"Hauteur" 					type:#worldunits range:[0,1e20,0]
		
		group "Cadre" (
			checkbox	shk_cadre				"Cadre"
			spinner 	spn_cadre_largeur	 "Largeur" 				type:#worldunits range:[0,1e20,0]
			checkbox	shk_montant_G		"Montant gauche" 			
			checkbox	shk_montant_D		"Montant droit" 		
			checkbox	shk_traverse_B		"traverse basse" 	
			spinner 	spn_travBasse_ht	"Hauteur" 				type:#worldunits range:[0,1e20,0]
		)	
		group "Vitrage" (
			spinner 	spn_vitrage_ep		"Epaisseur" 				type:#worldunits 	range:[0,1e20,0]
		)
		group "Croisillons" (
			spinner 	spn_div_montants_nbr	 "Nbr. montants" 	type:#integer			range:[0,1e20,0]
			spinner		spn_div_traverses_nbr	 "Nbr. traverses" 	type:#integer			range:[0,1e20,0]
			spinner 	spn_div_largeur			"Largeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_div_profondeur		"Profondeur" 		type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_div_calage_verti 	"Calage vertical" 	type:#worldunits		range:[-1e20,1e20,0]
		)
	)
	rollout roll_divers  "Divers"
	(
		group "Qualité" (
			radioButtons rdo_qualite 		"" labels:#("Full", "Medium", "Low poly") align:#left
		)
		group "Material ID" (
			spinner 	spn_matId_menuis 	"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner 	spn_matId_vitrage 	"Vitrage" 				type:#integer range:[1,1000,1]
		)
	) ---- fin rollout	----------
	

	
	--------------- ENVENEMENTS  ----------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		
		--- vider le mesh --------
		delete mesh
		
		----Données ------------	
		local posY_remplis
		local posY_div
		if qualite != 3 then (
			posY_remplis		=	- vitrage_epaisseur/2
			posY_div			=	- ( div_profondeur/2 )		
		) else	(
			posY_remplis		=	.01
			posY_div			=	0
		)
		
		local longueur_passage 	=	if cadre_use 	then longueur - 2* cadre_largeur 	else 	longueur
		local hauteur_passage		= 	if cadre_use 	then hauteur - ( cadre_largeur + travBasse_hauteur)		else 	hauteur
		
		
		local espace_div_H 		= ( longueur_passage - div_montants_nbr * div_largeur ) / ( div_montants_nbr + 1 )
		local depose_div_H		= [ espace_div_H, 	posY_div,		0	]
		
		local espace_div_V 		= ( hauteur_passage - div_traverses_nbr * div_largeur ) / ( div_traverses_nbr + 1 )
		local depose_div_V		= [0, 	posY_div,		 espace_div_V  + div_calage_verti	]
		
		
		local callage_G 	= 	if cadre_use 	then cadre_largeur else 0
		local callage_B 	= 	if cadre_use 	then travBasse_hauteur else 0
		local callage_Y	=	if qualite != 3 then profondeur/2	 else 0
		
		depose_div_V		+=	[	callage_G	,	callage_Y,	callage_B	]
		depose_div_H		+= 	[ callage_G, 	callage_Y,		callage_B	]
		
		
		
		---- le cadre ----
		if cadre_use do (
			
			local compo_cadre
			case qualite	of (
				1:	compo_cadre	=	 createInstance  cp_prim_boite				matId:matId_menuis
				2:	compo_cadre	=	 createInstance  cp_prim_boiteL				matId:matId_menuis
				3:	compo_cadre	=	 createInstance  cp_prim_planVertical		matId:matId_menuis
			)
			
			
			
			--- montant  gauche ----------
			if montant_G do (
				compo_cadre.longueur			=	cadre_largeur
				compo_cadre.hauteur			=	hauteur
				if qualite != 3 do	
					compo_cadre.profondeur		=	profondeur
				
				mgr_mesh.attacher		mesh		compo_cadre
				
			)
			
			--- montant droite ----------
			if montant_D do (
				compo_cadre.longueur			=	cadre_largeur
				compo_cadre.hauteur			=	hauteur
				if qualite != 3 do	(
					compo_cadre.profondeur		=	profondeur
					compo_cadre.symetrie			=	true
				)
				mgr_mesh.attacher		mesh		compo_cadre 	transf:[longueur - cadre_largeur,0,0]				
			)
			
			--- traverse basse ----------
			if travBasse do (			
				compo_cadre.longueur			=	longueur_passage
				compo_cadre.hauteur			=	travBasse_hauteur
				if qualite != 3 do	(
					compo_cadre.profondeur		=	profondeur
					compo_cadre.symetrie			=	false
					compo_cadre.horizontal		=	true
				)
				mgr_mesh.attacher		mesh		compo_cadre 	transf:[callage_G,0,0]				
			)
			
			--- traverse	haute ----------
			compo_cadre.longueur			=	longueur_passage
			compo_cadre.hauteur				=	cadre_largeur
			if qualite != 3 do	 (
				compo_cadre.profondeur	=	profondeur
				compo_cadre.symetrie		=	true
				compo_cadre.horizontal		=	true
			)
			
			mgr_mesh.attacher		mesh		compo_cadre 	transf:[callage_G,0,hauteur - cadre_largeur]
			
			
			--- les cotés du cadre en qualite medium, pour quand on ouvre la fenetre ...  ---------
			if qualite == 2 do (
				local plan_vertical = createInstance	cp_prim_planVertical		longueur:profondeur	hauteur:hauteur
				mgr_mesh.attacher		mesh		plan_vertical		transf:( rotateZMAtrix	90  * transMatrix [longueur, 0,0] )
				mgr_mesh.attacher		mesh		plan_vertical		transf:( rotateZMAtrix	-90 * transMatrix [0, profondeur,0]  )
			)
			
		) ------- fin cadre ------------------
		
		
		
		
		
		
		
		
		
		
		
		---- le vitrage ----
		local compo_vitrage
		case qualite	of (
			1:			compo_vitrage	=	 createInstance  cp_prim_boite				matId:matId_vitrage
			default:	compo_vitrage	=	 createInstance  cp_prim_planVertical		matId:matId_vitrage
		)
		
		compo_vitrage.longueur		=	longueur_passage
		compo_vitrage.hauteur		=	hauteur_passage
		if qualite == 1 	then compo_vitrage.profondeur		=	vitrage_epaisseur	
		
		mgr_mesh.attacher		mesh		compo_vitrage 	transf:[callage_G,callage_Y,callage_B]
		
		
		
		
		
		
		-------- divisions  --------------
		local compo_div
		case qualite	of (
			1:	compo_div	=	 createInstance  cp_prim_boite				matId:matId_menuis
			2:	compo_div	=	 createInstance  cp_prim_boiteU				matId:matId_menuis
			3:	compo_div	=	 createInstance  cp_prim_planVertical		matId:matId_menuis
		)
		
		
		
		-------- divisions horizontales --------------
		for i = 1 to div_montants_nbr do (
			
			compo_div.longueur			=	div_largeur
			compo_div.hauteur			=	hauteur_passage
			if qualite != 3 do	(
				compo_div.profondeur		=	div_profondeur
				compo_div.symetrie			=	false
				compo_div.horizontal		=	false
			)
			
			mgr_mesh.attacher		mesh		compo_div 	transf:depose_div_H
			
			depose_div_H.x += espace_div_H + div_largeur
		)
		
		-------- divisions verticales --------------
		for i = 1 to div_traverses_nbr do (
			
			compo_div.longueur			=	longueur_passage
			compo_div.hauteur			=	div_largeur
			if qualite != 3 do	(
				compo_div.profondeur		=	div_profondeur
				compo_div.symetrie			=	false
				compo_div.horizontal		=	true
			)
			
			mgr_mesh.attacher		mesh		compo_div 	transf:depose_div_V
			
			depose_div_V.z += espace_div_V + div_largeur
		)
		
		
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
				5: #stop
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
				5: (
					cadre_largeur 			= length ( gridPoint - pt_epaisseur )
					travBasse_hauteur	=	cadre_largeur
					
					---- init de quelques valeurs pour y voir quelque chose -------
					vitrage_epaisseur		=	2
					div_largeur				=	2
					div_profondeur		=	4
				)
			)		
	) --- fin tool create ---------
	
	
)	------- fin plugin ------------------------------------





