
	rollout roll_facades "Facades" width:180 height:435
	(
		
		button 'btn_ajouter' "Nouv." pos:[3,3] width:45 height:19 across:4 align:#left
		button 'btn_retirer' "Supp." pos:[91,3] width:45 height:19 align:#left
		button 'btn_dupliquer' "Dupl." pos:[47,3] width:45 height:19 across:4 align:#left
		button 'btn_monter' "/\\" pos:[135,3] width:19 height:19 align:#left
		button 'btn_descendre' "\\/" pos:[153,3] width:19 height:19 align:#left
		listbox 'lbx_facades' "" pos:[3,22] width:170 height:5 align:#left
		edittext 'edTxt_nom' "" pos:[-1,94] width:174 height:17 align:#left
		
		
		label 'lbl_etages' "Etages:" pos:[15,128] width:55 height:16 align:#left
		label 'lbl6' "Façades:" pos:[14,221] width:78 height:16 align:#left
		spinner 'spn_etages_min' "" pos:[31,141] width:50 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
		label 'lbl9' ">" pos:[85,142] width:12 height:15 align:#left
		checkbutton 'chk_etages_min' "" pos:[16,141] width:16 height:16 align:#left
		spinner 'spn_etages_max' "" pos:[110,141] width:50 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
		checkbutton 'chk_etages_max' "" pos:[95,141] width:16 height:16 align:#left
		label 'lbl28' "Longueurs:" pos:[15,159] width:55 height:16 align:#left
		spinner 'spn_longueur_min' "" pos:[31,172] width:50 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		label 'lbl29' ">" pos:[85,173] width:12 height:15 align:#left
		checkbutton 'chk_longueur_min' "" pos:[16,172] width:16 height:16 align:#left
		spinner 'spn_longueur_max' "" pos:[110,172] width:50 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		checkbutton 'chk_longueur_max' "" pos:[95,172] width:16 height:16 align:#left
		checkbutton 'ckb_mur_nord' "N." pos:[15,202] width:38 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." across:4 align:#left
		checkbutton 'ckb_mur_sud' "S." pos:[52,202] width:38 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left
		checkbutton 'ckb_mur_est' "E." pos:[89,202] width:38 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left
		checkbutton 'ckb_mur_ouest' "O." pos:[125,202] width:38 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left
		dropdownList 'ddl_murs' "" pos:[15,234] width:150 height:21 items:#("Tous", "Pignons", "Gouttereaux") align:#left
		label 'lbl5' "Orientation:" pos:[15,189] width:78 height:14 align:#left
		GroupBox 'grp1' "Contraintes" pos:[3,114] width:170 height:146 align:#left
		
		
		
		GroupBox 'grp_repart' "Répartition" pos:[3,263] width:170 height:91 align:#left
		dropdownList 'ddl_repartition' "" pos:[12,278] width:154 height:21 items:#("Répartir", "Centrer", "Aligner à gauche", "Aligner à droite", "Espacer") align:#left
		
			
		label 'lbl_decalage' "Décallage:" pos:[19,301] width:55 height:19 align:#left
		spinner 'spn_decalage' "" pos:[89,301] width:75 height:16 range:[-1e+20,1e+20,0] type:#worldunits align:#left
		label 'lbl_repetitions' "Répétitions:" pos:[19,316] width:60 height:19 align:#left
		spinner 'spn_repetitions' "" pos:[89,316] width:75 height:16 range:[0,1e+20,0] type:#integer align:#left
		label 'lbl_espacement' "Espacement:" pos:[19,331] width:69 height:19 align:#left
		spinner 'spn_espacement' "" pos:[89,331] width:75 height:16 range:[0,1e+20,0] type:#worldunits align:#left
		
	)
createDialog	roll_facades
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
