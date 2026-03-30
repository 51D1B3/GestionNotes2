# Architecture du Projet UniNotes

Ce document décrit le rôle des fichiers principaux et les fonctionnalités clés de l'application.

## 🚀 Fonctionnalités Majeures

- **Indépendance Réseau** : L'application fonctionne sans WiFi grâce à la persistance locale Firestore. Les données se synchronisent automatiquement dès le retour d'une connexion.
- **Saisie Flexible** : Deux modes d'ajout de matières (Calcul Automatique via 3 notes ou Saisie Manuelle directe).
- **Persistance des Réglages** : Le thème (sombre/clair), la taille de la police et la langue sont conservés après la fermeture de l'application via `SharedPreferences`.
- **Export Système** : Les relevés PDF sont générés avec le logo et sauvegardés directement dans le dossier "Download" public du téléphone.

## 📂 Structure des Fichiers (`lib/`)

### `main.dart`
- Initialise Firebase, `easy_localization` et la persistance Firestore.
- Configure le thème global et applique dynamiquement la taille de la police sur tout le système.
- Gère le démarrage rapide via `AuthWrapper` (connexion anonyme avec timeout).

### `screens/`
- **`onboarding_screen.dart`** : Introduction motivationnelle au premier lancement.
- **`pin_screen.dart`** : Écran de verrouillage par code PIN avec design épuré.
- **`home_screen.dart`** : Liste des semestres avec traduction dynamique des noms.
- **`subject_screen.dart`** : Tableau moderne des matières. Gère les modes Auto/Manuel et l'export PDF. Fermeture instantanée des fenêtres pour fluidité hors-ligne.
- **`settings_screen.dart`** : Gestion des préférences avec marques de sélection (coche) pour la langue et la police.
- **`statistics_screen.dart`** : Graphiques de progression limités à l'échelle des mentions (0 à 4).
- **`about_screen.dart`** : Présentation détaillée du développeur avec photo et contact.

### `services/`
- **`firestore_service.dart`** : Logique CRUD optimisée pour le mode hors-ligne.
- **`theme_provider.dart`** : Gestionnaire d'état pour le thème, la langue et la police avec sauvegarde automatique.
- **`pdf_service.dart`** : Génération de PDF professionnel ciblant le dossier public `/Download`.
- **`history_service.dart`** : Gestion de l'historique local des fichiers téléchargés.
- **`university_setup_service.dart`** : Initialisation automatique des facultés (FST, FLSH, FSAG).

### `widgets/`
- **`app_drawer.dart`** : Menu de navigation avec logo circulaire et bouton Quitter.
- **`custom_page_route.dart`** : Transitions de pages ultra-rapides (fondu de 200ms).

## 🎨 Ressources (`assets/`)
- **`applogo.png`** : Identité visuelle de l'application (utilisée pour l'icône et le PDF).
- **`developpeur.jpg`** : Photo officielle pour la page À propos.
- **`translations/`** : Fichiers `fr.json` et `en.json` pour le support multilingue.
