$(document).ready ->
  $('body').on 'click', ".toggle-source-option", ->
    $('.download-option input').val("")
    $('.source-option').show()
    $(this).closest('.source-option').hide()
