$(window).ready ->
  $('body').on 'shown.bs.tab', '.TYPE-source.new-view .new-source-widget a[data-toggle="tab"]', (e) ->
    updateSourceType e.target

  $('body').on 'submit', 'form.TYPE-source.new-view', (e) ->
    clearInactiveTabs e.target


clearInactiveTabs = (form) ->
  $form = $(form)
  active_tab = $form.find(".new-source-widget a.active[data-toggle=\"tab\"]")
  source_type = $(active_tab).data("source-type")
  removeLink($form) unless source_type == "Link"
  removeFile($form) unless source_type == "File"

updateSourceType = (tab) ->
  source_type = $(tab).data('source-type')
  source_type_subcard = $(tab).closest("form").find(".RIGHT-Xsource_type input:hidden.d0-card-content")

  source_type_subcard.val("[[" + source_type + "]]")
  source_type_subcard.siblings("ul").find("input[value=" + source_type + "]").prop("checked", true)

removeLink = ($form) ->
  $form.find("#card_subcards__Link_content").val("")

removeFile = ($form) ->
  $form.find(".choose-file").show()
  $form.find(".chosen-file").empty()


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
    $.ajax(decko.path('source.json?' + $.param(metaReqObj))).done((response) ->
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
