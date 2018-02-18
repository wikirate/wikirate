$.extend wikirate,
  showResearchDetailsTab: (tab) ->
    tab = $("#research-details .nav-tabs a[href='#research_page-#{tab}']")
    tab.removeClass("d-none").tab('show')

  toggleCitation: (ele, action) ->
    sourceID =  $(ele).closest(".TYPE-source").data("card-id")
    citations = $("form .cited-sources")
    if citations.length == 0
      alert "Can't change citations. Answer is not in edit mode."
    else
      toggleCiteButtons(sourceID, action)
      if (action == 'cite')
        citeSource(sourceID, citations)
      else if (action == 'uncite')
        unciteSource(sourceID, citations)

  citeButtons = (sourceID) ->
    $("._citeable-source[data-card-id='#{sourceID}'] .c-btn")

  citedSourceInForm = (sourceID) ->
    $("form ._citeable-source[data-card-id='#{sourceID}']")

  possibleSource = (sourceID) ->
    $("#research_page-source.tab-pane ._citeable-source[data-card-id='#{sourceID}']:first")

  citeSource = (sourceID, citations) ->
    $source = possibleSource(sourceID).clone(true)

    citations.empty() if citations.text().search("None") > -1
    citations.append($source)

  unciteSource = (sourceID, citations) ->
    citedSourceInForm(sourceID).remove()
    citations.text("None") if citations.is(':empty') || citations.text().trim() == ""

  toggleCiteButtons = (sourceID, action) ->
    citeButtons(sourceID).each ->
      toggleCiteButton $(this), action

  toggleCiteButton = (ele, action) ->
    if (action == 'cite')
      $citedButton = ele.removeClass("_cite_button")
        .removeClass("btn-outline-primary")
        .addClass("_cited_button btn-primary").text("Cited!")
      $citedButton.hover ( ->
        $(this).text('Uncite!').addClass('btn-danger').removeClass('btn-primary')
      ), ->
        $(this).text('Cited!').removeClass('btn-danger').addClass("btn-primary")
    else
      $citedButton = ele.removeClass("_cited_button btn-primary")
                        .addClass("_cite_button btn-outline-primary")
                        .text("Cite!")
      $citedButton.unbind('mouseenter mouseleave')

$(document).ready ->
  $('body').on 'click', '._cite_button', (event) ->
    wikirate.toggleCitation(this, 'cite')
    event.stopPropagation() # don't open preview

  $('body').on 'click', '._cited_button', (event) ->
    wikirate.toggleCitation(this, 'uncite')
    event.stopPropagation() # don't open previews

#  $('body').on 'click', '._add_new_source', ->
#    wikirate.appendSourceForm($(this))

  $("body").on 'click', '.slot_machine-view.SELF-research_page .cited-view.TYPE-source, .source-details-toggle', ->
    wikirate.showResearchDetailsTab("view_source")
    sourceID = $(this).data("card-name")
    load_path = decko.slotPath(sourceID + "?view=source_and_preview")
    $slot = $("#research_page-view_source > .card-slot")
    $slot.empty()
    wikirate.loader($slot).add()
    $slot.updateSlot(load_path)

  $('body').on 'ajax:error', "#research_page-view_source > .card-slot", (event, xhr) ->
    $(this).find(".loader-anime").remove() # remove loader

#      wikirate.handleYearData($parentForm, sourceYear)
