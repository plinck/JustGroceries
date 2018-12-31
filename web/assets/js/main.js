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

// Get a reference to the database service
const dbRef = firebase.database().ref();
const groceryItemsRef = dbRef.child('grocery-items');

// Populate the list of items 
let items = [];

// MAIN PROCESS + INITIAL CODE
// --------------------------------------------------------------------------------

groceryItemsRef .on("child_added", function (snapshot) {
    console.log(`key: ${snapshot.key}, value: ${snapshot.val()}`);
    let groceryItem = snapshot.val();
    console.log(groceryItem.name);
    console.log(groceryItem.addedByUser);
    console.log(groceryItem.completed);

    let newDiv = $("<div>");
    newDiv.text(`${groceryItem.name} ${groceryItem.addedByUser} ${groceryItem.completed}`);
    $(".articles").append(newDiv);
}, function (errorObject) {
    console.log("The read failed: " + errorObject.code);
});