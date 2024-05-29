importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    /* WARNING: Replace the following config with your own Firebase config. From /lib/config/firebase_options.dart -> web */
    apiKey: 'AIzaSyADkB4EuFUJQq1R6kx6djLyxVXr712qzO4',
    appId: '1:534351148362:web:b339b1c697cfeeb31ffdb3',
    messagingSenderId: '534351148362',
    projectId: 'spkdev-alfa',
    authDomain: 'spkdev-alfa.firebaseapp.com',
    storageBucket: 'spkdev-alfa.appspot.com',

});

self.addEventListener('notificationclick', function (event) {
    const clickedNotification = event.notification;
    const notification = clickedNotification.data.FCM_MSG;

    console.log('[firebase-messaging-sw.js] notificationclick event:', notification);

    let path = '/';

    if (notification.data['category'] == 'groupAssigned') {
        path = `/#/rabbitGroup/${notification.data['groupId']}`;
    } else if (notification.data['category'] == 'rabbitAssigned') {
        path = `/#/rabbit/${notification.data['rabbitId']}`;
    } else if (notification.data['category'] == 'rabbitMoved') {
        path = `/#/rabbit/${notification.data['rabbitId']}`;
    } else if (notification.data['category'] == 'admissionToConfirm') {
        path = `/#/rabbit/${notification.data['rabbitId']}?launchSetStatusAction=true`;
    } else if (notification.data['category'] == 'adoptionToConfirm') {
        path =
            `/#/rabbitGroup/${notification.data['groupId']}?launchSetAdoptedAction=true`;
    } else if (notification.data['category'] == 'nearVetVisit') {
        // TODO
    } else if (notification.data['category'] == 'vetVisitEnd') {
        // TODO
    }
    clickedNotification.close();

    const openPage = async () => {
        await clients.openWindow(path);
    }

    event.waitUntil(openPage());
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);
});