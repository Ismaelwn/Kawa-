# Projet Kawa - Implémentation d'un Langage de Programmation ☕

## Description 🎯

Le projet **Kawa** vise à développer un **interprète** pour un langage de programmation orienté objet simplifié, inspiré de **Java**. Ce langage pédagogique permet aux utilisateurs d'apprendre les bases de la programmation orientée objet avec des fonctionnalités comme :
- **Déclaration de variables**
- **Définition de classes et de méthodes**
- **Blocs d'instructions**
- **Gestion des types et structures**

## Installation et Exécution 🚀

1. **Cloner le dépôt** :
   ```bash
   git clone https://github.com/Ismaelwn/Kawa.git
   ```
2. **Exécuter les tests** :
   ```bash
   python3 run.py
   ```
   - Seuls les fichiers `.kwa` sont pris en compte.
   - Vous pouvez exécuter les tests autant de fois que nécessaire.

## Extensions Ajoutées 🔧

Nous avons intégré plusieurs fonctionnalités supplémentaires pour améliorer l’interprète :

### 1️⃣ Déclarations en Série 📝
- Permet la déclaration de plusieurs variables sur une seule ligne.
- Implémentation simple et rapide.

### 2️⃣ Test d’Égalité Structurelle 🔍
- Vérifie si deux objets ou structures ont le **même contenu** et la **même organisation interne**.
- Implémentation plus complexe avec un risque accru d’erreurs.

### 3️⃣ `Instance Of` ⚙️
- Vérifie dynamiquement **si un objet appartient à une classe ou sous-classe spécifique**.
- Utile pour la gestion avancée des types.

### 4️⃣ `Did You Mean` 🛠️
- Détecte les **fautes de frappe** dans les noms de fonctions et propose des corrections.
- Implémentation délicate pour éviter les ralentissements de l’interprète.

## Difficultés Rencontrées 🤯

### 🔴 Algorithme `Did You Mean`
- Détection efficace des erreurs sans ralentir l’interprète.
- Gestion des cas ambigus et des erreurs multiples.

### 🔴 Visibilité des Variables et Méthodes 🔐
- **Public, Private, Protected** : Fonctionnaient partiellement mais ont été retirés pour des raisons de cohérence.
- Difficulté à gérer **la portée de `static`**.

### 🔴 Simplification du Langage 🏗️
- **Déclaration simplifiée des variables** ✅
- **Simplification des méthodes** ❌ (conflits avec certains fichiers de test).

## Conclusion ✅

Ce projet nous a permis de :
- Développer un **interprète fonctionnel et interactif**.
- Approfondir nos connaissances sur les **mécanismes internes des langages de programmation**.
- Intégrer des fonctionnalités avancées pour **améliorer l'expérience utilisateur**.

Les futures améliorations pourraient inclure :
- **Optimisation de l’analyse syntaxique**.
- **Réintégration des extensions de visibilité**.
- **Support amélioré des erreurs et suggestions intelligentes**.

## Contributions 🤝

Les contributions sont les bienvenues !

1. **Forker le dépôt** 📌
2. **Créer une branche** (`git checkout -b feature/NouvelleAmélioration`)
3. **Committer vos changements** (`git commit -m "Ajout d'une nouvelle extension"`)
4. **Pousser votre branche** (`git push origin feature/NouvelleAmélioration`)
5. **Créer une Pull Request** 📬



