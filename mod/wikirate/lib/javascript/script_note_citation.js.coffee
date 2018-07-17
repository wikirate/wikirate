ajaxFail = ($popupWindow, xhr, ajaxOptions, thrownError) ->
  html = $(xhr.responseText)
  $popupWindow.html html
  return

relatedOverviewReturned = ($popupWindow, data) ->
  #get the topic list
  $popupWindow.html data
  $popupWindow.trigger 'slotReady'
  return

citationBoxOnClick = ->
  $_this = $(this)
  noteName = $_this.attr('id').split('+')[0]
  #loading image
  loadingImageUrl = '{{loading gif|source;size:medium}}'
  #create pop up
  popupId = 'citation-popup-window'
  $popupWindow = $('#' + popupId)
  if $popupWindow.length == 0
    $('#main').prepend '<div id="' + popupId + '" style="display:none;"></div>'
    #create one
    $popupWindow = $('#' + popupId)
  #show pop up of loading
  $popupWindow.html '<img src=\'' + loadingImageUrl + '\' />'
  $popupWindow.dialog
    height: 'auto'
    position:
      of: $_this
      my: 'right top'
      at: 'left top'
      collision: 'none none'
    minWidth: 500
    closeOnEscape: false
    resizable: false
    draggable: false
    close: (event, ui) ->
      $popupWindow.dialog 'destroy'
      return
  #get company and topic list
  companyUrl = '/' + noteName + '+related overview?view=content'
  jqxhr = $.ajax(companyUrl).done((data) ->
    relatedOverviewReturned $popupWindow, data
    return
  ).fail((xhr, ajaxOptions, thrownError) ->
    ajaxFail $popupWindow, xhr, ajaxOptions, thrownError
    return
  )
  false

citeSyntaxHelper = ->
  $general_overview = $('.RIGHT-overview')
  note_name = $(this).closest('.card-slot').data('card-name')
  if $general_overview.find('.tinymce-textarea').length > 0
    cite_syntax = '{' + '{' + note_name + '|cite}}'
    $('.sample-citation .note-tip').show()
    $('.sample-citation textarea').val cite_syntax
    $('.RIGHT-overview')[0].scrollIntoView true
  else
    param_key = if window.location.href.indexOf('?') > 0 then window.location.search + '&' else '?'
    url = window.location.pathname + param_key + 'citable=' + note_name + '&edit_general_overview=true'
    window.location = url
  return

decko.slotReady (slot) ->
  slot.find('.general_overview_cite_btn').on 'click', citeSyntaxHelper

#Because notes tab is loaded through ajax, slot ready not working :(
$(document).ajaxComplete ->
  $('.general_overview_cite_btn').on 'click', citeSyntaxHelper
  return
