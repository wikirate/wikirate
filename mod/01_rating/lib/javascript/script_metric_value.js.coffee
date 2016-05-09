$(document).ready ->
  $loader_anime = $("#ajax_loader").html()
  $source_form_container = $("#source-form-container")

  stickSourcePreview = () ->
    $previewContainer = $("#source-preview-main")
    if $(document).scrollTop() > 56
      $previewContainer.addClass 'stick-right'
    else
      $previewContainer.removeClass 'stick-right'

    if($(window).scrollTop() > ($("#main").height()-$(window).height()+300))
      $previewContainer.removeClass("stick-right")

  appendSourceForm = (company) ->
    $sourceForm     = $source_form_container.find('form')
    $loaderThing    = $source_form_container.find('.loader-anime')
    $sourceDetails  = $source_form_container.find('.source-details')
    if(!$sourceForm.exists() && !$loaderThing.exists())
      load_path_source = wagn.prepUrl(wagn.rootPath +
                                      "/new/source?preview=true&slot[company]="+
                                      company)
      $sourceDetails.addClass('hide')
      $source_form_container.append($loader_anime)
      $loaderThing  = $source_form_container.find('.loader-anime')

      $.get(load_path_source, ((data) ->
        $source_form_container.prepend(data)
        wagn.initializeEditors($source_form_container)
        $sourceForm.trigger('slotReady')
        $loaderThing.remove()
        return
      ), 'html').fail((xhr,d,e) ->
        $loaderThing.remove()
      )
    else
      $sourceForm.removeClass('hide')
      $sourceDetails.addClass('hide')

  appendNewValueForm = ($this) ->
    company   = encodeURIComponent($this.data("company"))
    metric    = encodeURIComponent($this.data("metric"))
    $target   = $this.closest('.timeline-data')
    $page     = if $('.TYPE-company.open-view').exists()
                  $('.TYPE-company.open-view')
                else $('.TYPE-metric.open-view')
    if(company && metric)
      $target.append($loader_anime)
      $('._blank_state_message').remove()
      if ($page.length>0)
        location.href = wagn.prepUrl(wagn.rootPath + '/' + company +
                                     '?view=new_metric_value&metric[]=' +
                                     metric)
      else
        source = $.urlParam('source')
        if source != null
          source = '&slot[source]=' + source
        else
          source = ''
        load_path = wagn.prepUrl(wagn.rootPath +
                               "/new/metric_value?noframe=true&slot[company]="+
                               company + "&slot[metric]=" + metric + source)

        $template = $('<div>').addClass('timeline-row new-value-form')
        $template = $template.append($('<div>')
                    .addClass('card-slot '))
        $.get(load_path, ((data) ->
          $template.find('.card-slot').append(data)
          # $target.find(".timeline-header").after($template)
          $this.hide()
          wagn.initializeEditors($target)
          $target.find(".loader-anime").remove()
          return
        ), 'html').fail((xhr,d,e) ->
          $template.find('.card-slot').append(xhr.responseText)
        ).always( ->
          $target.find(".timeline-header").after($template)
          wagn.initializeEditors($target)
          $template.find('.card-slot').trigger('slotReady')
          $target.find(".loader-anime").remove()
        )
        appendSourceForm(company)

  appendSourceDetails = (sourceID) ->
    load_path = wagn.prepUrl(wagn.rootPath + sourceID +
                                    "?view=source_and_preview")
    $source_form_container.append($loader_anime)
    $.get(load_path, ((data) ->
      $source_form_container.prepend(data)
      resizeIframe($source_form_container)
      $source_form_container.find(".loader-anime").remove()
      return
    ), 'html').fail((xhr,d,e) ->
      $source_form_container.find(".loader-anime").remove()
    )

  sourceCitation = (ele, action) ->
    $this                = $(ele)
    $timelineContainer   = $this.closest(".timeline-row .card-slot form")
    sourceID             = "#"+$this.closest(".TYPE-source")
                            .attr("id")+".TYPE-source:first"

    if !$timelineContainer.exists() and
      $(ele).closest('#source-form-container')
        $timelineContainer = $('.timeline-row .card-slot>form')
    args =
      $relSource        : $timelineContainer.find(".relevant-sources")
      $citedSource      : $timelineContainer.find(".cited-sources")
      sourceName        : $this.closest(".TYPE-source").data("card-name")
      $sourceContainer  : $timelineContainer.find(sourceID).parent().detach()
      $sourceFormContr  : $source_form_container.find(sourceID)
      $hiddenInput      : $('<input>').attr('type','hidden')
                            .addClass('pointer-select')
                            # .attr('name','card[subcards][+source][content]')
    if(action =='cite')
      citeSource(args)
    if(action == 'uncite')
      unciteSource(args)

  citeSource = (args) ->
    $([args.$sourceFormContr.find("._cite_button"),
      args.$sourceContainer.find("._cite_button"), ]).each ->
        sourceCiteButtons($(this),'cite')

    args.$citedSource.empty() if args.$citedSource.text().search("None") > -1
    args.$hiddenInput.attr('value',args.sourceName)
    args.$sourceContainer.append(args.$hiddenInput)
    args.$citedSource.append(args.$sourceContainer.first())
    args.$relSource.text("None") if args.$relSource.is(':empty')

  unciteSource = (args) ->
    $([args.$sourceFormContr.find("._cited_button"),
     args.$sourceContainer.find("._cited_button"), ]).each ->
       sourceCiteButtons($(this), 'uncite')

    args.$sourceContainer.find('input').remove()
    args.$relSource.empty() if args.$relSource.text().search("None") > -1
    args.$relSource.append(args.$sourceContainer.first())
    args.$citedSource.text("None") if args.$citedSource.is(':empty')


  sourceCiteButtons = (ele,action) ->
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

  valueChecking = (ele, action) ->
    path = encodeURIComponent(ele.data('path'))
    action = '?' + action + '=true'
    load_path = wagn.prepUrl(wagn.rootPath + '/update/' + path + action )
    $parent = ele.closest('.double-check')
    $parent = ele.closest('.RIGHT-checked_by') unless $parent.exists()
    $parent.html('loading...')
    $.get(load_path, ((data) ->
      content = $(data).find('.card-body').html()
      $parent.empty().html(content)
    ), 'html').fail((xhr,d,e) ->
      $parent.html('Error')
    )

  $('body').on 'click','._view_methodology', ->
    $(this).text (i, old) ->
      btn_txt = 'View Methodology'
      if old == btn_txt then 'Hide Methodology' else btn_txt

  $('body').on 'click','._value_check_button', ->
    valueChecking($(this), 'checked')

  $('body').on 'click','._value_uncheck_button', ->
    valueChecking($(this), 'uncheck')

  $('body').on 'click','._new_value_next', ->
    $parent_slot = $(this).slot()
    company = $(".RIGHT-company .input-group input").val()
    metric  = $(".RIGHT-metric select").val()
    source  = $("#card_hidden_source").val()
    company = Array.isArray(company) && company[0] || company
    company = encodeURIComponent(company.replace('.',''))
    metric = metric.map((obj) ->
      obj = '&metric[]=' + encodeURIComponent(obj)
      obj
    ).join('')
    if source != undefined
      source = '&source=' + source
    else
      source = ''
    # metric  = encodeURIComponent(metric)
    if(company&&metric)
      $parent_slot.append($loader_anime)
      location.href = wagn.prepUrl(wagn.rootPath + '/' + company +
                                  '?view=new_metric_value' + metric + source)

  $('body').on 'ajax:success',
  '[data-form-for="new_metric_value"]',
  (event, data) ->
    $parentForm     = $(".timeline-row .card-slot form")
    $container      = $parentForm.find(".relevant-sources")
    $container      = $container.empty() if $container.text().search("None") >-1
    sourceID        = $(data).data('source-for')
    sourceYear      = parseInt($(data).data('year'))
    sourceInList    = "[data-source-for='"+sourceID+"']"
    $sourceInForm   = $('.timeline-row form')
                      .find(sourceInList+'.source-details-toggle')

    #check if the source already exist in new value form.
    if(!$sourceInForm.exists())
      $('.source-details-toggle').removeClass('active')
      $sourceDetailsToggle = $('<div>')
                            .attr('data-source-for',sourceID)
                            .attr('data-year', sourceYear)
                            .addClass('source-details-toggle active')
      $sourceDetailsToggle.append($(data)
        .find(".source-info-container").parent())

      # TODO: following statement must be handled in the backend.
      $sourceDetailsToggle.find('.STRUCTURE-source_link')
        .find('a.known-card, a.source-preview-link').replaceWith ->
          $ '<span>' + $(this).html() + '</span>'
      $container.append($sourceDetailsToggle)
      handleYearData($parentForm, sourceYear)
      pageName  = $("#source-name").html()
      url       = $("#source_url").html()

      resizeIframe()
      testSameOrigin(url, pageName) if (url)
    else
      $citeButton = $sourceInForm.find('._cite_button')
      if(!$citeButton.exists())
        $citeButton   = $(sourceInList+'.source-details').find('._cite_button')
        sourceCiteButtons($citeButton, 'cite')

  $("body").on 'click', '.source-details-toggle', ->
    $this           = $(this)
    sourceID        = $this.data("source-for")
    sourceYear      = parseInt($this.data("year"))
    sourceSelector  = "[data-source-for='"+sourceID+"']"
    $sourceCntr     = $("#source-form-container")
    $loaderThing    = $sourceCntr.find('.loader-anime')
    $parentForm     = $this.closest('form')
    if (!$loaderThing.exists())
      $('.source-details-toggle').removeClass('active')
      $(sourceSelector+'.source-details-toggle').addClass('active')
      # $this.addClass("active")
      $sourceCntr.find('.source-details').addClass('hide')
      $sourcePreview = $sourceCntr.find(sourceSelector)
      $sourceCntr.find('form').addClass('hide')
      handleYearData($parentForm, sourceYear)
      if($sourcePreview.exists())
        $sourcePreview.removeClass('hide')
      else
        appendSourceDetails(sourceID)

  handleYearData = (ele, sourceYear) ->
    $input = ele.find('.year input#pointer_item')
    return unless $input.exists()
    inputYear = $input.val()
    NaNi = !isNaN(sourceYear)
    updateInput = ->
      ele.find('.year input#pointer_item').val(sourceYear) if NaNi
    updateInput() if inputYear.trim() == ""
    if inputYear.trim() != "" && NaNi && (parseInt(inputYear) != sourceYear)
      message = 'Note: This source is for ' + inputYear +
                ' Would you like to change the year of this' +
                ' answer to ' + sourceYear + '?'
      response = window.confirm(message)
      if response
        updateInput()

  $('body').on 'click', '._cite_button', ->
    sourceCitation(this, 'cite')

  $('body').on 'click', '._cited_button', ->
    sourceCitation(this, 'uncite')

  $('body').on 'click', '._add_new_source', ->
    $this           = $(this)
    company         = $this.closest('form')
                        .find('#card_subcards__company_content').attr('value')
    appendSourceForm(company)

  $('body').on 'click', '._add_new_value', ->
    $form = $(this).closest('.timeline-row')
            .siblings('.new-value-form').find('form')
    if $form.exists() && $form.hasClass('hide')
      $form.removeClass('hide')
      $(this).hide()
    else
      appendNewValueForm($(this))

  $('._add_new_value:first').trigger 'click' if $('.metric-row').length == 1

  $('body').on 'click', '._form_close_button', ->
    $form = $(this).closest('.new-value-form')
    $form.find('form').addClass('hide')
    $form.closest('.timeline-body')
          .find('.timeline-header ._add_new_value').show()

  $('body').on 'click.collapse-next', '[data-toggle=collapse-next]', ->
    $this     = $(this)
    parent    = $this.data("parent")
    collapse  = $this.data("collapse")+".collapse"
    $target   = $this.closest(parent).find(collapse)

    if !$target.data('collapse')
      $target.collapse('toggle').on('shown.bs.collapse', ->
        $this.parent().find('.fa-caret-right ')
                      .removeClass('fa-caret-right ')
                      .addClass 'fa-caret-down'
      ).on 'hidden.bs.collapse', ->
        $this.parent().find('.fa-caret-down')
                      .removeClass('fa-caret-right')
                      .addClass 'fa-caret-right'

  $(window).scroll ->
    if($("#source-preview-main").exists())
      stickSourcePreview()

#get url param
$.urlParam = (name) ->
  results = new RegExp('[?&]' + name + '=([^&#]*)').exec(window.location.href)
  if results == null
    null
  else
    results[1] or 0

wagn.slotReady (slot) ->
  add_val_form = slot.find('.timeline-row .card-slot>form').is(':visible')
  if add_val_form then slot.find('._add_new_value').hide()
  else slot.find('._add_new_value').show()
  resizeIframe(slot)

jQuery.fn.exists = -> return this.length>0
