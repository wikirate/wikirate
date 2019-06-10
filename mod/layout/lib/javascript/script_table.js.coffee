# FIXME: change name to "toggle_details"

$(document).ready ->
  $('body').on 'click', "[data-details-mark]", ->
    (new decko.details).toggle $(this)

  $('body').on 'click', ".details-close-icon", ->
    (new decko.details).closeLast()

  $('body').on 'click', '.details ._update-details', (e) ->
    (new decko.details).add $(this)
    e.preventDefault()

decko.details = (dSlot) ->
  @dSlot = if dSlot then $(dSlot) else $(".details")

  @closeLast = ()->
    if @dSlot.children().length == 1
      @turnOff()
    else
      @lastDetails().remove()
      @showLastDetails()

  @closeAll = ()->
    @dSlot.children().not(":first").remove()
    @turnOff()

  @turnOff = () ->
    $(".details-toggle").removeClass "active"
    @dSlot.hide()

  @toggle = (el) ->
    if el.hasClass "active"
      el.removeClass "active"
      @closeAll()
    else
      @turnOff()
      el.addClass "active"
      @add el, true

  @add = (el, root) ->
    @showDetails @urlFor(el, root)

  @urlFor = (el) ->
    mark = el.attr("href") || el.data "details-mark"
    view = el.closest("[data-details-view]").data "details-view"
    decko.path mark + "?view=" + view

  @showDetails = (url, root) ->
    unless @currentURL() == url
      @dSlot.html("") if root
      page = @loadPage(url)
      @dSlot.append page
      @setCurrentURL url
    @showLastDetails()

  @showLastDetails = () ->
    @dSlot.children().hide()
    @lastDetails().show()
    @dSlot.show()

  @currentURL = () ->
    @lastDetails().data "currentUrl"

  @setCurrentURL = (url) ->
    @lastDetails().data "currentUrl", url

  @lastDetails = () ->
    @dSlot.children().last()

  @loadPage =(url) ->
    page = $('<div></div>')
    page.load url
    page.find(".card-slot").trigger "slotReady"
    page

  this


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