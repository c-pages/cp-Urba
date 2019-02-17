
plugin simpleObject		cp_menuiserie_ensemble
name:"Ensemble menuisé"
classID:#(0x88033db, 0x50dbc2e7)
category:"CP | Menuiserie"
-- invisible:true
(
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_menuiserie_ensemble"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local corriger_parametres , 	actualiser_composants , ouvrir_roll_sequence
	local	ajouter_element_menuis, retirer_element_menuis,dupliquer_element_menuis,  instancier_element_menuis, rendreUnique_element_menuis, monter_element_menuis, descendre_element_menuis, renommer_element
	local deplacer_element
	local est_instance
	
	
	---- sequence provisoire pour construction du mesh -------
	local sequence_tmp
	
	---- composants ---------
	local compo_cadre, compo_meneau
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	
	parameters params_global rollout:roll_global	(
		hauteur	 				type:#worldUnits 	ui:spn_hauteur 				default:0.
	)
	parameters params_general rollout:roll_parametres	(
		
		nom	 					type:#string 		/* 	ui:edTxt_nom		 */			default:"Ens. menuisé"
		
		longueur 				type:#worldUnits 	ui:spn_longueur 				default:120.
		
		menuis_epaisseur		type:#worldUnits 	ui:spn_menuis_largeur			default:5.
		menuis_profondeur	type:#worldUnits 	ui:spn_menuis_profondeur		default:7.
		
		
		sequence				type:#maxObjectTab	tabSizeVariable:true
		
		parent					type:#maxObject	
	)
	parameters params_divers rollout:roll_divers
	(
		
		------ options --------------
-- 		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		qualite							type:#integer 			ui:rdo_qualite				default:1
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_huisserie				type:#integer 			ui:spn_matId_huisserie	default:3
		matId_mur						type:#integer 			ui:spn_matId_mur		default:4
		
	)	-----	fin parametres --------------------
	
	parameters params_hasard rollout:roll_hasard
	(
		hasard_seed					type:#integer 			ui:spn_hasard_seed		default:123456
		
		fen_proba_ouv				type:#float 			ui:spn_fen_proba_ouv		default:0.
		fen_ouvMax					type:#float 			ui:spn_fen_ouvMax			default:0.
	)
	
	
	
	rollout roll_global  "Global"	(
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
	)
	rollout roll_parametres  "Ensemble menuisé"	(		
		
		--- UI ------------------------------------------------------------------------------------------------------
		
		
		group "Dimensions" (
			spinner 	spn_longueur 			"Longueur" 			type:#worldunits 	range:[0,1e20,0]
			
-- 			spinner 	spn_profondeur		"Profondeur" 		type:#worldunits 	range:[0,1e20,0]
-- 			spinner 	spn_allege_hauteur 	"Allège" 		type:#worldunits 	range:[0,1e20,0]
		)
		group "Menuiserie" (
			spinner 	spn_menuis_largeur 			"Largeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_menuis_profondeur 	"Profondeur" 		type:#worldunits 	range:[0,1e20,0]
-- 			button		btn_editer_sequence		"Editer séquence"	width:110 height:25
		)
		
		
		------------ TRee view -----------------------------
		local m_dragDropEffect		=	dotNetClass "System.Windows.Forms.DragDropEffects"		
		local tv_imageList 			=	dotNetObject "System.Windows.Forms.ImageList"
		
		
-- 		group "Séquence" (
			------------------- UI -------------------------
			button 		btn_ajouter_fixe 				"Fixe"				width:50		height:17	across:3		align:#left
			button 		btn_ajouter_fenetre 		"Fenêtre"		width:50		height:17	align:#left
			button 		btn_ajouter_porte 			"Porte"			width:50		height:17	align:#left
			
			
			
			dotNetControl tv_sequence	 "treeview" /* width:145 */ height:120 --align:#left
			
			
			button 		btn_dupliquer	 		"Dup."			width:27	height:17				align:#left	across:4
			button 		btn_instancier	 		"Ins."			width:27			height:17			align:#left
			button 		btn_rendreUnique	 	"Uni."			width:27			height:17			align:#left
			button 		btn_retirer	 		"Sup."				width:27		height:17			align:#left
			
			
			subrollout	subroll_param		""	height:200
			
			dotNetControl btn_resize 	"System.Windows.Forms.Button" 		align:#left /* width:150 */ height:10
-- 		)
		
		
		---------- Treeview -----------------------------------------------------------------------------
		local id_element_enDrag	=	0
		local id_element_destination	=	0		
		local elementParent_enDrag
		local element_enDrag
		local node_enDrag
		
		fn vider_tv = (
			tv_sequence.Nodes.Clear()
		)
		fn get_element		_noeud 	=(
			
			local element
			if _noeud != undefined do 
				element = sequence[_noeud.index + 1 ]
			
			element
		)
		------- drag and drop -------------------------
		fn drag_checkSurvol	 _arg = (
			
			_arg.Effect=_arg.AllowedEffect			
			
			local posDrag		= tv_sequence.PointToClient 	tv_sequence.MousePosition
			local itemSurvol	= tv_sequence.GetNodeAt (dotNetObject "System.Drawing.Point" posDrag.x 	posDrag.y)
			
			
			if itemSurvol != undefined then	
				tv_sequence.SelectedNode = itemSurvol
			else 
				tv_sequence.SelectedNode = undefined
			
			
			
		)
		fn drag_demarrer 	_arg =(
			
			if _arg.item != undefined do (
				
				if _arg.item.tag	!=		"vide" do (
				
					
					node_enDrag				=		_arg.item
					id_element_enDrag		=		_arg.item.Index	+	1
-- 					elementParent_enDrag	= 		get_element_parent		_arg.item
					element_enDrag 			=  	get_element		 	_arg.item
					
					tv_sequence.doDragDrop 		_arg.item 		m_dragDropEffect.Move
				)
				
			)
		)
		fn drag_recevoir 	_arg =(
			
			local posDrop		= tv_sequence.PointToClient 	tv_sequence.MousePosition
			local noeudDest 	= tv_sequence.GetNodeAt (dotNetObject "System.Drawing.Point" posDrop.x 	posDrop.y )
			
			if noeudDest != undefined then	(
				
				
-- 				local elementParent_dest 		= get_element_parent	noeudDest
				local element_dest 				= get_element		 	noeudDest
				
				
-- 				if valider_drop	noeudDest do 
					deplacer_element				id_element_enDrag			( noeudDest.index + 1 )
				
				
			) else 
				deplacer_element				id_element_enDrag				( sequence.count +1)			
			
			
			elementParent_enDrag 		= undefined
			element_enDrag 				= undefined
			id_element_enDrag			=	0
			id_element_destination 		= 0
			
			node_enDrag = undefined
			
		)
		fn ajouter_TV_item	_item_aAjouter	_itemParent	=(
			
			---- pour element vide ---------
			struct tv_elem_vide (
				nom ="..."
			)
		
			local nv_node 	=	_itemParent.Nodes.add 		_item_aAjouter.nom
			
			if est_instance 	( nv_node.index + 1 )	do nv_node.text += " *"
			
			case classof _item_aAjouter of (
				cp_menuiserie_fixe:			nv_node.imageIndex = nv_node.selectedImageIndex	=	0
				cp_menuiserie_fenetre:		nv_node.imageIndex = nv_node.selectedImageIndex	=	1
				cp_menuiserie_porte:		nv_node.imageIndex = nv_node.selectedImageIndex	=	2
				
				default:	nv_node.imageIndex = nv_node.selectedImageIndex	=	0
			)
			
			
			if hasProperty	_item_aAjouter	"elements" do (
				if _item_aAjouter.elements.count == 0 then (
						local elem_vide = ajouter_TV_item	(tv_elem_vide () )	nv_node
						elem_vide.tag	="vide"
				) else (
					for elem in _item_aAjouter.elements	do (
						local elem_enfant = ajouter_TV_item	elem	nv_node
						
					)
				)
			)
			
			nv_node.expand ()
			nv_node
		)
		
		
		----- UI	divers ----------------------------------------------------------------------------------------------------
		fn actualiser =(
			

			--- les parametres de l'element (le subrollout)  ---------------			
			--- on retire les vieux rollouts --------
			if subroll_param.rollouts.count > 0 do 
				for subRoll in subroll_param.rollouts  do
					removeSubRollout subroll_param	subRoll
				
			---- tree view ----------
			vider_tv ()
			for i = 1 to sequence.count do 				
				ajouter_TV_item	sequence[i]		tv_sequence
			
			
		) --- fin actualiser -----------
		fn initialiser_tv = (
			
			---- TRee view ----
			tv_sequence.borderstyle 			= (dotnetclass "System.Windows.Forms.BorderStyle").None
			tv_sequence.LabelEdit 				= false 
			tv_sequence.allowdrop 				= true
			tv_sequence.HideSelection 		= false
			tv_sequence.ShowRootLines	 	= false
			tv_sequence.ShowLines   			= false
-- 			tv_sequence.HotTracking   		= true
			tv_sequence.BackColor 			= (dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
			tv_sequence.ForeColor 				= (dotNetClass "System.Drawing.Color").fromARGB 	255	255	255
			tv_sequence.LineColor 				= (dotNetClass "System.Drawing.Color").fromARGB 	255	255	255
			tv_sequence.DrawMode 			= (dotnetclass "TreeViewDrawMode.OwnerDrawText")
			
			tv_sequence.indent				= 0
			tv_sequence.Left				= 0
			
			
			
			local dossier_images = ( GetDir #userScripts ) + "\\cp-Urba\\img\\"
			tv_imageList.imageSize 	= 	dotNetObject "System.Drawing.Size" 32 32			
			tv_imageList.Images.Clear ()
			tv_imageList.Images.Add((dotnetclass "System.Drawing.Image" ).FromFile(dossier_images + "tv - fixe.png"))
			tv_imageList.Images.Add((dotnetclass "System.Drawing.Image" ).FromFile(dossier_images + "tv - fenetre.png"))
			tv_imageList.Images.Add((dotnetclass "System.Drawing.Image" ).FromFile(dossier_images + "tv - porte.png"))
			tv_sequence.ImageList =	tv_imageList

			
		)
		
		
		
		
		
		----- Gestion du resize du subRollout -----------------------
		local resize_enCours 			= false
		local pos_initial					=	[0,0]
		local subRoll_hauteur_init		=	0
		local btnResize_pos_init		=	[0,0]
		local roll_parametres_hauteur_init	=	[0,0]
		
		fn resize_surbRoll =(
			if resize_enCours do (
				local mouse_pos 			= mouse.posUnscaled
				local changement_ht 	= mouse_pos.y - pos_initial.y
				local subRoll_nvl_ht 	= subRoll_hauteur_init 		+ 	changement_ht
				
				if subRoll_nvl_ht >	50 do (
					subroll_param.height		=	subRoll_nvl_ht
					btn_resize.pos.y			=	btnResize_pos_init.y		+	changement_ht
					roll_parametres.height		=	roll_parametres_hauteur_init 	+ 	changement_ht
				)
			)
		)
		------------ le bouton resize -----------------------
		on	btn_resize	MouseDown 	do (
			resize_enCours 				= true
			pos_initial						=	mouse.posUnscaled
			subRoll_hauteur_init			= subroll_param.height
			btnResize_pos_init			=	btn_resize.pos
			roll_parametres_hauteur_init	=	roll_parametres.height
		)
		on	btn_resize	MouseUp 		do	resize_enCours = false		
		on	btn_resize	MouseMove 	do 	resize_surbRoll ()
		on	btn_resize	MouseLeave 	do	resize_enCours = false		
		
		
		
		
		
		
		
		on roll_parametres	open do (
			
			---- le bouton resize -----------------------
			btn_resize.FlatStyle	=		(dotNetClass "System.Windows.Forms.FlatStyle").flat	
			btn_resize.BackColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
			btn_resize.ForeColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
		
			
			initialiser_tv ()
			actualiser ()
			
		)
		
		
		
		-------- la sequence -----------
		
		on lbx_sequence 		selected sel 	do	actualiser ()
		/* 
		on lbx_sequence	 rightClick 	_id 	do	(
			lbx_sequence.selection = _id
			actualiser ()
			creer_RCM_edition ()
		)
		 */
-- 		on btn_ajouter 		pressed 			do 	creer_RCM_ajouter ()
		on btn_ajouter_fixe 			pressed 			do 	ajouter_element_menuis 	cp_menuiserie_fixe
		on btn_ajouter_fenetre 	pressed 			do 	ajouter_element_menuis 	cp_menuiserie_fenetre
		on btn_ajouter_porte 		pressed 			do 	ajouter_element_menuis 	cp_menuiserie_porte
		
		on btn_dupliquer 			pressed 			do	dupliquer_element_menuis 			( tv_sequence.SelectedNode.index + 1 )
		on btn_instancier 		pressed 			do	instancier_element_menuis 		( tv_sequence.SelectedNode.index + 1 )
		on btn_rendreUnique	pressed 			do	rendreUnique_element_menuis 	( tv_sequence.SelectedNode.index + 1 )
		on btn_retirer 			pressed 			do	retirer_element_menuis 			( tv_sequence.SelectedNode.index + 1 )
-- 		on btn_monter 			pressed 			do	monter_element_menuis 			lbx_sequence.selection 
-- 		on btn_descendre 		pressed		 	do	descendre_element_menuis 		lbx_sequence.selection 
		
		
		--------- le treeView ---------
		on tv_sequence 	mouseDown 				_arg 	do  	(
-- 			clq_down  				_arg
			local noeud_selec 	= tv_sequence.GetNodeAt (dotNetObject "System.Drawing.Point" _arg.x _arg.y )
			local elem_selec 		= get_element	noeud_selec
			
			local subroll_dest	 = subroll_param	--	roll_parametres_element.subroll_param
			if subroll_dest.rollouts.count > 0 do 
				for subRoll in subroll_dest.rollouts  do
					removeSubRollout subroll_dest	subRoll
				
			if elem_selec != undefined then 
				addSubRollout 	subroll_dest		elem_selec.roll_parametres
			else
				tv_sequence.SelectedNode = undefined
		)
-- 		on tv_sequence 	mouseUp 	_sender 		_arg 	do 	clq_up 					_arg
		on tv_sequence 	DragOver 	_sender		_arg	do	drag_checkSurvol  	_arg
		on tv_sequence 	DragDrop 					_arg 	do	drag_recevoir 			_arg
			
		on tv_sequence 	ItemDrag 	_sender		_arg 	do	drag_demarrer 		_arg

-- 		on btn_editer_sequence pressed do ouvrir_roll_sequence ()
		
		
	)
	
	
	
	
	
	
	
	rollout roll_divers  "Divers"	(
		/*  group "Qualité" (
			checkbox	shk_lowPoly			"Low poly" 		
		)  */
		group "Qualité" (
			radioButtons rdo_qualite 			"" labels:#("Full", "Medium", "Low poly") align:#left
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
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------

	
	
	fn actualiser_UI = (
		corriger_parametres ()		
		actualiser_composants()		
		if roll_parametres.open do	roll_parametres.actualiser ()		
		redrawViews ()
	)
	
	
	
	--------- divers ------------------
	fn est_porte		_compo	=	classof	_compo	==	cp_menuiserie_porte
	fn est_fenetre		_compo	=	classof	_compo	==	cp_menuiserie_fenetre
	fn est_ouvrable	_compo	=	est_fenetre		_compo	or est_porte		_compo	
	
	fn est_fixe			_compo	=	classof	_compo	==	cp_menuiserie_fixe
	fn est_copiable				=	 roll_sequence.lbx_sequence.selection != 0
	fn est_instance	_id		= (
-- 		if id == unsupplied do id = roll_sequence.lbx_sequence.selection
		local result =false
		for i = 1 to sequence.count where i != _id do
			if sequence[i] == sequence[ _id] do result = true
		result
	)
	
	
	fn get_longueur	=	longueur
		
	fn set_hasard	_fen_ouvMax	_fen_proba_ouv =(
		fen_ouvMax 		= _fen_ouvMax
		fen_proba_ouv 	= _fen_proba_ouv
		for elem in sequence do 
			elem.set_hasard	_fen_ouvMax	_fen_proba_ouv 
	)
	
	
	
	
	
	fn get_longueur_composant =(
		local longueur_passage 			= longueur 	- 2*menuis_epaisseur
		local nbr_meneaux					= sequence.count - 1		
		local longueur_total_meneaux	=	( sequence.count - 1 )* menuis_epaisseur
		local longueur_definies_total 		= 0
		local nbr_elem_definies 			= 0
		for i = 1 to sequence.count do (
			if sequence[i].longueur != 0 do (
				longueur_definies_total+= sequence[i].longueur
				nbr_elem_definies += 1
			)
		)		
		local longueur_composant	= ( longueur_passage - ( longueur_total_meneaux + longueur_definies_total ) ) / ( sequence.count - nbr_elem_definies )
		
		longueur_composant
	)
	
	
	
	
	
	fn ouvrir_roll_sequence = (
		
		createDialog roll_sequence	width:180	
	)

	
	
	--------------- sequence ----------------------------------
	
	
	fn deplacer_element				_id_aDeplacer				_id_destination		=(
		
		local elem_aDeplacer
		
		----- on retire l'element à deplacer de son origine -------------
		elem_aDeplacer	=	 	sequence		[_id_aDeplacer]
		deleteItem 	sequence 			_id_aDeplacer
		
		
		
		
		----- on le pose à sa destination -------------
			
			if _id_destination > sequence.count then 
				append sequence	 elem_aDeplacer
			else
				insertItem 	elem_aDeplacer			sequence  			_id_destination  
		
		
		
		---- actualisations -----------
		actualiser_UI ()
	
	)
	
	
	
	fn ajouter_element_menuis		_element_plug	 =(
		
-- 		local	id_elem_select 	= 	roll_sequence.lbx_sequence.selection
-- 		local	id_elem_insert		= 	id_elem_select + 1
		
		local nvl_element 		= createinstance	_element_plug
		
-- 		if id_elem_select != 0 and id_elem_select	!= sequence.count	then	
-- 			insertItem nvl_element 		sequence 		id_elem_insert
-- 		 else 		
			append sequence		nvl_element
		
		
		---- actualisations -----------
		actualiser_UI ()
		/* 
		if roll_parametres.open do	(
-- 			roll_sequence.lbx_sequence.selection = id_elem_insert 
			roll_parametres.actualiser ()	
		) */
		
	)
	fn retirer_element_menuis		_id	 	=(
		
		deleteItem sequence 				_id
		
		---- actualisations -----------
		actualiser_UI ()
	)
	fn monter_element_menuis 		_id 		=(
		
		local elem_temp 		= sequence[ _id ]
		deleteItem 	sequence 				_id
		insertItem 	elem_temp			sequence  					(	_id - 1 )
		
		---- actualisations -----------
		actualiser_UI ()
		
		if roll_sequence.open do	(
-- 			roll_sequence.lbx_sequence.selection -=  1
			roll_sequence.actualiser ()	
		)
	)
	fn	descendre_element_menuis 	_id 		=(
		
		local elem_temp 		= sequence[ _id ]
		deleteItem 	sequence 				_id
		if _id == sequence.count then 
			append sequence 				elem_temp
		else 
			insertItem 	elem_temp		sequence  					(	_id + 1 )		
		
		---- actualisations -----------
		actualiser_UI ()
		
		if roll_sequence.open do	(
-- 			roll_sequence.lbx_sequence.selection +=  1
			roll_sequence.actualiser ()	
		)
	)
	fn renommer_element_menuis	_id	_nv_nom =(
		sequence[ _id ].nom = _nv_nom
		if roll_sequence.open do	roll_sequence.actualiser ()
	)
	
	
	
	--------- edition sequence ---------------
	fn dupliquer_element_menuis _id		=(
		
		
		local nvl_element 			= copy sequence[ _id ]
		
		if _id != 0 and _id	!= sequence.count	then	
			insertItem nvl_element 		sequence 		(_id+1)
		else
			append sequence		nvl_element
		
		---- actualisations -----------
		actualiser_UI ()
		
		if roll_sequence.open do	(
-- 			roll_sequence.lbx_sequence.selection = (_id+1) 
			roll_sequence.actualiser ()	
		)
	)
	fn instancier_element_menuis 	_id		=(

		
		local nvl_element 			=  sequence[ _id ]
		
		if _id != 0 and _id	!= sequence.count	then	
			insertItem nvl_element 		sequence 		(_id+1)
		else
			append sequence		nvl_element
		
		---- actualisations -----------
		actualiser_UI ()
		
		if roll_sequence.open do	(
-- 			roll_sequence.lbx_sequence.selection = (_id+1) 
			roll_sequence.actualiser ()	
		)
	)	
	fn rendreUnique_element_menuis	 _id		=(
		
		sequence[ _id ] = copy sequence[ _id ] 
		
		---- actualisations -----------
		actualiser_UI ()
	)
	
	
	
	
	
	
	
	----------- Actualisation de la sequence		-----------------------------------
	fn actualiser_composants	= with redraw off (
		
		---- creation des composants ------------------
		if compo_cadre 		== undefined	do	compo_cadre		= 	createInstance  cp_menuisElem_cadre
		if compo_meneau		== undefined	do	compo_meneau	= 	createInstance  cp_menuisElem_meneau
		
		----- maj du cadre ----------------------
		compo_cadre.longueur 						= longueur
		compo_cadre.hauteur 						= hauteur	
		compo_cadre.profondeur 					= menuis_profondeur
		compo_cadre.menuis_epaisseur	 		= menuis_epaisseur	
-- 		compo_cadre.low_poly			 			= low_poly		
		compo_cadre.qualite			 				= qualite		
		compo_cadre.matId_menuis	 			= matId_menuis
		compo_cadre.travBasse					=	false
		
		----- Meneaux  ----------------------
		compo_meneau.longueur 					= menuis_epaisseur
		compo_meneau.profondeur 				= menuis_profondeur
		compo_meneau.hauteur 					= hauteur	-  menuis_epaisseur
-- 		compo_meneau.low_poly			 		= low_poly		
		compo_meneau.qualite			 			= qualite		
		
		
		
		--- maj des composants de la sequence -------------
		local longueur_composant	= get_longueur_composant ()
		sequence_tmp 				= #()
		for i = 1 to sequence.count do (
			
			local compo_temp 				= 	copy sequence[i]
	
			if compo_temp.longueur == 0 then		compo_temp.longueur 	= 		longueur_composant
			
			if est_porte 	compo_temp 	then		compo_temp.hauteur	=		hauteur - menuis_epaisseur
													else		compo_temp.hauteur	=		hauteur - 2*menuis_epaisseur
			
			compo_temp.profondeur		=	menuis_profondeur
-- 			compo_temp.low_poly			=	low_poly
			compo_temp.qualite			 	= qualite		
			compo_temp.set_hasard		fen_ouvMax	fen_proba_ouv
			compo_temp.cadre 				= false
			
			append sequence_tmp		compo_temp
		)
		
		
		
		--- Si notre sequence est vide
		if sequence.count == 0 do (
			local compo_temp = createInstance cp_menuiserie_fixe
			
			append	sequence_tmp  	compo_temp
			
			compo_temp.hauteur			=	hauteur 	- 2*menuis_epaisseur
			compo_temp.profondeur		=	menuis_profondeur
-- 			compo_temp.low_poly			=	low_poly
			compo_temp.qualite				=	qualite
			compo_temp.longueur			=	longueur 		- 2*menuis_epaisseur
		)
		
	)  --- fin actualiser_composants  ------------------
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		
		---- maj des composants -----
		actualiser_composants ()
		
		
		--- vider le mesh --------
		delete mesh
		
		--- Construction ---------------------------------------------------------------------------------------

		---- le cadre  -------
		mgr_mesh.attacher		mesh		compo_cadre 	--	transf:[0, profondeur  , 0 ]
		
		---- la sequence	-----
		local compo_travBas		= 	if qualite ==3	then	createInstance  cp_prim_boiteL  horizontal:true	else createInstance 	cp_prim_boite
		local depos_composant 	= [ menuis_epaisseur, 0  , 0 ]
		
		for i = 1 to	sequence_tmp.count do (
			
			---- le composant -----
			local composant 		= sequence_tmp [i]
			local calage_z			= if est_porte		composant		then 	0 else  menuis_epaisseur			
			local depose_temp 	= if  not est_fixe 	composant 	then  	depos_composant  	+ [0, 	0,		calage_z ]
																					else		depos_composant 	+ [0,		0,		menuis_epaisseur ]
			
			
			mgr_mesh.attacher		mesh		composant	transf:depose_temp
			
			
			
			---- la traverse du bas ------------
			if not est_porte 	composant 	do (
				compo_travBas.hauteur 		= 	menuis_epaisseur
				compo_travBas.profondeur		=	menuis_profondeur
				compo_travBas.longueur		=	composant.longueur
				mgr_mesh.attacher		mesh		compo_travBas	transf:depos_composant
			)
				
			
			depos_composant.x += composant.longueur
			
			--- le meneau- ----
			if i != sequence_tmp.count do (				
				mgr_mesh.attacher		mesh		compo_meneau	transf:depos_composant
				depos_composant.x += compo_meneau.longueur
			)
		)
		
		
		
		
		
	)  ----- fin on buld mesh -----------------
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
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
					longueur 				= length ( gridPoint - pt_debut )
					local norm_dir 		=	normalize (gridPoint - pt_debut )
					local angle_pts		=	acos(dot  [1,0,0]  norm_dir)		
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
					pt_profondeur	=	gridPoint
				)
				3:	(
					profondeur 				= length ( gridPoint - pt_profondeur )
					pt_hauteur				=	gridPoint
				)
				4:	hauteur 					= length ( gridPoint - pt_hauteur )
			)
	) --- fin tool create ---------
	
	
) ------- fin plugin ---------------------


