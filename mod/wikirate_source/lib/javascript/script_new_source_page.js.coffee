decko.slotReady (slot) ->
  if slot.hasClass('new-view') && (slot.hasClass('TYPE-source') || slot.hasClass('TYPE-metric_value'))
# bind listener to the tab anchor
    slot.find('#myTab').find("a").click (e) ->
# update the source type
      source_type = $(this).data('source-type')
      source_type_subcard = slot.find(".RIGHT-Xsource_type").find("input:hidden.d0-card-content")
      source_type_subcard.val("[[" + source_type + "]]")
      source_type_subcard.siblings("ul").find("input[value=" + source_type + "]").prop("checked", true)

$(window).ready ->

  ###
    To autopopulate the meta data in the input fields in new source page
  ###

#$('#card_subcards__File_attach').change ->
#$('.first-meta').fadeIn()
#return
#$('#text-tab').click ->
#plus_text_tinymce_eidtor = null
#i = 0
#while i < tinymce.editors.length
#if tinymce.editors[i].editorId.indexOf('+text') > -1
#plus_text_tinymce_eidtor = tinymce.editors[i]
#i++
#if plus_text_tinymce_eidtor
#plus_text_tinymce_eidtor.onKeyUp.add (ed, l) ->
#if !$('.first-meta').is(':visible')
#$('.first-meta').fadeIn()
#return
#return
  $('#add-company-and-topic').click (e) ->
    e.preventDefault()
    $('#company-topic-meta').fadeIn()
    $('#add-company-and-topic').hide()
    return
  $('#add-tags-other').click (e) ->
    e.preventDefault()
    $('#tag-date-others-meta').fadeIn()
    $('#add-tags-other').hide()
    return

  # update source type


  $('#suggest_button').on 'click', ->
    sourceElement = $('#card_subcards__Link_content')
    errorDiv = '<div class="sourceErrorMsg"> Invalid URL. (Valid URL looks like "http://www.example.com")</div>'
    if !sourceElement.val().match(/^http/)
      if sourceElement.siblings('.sourceErrorMsg').length > 0 then '' else sourceElement.after(errorDiv)
      return false
    else
      sourceElement.siblings('.sourceErrorMsg').remove()
    if $(this).parents(".modal.fade").length >= 1
      return false
    else
      loaderHTML = '<span class=\'addSourceLoader\'>Loading Metadata...</span>'
      if sourceElement.siblings('.addSourceLoader').length > 0 then '' else sourceElement.after(loaderHTML)
    $('#loading').fadeIn()
    titleElement = $('#card_subcards__Title_content')
    websiteElement = $('#card_subcards__Website_content').siblings('.pointer-list-ul').find('.pointer-item-text')
    url = sourceElement.val()
    metaReqObj = {}
    metaReqObj.view = 'metadata'
    metaReqObj.url = url
    $.ajax(decko.rootPath + '/source.json?' + $.param(metaReqObj)).done((response) ->
      titleElement.val response.title
      websiteElement.focusin().val(response.website).focusout()
      id = $('.new-view.TYPE-source .RIGHT-description').find('textarea:first').attr('id')
      tinyMCE.get(id).setContent response.description
      sourceElement.siblings('.addSourceLoader').remove()
      return
    ).error((errorMsg) ->
#Need to handle error
      return
    ).complete (data) ->
      $('#loading').hide()
      $('.first-meta').fadeIn()
      return
    return
  return
