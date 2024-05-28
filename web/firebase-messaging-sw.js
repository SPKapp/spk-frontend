self.addEventListener('notificationclick', function (event) {
    const clickedNotification = event.notification;
    const notification = clickedNotification.data.FCM_MSG;

    console.log('[firebase-messaging-sw.js] notificationclick event:', notification);


    let url = '/';

    if (notification.data['category'] == 'groupAssigned') {
        url = `/#/rabbitGroup/${notification.data['groupId']}`;
    } else if (notification.data['category'] == 'rabbitAssigned') {
        url = `/#/rabbit/${notification.data['rabbitId']}`;
    } else if (notification.data['category'] == 'rabbitMoved') {
        url = `/#/rabbit/${notification.data['rabbitId']}`;
    } else if (notification.data['category'] == 'rabbitPickup') {
        // TODO
    } else if (notification.data['category'] == 'adoptionToConfirm') {
        url =
            `/#/rabbitGroup/${notification.data['groupId']}?launchSetAdoptedAction=true`;
    } else if (notification.data['category'] == 'nearVetVisit') {
        // TODO
    } else if (notification.data['category'] == 'vetVisitEnd') {
        // TODO
    }



    console.log('[firebase-messaging-sw.js] notificationclick url:', url);
    clickedNotification.close();
    event.waitUntil(
        clients.openWindow(url)
    );
});



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
    console.log("onBackgroundMessage", JSON.stringify(message));
});