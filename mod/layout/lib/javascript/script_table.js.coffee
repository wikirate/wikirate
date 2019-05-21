# FIXME: change name to "toggle details"

$(document).ready ->

  # details toggle
  active_details = null

  # hack to solve the problem that
  # if you click somewhere in the details area
  # it is closed because it is a child of .details-toggle
  no_toggle = null
  $('body').on 'click', ".details-toggle  .details", ->
    no_toggle = true

  $('body').on 'click', ".details-close-icon", ->
    trToggleDetails this

  $('body').on 'click', ".details-toggle", (_event) ->
    if no_toggle
      no_toggle = null
    else
      trToggleDetails this

  trToggleDetails = (toggle) ->
    $toggle = $(toggle)
    row = $toggle.closest('.details-toggle')
    if row.hasClass "active"
      deactivateRow row
    else
      deactivateRow $(".details-toggle.active")
      activateRow row, $toggle

  deactivateRow = (row) ->
    active_details = null
    row.find('.details').hide()
    row.removeClass "active"

  activateRow = (row, $toggle) ->
    active_details = row.find('.details')
    row.addClass "active"
    showDetails $toggle

  showDetails = ($toggle) ->
    url = detailsUrl $toggle
    return unless url
    loadDetails $toggle, url
    active_details.show()
    #     stickDetails()

  loadDetails = ($toggle, url) ->
    return if $.trim(active_details.html()) # already loaded
    startLoaderAnime
    loadDetailsUrl url

  startLoaderAnime = () ->
    active_details.append $("#ajax_loader").html()

  detailsUrl = ($toggle) ->
    configuredUrl = $toggle.data("details-url")
    if configuredUrl? # no if undefined or null. yes if false
      configuredUrl
    else
      constructDetailsUrl $toggle

  constructDetailsUrl = ($toggle) ->
    view = $toggle.data('view') || 'content'
    right_name = $toggle.data 'append'
    card_name = $toggle.closest('.card-slot').attr 'id'
    "/#{card_name}+#{right_name}?view=#{view}"

  loadDetailsUrl = (url) ->
    active_details.load url, ->
      active_details.find('.card-slot').trigger 'slotReady'

  #stick the details when scrolling
  #   stickDetails = () ->
  #     if stickableDetails()
  #       active_details.addClass 'stick'
  #     else
  #       active_details.removeClass 'stick'
  #
  #   # TODO: move each to well-named function
  #   stickableDetails = () ->
  #     return false if $(window).scrollTop() > ($("#main").height() - $(window).height() + 300)
  #     return true if $(document).scrollTop() > 56
  #     return true if active_details.closest('.modal-body').exists() # is modal
  #     false
  #
  #   $(window).scroll ->
  #     if active_details
  #       stickDetails()
  #