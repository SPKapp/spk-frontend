importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    /* WARNING: Replace the following config with your own Firebase config. From /lib/config/firebase_options.dart -> web */
    // apiKey: "...",
    // appId: "...",
    // messagingSenderId: "...",
    // projectId: "...",
    // authDomain: "...",
    // storageBucket: "...",

});



const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);
});