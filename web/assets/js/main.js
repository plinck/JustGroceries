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
const groceryItemsRef = dbRef.child('grocery-items'); // All grocery items
const usersRef = dbRef.child('online'); // online users

// The list of items 
let items = [];

// Render one item on DOM
function groceryItemRender(item) {
    let newDiv = $("<div>");
    newDiv.text(`${item.name} ${item.addedByUser} ${item.completed}`);
    $(".articles").append(newDiv);
}

// listener for each item when added in grocery-items 
groceryItemsRef.on("child_added", function (snapshot) {
    let groceryItem = snapshot.val();
}, function (errorObject) {
    console.log("The read failed: " + errorObject.code);
});

// listener for all items in grocery-items order by completed or not
groceryItemsRef.orderByChild("completed").on("value", function (snapshot) {
    $(".articles").empty();
    snapshot.forEach(function (child) {
        console.log(child.key);
        let groceryItem = child.val();
        groceryItemRender(groceryItem);
    });
}, function (errorObject) {
    console.log("The read failed: " + errorObject.code);
});

// There are three ways to save data to the Firebase Database that are
// Push()
// Set() and
// Update()

// save to firebase
function firebaseSaveItem(itemVal) {
    // Make the key be item in lowercase to avoid duplicates
    let itemKey = itemVal.toLowerCase();

    let newItem = {};
    newItem.name = itemVal;
    newItem.addedByUser = "paul@linck.net";
    newItem.completed = false;

    let groceryItemRef = groceryItemsRef.child(itemKey);
    groceryItemRef.set(newItem);
}

// delete item from firebase
function firebaseDeleteItem(itemVal) {
    // Make the key be item in lowercase to avoid duplicates
    let itemKey = itemVal.toLowerCase();

    let groceryItemRef = groceryItemsRef.child(itemKey);
    groceryItemRef.remove();
}


// MAIN PROCESS + INITIAL CODE
// --------------------------------------------------------------------------------
$(document).ready(function () {

    $("#add-item").on("click", function () {
        // make it so it wont refresh the page when form submits
        // eliminating form wrapper tag also does this
        event.preventDefault();

        // This line grabs the input from the textbox
        let itemVal = $("#item-input").val().trim();
        firebaseSaveItem(itemVal);
    });

    $("#delete-item").on("click", function () {
        // make it so it wont refresh the page when form submits
        // eliminating form wrapper tag also does this
        event.preventDefault();

        // This line grabs the input from the textbox
        let itemVal = $("#item-input").val().trim();
        firebaseDeleteItem(itemVal);
    });

});  // document.ready