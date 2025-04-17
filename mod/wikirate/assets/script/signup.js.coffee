$ ->
  $("body").on "click", "input[name=terms_of_use]", ->
    disabled = $(this).filter(":checked").val() == "no"
    $("#_signup-button").prop "disabled", disabled
