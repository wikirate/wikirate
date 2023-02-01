$(document).ready ->

  $("body").on "click", "._flip-card", ->
    $(this).toggleClass "flipped"
