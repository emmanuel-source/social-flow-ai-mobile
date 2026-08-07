$ErrorActionPreference = "Stop"

Write-Host "SocialFlow AI - preparation des plateformes Flutter"
flutter --version
flutter create --platforms=android,ios,web .
flutter pub get
flutter analyze
flutter test

Write-Host "Projet pret. Ouvrez ensuite le dossier dans Android Studio ou IntelliJ."
