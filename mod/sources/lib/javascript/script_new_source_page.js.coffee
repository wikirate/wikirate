$(document).ready ->
  $('body').on 'click', ".toggle-source-option", ->
    $('.source-option').show()
    $(this).closest('.source-option').hide()
