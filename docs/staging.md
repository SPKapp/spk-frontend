# Jak Utworzono środowisko testowe

## Backend
Patrz [Bacnekd repo](https://github.com/SPKapp/spk-backend-service/blob/main/docs/staging.md)

## Zainicjowanie Firebase Hosting
TODO: Dodaj opis

## Web
1. Ustawienie zmiennych środowskowych w `.env/staging.env`
2. Dodanie konfiguracji firebase do `web/firebase-messaging-sw.js` zgodnie z komentarzem
3. Zbudowanie aplikacji `flutter build web --dart-define-from-file .env/staging.env`
4. Wypchnięcie aplikacji do Firebase Hosting `firebase deploy`