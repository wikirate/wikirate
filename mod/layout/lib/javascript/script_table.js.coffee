# FIXME: change name to "toggle_details"

$(document).ready ->
  $('body').on 'click', "[data-details-mark]", ->
    (new decko.details(this)).toggle $(this)

  $('body').on 'click', ".details-close-icon", (e)->
    (new decko.details($(this).closest(".details-toggle"))).closeLast()
    e.stopPropagation()
    e.preventDefault()

  $('body').on 'click', '.details ._update-details', (e) ->
    unless $(this).closest(".relations_table-view").length > 0
    # update details unless we're looking at relationship details
    # (we don't yet have a relationship details view)
      (new decko.details(this)).add $(this)
      e.preventDefault()

decko.details = (el) ->
  @dInnerSlot = $(el).find ".details"
  @dSlot = if @dInnerSlot.exists() then @dInnerSlot else $(".details")

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
    @showDetails @urlFor(el), root

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
    page.load url, ()->
      page.find(".card-slot").trigger "slotReady"
    page

  this
