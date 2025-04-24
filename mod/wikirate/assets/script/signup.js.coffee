$ ->
  $("body").on "change", "#_terms-checkbox", ->
    $("#_signup-button").prop "disabled", !$(this).is(":checked")

  $("body").on "change", "#_newsletter-checkbox", ->
    yesno = $(this).is(":checked") && "Yes" || "No"
    $("#_newsletter_hidden").val yesno