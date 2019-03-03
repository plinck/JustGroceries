// firebase setup and config
var config = {
    apiKey: "AIzaSyD-Rni68sV7NSl1a_nRI5QtDZ-GazqCcYg",
    authDomain: "workoutbuddies-a9eb5.firebaseapp.com",
    databaseURL: "https://workoutbuddies-a9eb5.firebaseio.com",
    projectId: "workoutbuddies-a9eb5",
    storageBucket: "workoutbuddies-a9eb5.appspot.com",
    messagingSenderId: "25982813153"
};
firebase.initializeApp(config);
var database = firebase.database();
var user

//  THIS IS NEEDED TO GET THE CURRENT USER. AND BECAUSE WE HAVE TO WAIT FOR A REPLY FROM THE DATABASE
firebase.auth().onAuthStateChanged( user => {
    if (user) { 
        userId = user.uid    

        var currentPersonProfilePicture;

        // get values from database and add them to the form
        var userSnap = firebase.database().ref('users/' + userId);
        // use the values from the database to populate the form. 
        userSnap.on('value', function(snap) {
            $("#profilePicture").attr('src', (snap.val().profilePicture));
            $("label[for='username']").addClass("active");
            $("#username").val(snap.val().username);
            $("label[for='username']").addClass("active");
            $("#address").val(snap.val().address);
            $("label[for='address']").addClass("active");
            $("#city").val(snap.val().city);
            $("label[for='city']").addClass("active");
            $("#state").val(snap.val().state);
            $("label[for='state']").addClass("active");
            $("#zipCode").val(snap.val().zipCode);
            $("label[for='zipCode']").addClass("active");
            $("#aboutMe").val(snap.val().aboutMe);
            $("label[for='aboutMe']").addClass("active");

            if (firebase.auth().currentUser.photoURL) {
                currentPersonProfilePicture = firebase.auth().currentUser.photoURL;
            }
            else if (snap.val().profilePicture) {
                currentPersonProfilePicture = snap.val().profilePicture;
            }
            else {
                currentPersonProfilePicture = "images/icons/fitness.svg";
            }

            if (snap.val().workoutPreferences) {
                currentPersonSorkoutPreferences = snap.val().workoutPreferences;
            }
            else {
                currentPersonWorkoutPreferences = "Mall Walking";
            }
            $("#profilePictureSelect").val(currentPersonProfilePicture);

            $("select#workoutPreferences").val(currentPersonSorkoutPreferences);

        });

        // submit and update values
        $("#profileButton").on("click", function() {
            event.preventDefault();
            console.log("Profile Picture: " + currentPersonProfilePicture);

            var username = $("#username").val();
            var aboutMe = $("#aboutMe").val();
            var address = $("#address").val();
            var city = $("#city").val();
            var state = $("#state").val();
            var zipCode = $("#zipCode").val();
            var dateNow = $.now();
            var dateNow = moment(dateNow).format('MMMM Do, h:mm:ss a');
            var workoutPreferences = $("#workoutPreferences").val();
            var uid = firebase.auth().currentUser.uid;
    
    
            if (currentPersonProfilePicture.includes("http")) {
                var profilePicture = currentPersonProfilePicture;
            } 
            else if ($("select#profilePictureSelect").val()) {
                var profilePicture = $("select#profilePictureSelect").val();
            }
            else {
                var profilePicture = "images/icons/fitness.svg";
            }


            console.log("Profile Picture: " + profilePicture);

            console.log("workoutPreferences: " + workoutPreferences);

            // populate form values to the user profile in the database
            firebase.database().ref('users/' + uid).update({
                username: username,
                aboutMe: aboutMe,
                address: address,
                city: city,
                state: state,
                zipCode: zipCode,
                aboutMe: aboutMe,
                profilePicture: profilePicture,
                workoutPreferences: workoutPreferences
            });
            window.location.replace("index.html");
        });
    }
    else {
        window.location.replace("login.html");
    };

});

