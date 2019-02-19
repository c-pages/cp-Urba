
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
	local corriger_parametres , 	actualiser_composants 
	local	ajouter_element_menuis, retirer_element_menuis,dupliquer_element_menuis,  instancier_element_menuis, rendreUnique_element_menuis, monter_element_menuis, descendre_element_menuis, renommer_element
	local deplacer_element
	local est_instance
	local est_fixe, est_porte, est_fenetre
	
	---- sequence provisoire pour construction du mesh -------
	local sequence_tmp
	
	---- composants ---------
	local compo_cadre, compo_meneau
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	
	parameters params_global rollout:roll_global	(
		hauteur	 					type:#worldUnits 	ui:spn_hauteur 						default:0.
		longueur 					type:#worldUnits 	ui:spn_longueur 					default:120.
		
		menuis_epaisseur		type:#worldUnits 	ui:spn_menuis_largeur				default:7.
-- 		menuis_ouvrant_ep	type:#worldUnits 	ui:spn_menuis_ouvrLargeur		default:7.
		menuis_profondeur	type:#worldUnits 	ui:spn_menuis_profondeur			default:5.
	)
	parameters params_general rollout:roll_parametres	(
		
		nom	 					type:#string 		/* 	ui:edTxt_nom		 */			default:"Ens. menuisé"
		
		sequence				type:#maxObjectTab	tabSizeVariable:true
-- 		
-- 		parent					type:#maxObject	
	)
	parameters params_divers rollout:roll_divers
	(
		
		------ options --------------
		qualite							type:#integer 			ui:rdo_qualite				default:1
		
		------ mat ID ----------
		matId_menuis				type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage				type:#integer 			ui:spn_matId_vitrage	default:2
		matId_huisserie				type:#integer 			ui:spn_matId_huisserie	default:3
		matId_mur					type:#integer 			ui:spn_matId_mur			default:4
		
	)	-----	fin parametres --------------------
	
	parameters params_hasard rollout:roll_hasard
	(
		hasard_seed					type:#integer 			ui:spn_hasard_seed		default:123456
		
		fen_proba_ouv				type:#float 			ui:spn_fen_proba_ouv		default:0.
		fen_ouvMax					type:#float 			ui:spn_fen_ouvMax			default:0.
	)
	
	
	
	rollout roll_global "Global" width:180 height:161
	(
		
		GroupBox 'grp_dimensions' "Dimensions" pos:[5,0] width:170 height:53 align:#left
		
		spinner 'spn_longueur' "" pos:[90,15] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		label 'lbl_longueur' "Longueur:" pos:[20,15] width:67 height:16 align:#left
		spinner 'spn_hauteur' "" pos:[90,30] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		label 'lbl_hauteur' "Hauteur:" pos:[20,30] width:67 height:16 align:#left
		
		GroupBox 'grp_menuiserie' "Menuiseries" pos:[5,55] width:170 height:53 align:#left
		
		
		spinner 'spn_menuis_largeur' "" pos:[90,71] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		label 'lbl_largeur' "Largeur" pos:[20,71] width:67 height:16 align:#left
-- 		spinner 'spn_menuis_ouvrLargeur' "" pos:[90,93] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
-- 		label 'lbl_ouvr_larg' "Ouvr. larg." pos:[20,93] width:67 height:16 align:#left
		spinner 'spn_menuis_profondeur' "" pos:[90,86] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		label 'lbl_menuis_profondeur' "Profondeur:" pos:[20,86] width:67 height:16 align:#left
	)
	
	
	
	rollout roll_parametres "Menuiseries" width:180 height:285
	(
		
		
		------------ TRee view -----------------------------
		local m_dragDropEffect		=	dotNetClass "System.Windows.Forms.DragDropEffects"		
		local tv_imageList 			=	dotNetObject "System.Windows.Forms.ImageList"
		
		
		--- UI ------------------------------------------------------------------------------------------------------
		button 'btn_ajouter_fixe' "Fixe" pos:[7,0] width:48 height:17 align:#left
		button 'btn_ajouter_fenetre' "Fenêtre" pos:[54,0] width:48 height:17 align:#left
		button 'btn_ajouter_porte' "Porte" pos:[101,0] width:48 height:17 align:#left
		
		dotNetControl 'tv_sequence' "treeview" pos:[7,19] width:141 height:89 align:#left
		
		button 'btn_dupliquer' "Dup" pos:[150,17] width:25 height:17 toolTip:"Dupliquer." align:#left
		button 'btn_instancier' "Inst" pos:[150,33] width:25 height:17 toolTip:"Instancier." align:#left
		button 'btn_rendreUnique' "Uni" pos:[150,49] width:25 height:17 toolTip:"Rendre unique." align:#left
		button 'btn_supprimer' "Sup" pos:[150,65] width:25 height:17 toolTip:"Supprimer." align:#left
		
		GroupBox 'grp_element' "Elément" pos:[5,115] width:170 height:108 align:#left
		
		spinner 'spn_elem_longueur' "" pos:[90,130] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		label 'lbl_elem_longueur' "Longueur:" pos:[20,130] width:67 height:19 align:#left
		spinner 'spn_elem_montants' "" pos:[90,145] width:75 height:16 range:[0,10,0] type:#integer align:#left
		label 'lbl_elem_montants' "Montants:" pos:[20,145] width:64 height:19 align:#left
		spinner 'spn_elem_traverses' "" pos:[90,160] width:75 height:16 range:[0,10,0] type:#integer align:#left
		label 'lbl_elem_traverses' "Traverses:" pos:[20,160] width:63 height:19 align:#left
		
		checkbox 'chk_double' "Double" pos:[18,175] width:69 height:16 align:#left		
		
		
		
		
		
		spinner 'spn_elem_tiercee' "" pos:[90,175] width:55 height:16 range:[0,100,0] type:#float align:#left
		label 'lbl_tierce_pourcent' "%" pos:[151,176] width:15 height:16 align:#left
		
		checkbox 'chk_invSens' "Inv. sens" pos:[18,189] width:71 height:16 align:#left
		
		checkbox 'chk_pleine' "Pleine" pos:[18,203] width:133 height:16 align:#left
		
		spinner 'spn_imposte' "" pos:[90,244] width:85 height:16 range:[0,100,0] type:#worldunits align:#left
		spinner 'spn_allege' "" pos:[90,259] width:85 height:16 range:[0,100,0] type:#worldunits align:#left
		checkbox 'chk_imposte' "Imposte:" pos:[10,243] width:76 height:16 align:#left
		checkbox 'chk_allege' "Allège:" pos:[10,257] width:60 height:16 align:#left
	
	
		---------- Treeview -----------------------------------------------------------------------------
		local id_element_enDrag	=	0
		local id_element_destination	=	0		
		local elementParent_enDrag
		local element_enDrag
		local node_enDrag
		
		local	element_select
		
		---- divers ---------------
		fn vider_tv = (
			tv_sequence.Nodes.Clear()
		)
		fn get_element		_noeud 	=(
			
			local element
			if _noeud != undefined do 
				element = sequence[_noeud.index + 1 ]
			
			element
		)
		fn initialiser_tv = (
			
			---- TRee view ----
			tv_sequence.borderstyle 			= (dotnetclass "System.Windows.Forms.BorderStyle").None
			tv_sequence.LabelEdit 				= false 
			tv_sequence.allowdrop 				= true
			tv_sequence.HideSelection 		= false
			tv_sequence.ShowRootLines	 	= false
			tv_sequence.ShowLines   			= false
			
			tv_sequence.BackColor 				= (dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
			tv_sequence.ForeColor 				= (dotNetClass "System.Drawing.Color").fromARGB 	255	255	255
			tv_sequence.LineColor 				= (dotNetClass "System.Drawing.Color").fromARGB 	255	255	255
			tv_sequence.DrawMode 				= (dotnetclass "TreeViewDrawMode.OwnerDrawText")
			
			tv_sequence.indent					= 0
			tv_sequence.Left						= 0
			
			
			
			local dossier_images = ( GetDir #userScripts ) + "\\cp-Urba\\img\\"
			tv_imageList.imageSize 	= 	dotNetObject "System.Drawing.Size" 32 32			
			tv_imageList.Images.Clear ()
			tv_imageList.Images.Add((dotnetclass "System.Drawing.Image" ).FromFile(dossier_images + "tv - fixe.png"))
			tv_imageList.Images.Add((dotnetclass "System.Drawing.Image" ).FromFile(dossier_images + "tv - fenetre.png"))
			tv_imageList.Images.Add((dotnetclass "System.Drawing.Image" ).FromFile(dossier_images + "tv - porte.png"))
			tv_sequence.ImageList =	tv_imageList

			
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
					element_enDrag 			=  	get_element		 	_arg.item
					
					tv_sequence.doDragDrop 		_arg.item 		m_dragDropEffect.Move
				)
				
			)
		)
		fn drag_recevoir 	_arg =(
			
			local posDrop		= tv_sequence.PointToClient 	tv_sequence.MousePosition
			local noeudDest 	= tv_sequence.GetNodeAt (dotNetObject "System.Drawing.Point" posDrop.x 	posDrop.y )
			
			if noeudDest != undefined then	(
				
				local element_dest 			= get_element		 	noeudDest
				deplacer_element				id_element_enDrag			( noeudDest.index + 1 )
				
			) else 
				deplacer_element				id_element_enDrag				( sequence.count +1)			
			
			elementParent_enDrag 		= undefined
			element_enDrag 				= undefined
			id_element_enDrag			=	0
			id_element_destination 		= 0
			
			node_enDrag = undefined
			
			--- on selectionne le premiere element ----
			tv_sequence.SelectedNode = 	tv_sequence.Nodes.Item[ noeudDest.index ]
			element_select 					= get_element		tv_sequence.SelectedNode 
			
			
		)
		
		
		
		
		
		fn ajouter_TV_item	_item_aAjouter	_itemParent	=(
			
			---- pour element vide ---------
			struct tv_elem_vide (
				nom ="..."
			)
		
			local nv_node 	=	_itemParent.Nodes.add 		_item_aAjouter.nom
			
-- 			if est_instance 	( nv_node.index + 1 )	do nv_node.text += " *"
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
		fn actualiser_boutons =(
			
			btn_dupliquer.enabled 		= element_select != undefined
			btn_instancier.enabled 		= element_select != undefined
			btn_supprimer.enabled 		= element_select != undefined
			btn_rendreUnique.enabled 	= element_select != undefined	and est_instance ( tv_sequence.SelectedNode.index  + 1 )
			
		)
		fn actualiser_element 			=(
			
			local ui_elem_enable		= false
			if element_select != undefined do ui_elem_enable = true
			
			lbl_elem_longueur.enabled 				= ui_elem_enable
			spn_elem_longueur.enabled 				= ui_elem_enable
			spn_elem_longueur.indeterminate		=	not ui_elem_enable
			
			lbl_elem_montants.enabled 				= ui_elem_enable
			spn_elem_montants.enabled 				= ui_elem_enable
			spn_elem_montants.indeterminate		=	not ui_elem_enable
			
			lbl_elem_traverses.enabled 				= ui_elem_enable
			spn_elem_traverses.enabled 				= ui_elem_enable
			spn_elem_traverses.indeterminate		=	not ui_elem_enable
			
			spn_elem_tiercee.enabled 					=  ui_elem_enable and	not	est_fixe element_select	and element_select.ouvrant_double
			spn_elem_tiercee.indeterminate			=	not spn_elem_tiercee.enabled 
			lbl_tierce_pourcent.enabled 				=  spn_elem_tiercee.enabled 	
			
			chk_double.enabled 	= ui_elem_enable	and not	est_fixe 		element_select
			chk_invSens.enabled 	= ui_elem_enable 	and not	est_fixe 		element_select and not element_select.ouvrant_double
			if not chk_invSens.enabled do chk_invSens.checked = false
			chk_pleine.enabled 	= ui_elem_enable	and 			est_porte 		element_select
			
			
			if element_select != undefined do (
				
				spn_elem_longueur.value = element_select.longueur
				spn_elem_montants.value = element_select.div_montants_nbr
				spn_elem_traverses.value = element_select.div_traverses_nbr
				
				if not	est_fixe 	element_select	do	chk_double.checked 		= element_select.ouvrant_double
				if not	est_fixe 	element_select	and chk_invSens.enabled do	chk_invSens.checked 	= element_select.symetrie
				if not	est_fixe 	element_select	and 	element_select.ouvrant_double do	spn_elem_tiercee.value	= element_select.ouvrant_tierce_pourcent
				if 	est_porte 			element_select	do	chk_pleine.checked 		= not	element_select.ouvrant_vitree
			)
			
			actualiser_boutons ()
			
		)
		
		
		
		fn actualiser =(
			
			---- tree view ----------
			vider_tv ()
			for i = 1 to sequence.count do 				
				ajouter_TV_item	sequence[i]		tv_sequence
			
-- 			actualiser_element 	()
			
		) --- fin actualiser -----------
		
		
		
		
		----- EVENEMENTS----------------------------------------------------------------------------------------------------
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		on roll_parametres open do
		(
			initialiser_tv ()
			actualiser ()
			
			--- on selectionne le premiere element ----
			if sequence.count> 0 do ( 
				tv_sequence.SelectedNode = 	tv_sequence.Nodes.Item[0]
				element_select 					= get_element		tv_sequence.SelectedNode 
			)
			
			actualiser_element ()
		)
		on btn_ajouter_fixe pressed do
		(
					
					local id_elem_selectBack = if element_select != undefined then	( tv_sequence.SelectedNode.index  + 1 )	else	sequence.count
					ajouter_element_menuis 	cp_menuiserie_fixe	pos:( id_elem_selectBack + 1 )
					
					----- on selectionne le bon élément de la liste ----------
					tv_sequence.SelectedNode = 	tv_sequence.Nodes.Item[ id_elem_selectBack ]
					element_select 					= get_element		tv_sequence.SelectedNode 
					actualiser_element ()
					
				)
		on btn_ajouter_fenetre pressed do
		(
					
					local id_elem_selectBack = if element_select != undefined then	( tv_sequence.SelectedNode.index  + 1 )	else	sequence.count
					ajouter_element_menuis 	cp_menuiserie_fenetre	pos:( id_elem_selectBack + 1 )
					
					----- on selectionne le bon élément de la liste ----------
					tv_sequence.SelectedNode = 	tv_sequence.Nodes.Item[ id_elem_selectBack ]
					element_select 					= get_element		tv_sequence.SelectedNode 
					actualiser_element ()
					
				)
		on btn_ajouter_porte pressed do
		(
					
					local id_elem_selectBack = if element_select != undefined then	( tv_sequence.SelectedNode.index  + 1 )	else	sequence.count
					ajouter_element_menuis 	cp_menuiserie_porte	pos:( id_elem_selectBack + 1 )
					
					----- on selectionne le bon élément de la liste ----------
					tv_sequence.SelectedNode = 	tv_sequence.Nodes.Item[ id_elem_selectBack ]
					element_select 					= get_element		tv_sequence.SelectedNode 
					actualiser_element ()
					
				)
		on tv_sequence mouseDown _arg 	do
		(
					
					local noeud_selec 		= tv_sequence.GetNodeAt (dotNetObject "System.Drawing.Point" _arg.x _arg.y )
					element_select			= get_element	noeud_selec
					
					if element_select != undefined then (
		-- 				addSubRollout 	subroll_dest		elem_selec.roll_parametres
						tv_sequence.SelectedNode 	= noeud_selec
					)else (
						tv_sequence.SelectedNode 	= undefined
						element_select 						= undefined
					)
					
					actualiser_element 	()
				)
		on tv_sequence DragOver _sender		_arg	do
			drag_checkSurvol  	_arg
		on tv_sequence DragDrop _arg 	do
			drag_recevoir 			_arg
		on tv_sequence ItemDrag _sender		_arg 	do
			drag_demarrer 		_arg
		on btn_dupliquer pressed do
		(
					local id_elem_selec = ( tv_sequence.SelectedNode.index + 1 )
					dupliquer_element_menuis 		id_elem_selec
					
					----- on selectionne le bon élément de la liste ----------
					tv_sequence.SelectedNode = 	tv_sequence.Nodes.Item[ id_elem_selec ]
					element_select 					= get_element		tv_sequence.SelectedNode 
					actualiser_element ()
				)
		on btn_instancier pressed do
		(
					local id_elem_selec = ( tv_sequence.SelectedNode.index + 1 )
					instancier_element_menuis 		id_elem_selec
					
					----- on selectionne le bon élément de la liste ----------
					tv_sequence.SelectedNode = 	tv_sequence.Nodes.Item[ id_elem_selec ]
					element_select 					= get_element		tv_sequence.SelectedNode 
					actualiser_element ()
				)
		on btn_rendreUnique pressed do
		(
					rendreUnique_element_menuis 	( tv_sequence.SelectedNode.index + 1 )
				)
		on btn_supprimer pressed do
		(
					local id_elem_selec = ( tv_sequence.SelectedNode.index + 1 )
					retirer_element_menuis 			id_elem_selec
					
					if sequence.count> 0 then  ( 
						id_elem_selec = if id_elem_selec > sequence.count then id_elem_selec - 1 else	id_elem_selec 
						
						tv_sequence.SelectedNode = 	tv_sequence.Nodes.Item[ id_elem_selec - 1 ]
						element_select 					= get_element		tv_sequence.SelectedNode 
						
					) else element_select = undefined
					actualiser_element ()
				)
		on spn_elem_longueur changed val do
		(
					
					element_select.longueur = val
					redrawViews ()
				)
		on spn_elem_montants changed val do
		(
					
					element_select.div_montants_nbr = val
					redrawViews ()
				)
		on spn_elem_traverses changed val do
		(
					element_select.div_traverses_nbr = val
					redrawViews ()
				)
		on chk_double changed state do
		(
					
					element_select.ouvrant_double = state
					actualiser_element 	()
					redrawViews ()
				)
		on spn_elem_tiercee changed val do
		(
					element_select.ouvrant_tierce_pourcent = val
					redrawViews ()
				)
		on chk_invSens changed state do
		(
					
					element_select.symetrie = state
					redrawViews ()
				)
		on chk_pleine changed state do
		(
					
					element_select.ouvrant_vitree = not	state
					redrawViews ()
				)
	)
	
	
	
	
	
	
	
	rollout roll_divers  "Divers"	(
		
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
		
		actualiser_composants()		
		if roll_parametres.open do	roll_parametres.actualiser ()		
		redrawViews ()
	)
	
	
	
	--------- divers ------------------
	fn est_porte			_compo	=	classof	_compo	==	cp_menuiserie_porte
	fn est_fenetre		_compo	=	classof	_compo	==	cp_menuiserie_fenetre
	fn est_fixe				_compo	=	classof	_compo	==	cp_menuiserie_fixe
	
	fn est_instance		_id		= (
		
		local result =false
		for i = 1 to sequence.count where i != _id do
			if sequence[i] == sequence[ _id] do result = true
		result
	)
	
	
	
	fn set_hasard	_fen_ouvMax	_fen_proba_ouv =(
		fen_ouvMax 		= _fen_ouvMax
		fen_proba_ouv 	= _fen_proba_ouv
		for elem in sequence do 
			elem.set_hasard	_fen_ouvMax	_fen_proba_ouv 
	)
	
	
	
	
	--------- accessions	-----------------------
	fn get_longueur	=	longueur
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
	
	
	
	fn ajouter_element_menuis		_element_plug	 pos:	=(
		
		local nvl_element 		= createinstance	_element_plug
		if pos == unsupplied or pos > sequence.count	then (
			append sequence		nvl_element
		) else (
			insertItem		nvl_element		sequence		pos
		)
		
		
		---- actualisations -----------
		actualiser_UI ()
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
	)
	fn renommer_element_menuis	_id	_nv_nom =(
		sequence[ _id ].nom = _nv_nom
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
	)
	fn instancier_element_menuis 	_id		=(

		
		local nvl_element 			=  sequence[ _id ]
		
		if _id != 0 and _id	!= sequence.count	then	
			insertItem nvl_element 		sequence 		(_id+1)
		else
			append sequence		nvl_element
		
		---- actualisations -----------
		actualiser_UI ()
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
			
			if not est_fixe compo_temp do compo_temp.ouvrant_cadre_larg		=	menuis_epaisseur
			
			
			compo_temp.profondeur			=	menuis_profondeur
			compo_temp.div_largeur		=	menuis_epaisseur / 2
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

