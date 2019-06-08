# FIXME: change name to "toggle_details"

$(document).ready ->
  viewSelector = ".RIGHT-answer.table-view"
  rowSelector = viewSelector + " tr"

  $('body').on 'click', rowSelector, ->
    answer = $(this).data "row-card"
    if answer["known"]
      details_view = $(this).closest(viewSelector).data("details-view")
      url = decko.path answer["url_key"] + "?view=" + details_view
      details_slot = $(".details-slot")
      details_slot.load url
      details_slot.find(".card-slot").trigger "slotReady"

  $('body').on 'click', ".details-close-icon", ->
    $(".details-slot").html('')

  $('body').on 'click', '.details_sidebar-view ._update-details', (e) ->
    url = $(this).attr('href') + '?view=details_sidebar'
    $(this).closest('.details_sidebar-view').reloadSlot url
    e.preventDefault()

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