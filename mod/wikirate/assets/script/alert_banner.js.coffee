$ ->
  if $('#homepage-alert').length
    $('#close-alert-button').click ->
      $('#homepage-alert').slideUp "slow"
