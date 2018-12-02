$.extend wikirate,
  showResearchDetailsTab: (tab) ->
    tab = $("#research-details .nav-tabs a[href='#research_page-#{tab}']")
    tab.removeClass("d-none").tab('show')

  toggleCitation: (ele, action) ->
    if citations().length == 0
      alert "Can't change citations. Answer is not in edit mode."
    else
      updateCitation action, sourceIdFromEl(ele)

  hideAlreadyCited: () ->
    citations().each ->
      sourceId = $(this).find(".bar-view").data "card-id"
      possibleSource(sourceId).hide()

  previewSource: (sourceID) ->
    wikirate.showResearchDetailsTab "source"
    slot = $(".preview-view")
    slot.empty()
    wikirate.loader(slot).add()
    updatePreviewSlot slot, sourceID

  activateSourceBar: (link) ->
    sourceList = $(".cited-sources")
    bars = sourceList.find(".bar-view")
    bars.removeClass "active"
    activeBar = if link then link.closest(".bar-view") else $(bars[0])
    activeBar.addClass "active"

  citations = () ->
    $(".left_research_side-view .cited-sources")

  sourceIdFromEl = (el) ->
    $(el).closest("._cite-bar").data("card-id")

  updateCitation = (action, sourceID) ->
    if (action == 'cite')
      citeSource sourceID
    else if (action == 'uncite')
      unciteSource sourceID

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
          "for #{years.toString()}. " + message

    response = window.confirm message
    addYearToSource($source, researchedYear) if response
    return response

  addYearToSource = ($source, year) ->
    $source.append yearHiddenInput($source, year)
    fancy = $source.find ".fancy-years"
    if fancy.is(":empty")
      fancy.html year
    else
      fancy.html (fancy.html().trim() + ", " + year)

  # adds a hidden input tag to cite bar so that source year will be added when
  # answer is submitted.
  yearHiddenInput = ($source, year) ->
    year_list = $source.data("year")
    year_list.push(year)
    year_list = year_list.map (year) -> "[[#{year}]]"
    $("<input>").attr("type", "hidden")
                .attr("name", "card[subcards][#{$source.data("card-name")}+year][content]")
                .attr("value", year_list.join("\n"))

  citedSourceInForm = (sourceID) ->
    $("form ._cite-bar[data-card-id='#{sourceID}']")

  possibleSource = (sourceID) ->
    $("#research_page-source.tab-pane .source-list > ._cite-bar[data-card-id='#{sourceID}']")

  citeSource = (sourceID) ->
    possible = possibleSource sourceID
    return false unless checkYearData(possible)
    $source = possible.clone(true)
    possible.hide()

    ctns = citations()
    ctns.empty() if ctns.text().search("None") > -1
    ctns.append($source)
    return true

  unciteSource = (sourceID) ->
    citedSourceInForm(sourceID).remove()
    ctns = citations()
    ctns.text("None") if ctns.is(':empty') || ctns.text().trim() == ""
    possibleSource(sourceID).show()

  updatePreviewSlot = (slot, sourceID) ->
    load_path = decko.slotPath(sourceID + "?view=preview")
    slot.updateSlot load_path

staticPreviewLink = "#Research_Page .TYPE-answer.titled-view .source-preview-link"

$(document).ready ->
  $('body').on 'click', '._cite-button', (event) ->
    wikirate.toggleCitation(this, 'cite')

  $('body').on 'click', '._uncite-button', (event) ->
    wikirate.toggleCitation(this, 'uncite')

  $("body").on 'click', staticPreviewLink, (event) ->
    wikirate.previewSource $(this).slot().data("card-name")
    wikirate.activateSourceBar $(this)
    event.preventDefault()

  $('body').on 'ajax:error', "#research_page-view_source > .card-slot", (event, xhr) ->
    $(this).find(".loader-anime").remove() # remove loader

  if $(staticPreviewLink)
    wikirate.activateSourceBar null

decko.slotReady (slot) ->
  if slot.find(".TYPE-answer.source_selector-view")[0]
    wikirate.hideAlreadyCited()
