# ~~~~~~~~ Research Dashboard Handling ~~~~~~~~~~~~~~~~

revealOverlay = (overlay) ->
  overlay.hide()
  $("html, body").animate { scrollTop: 0 }, 300
  $(window).scrollTop
  overlay.show "slide", { direction: "down" }, 600

hideOverlay = (overlay) ->

decko.slotReady (slot) ->
  # slide up new overlays
  if slot.hasClass "_overlay"
    revealOverlay slot

  newSource = slot.find "._new_source"
  if newSource.length
    sourceId = newSource.data "cardId"
    slot.closest("._modal-slot").find("._close-modal").trigger "click"
    alert "source id = #{sourceId}"
    (new decko.filter $(".SELF-source.filtered_content-view ._filter-widget")).update()

$(document).ready ->
  # toggle more/less years
  $("body").on "click", "._more-years-toggle", () ->
    el = $(this).find "._more-or-fewer"
    if el.text().match(/More/)
      el.text "Fewer"
    else
      el.text "More"

  # click anywhere on year option to select it
  $("body").on "click", "._research-year-option", () ->
    $(this).find("input").prop "checked", "true"

  # open source tab after clicking "select year"
  $("body").on "click", "#_select_year", (event) ->
    openTabWithParams "source_phase", event, year: selectedYear()

  # open answer tab after clicking "select year"
  $("body").on "click", "#_select_source", (event) ->
    openTabWithParams "answer_phase", event, {
      year: selectedYear()
      source: $(this).data("source")
    }

  # open new source form from button
  $("body").on "click", "._add_source_modal_link", () ->
    link = $(this)
    params = link.data "sourceFields"
    params._Year = selectedYear
    appendToHref link, params

  # close overlay with a smooth slide
  $(".research-layout #main").on "click", '[data-dismiss="overlay"]', (e)->
    el = $(this)
    el.overlaySlot().hide "slide", {
      direction: "down",
      complete: ()->
        el.removeOverlay()
    }, 600
    e.stopPropagation()

openTabWithParams = (tabname, event, params)->
  link = $(".tab-li-#{tabname} a")
  appendToDataUrl link, params
  link.trigger "click"
  event.preventDefault()

selectedYear = ()->
  $("input[name='year']:checked").val()

appendToUrl = (url, params) ->
  url + "&" + $.param(params)

appendToDataUrl = (link, params) ->
  url = initialUrl link, link.data("url")
  link.data "url", appendToUrl(url, params)

appendToHref = (link, params)->
  href = initialUrl link, link.attr("href")
  link.attr "href", appendToUrl(href, params)

initialUrl = (link, url) ->
  unless link.data "initialUrl"
    link.data "initialUrl", url
  link.data "initialUrl"

  # add related company to name
  # otherwise the card can get the wrong type because it
  # matches the ltype_rtype/record/year pattern
  #  $("body").on "submit", "form.answer-form", (e) ->
  #    $form = $(e.target)
  #    related_company = $form.find("#card_subcards__related_company_content")
  #    if related_company.length == 1
  #      # name = $form.find("#card_name").val()
  #      # $form.find("#card_name").val(name + "+" + related_company.val())
  #      unless $form.find("#success_id").val() == ":research_page"
  #        $form.find("#success_id").val("_left")
