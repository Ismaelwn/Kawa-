
Almahdi Mohamed , Wane Ismael

Rapport du Projet Kawa :

 consigne : 
 Pour lancer tous nos tests, veuiller ecrire dans le terminal python3 run.py.
 Vous pouvez lancer les tests autant de fois que vous le souhaitez, le fichier python ne prend en compte que les .kwa et non les Zone.identifier

 But du Projet :

Le projet Kawa consiste à développer un interprète pour un langage de programmation orienté objet simplifié, inspiré de Java. 
Ce langage pédagogique permet d’apprendre les bases des langages orientés objet avec des fonctionnalités comme les classes, les méthodes,
 la déclaration de variables, et les blocs d’instructions.


**Extensions Ajoutées**

Nous avons intégré plusieurs extensions au cours du projet

 Voici un résumé de leurs fonctionnalités : 
1 :Déclarations en Série
Permet de déclarer plusieurs variables sur une seule ligne pour rendre le code plus concis.
Pas très compliqué à implenter, nous n'avons pas perdu beaucoup de temps dessus.

2: Test d’Égalité Structurelle
Compare deux objets ou structures en vérifiant leur contenu et leur organisation interne.
Pas compliqué à implenter, juste plus long à implementer et beaucoup plus de risques d'erreur.

3:Instance Of
Vérifie dynamiquement si un objet appartient à une classe ou sous-classe spécifique, utile pour la gestion des types.

4:Did You Mean
Détecte les fautes de frappe dans les commandes ou instructions et propose des suggestions( on l'a implementé pour les fonctions).



Difficultés Rencontrées
On a eu quelque difficultes comme par exemple , avec  Did You Mean : 

Trouver un algorithme performant pour détecter et corriger les erreurs sans ralentir l’interprète.
Des tests pertinent  pour gérer les cas ambigus ou les erreurs multiples.


. #### **Conclusion** 

Ce projet a permis de développer un interprète fonctionnel et interactif, 
tout en approfondissant nos connaissances sur les mécanismes internes des langages de programmation. 
Les extensions  ajoutées améliorent l’expérience utilisateur .