# Validation de la base v2

## Vérifié dans l'environnement de génération

- 132 fichiers Dart présents ;
- 24 modules sous `lib/features/` ;
- aucun import Dart relatif ne pointe vers un fichier absent ;
- les 38 écrans du prototype restent représentés dans les parcours existants ;
- les 5 destinations principales restent `Accueil / Créer / Calendrier / Statistiques / Profil` ;
- les dépendances fournies par le projet sont conservées dans `pubspec.yaml` ;
- le prototype HTML de référence est conservé sous `docs/prototype_reference/` ;
- les nouveaux modules future-ready disposent de routes et/ou squelettes sans casser les anciens parcours.

## À exécuter sur la machine Flutter

L'environnement de génération ne possède pas le SDK Flutter. Lancer :

```bash
flutter pub get
flutter analyze
flutter test
```

Sous Windows, `scripts/prepare_platforms.ps1` peut également générer les dossiers Android/iOS/Web manquants et lancer ces vérifications.

## Principe de validation pour la suite

À chaque module réellement implémenté :

1. test du repository ;
2. test du controller Riverpod ;
3. test widget du parcours critique ;
4. vérification du mode offline/erreur réseau ;
5. vérification du changement de workspace ;
6. vérification du statut backend avant d'afficher un succès de publication.
