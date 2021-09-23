showSourceTab = () ->
  tab = $("#research-details .nav-tabs li:first a")
  tab.removeClass("d-none").tab('show')

toggleCitation = (ele, action) ->
  if citations().length == 0
    alert "Can't change citations. Answer is not in edit mode."
  else
    updateCitation action, sourceIdFromEl(ele)

hideAlreadyCited = () ->
  citations().each ->
    sourceId = $(this).find(".bar-view").data "card-id"
    possibleSource(sourceId).hide()

previewSource = (sourceID) ->
  showSourceTab "source"
  slot = $(".preview-view")
  slot.empty()
  wikirate.loader(slot).add()
  updatePreviewSlot slot, sourceID

activateSourceBar = (link) ->
  sourceList = $(".cited-sources")
  bars = sourceList.find(".bar-view")
  bars.removeClass "active"
  activeBar = if link then link.closest(".bar-view") else $(bars[0])
  activeBar.addClass "active"


sourceIdFromEl = (el) ->
  $(el).closest("._cite-bar").data("card-id")

checkYearData = ($source) ->
  researchedYear = $("form.answer-form > input#success_year").val()
  years = $source.data("year") or []
  message =
    "Please confirm that you wish to cite this source for a #{researchedYear} " +
    "answer (and add #{researchedYear} to the years covered by this source)."
  if years.length > 0
    if years.includes(researchedYear)
      return true
    else
      message =
        "The source you are citing is currently listed as a source " +
        "for #{years.sort().toString()}. " + message

  response = window.confirm message
  # addYearToSource($source, researchedYear) if response
  return response


possibleSource = (sourceID) ->
  $("#research-details .source-list > ._cite-bar[data-card-id='#{sourceID}']")


updatePreviewSlot = (slot, sourceID) ->
  load_path = decko.slotPath(sourceID + "?view=preview")
  slot.reloadSlot load_path

openBar = (bar) ->
  path = bar.slot().data "card-link-name"
  window.open decko.path(path)

staticPreviewLink = ".slot_machine-view .TYPE-answer.titled-view .source-preview-link"

$(document).ready ->
  $('body').on 'click', '.bar.TYPE-task', () ->
    openBar $(this)

  $('body').on 'click', '.bar.TYPE-task a', () ->
    openBar $(this).closest('.bar')
    return false

  $("body").on 'click', staticPreviewLink, (event) ->
    previewSource $(this).slot().data("card-name")
    activateSourceBar $(this)
    event.preventDefault()

  $('body').on 'ajax:error', "#research_page-view_source > .card-slot", (event, xhr) ->
    $(this).find(".loader-anime").remove() # remove loader

  if $(staticPreviewLink).exists()
    activateSourceBar null

decko.slotReady (slot) ->
  if slot.find(".TYPE-answer.source_selector-view")[0]
    hideAlreadyCited()
