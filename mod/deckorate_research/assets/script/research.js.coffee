# ~~~~~~~~ Research Dashboard Handling ~~~~~~~~~~~~~~~~

decko.editorInitFunctionMap["._removable-content-list ul"] = ->
  @sortable({handle: '._handle', cancel: ''})

decko.editorContentFunctionMap["._removable-content-list ul"] = ->
  decko.pointerContent citedSources($(this))

decko.slotReady (slot) ->
  if slot.closest(".research-layout")[0]

    # slide up new overlays
    if slot.hasClass("_overlay")
      revealOverlay slot

    # newly added source
    newSource = slot.find "._new_source"
    if newSource.length
      closeSourceModal slot
      (new decko.filter $(".RIGHT-source.filtered_content-view ._filter-widget")).update()

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
      slot.find(".button-form-group").append btn

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

  $(".research-layout").on "click", "._copy_caught_source", (e) ->
    link = $(this)
    sourceMark = link.data "cardName"
    closeSourceModal link
    openPdf sourceMark
    e.preventDefault()

closeSourceModal = (el)->
  el.closest("._modal-slot").find("._close-modal").trigger "click"

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
  selectedYearInput().val()

selectedYearNotResearched = ->
  selectedYearInput().closest("._research-year-option").find(".not-researched")[0]

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
