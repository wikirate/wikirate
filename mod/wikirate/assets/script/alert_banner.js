// slides up the alert banner on click
$(document).ready(function() {
    if ($('#homepage-alert').length) {
        $('#close-alert-button').click(function() {
          $('#homepage-alert').slideUp("slow");
        });
    }
});
