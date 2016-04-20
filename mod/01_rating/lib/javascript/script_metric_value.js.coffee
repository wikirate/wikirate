$(document).ready ->
  $loader_anime = $("#ajax_loader").html()
  $('body').on 'click','._new_value_next', ->
    $parent_slot = $(this).slot()
    company = $(".RIGHT-company .input-group input").val()
    metric  = $(".RIGHT-metric select").val()
    company = Array.isArray(company) && company[0] || company
    company = encodeURIComponent(company.replace('.',''))
    metric = metric.map((obj) ->
      obj = '&metric[]=' + encodeURIComponent(obj)
      obj
    ).join('')
    # metric  = encodeURIComponent(metric)
    if(company&&metric)
      $parent_slot.append($loader_anime)
      location.href = wagn.prepUrl(wagn.rootPath + '/' + company +
                                  '?view=new_metric_value' + metric)
      # load_path = wagn.prepUrl(wagn.rootPath + '/' + company +
      #                          '?view=new_metric_value' + metric)
      # $parent_slot.append($loader_anime)
      # $.get load_path, (data) ->
      #   $parent_slot.replaceWith(data)
      #   $parent_slot.trigger('slotReady')
      #   $('._add_new_value').trigger 'click'

  stickSourcePreview = () ->
    $previewContainer = $("#source-preview-main")
    if $(document).scrollTop() > 56
      $previewContainer.addClass 'stick-right'
    else
      $previewContainer.removeClass 'stick-right'

    if($(window).scrollTop() > ($("#main").height()-$(window).height()+300))
      $previewContainer.removeClass("stick-right")

  $(window).scroll ->
    if($("#source-preview-main").length>0)
      stickSourcePreview()

  appendSourceForm = (company) ->

    $source_target = $("#source-form-container")
    $sourceForm     = $source_target.find('form')
    $loaderThing    = $source_target.find('.loader-anime')
    if(!$sourceForm.length > 0 && !$loaderThing.length > 0)
      load_path_source = wagn.prepUrl(wagn.rootPath +
                                      "/new/source?preview=true&slot[company]="+
                                      company)
      $source_target.find('.source-details').addClass('hide')
      $source_target.append($loader_anime)
      $.get(load_path_source, ((data) ->
        # $sourceCntr     = $("#source-form-container")
        $source_target.prepend(data)
        wagn.initializeEditors($source_target)
        $source_target.find(".loader-anime").remove()
        $source_target.find('form').trigger('slotReady')
        return
      ), 'html').fail((xhr,d,e) ->
        $source_target.find(".loader-anime").remove()
      )
    else
      $source_target.find('form').removeClass('hide')
      $source_target.find('.source-details').addClass('hide')

  appendSourceDetails = (sourceID) ->
    $source_target = $("#source-form-container")
    load_path = wagn.prepUrl(wagn.rootPath + sourceID +
                                    "?view=source_and_preview")
    $source_target.append($loader_anime)
    $.get(load_path, ((data) ->
      $source_target.prepend(data)
      $source_target.find(".loader-anime").remove()
      return
    ), 'html').fail((xhr,d,e) ->
      $source_target.find(".loader-anime").remove()
    )

  $('body').on 'ajax:success',
  '[data-form-for="new_metric_value"]',
  (event, data) ->
    $container      = $(".timeline-row .card-slot form .relevant-sources ")
    $container      = $container.empty() if $container.text().search("None") >-1
    sourceID        = $(data).data('source-for')
    sourceInList    = "[data-source-for='"+sourceID+"']"
    $sourceInForm   = $('.timeline-row form')
                      .find(sourceInList+'.source-details-toggle')

    #check if the source already exist in new value form.
    if(!$sourceInForm.length > 0)
      $('.source-details-toggle').removeClass('active')
      $sourceDetailsToggle = $('<div>')
                            .attr('data-source-for',sourceID)
                            .addClass('source-details-toggle active')
      $sourceDetailsToggle.append($(data)
        .find(".source-info-container").parent())
      $container.append($sourceDetailsToggle)
      pageName  = $("#source-name").html()
      url       = $("#source_url").html()
      # testSameOrigin(url) if (url)
    else
      $citeButton = $sourceInForm.find('._cite_button')
      if(!$citeButton.length > 0)
        $citeButton   = $(sourceInList+'.source-details').find('._cite_button')
        sourceCiteButtons($citeButton, 'cite')

  $("body").on 'click', '.source-details-toggle', ->
    $this           = $(this)
    sourceID        = $this.data("source-for")
    sourcePreview   = "[data-source-for='"+sourceID+"']"
    $sourceCntr     = $("#source-form-container")
    $loaderThing    = $sourceCntr.find('.loader-anime')
    if (!$loaderThing.length > 0)
      $('.source-details-toggle').removeClass('active')
      $this.addClass("active")
      $sourceCntr.find('.source-details').addClass('hide')
      $sourcePreview = $sourceCntr.find(sourcePreview)
      $sourceCntr.find('form').addClass('hide')
      if($sourcePreview.length > 0)
        $sourcePreview.removeClass('hide')
      else
        appendSourceDetails(sourceID)


  $('body').on 'click', '._cite_button', ->
    sourceCitation(this, 'cite')

  $('body').on 'click', '._cited_button', ->
    sourceCitation(this, 'uncite')

  sourceCitation = (ele, action) ->
    $this               = $(ele)
    $timelineContainer   = $this.closest(".timeline-row .card-slot form")
    if !$timelineContainer.length > 0 and
      $(ele).closest('#source-form-container')
        $timelineContainer = $('.timeline-row .card-slot>form')
    $relSource          = $timelineContainer.find(".relevant-sources")
    $citedSource        = $timelineContainer.find(".cited-sources")
    sourceName          = $this.closest(".TYPE-source").data("card-name")
    sourceID            = "#"+$this.closest(".TYPE-source")
                            .attr("id")+".TYPE-source:first"
    $sourceContainer    = $timelineContainer.find(sourceID).parent().detach()
    $sourceFormContr    = $('#source-form-container').find(sourceID)
    $hiddenInput        = $('<input>').attr('type','hidden')
                          .addClass('pointer-select')
                            # .attr('name','card[subcards][+source][content]')
    if(action =='cite')
      $([$sourceFormContr.find("._cite_button"),
        $sourceContainer.find("._cite_button"), ]).each ->
          sourceCiteButtons($(this),action)

      $citedSource.empty() if $citedSource.text().search("None") > -1
      $hiddenInput.attr('value',sourceName)
      $sourceContainer.append($hiddenInput)
      $citedSource.append($sourceContainer.first())
      $relSource.text("None") if $relSource.is(':empty')

     if(action == 'uncite')
       $([$sourceFormContr.find("._cited_button"),
        $sourceContainer.find("._cited_button"), ]).each ->
          sourceCiteButtons($(this), action)

       $sourceContainer.find('input').remove()
       $relSource.empty() if $relSource.text().search("None") > -1
       $relSource.append($sourceContainer.first())
       $citedSource.text("None") if $citedSource.is(':empty')

  sourceCiteButtons = (ele,action) ->
    if(action == 'cite')
      $citedButton = ele.removeClass("_cite_button btn-highlight")
                      .addClass("_cited_button btn-default").text("Cited!")
      $citedButton.hover ( ->
        $(this).text('Uncite!')
      ), ->
        $(this).text('Cited!')
    else
      $citedButton = ele.removeClass("_cited_button btn-default")
                      .addClass("_cite_button btn-highlight").text("Cite!")
      $citedButton.unbind('mouseenter mouseleave')



  $('body').on 'click', '._add_new_source', ->
    $this           = $(this)
    company         = $this.closest('form')
                        .find('#card_subcards__company_content').attr('value')
    appendSourceForm(company)

  $('body').on 'click', '._add_new_value', ->
    $this     = $(this)
    company   = $this.data("company")
    metric    = $this.data("metric")
    $target   = $this.closest('.timeline-data')
    $page     = if $('.TYPE-company.open-view').length > 0
                  $('.TYPE-company.open-view')
                else $('.TYPE-metric.open-view')
    if(company && metric)
      $target.append($loader_anime)
      if ($page.length>0)
        location.href = wagn.prepUrl(wagn.rootPath + '/' +
                                     encodeURIComponent(company) +
                                     '?view=new_metric_value&metric[]=' +
                                     encodeURIComponent(metric))
      else
        load_path = wagn.prepUrl(wagn.rootPath +
                               "/new/metric_value?noframe=true&slot[company]="+
                               encodeURIComponent(company)+"&slot[metric]="+
                               encodeURIComponent(metric))
        $template = $('<div>').addClass('timeline-row')
        $template = $template.append($('<div>').addClass('card-slot'))
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
          $target.find(".loader-anime").remove()
        )
        appendSourceForm(company)
  $('._add_new_value:first').trigger 'click'

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


wagn.slotReady (slot) ->
  add_val_form = slot.find('.timeline-row .card-slot>form').is(':visible')
  if add_val_form then slot.find('._add_new_value').hide()
  else slot.find('._add_new_value').show()
  resizeIframe()
