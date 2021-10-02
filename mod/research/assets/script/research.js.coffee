# ~~~~~~~~ Research Dashboard Handling ~~~~~~~~~~~~~~~~

decko.editorInitFunctionMap["._removable-content-list"] = ->
  @sortable({handle: '._handle', cancel: ''})

decko.editorContentFunctionMap["._removable-content-list"] = ->
  decko.pointerContent citedSources($(this))

decko.slotReady (slot) ->
  # slide up new overlays
  if slot.hasClass("_overlay") && slot.closest(".research-layout")[0]
    revealOverlay slot

  newSource = slot.find "._new_source"
  if newSource.length
    sourceId = newSource.data "cardId"
    slot.closest("._modal-slot").find("._close-modal").trigger "click"
    alert "source id = #{sourceId}"
    (new decko.filter $(".SELF-source.filtered_content-view ._filter-widget")).update()

  if slot.find("#jPages")[0]
    $("#jPages").jPages
      containerID: "research-year-list"
      perPage: 5
      previous: false
      next: false

$(document).ready ->
  # open source tab after clicking "select year"
  $("body").on "click", "#_select_year", (event) ->
    toPhase "source", event

  # open answer tab after clicking "select year"
  $("body").on "click", "#_select_source", (event) ->
    unless tabPhase("answer").hasClass "load"
      addSource selectedSource()
    toPhase "answer", event

  # open new source form from button
  $("body").on "click", "._add_source_modal_link", () ->
    link = $(this)
    params = link.data "sourceFields"
    params._Year = selectedYear
    appendToHref link, params

  # open pdf preview when clicking on source box/bar
  $('.research-layout #main').on 'click', ".TYPE-source.box, .TYPE-source.bar", (e) ->
    toPhase "source", e
    openPdf $(this).data("cardName")
    e.stopPropagation()

  # remove source item from answer page
  $('body').on 'click', '._remove-removable', ->
    $(this).closest('li').remove()

  # close overlay with a smooth slide
  $(".research-layout #main").on "click", '[data-dismiss="overlay"]', (e)->
    el = $(this)
    el.overlaySlot().hide "slide", {
      direction: "down",
      complete: ()->
        el.removeOverlay()
    }, 600
    e.stopPropagation()

  researchTabSelector = ".research-layout #main .nav-item:not(.tab-li-question_phase)"
  $(researchTabSelector).on "click", ".nav-link:not(.active)", (e)->
    return unless $(this).hasClass "load"
    if !selectedYear()
      demandYear e
    else
      appendToDataUrl $(this),
        year: selectedYear()
        source: selectedSource()

appendToUrl = (url, params) ->
  url + "&" + $.param(params)

appendToDataUrl = (link, params) ->
  url = initialUrl link, link.data("url")
  link.data "url", appendToUrl(url, params)

appendToHref = (link, params)->
  href = initialUrl link, link.attr("href")
  link.attr "href", appendToUrl(href, params)

demandYear = (event) ->
  alert "Please select a year"
  event.preventDefault()
  event.stopPropagation()

toPhase = (phase, event) ->
  tabPhase(phase).trigger "click"
  event.preventDefault()

tabPhase = (phase) ->
  $(".tab-li-#{phase}_phase a")

addSource = (source) ->
  ed = $(".RIGHT-source.card-editor")
  sourceContent = addToSourceContent ed, source
  slot = ed.find(".card-slot.removable_content-view")
  reloadSourceSlot slot, sourceContent

addToSourceContent = (editor, source) ->
  sources = citedSources editor
  sources.push source
  content = decko.pointerContent $.uniqueSort(sources)
  editor.find(".d0-card-content").val content
  content

reloadSourceSlot = (slot, content) ->
  query = $.param assign: true, card: { content: content }
  slot.reloadSlot "#{slot.data 'cardName'}?#{query}"

selectedSource = ()->
  $("#_select_source").data "source"

citedSources = (el) ->
  el.find('._removable-content-item').map( -> $(this).data('cardName') )

selectedYear = ()->
  $("input[name='year']:checked").val()

initialUrl = (link, url) ->
  unless link.data "initialUrl"
    link.data "initialUrl", url
  link.data "initialUrl"

revealOverlay = (overlay) ->
  overlay.hide()
  $("html, body").animate { scrollTop: 0 }, 300
  $(window).scrollTop
  overlay.show "slide", { direction: "down" }, 600

researchPath = (view)->
  path = window.location.pathname.replace(/\/\w+$/, "")
  decko.path path + "/" + view

openPdf = (sourceMark) ->
  el = $(".source_phase-view")
  if el[0] && sourceMark != selectedSource
    url = researchPath("source_selector") + "?" + $.param(source: sourceMark)
    el.addClass "slotter"
    el[0].href = url
    $.rails.handleRemote el

wikirate.tabPhase = tabPhase

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
