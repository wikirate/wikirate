# ~~~~~~~~ Research Dashboard Handling ~~~~~~~~~~~~~~~~

decko.editors.init["._removable-content-list ul"] = ->
  @sortable({handle: '._handle', cancel: ''})

decko.editors.content["._removable-content-list ul"] = ->
  itemNames = $(this).find("._removable-content-item").map -> $(this).data("cardName")
  decko.pointerContent $.unique(itemNames)

decko.slot.ready (slot) ->
  if slot.closest(".research-layout")[0]

    # slide up new overlays
    if slot.hasClass("_overlay")
      revealOverlay slot

    # newly added source
    newSource = slot.find "._new_source"
    if newSource.length
      closeSourceModal slot
      (new decko.compactFilter $(".RIGHT-source.filtered_content-view ._compact-filter")).update()

    # year paging
    if slot.find("#jPages")[0]
      $("#jPages").jPages
        containerID: "research-year-list"
        perPage: 5
        previous: false
        next: false

    # add source to edit answer
    if slot.hasClass("edit_inline-view") && $("#_select_source").data("stash")
      $("#_select_source").data "stash", false
      addSourceItem()

    # new answer success message (if in project context)
    success_in_project = slot.find ".answer-success-in-project"
    if success_in_project[0] && $("._company-project-research")[0]
      success_in_project.show()

    btn = $("._next-question-button")
    if btn.length && slot.find("._edit-answer-button").length
      btn = btn.clone()
      slot.find("._research-buttons").append btn

$(document).ready ->
  $("body").on "click", "#_select_year", (e) ->
    return unless selectedYear()
    phase = selectedYearNotResearched() && "source" || "answer"
    toPhase phase, e

  $("body").on "click", "._to_question_phase", (e) ->
    toPhase "question", e

  $("body").on "click", "._to_source_phase", (e) ->
    toPhase "source", e

  # open answer tab after clicking "select year"
  $("body").on "click", "#_select_source", (event) ->
    addSourceItem() unless tabPhase("answer").hasClass "load"
    toPhase "answer", event

  # open new source form from button
  $("body").on "click", "._add_source_modal_link", () ->
    link = $(this)
    params = link.data "sourceFields"
    params._Year = selectedYear
    appendToHref link, params

  # open pdf preview when clicking on source box/bar
  $('.research-layout #main').on 'click', ".TYPE-source.box, .TYPE-source.bar", (e) ->
    unless $(this).data("skip") == "on" # see _over-card-link mechanism
      toPhase "source", e
      e.stopPropagation()
      openPdf $(this).data("cardName")

  # remove source item from answer page
  $('body').on 'click', '._remove-removable', ->
    $(this).closest('li').remove()

  # close overlay with a smooth slide
  $(".research-layout #main").on "click", '[data-bs-dismiss="overlay"]', (e)->
    el = $(this)
    el.overlaySlot().hide "slide", {
      direction: "down",
      complete: ()->
        el.removeOverlay()
    }, 600
    e.stopPropagation()

  researchTabSelector = ".research-layout #main .nav-item:not(.tab-li-question_phase)"
  $(researchTabSelector).on "show.bs.tab", ".nav-link", (e) ->
    return unless $(this).hasClass "load"
    if !selectedYear()
      demandYear e
    else
      appendToDataUrl $(this),
        year: selectedYear()
        source: selectedSource()

  $(".research-layout").on "click", "._copy_caught_source", (e) ->
    link = $(this)
    sourceMark = link.data "cardName"
    closeSourceModal link
    openPdf sourceMark
    e.preventDefault()

  $(".research-layout").on "click", "._methodology-link", (e) ->
    toPhase "question", e
    $("._methodology-button").click()

  $("body").on "click", "._metric_arrow_button", (e) ->
    $(this).slot().slotReloading()

closeSourceModal = (el)->
  bootstrap.Modal.getInstance(el.closest("._modal-slot")).hide()

appendToUrl = (url, params) ->
  # use decko.path?
  joiner = url.match(/\?/) && "&" || "?"
  url + joiner + $.param(params)

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
  (new bootstrap.Tab tabPhase(phase)).show()
  event.preventDefault()

tabPhase = (phase) ->
  $(".tab-li-#{phase}_phase a")

addSourceItem = () ->
  return if openAnswerFormBeforeAddingSource()
  ed = $(".RIGHT-source.card-editor")
  sourceContent = addToSourceContent ed, selectedSource()
  slot = ed.find(".card-slot.removable_content-view")
  reloadSourceSlot slot, sourceContent

openAnswerFormBeforeAddingSource = ->
  edit_answer = $("._edit-answer-button")
  return false unless edit_answer[0] # answer is in view mode
  edit_answer.trigger "click"
  $("#_select_source").data "stash", true
  true

addToSourceContent = (editor, source) ->
  sources = citedSources()
  sources.push source
  content = decko.pointerContent $.uniqueSort(sources)
  editor.find(".d0-card-content").val content
  content

reloadSourceSlot = (slot, content) ->
  query = $.param assign: true, card: { content: content }
  slot.slotReload "#{slot.data 'cardLinkName'}?#{query}"

selectedSource = ()->
  $("#_select_source").data "source"

citedSources = () ->
  $(".RIGHT-source .bar").map( -> $(this).data("cardName") )

selectedYear = ()->
  selectedYearInput().val() || $(".answer-breadcrumb .year").html()

selectedYearNotResearched = ->
  selectedYearInput().closest("._research-year-option").find("._not-researched")[0]

selectedYearInput = ->
  $("input[name='year']:checked")

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
  whenAvailable ".source_phase-view", ->
    el = $(".source_phase-view")
    if sourceMark != selectedSource
      params = { source: sourceMark }
      if citedSources().toArray().includes(sourceMark)
        params["slot"] = { hide: "select_source_button" }
      url = researchPath("source_selector") + "?" + $.param(params)
      el.addClass "slotter"
      el[0].href = url
      $.rails.handleRemote el

whenAvailable = (selector, callback, maxTimes = 100) ->
  if jQuery(selector).length
    callback()
  else if maxTimes == false || maxTimes > 0
    (maxTimes != false) && maxTimes--
    setTimeout (-> whenAvailable selector, callback, maxTimes), 100

deckorate.tabPhase = tabPhase

# add related company to name
# otherwise the card can get the wrong type because it
# matches the ltype_rtype/answer/year pattern
#  $("body").on "submit", "form.answer-form", (e) ->
#    $form = $(e.target)
#    related_company = $form.find("#card_subcards__related_company_content")
#    if related_company.length == 1
#      # name = $form.find("#card_name").val()
#      # $form.find("#card_name").val(name + "+" + related_company.val())
#      unless $form.find("#success_id").val() == ":research_page"
#        $form.find("#success_id").val("_left")
