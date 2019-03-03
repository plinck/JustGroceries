//  THIS IS NEEDED TO GET THE CURRENT USER. AND BECAUSE WE HAVE TO WAIT FOR A REPLY FROM THE DATABASE
authCheck("user.html", (user) => {
    if (user) {
        userId = user.uid;

        $(document).ready(function () {
            // logged in so put logic here
        });
    };
});