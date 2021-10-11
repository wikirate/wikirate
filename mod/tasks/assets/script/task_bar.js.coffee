openBar = (bar) ->
  path = bar.slot().data "card-link-name"
  window.open decko.path(path)

$(document).ready ->
  $('body').on 'click', '.bar.TYPE-task', () ->
    openBar $(this)

  $('body').on 'click', '.bar.TYPE-task a', () ->
    openBar $(this).closest('.bar')
    return false
