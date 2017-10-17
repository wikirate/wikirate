$.extend wikirate,

# Hides the "Add answer" button and loads the form.
# don't know what the source stuff is doing -pk
  appendNewValueForm: ($button) ->
    $form_slot = $button.parent().parent().find('.card-slot.answer_table-view')
    $loader = wikirate.loader($form_slot, true)
    $loader.add()
    $button.hide()

    source = $.urlParam('source')
    if source != null
      source = '&source=' + source
    else
      source = ''

    load_path = decko.prepUrl($button.data("url") + source)

    $.get(load_path, ((data) ->
      $form_slot.prepend(data)
      decko.initializeEditors($form_slot)
      $form_slot.trigger('slotReady')
      $loader.remove()
    ), "html").fail((xhr, d, e) ->
      $loader.remove()
      $form_slot.prepend(xhr.responseText)
    )

  handleYearData: (ele, sourceYear) ->
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


  valueChecking: (ele, action) ->
    path = encodeURIComponent(ele.data('path'))
    action = '?set_flag=' + action
    load_path = decko.prepUrl(decko.rootPath + '/update/' + path + action)
    $parent = ele.closest('.double-check')
    $parent = ele.closest('.RIGHT-checked_by') unless $parent.exists()
    $parent.html('loading...')
    $.get(load_path, ((data) ->
      content = $(data).find('.d0-card-body').html()
      $parent.empty().html(content)
    ), 'html').fail((xhr, d, e) ->
      $parent.html('please <a href=/*signin>sign in</a>')
    )

$(document).ready ->
  $loader_anime = $("#ajax_loader").html()

  # $(window).scroll ->
  #   if($("#source-preview-main").exists())
  #     stickContent()

  $('body').on 'click', '._toggle_button_text', ->
    $(this).text (i, old_txt) ->
      new_txt = $(this).data("toggle-text")
      $(this).data("toggle-text", old_txt)
      new_txt

  $('body').on 'click','._value_check_button', ->
    wikirate.valueChecking($(this), 'checked')

  $('body').on 'click','._value_uncheck_button', ->
    wikirate.valueChecking($(this), 'not-checked')

  $('body').on 'click', '._add_new_value', ->
    $form = $(this).closest('.record-row')
      .find('.card-slot.new_answer_form-view form')
    if $form.exists() && $form.hasClass('hide')
      $form.removeClass('hide')
      $(this).hide()
    else
      wikirate.appendNewValueForm($(this))

  $('body').on 'click', '._form_close_button', ->
    $(this).closest('form').addClass('hide')
    $(this).closest('.record-row').find('._add_new_value').show()

  $('body').on 'ajax:success',
  '[data-form-for="new_metric_value"]',
  (event, data) ->
    $parentForm     = $("form.new-value-form")
    $container      = $parentForm.find(".relevant-sources")
    $container      = $container.empty() if $container.text().search("None") >-1
    sourceID        = $(data).data('source-for')
    sourceYear      = parseInt($(data).data('year'))
    sourceInList    = "[data-source-for='"+sourceID+"']"
    $sourceInForm   = $('form.new-value-form')
                      .find(sourceInList+'.source-details-toggle')

    #check if the source already exist in new value form.
    if(!$sourceInForm.exists())
      $('.source-details-toggle').removeClass('active')
      $sourceDetailsToggle = $('<div>').attr('data-source-for',sourceID)
                            .attr('data-year', sourceYear)
                            .addClass('source-details-toggle active')
      $sourceDetailsToggle.append($(data)
        .find(".source-info-container").parent())

      # TODO: following statement must be handled in the backend.
      $sourceDetailsToggle.find('.source-link')
        .find('a.known-card, a.source-preview-link').replaceWith ->
          $ '<span>' + $(this).html() + '</span>'
      $container.append($sourceDetailsToggle)
      wikirate.handleYearData($parentForm, sourceYear)
      wikirate.prepareSourceAppend(data)
    else
      $citeButton = $sourceInForm.find('._cite_button')
      if(!$citeButton.exists())
        $citeButton   = $(sourceInList+'.source-details').find('._cite_button')
        wikirate.sourceCiteButtons($citeButton, 'cite')

  # stick source preview container when scrolled the page
  stickContent = ->
    $previewContainer = $("#source-preview-main")
    $metricContainer = $("#metric-container")
    stickClass = {
      add: ->
        $previewContainer.addClass 'stick-right'
        $metricContainer.addClass 'stick-left'
      remove: ->
        $previewContainer.removeClass 'stick-right'
        $metricContainer.removeClass 'stick-left'
    }

    if $(document).scrollTop() > 60
      stickClass.add()
    else
      stickClass.remove()

    if($(window).scrollTop() > ($("#main").height() - $(window).height() + 300))
      stickClass.remove()


decko.slotReady (slot) ->
  add_val_form = slot.find('form.new-value-form').is(':visible')
  if add_val_form
    slot.find('._add_new_value').hide()
  else
    slot.find('._add_new_value').show()

  resizeIframe(slot)

  if slot.hasClass("_show_add_new_value_button")
    slot.parent().find("._add_new_value").show()


