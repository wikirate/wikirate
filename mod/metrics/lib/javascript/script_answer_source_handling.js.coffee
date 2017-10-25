$.extend wikirate,
  prepareSourceAppend: (data) ->
    $source_form_container = $("#source-form-container")
    pageName = $(data).find('#source-name').text()
    url = $(data).find('#source_url').text()
    resizeIframe($source_form_container)
    testSameOrigin(url, pageName) if (url)

  sourceCitation: (ele, action) ->
    $source_form_container = $("#source-form-container")
    $this = $(ele)
    $timelineContainer = $this.closest("form")
    sourceID = "#" + $this.closest(".TYPE-source").attr("id") + ".TYPE-source:first"

    if !$timelineContainer.exists() and $(ele).closest('#source-form-container')
      $timelineContainer = $('.record-row .card-slot>form')
    args =
      $relSource: $timelineContainer.find(".relevant-sources")
      $citedSource: $timelineContainer.find(".cited-sources")
      sourceName: $this.closest(".TYPE-source").data("card-name")
      $sourceContainer: $timelineContainer.find(sourceID).parent().detach()
      $sourceFormContr: $source_form_container.find(sourceID)
      $hiddenInput: $('<input>').attr('type', 'hidden')
        .addClass('pointer-select')
    # .attr('name','card[subcards][+source][content]')
    if(action == 'cite')
      citeSource(args)
    if(action == 'uncite')
      unciteSource(args)

  appendSourceDetails: (sourceID) ->
    $source_form_container = $("#source-form-container")
    load_path = decko.prepUrl(decko.rootPath + sourceID +
        "?view=source_and_preview")
    $loader = wikirate.loader($source_form_container)
    $loader.add()
    $.get(load_path, ((data) ->
      $(data).find('#source_url').text()
      $source_form_container.prepend(data)
      wikirate.prepareSourceAppend(data)
      $loader.remove()
      return
    ), 'html').fail((xhr, d, e) ->
      $loader.remove()
    )

  citeSource = (args) ->
    $([args.$sourceFormContr.find("._cite_button"),
      args.$sourceContainer.find("._cite_button"),]).each ->
        sourceCiteButtons($(this), 'cite')

    args.$citedSource.empty() if args.$citedSource.text().search("None") > -1
    args.$hiddenInput.attr('value', args.sourceName)
    args.$sourceContainer.append(args.$hiddenInput)
    args.$citedSource.append(args.$sourceContainer.first())
    args.$relSource.text("None") if args.$relSource.is(':empty')

  unciteSource = (args) ->
    $([args.$sourceFormContr.find("._cited_button"),
      args.$sourceContainer.find("._cited_button"),]).each ->
      sourceCiteButtons($(this), 'uncite')

    args.$sourceContainer.find('input').remove()
    args.$relSource.empty() if args.$relSource.text().search("None") > -1
    args.$relSource.append(args.$sourceContainer.first())
    args.$citedSource.text("None") if args.$citedSource.is(':empty')

  sourceCiteButtons = (ele, action) ->
    if(action == 'cite')
      $citedButton = ele.removeClass("_cite_button btn-highlight")
        .addClass("_cited_button btn-success").text("Cited!")
      $citedButton.hover ( ->
        $(this).text('Uncite!').addClass('btn-default')
      ), ->
        $(this).text('Cited!').removeClass('btn-default')
    else
      $citedButton = ele.removeClass("_cited_button btn-success")
        .addClass("_cite_button btn-highlight").text("Cite!")
      $citedButton.unbind('mouseenter mouseleave')

# add or show source form on the right side
  appendSourceForm: ($button) ->
    $source_form_container = $("#source-form-container")
    $sourceForm = $source_form_container.find('form')
    $loader = wikirate.loader($source_form_container)
    $sourceDetails = $source_form_container.find('.source-details')
    if(!$sourceForm.exists() && !$loader.isLoading())
      $('._blank_state_message').remove()
      load_path_source = $button.data("url")
      $sourceDetails.addClass('hide')
      $loader.add()

      $.get(load_path_source, ((data) ->
        $source_form_container.prepend(data)
        decko.initializeEditors($source_form_container)
        $sourceForm = $source_form_container.find('form')
        $sourceForm.trigger('slotReady')
        $loader.remove()
        return
      ), 'html').fail((xhr, d, e) ->
        $loader.remove()
      )
    else
      $sourceForm.removeClass('hide')
      $sourceDetails.addClass('hide')

$(document).ready ->
  $('body').on 'click', '._cite_button', ->
    wikirate.sourceCitation(this, 'cite')

  $('body').on 'click', '._cited_button', ->
    wikirate.sourceCitation(this, 'uncite')

  $('body').on 'click', '._add_new_source', ->
    wikirate.appendSourceForm($(this))

  $("body").on 'click', '.source-details-toggle', ->
    $source_form_container = $("#source-form-container")
    $this = $(this)
    sourceID = $this.data("source-for")
    sourceYear = parseInt($this.data("year"))
    sourceSelector = "[data-source-for='" + sourceID + "']"
    # $sourceCntr     = $("#source-form-container")
    $loader = wikirate.loader($source_form_container)
    $parentForm = $this.closest('form')

    if (!$loader.isLoading())
      $('._blank_state_message').remove()
      $('.source-details-toggle').removeClass('active')
      $(sourceSelector + '.source-details-toggle').addClass('active')
      # $this.addClass("active")
      $source_form_container.find('.source-details').addClass('hide')
      $sourcePreview = $source_form_container.find(sourceSelector)
      $source_form_container.find('form').addClass('hide')
      wikirate.handleYearData($parentForm, sourceYear)
      if($sourcePreview.exists())
        $sourcePreview.removeClass('hide')
      else
        wikirate.appendSourceDetails(sourceID)
