$.extend wikirate,
#  prepareSourceAppend: (data) ->
#    $source_form_container = $("#source-form-container")
#    pageName = $(data).find('#source-name').text()
#    url = $(data).find('#source_url').text()
#    resizeIframe($source_form_container)
#    testSameOrigin(url, pageName) if (url)

  toggleCitation: (ele, action) ->
    sourceID =  $(ele).closest(".TYPE-source").data("card-id")
    citations = $("form.new-value-form .cited-sources")

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
    $("form.new-value-form .relevant-view.TYPE-source[data-card-id='#{sourceID}']")

  possibleSource = (sourceID) -> \
    $(".source_tab-view.SELF-research_page .relevant-view.TYPE-source[data-card-id='#{sourceID}']")

  citeSource = (sourceID, citations) ->
    $source = possibleSource(sourceID)
    $sourceContainer = $source.parent().clone() #.detach()

    hiddenInput = $('<input>').addClass('pointer-select')
                              .attr('type', 'hidden')
                              .attr('value', $source.data("card-name"))
    $sourceContainer.append(hiddenInput)

    citations.empty() if citations.text().search("None") > -1
    citations.append($sourceContainer)

  unciteSource = (sourceID, citations) ->
    citedSourceInForm(sourceID).remove()
    citations.text("None") if citations.is(':empty') || citations.text() == ""

  toggleCiteButtons = (sourceID, action) ->
    citeButtons(sourceID).each ->
      toggleCiteButton $(this), action

  toggleCiteButton = (ele, action) ->
    if (action == 'cite')
      $citedButton = ele.removeClass("_cite_button btn-highlight")
        .addClass("_cited_button btn-success").text("Cited!")
      $citedButton.hover ( ->
        $(this).text('Uncite!').addClass('btn-secondary')
      ), ->
        $(this).text('Cited!').removeClass('btn-secondary')
    else
      $citedButton = ele.removeClass("_cited_button btn-success")
                        .addClass("_cite_button btn-highlight")
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
  $('body').on 'click', '._cite_button', ->
    wikirate.toggleCitation(this, 'cite')

  $('body').on 'click', '._cited_button', ->
    wikirate.toggleCitation(this, 'uncite')

#  $('body').on 'click', '._add_new_source', ->
#    wikirate.appendSourceForm($(this))

  $("body").on 'click', '.source-details-toggle', ->
    $('#research-details .nav-tabs a[href="#research_page-source_preview"]').tab('show')
    sourceID = $(this).data("source-for")
    load_path = decko.prepUrl(decko.rootPath + sourceID + "?view=source_and_preview")
    $slot = $("#research_page-source_preview > .card-slot")
    $slot.empty()
    wikirate.loader($slot).add()
    $slot.updateSlot(load_path)

  $('body').on 'ajax:error', "#research_page-source_preview > .card-slot", (event, xhr) ->
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
