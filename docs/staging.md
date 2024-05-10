# Jak Utworzono środowisko testowe

## Backend
Patrz [Bacnekd repo](https://github.com/SPKapp/spk-backend-service/blob/main/docs/staging.md)

## Zainicjowanie Firebase Hosting
TODO: Dodaj opis

## Web
1. Ustawienie zmiennych środowskowych w `.env/staging.env`
2. Zbudowanie aplikacji `flutter build web --dart-define-from-file .env/staging.env`
3. Wypchnięcie aplikacji do Firebase Hosting `firebase deploy`