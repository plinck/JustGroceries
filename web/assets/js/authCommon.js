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

// this should be available on every page. 
function authLogOff() {
    firebase.auth().signOut().then(function () {
        console.log('success logout');
        window.location.replace("login.html");
    }, function () {});
};

function authCheck(redirectURL, aCallback) {
    firebase.auth().onAuthStateChanged(user => {
        if (user) {
            // get the user ID from the firebase auth -- this should connect to our SQL User DB
            userId = user.uid;
            // Hide all items that should only appear if logged off
            // Show all items that should only appear if logged in
            $(".loggedIn").removeClass('hide');
            $(".notLoggedIn").addClass('hide');
            aCallback(user);
        } else {
            // Show all items that should only appear if logged off
            // Hide all items that should only appear if logged in
            $(".loggedIn").addClass('hide');
            $(".notLoggedIn").removeClass('hide');
            window.location.replace("login.html");
            aCallback(null);
        }
    });
}

function authLogin() {
    // See how to pass this url or route later
    let redirectURL = "index.html";

    // Firebase pre-built UI
    // Initialize the FirebaseUI Widget using Firebase.
    var ui = new firebaseui.auth.AuthUI(firebase.auth());
    var uiConfig = {
        callbacks: {
            signInSuccessWithAuthResult: function (authResult, redirectUrl) {
                // User successfully signed in.
                $(".loggedIn").removeClass('hide');
                $(".notLoggedIn").addClass('hide');    
                window.location.replace(redirectURL);
                return true;
            },
            uiShown: function () {
                // Hide Spinning wait message
                $("#loader").addClass('hide');
            }
        },
        // Use popup for IDP Providers sign-in flow instead of the default, redirect.
        signInFlow: 'redirect',
        signInSuccessUrl: redirectURL,
        signInOptions: [
            // Make sure these are all autorized on firebase signin options on dashboard
            firebase.auth.GoogleAuthProvider.PROVIDER_ID,
            firebase.auth.EmailAuthProvider.PROVIDER_ID
        ],
        // Terms of service url.
        tosUrl: '#',
        // Privacy policy url.
        privacyPolicyUrl: '#'
    };

    // Unhide the loading spinner message.
    $("#loader").removeClass('hide');
    $(".loggedIn").addClass('hide');
    $(".notLoggedIn").removeClass('hide');

    // The start method will wait until the DOM is loaded.
    ui.start('#firebaseui-auth-container', uiConfig);
}