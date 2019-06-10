# FIXME: change name to "toggle_details"

$(document).ready ->
  $('body').on 'click', "[data-details-mark]", ->
    new(decko.details).loadFor this

  $('body').on 'click', ".details-close-icon", ->
    new(decko.details).close()

  $('body').on 'click', '.details_sidebar-view ._update-details', (e) ->
    url = $(this).attr('href') + '?view=details_sidebar'
    $(this).closest('.details_sidebar-view').reloadSlot url
    e.preventDefault()


decko.details = (dSlot) ->
  @dSlot = if dSlot then $(dSlot) else $(".details")

  @close = ()->
    @dSlot.hide()

  @loadFor = (el) ->
    @loadDetails urlFor(el)

  @urlFor = (el) ->
    mark = el.data "details-mark"
    view = el.closest("[data-details-view]").data "details-view"
    decko.path mark + "?view=" + view

  @loadDetails = (url) ->
    @dSlot.load url
    @dSlot.find(".card-slot").trigger "slotReady"
    @dSlot.show()


#   $('body').on 'click', ".details-toggle", (_event) ->
#     if no_toggle
#       no_toggle = null
#     else
#       trToggleDetails this
#
#  trToggleDetails = (toggle) ->
#    $toggle = $(toggle)
#    row = $toggle.closest('.details-toggle')
#    if row.hasClass "active"
#      deactivateRow row
#    else
#      deactivateRow $(".details-toggle.active")
#      activateRow row, $toggle
#
#  deactivateRow = (row) ->
#    active_details = null
#    row.find('.details').hide()
#    row.removeClass "active"
#
#  activateRow = (row, $toggle) ->
#    active_details = row.find('.details')
#    row.addClass "active"
#    showDetails $toggle
#
#  showDetails = ($toggle) ->
#    url = detailsUrl $toggle
#    return unless url
#    loadDetails $toggle, url
#    active_details.show()
#    #     stickDetails()
#
#  loadDetails = ($toggle, url) ->
#    return if $.trim(active_details.html()) # already loaded
#    startLoaderAnime
#    loadDetailsUrl url
#
#  startLoaderAnime = () ->
#    active_details.append $("#ajax_loader").html()
#
#  detailsUrl = ($toggle) ->
#    $toggle.data("details-url")
#
#  loadDetailsUrl = (url) ->
#    active_details.load url, ->
#      active_details.find('.card-slot').trigger 'slotReady'
#