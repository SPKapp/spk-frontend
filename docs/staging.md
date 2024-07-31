# Jak Utworzono środowisko testowe

## Backend
Patrz [Bacnekd repo](https://github.com/SPKapp/spk-backend-service/blob/main/docs/staging.md)

- uruchom `flutterfire configure`
- przenieś `lib/firebase_options.dart` do `lib/config/firebase_options.dart`

## Web
1. Ustawienie zmiennych środowskowych w `.env/staging.env`
    - `GOOGLE_CLIENT_ID` firebase Auth Google Config
    - `WEB_VAPID_KEY` firebase settigns -> Cloud Messaging -> Web configuration
2. Dodanie konfiguracji firebase do `web/firebase-messaging-sw.js` zgodnie z komentarzem
3. Zbudowanie aplikacji `flutter build web --dart-define-from-file .env/staging.env`
4. Wypchnięcie aplikacji do Firebase Hosting `firebase deploy -P <nazwa_projektu>`
    - dodanie domeny w firebase