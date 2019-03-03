// Initialize Firebase
var config = {
    apiKey: "AIzaSyAQflvsF9L2Zrw5183L9LlBXjxNBzewIho",
    authDomain: "justgroceries-3af71.firebaseapp.com",
    databaseURL: "https://justgroceries-3af71.firebaseio.com",
    projectId: "justgroceries-3af71",
    storageBucket: "justgroceries-3af71.appspot.com",
    messagingSenderId: "410385570434"
};

firebase.initializeApp(config);

var database = firebase.database();

// Firebase pre-built UI
// Initialize the FirebaseUI Widget using Firebase.
var ui = new firebaseui.auth.AuthUI(firebase.auth());
var uiConfig = {
    callbacks: {
        signInSuccessWithAuthResult: function (authResult, redirectUrl) {
            // User successfully signed in.
            // Return type determines whether we continue the redirect automatically
            // This will be in SQL Database for twilioCMS
            var userSnap = firebase.database().ref('users/' + firebase.auth().currentUser.uid);
            userSnap.update({
                username: firebase.auth().currentUser.displayName,
                email: firebase.auth().currentUser.email,
                profilePicture: firebase.auth().currentUser.photoURL
            });
            return true;
        },
        uiShown: function () {
            // Hide the log.
            document.getElementById('loader').style.display = 'none';
        }
    },
    // Use popup for IDP Providers sign-in flow instead of the default, redirect.
    signInFlow: 'popup',
    signInSuccessUrl: "index.html",
    signInOptions: [
        // Leave the lines as is for the providers you want to offer your users.
        firebase.auth.GoogleAuthProvider.PROVIDER_ID,
        firebase.auth.EmailAuthProvider.PROVIDER_ID
    ],
    // Terms of service url.
    tosUrl: 'index.html',
    // Privacy policy url.
    privacyPolicyUrl: 'index.html'
};

// The start method will wait until the DOM is loaded.
ui.start('#firebaseui-auth-container', uiConfig);


