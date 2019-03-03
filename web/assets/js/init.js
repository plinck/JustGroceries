//  this animates the mobile sidebar
(function ($) {
    $(function () {

        $('.sidenav').sidenav();

    }); // end of document ready
})(jQuery); // end of jQuery name space

//  this is the animation for the multi select
$(document).ready(function () {
    $('select').formSelect();
});

// this should be available on every page. 
logMeOut = function () {
    firebase.auth().signOut().then(function () {
        console.log('success logout');
        window.location.replace("login.html");
    }, function () {});
};