$ ->
  if $('._homepage-alert').length
    $('._close-alert-button').click ->
      $('._homepage-alert').slideUp "slow"
