NOTES APPLI SHINY SITE PCS

---- 10 avril 2019 ----

1. Architecture globale :
	- on entre par une liste de thématiques
	- on sélectionne la variable d'intérêt
	- on sélectionne le niveau pertinent de la PCS
	- on sélectionne le champ : ensemble de la population ayant déjà travaillé ; ensemble des actifs ; actifs occupés ; chômeurs et inactifs.
	- on choisit le type de sortie : graphique ou tableau (% ou effectifs). Si variable numérique, graphique = facet histogramme et tableaux = min, max, moy, med, q1, q3 par niveau de la PCS et au total. Si variable catégorielle, graphique = barplot et tableau = table de contingence.
	- on peut exporter le résultat : graphique en format .pdf ou .png et tableau en format .xlsx

Rq concernant les thématiques et les variables variables disponibles : il faudra se caler sur les thématiques et variables mises à disposition dans la rubrique "Décrire", et veiller à ce que ce soit Insee-compatible.

2. Veuillez toujours à ce que la mise en forme des tableaux et des graphiques présente toujours : 
	- source
	- champ
	- une mention générique "Généré en ligne sur le site dédié à la PCS : http://pcs.progedo.fr/..."

3. Concernant les graphiques :
	- les libellés des axes doivent être explicites (effectifs, %, intitulé de la variable en langue "naturelle")
	- une légende sans titre doit toujours être présentée pour les barplots afin de préciser le code couleurs
	- on doit pouvoir choisir un graphique en effectifs ou en %

4. Concernant les tableaux
	- proposer par défaut trois tableaux : effectifs, % ligne et % colonne
	- ajouter une note sous les tableaux avec les résultats d'un test de chi2 : "$\Chi^2$ = ... ; ddl = ; p < ..."

5. A propos du bac à sable que l'on présentera pour le rapport :
	- données = EEC 2013 fichier FPR (à actualiser si besoin avec la dernière livraison disponible sur Quetelet ; ou bien prendre la dernière version disponible sur le site de l'Insee : https://www.insee.fr/fr/statistiques/3555153)
	- entrée thématique : 
		- Indicateurs socio-démographiques : variables d'intérêt : âge (numérique et catégoriel en décennies), sexe
		- Emploi : variables d'intérêt : niveau de qualification (diplôme le plus élevé obtenu), statut dans l'emploi
	- la PCS est disponible à trois niveaux d'agrégation : GS, CS intermédiaire et CS. 
	- proposer deux possibilités de résultats au niveau CS pour les ouvriers et les cadres et prof. intel sup. 

