etages_nbre=1
etages_hauteur_global=306.8
dalle_epaisseur=20.0
soubassement_hauteur=100.0
etages_spe_min=#()
etages_spe_max=#()
etages_spe_hauteur=#()
optim_aplanir=true
optim_souder=true
optim_orthonormer=true
optim_aligner=false
optim_projeter=false
optim_aplanir_seuil=20.0
optim_souder_seuil=30.0
optim_ortho_seuil=100.0
optim_aligner_seuil=50.0
facades=maxObjs#(

		itemClasse=	CP_BATIMENTELEM_FACADE
		longueur=0.0
		profondeur=10.0
		hauteur=0.0
		repartition=1
		repart_repetitions=3
		repart_decalage=0.0
		repart_espacement=0.0
		sequence=maxObjs#(

				itemClasse=	CP_FACADEELEM_MUR
				hauteur=0.0
				profondeur=0.0
				nom="Mur"
				longueur=20.0
				debord=0.0
				parent=undefined
				qualite=1
				matID=4
				FINitemClasse----------------------------------------------

			
				itemClasse=	CP_FACADEELEM_BAIE
				hauteur=250.0
				menuis_epaisseur=7.0
				menuis_profondeur=5.0
				longueur=150.0
				baie_hauteur=-12.4
				profondeur=18.1
				allege_hauteur=0.0
				tablette=true
				menuiserie_objet:itemClasse=	CP_MENUISERIE_ENSEMBLE
				
					hauteur=0.0
					longueur=120.0
					menuis_epaisseur=7.0
					menuis_profondeur=5.0
					nom="Ens. menuisé"
					sequence=maxObjs#(

							itemClasse=	CP_MENUISERIE_PORTE
							hauteur=0.0
							menuis_profondeur=5.0
							cadre=true
							menuis_epaisseur=5.0
							travBasse=false
							longueur=90.0
							vitrage_epaisseur=1.0
							ouvrant_travBasse_ht=10.0
							div_profondeur=3.0
							ouvrant_double=false
							ouvrant_tierce_pourcent=50.0
							ouvrant_vitree=true
							ouvrant_cadre_larg=7.0
							ouvrant_cadre_travB_ht=12.0
							div_largeur=2.0
							div_montants_nbr=0
							div_montants_nbr_2=0
							div_traverses_nbr=0
							div_calage_verti=0.0
							symetrie=true
							ouvert_angle_1=0.0
							ouvert_angle_2=0.0
							poignee_1_use=true
							poignee_2_use=true
							poignee_hauteur=90.0
							poignee_align_x=1.0
							nom="Porte"
							qualite=1
							matId_menuis=1
							matId_vitrage=2
							matId_poignee=3
							hasard_seed=123456
							fen_proba_ouv=0.0
							fen_ouvMax=0.0
							FINitemClasse----------------------------------------------


							itemClasse=	CP_MENUISERIE_FIXE
							hauteur=0.0
							menuis_profondeur=5.0
							cadre=true
							menuis_epaisseur=5.0
							longueur=0.0
							vitrage_epaisseur=1.0
							div_profondeur=3.0
							div_largeur=2.0
							div_montants_nbr=0
							div_traverses_nbr=0
							div_calage_verti=0.0
							nom="Fixe"
							qualite=1
							matId_menuis=1
							matId_vitrage=2
							FINitemClasse----------------------------------------------

					)
					allege_use=false
					allege_hauteur=100.0
					alleges_use=#(false, false)
					alleges_hauteur=#(100.0, 100.0)
					qualite=1
					matId_menuis=1
					matId_vitrage=2
					matId_huisserie=3
					matId_mur=4
					hasard_seed=123456
					fen_proba_ouv=0.0
					fen_ouvMax=0.0
					FINitemClasse----------------------------------------------


				imposte_use=true
				imposte_hauteur=216.2
				imposte_montants=0
				imposte_traverses=0
				imposte_arc_use=false
				imposte_arc_rayon=250.0
				imposte_objet:itemClasse=	CP_MENUISERIE_FIXE

						hauteur=0.0
						menuis_profondeur=5.0
						cadre=true
						menuis_epaisseur=5.0
						longueur=0.0
						vitrage_epaisseur=1.0
						div_profondeur=3.0
						div_largeur=2.0
						div_montants_nbr=0
						div_traverses_nbr=0
						div_calage_verti=0.0
						nom="Fixe"
						qualite=1
						matId_menuis=1
						matId_vitrage=2
						FINitemClasse----------------------------------------------
				
				
				nom="Baie"
				qualite=1
				matId_menuis=1
				matId_vitrage=2
				matId_poignee=3
				matId_mur=4
				hasard_seed=123456
				fen_proba_ouv=0.0
				fen_ouvMax=0.0
				FINitemClasse----------------------------------------------
		
		
		)
		nom="Facade"
		qualite=1
		matId_menuis=1
		matId_vitrage=2
		matId_huisserie=3
		matId_mur=4
		etages_min_use=false
		etages_min=0
		etages_max_use=true
		etages_max=0
		longueur_min_use=false
		longueur_min=0
		longueur_max_use=false
		longueur_max=0
		mur_nord=false
		mur_sud=false
		mur_est=false
		mur_ouest=false
		murs=1
		hasard_seed=123456
		fen_proba_ouv=0.0
		fen_ouvMax=0.0
		FINitemClasse----------------------------------------------
		
		
		
		
		
		itemClasse=	CP_BATIMENTELEM_FACADE
		longueur=0.0
		profondeur=10.0
		hauteur=0.0
		repartition=1
		repart_repetitions=1
		repart_decalage=0.0
		repart_espacement=0.0
		sequence=maxObjs#(
		
		
				itemClasse=	CP_FACADEELEM_BAIE
				hauteur=250.0
				menuis_epaisseur=7.0
				menuis_profondeur=5.0
				longueur=269.8
				baie_hauteur=-50.0
				profondeur=15.0
				allege_hauteur=100.0
				tablette=true
				menuiserie_objet:itemClasse=	CP_MENUISERIE_ENSEMBLE
						hauteur=0.0
						longueur=120.0
						menuis_epaisseur=7.0
						menuis_profondeur=5.0
						nom="Ens. menuisé"
						sequence=maxObjs#(

								itemClasse=	CP_MENUISERIE_FIXE
								hauteur=0.0
								menuis_profondeur=5.0
								cadre=true
								menuis_epaisseur=5.0
								longueur=52.4
								vitrage_epaisseur=1.0
								div_profondeur=3.0
								div_largeur=2.0
								div_montants_nbr=0
								div_traverses_nbr=0
								div_calage_verti=0.0
								nom="Fixe"
								qualite=1
								matId_menuis=1
								matId_vitrage=2
								FINitemClasse----------------------------------------------


								itemClasse=	CP_MENUISERIE_FENETRE
								hauteur=0.0
								menuis_profondeur=5.0
								cadre=true
								menuis_epaisseur=5.0
								longueur=0.0
								vitrage_epaisseur=1.0
								ouvrant_profondeur=4.0
								ouvrant_callage=1.5
								ouvrant_cadre_larg=4.0
								div_profondeur=3.0
								ouvrant_double=true
								ouvrant_tierce_pourcent=50.0
								div_largeur=2.0
								div_montants_nbr=0
								div_montants_nbr_2=0
								div_traverses_nbr=0
								div_calage_verti=0.0
								symetrie=false
								ouvert_angle_1=0.0
								ouvert_angle_2=0.0
								nom="Fenêtre"
								qualite=1
								matId_menuis=1
								matId_vitrage=2
								hasard_seed=123456
								fen_proba_ouv=0.0
								fen_ouvMax=0.0
								FINitemClasse----------------------------------------------
						)
						allege_use=false
						allege_hauteur=100.0
						alleges_use=#(false, false)
						alleges_hauteur=#(100.0, 100.0)
						qualite=1
						matId_menuis=1
						matId_vitrage=2
						matId_huisserie=3
						matId_mur=4
						hasard_seed=123456
						fen_proba_ouv=0.0
						fen_ouvMax=0.0
						FINitemClasse----------------------------------------------


				imposte_use=false
				imposte_hauteur=210.0
				imposte_montants=0
				imposte_traverses=0
				imposte_arc_use=false
				imposte_arc_rayon=250.0
				imposte_objet:itemClasse=	CP_MENUISERIE_FIXE
						hauteur=0.0
						menuis_profondeur=5.0
						cadre=true
						menuis_epaisseur=5.0
						longueur=0.0
						vitrage_epaisseur=1.0
						div_profondeur=3.0
						div_largeur=2.0
						div_montants_nbr=0
						div_traverses_nbr=0
						div_calage_verti=0.0
						nom="Fixe"
						qualite=1
						matId_menuis=1
						matId_vitrage=2
						FINitemClasse----------------------------------------------
				nom="Baie"
				qualite=1
				matId_menuis=1
				matId_vitrage=2
				matId_poignee=3
				matId_mur=4
				hasard_seed=123456
				fen_proba_ouv=0.0
				fen_ouvMax=0.0
				FINitemClasse----------------------------------------------
		)
		
		
		
		
		nom="Facade"
		qualite=1
		matId_menuis=1
		matId_vitrage=2
		matId_huisserie=3
		matId_mur=4
		etages_min_use=true
		etages_min=1
		etages_max_use=false
		etages_max=0
		longueur_min_use=false
		longueur_min=0
		longueur_max_use=false
		longueur_max=0
		mur_nord=false
		mur_sud=false
		mur_est=false
		mur_ouest=false
		murs=1
		hasard_seed=123456
		fen_proba_ouv=0.0
		fen_ouvMax=0.0
		FINitemClasse----------------------------------------------
)
editeur_facade_ouvert=false
qualite_courante=1
qualite_viewport=1
qualite_render=1
matId_menuis=1
matId_vitrage=2
matId_huisserie=3
matId_mur=4
hasard_seed=123457
fen_proba_ouv=66.9
fen_ouvMax=50.0
toiture_type=5
toiture:itemClasse=	CP_BATIMENTELEM_TOITURE_NPANS

		points_surface=#()
		pente=20.0
		decallage=30.0
		debord_use=true
		debord_longueur=30.0
		debord_hauteur=20.0
		nom="Toiture n pans"
		qualite=1
		matId_toiture=5
		matId_corniche=4
		FINitemClasse----------------------------------------------
























