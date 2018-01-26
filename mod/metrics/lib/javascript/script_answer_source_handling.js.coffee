$.extend wikirate,
#  prepareSourceAppend: (data) ->
#    $source_form_container = $("#source-form-container")
#    pageName = $(data).find('#source-name').text()
#    url = $(data).find('#source_url').text()
#    resizeIframe($source_form_container)
#    testSameOrigin(url, pageName) if (url)

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


#  appendSourceDetails: (sourceID) ->
#    $source_form_container = $("#source-form-container")
#    load_path = decko.prepUrl(decko.rootPath + sourceID + "?view=source_and_preview")
#    $loader = wikirate.loader($source_form_container)
#    $loader.add()
#    $.get(load_path, ((data) ->
#      $(data).find('#source_url').text()
#      $source_form_container.prepend(data)
#      wikirate.prepareSourceAppend(data)
#      $loader.remove()
#      return
#    ), 'html').fail((xhr, d, e) ->
#      $loader.remove()
#    )

  citeButtons = (sourceID) ->
    $(".TYPE-source[data-card-id='#{sourceID}'] .c-btn")

  citedSourceInForm = (sourceID) ->
    $("form .relevant-view.TYPE-source[data-card-id='#{sourceID}']")

  possibleSource = (sourceID) -> \
    $(".source_tab-view.SELF-research_page .relevant-view.TYPE-source[data-card-id='#{sourceID}']")

  citeSource = (sourceID, citations) ->
    $source = possibleSource(sourceID).clone(true)

    hiddenInput = $('<input>').addClass('pointer-select')
                              .attr('type', 'hidden')
                              .attr('value', $source.data("card-name"))
    $source.append(hiddenInput)

    citations.empty() if citations.text().search("None") > -1
    citations.append($source)

  unciteSource = (sourceID, citations) ->
    citedSourceInForm(sourceID).remove()
    citations.text("None") if citations.is(':empty') || citations.text() == ""

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

# add or show source form on the right side
#  appendSourceForm: ($button) ->
#    $source_form_container = $("#source-form-container")
#    $sourceForm = $source_form_container.find('form')
#    $loader = wikirate.loader($source_form_container)
#    $sourceDetails = $source_form_container.find('.source-details')
#    if(!$sourceForm.exists() && !$loader.isLoading())
#      $('._blank_state_message').remove()
#      load_path_source = $button.data("url")
#      $sourceDetails.addClass('hide')
#      $loader.add()
#
#      $.get(load_path_source, ((data) ->
#        $source_form_container.prepend(data)
#        decko.initializeEditors($source_form_container)
#        $sourceForm = $source_form_container.find('form')
#        $sourceForm.trigger('slotReady')
#        $loader.remove()
#        return
#      ), 'html').fail((xhr, d, e) ->
#        $loader.remove()
#      )
#    else
#      $sourceForm.removeClass('hide')
#      $sourceDetails.addClass('hide')

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
    view_source_tab = $('#research-details .nav-tabs a[href="#research_page-view_source"]')
    view_source_tab.removeClass("d-none").tab('show')
    sourceID = $(this).data("card-name")
    load_path = decko.prepUrl(decko.rootPath + sourceID + "?view=source_and_preview")
    $slot = $("#research_page-view_source > .card-slot")
    $slot.empty()
    wikirate.loader($slot).add()
    $slot.updateSlot(load_path)

  $('body').on 'ajax:error', "#research_page-view_source > .card-slot", (event, xhr) ->
    $(this).find(".loader-anime").remove() # remove loader


#    $source_form_container = $("#source-form-container")
#    sourceYear = parseInt($this.data("year"))
#    sourceSelector = "[data-source-for='" + sourceID + "']"
#    # $sourceCntr     = $("#source-form-container")
#    $loader = wikirate.loader($source_form_container)
#    $parentForm = $this.closest('form')
#
#    if (!$loader.isLoading())
#      $('._blank_state_message').remove()
#      $('.source-details-toggle').removeClass('active')
#      $(sourceSelector + '.source-details-toggle').addClass('active')
#      # $this.addClass("active")
#      $source_form_container.find('.source-details').addClass('hide')
#      $sourcePreview = $source_form_container.find(sourceSelector)
#      $source_form_container.find('form').addClass('hide')
#      wikirate.handleYearData($parentForm, sourceYear)
#
#      if($sourcePreview.exists())
#        $sourcePreview.removeClass('hide')
#      else
#        wikirate.appendSourceDetails(sourceID)
