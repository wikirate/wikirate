sourceListHtmlReturned = (header, data) ->
  $popupWindow = $('#popup-window')
  $_data = $(data)
  if header
    $_data.find('.d0-card-header').remove()
  $popupWindow.html $_data
  height = $(window).height() - $('.navbar:first').height() - 1
  if $popupWindow.height() > height
    $popupWindow.dialog 'option', 'height', height
  decko.initializeEditors $popupWindow.find('div:first')
  $popupWindow.find('div:first').trigger 'slotReady'
  return

gettingSourceListHtmlFail = (xhr, ajaxOptions, thrownError) ->
  $popupWindow = $('#popup-window')
  html = $(xhr.responseText)
  $popupWindow.html html
  return

linkOnClick = (e) ->
  e.preventDefault()
  $_this = $(this)
  href = $_this.attr('href')
  # show the loading image for this
  loadingImageUrl = '{{loading gif|source;size:large}}'
  position = 'center'
  if $_this.hasClass('position-right')
    position =
      of: '.navbar'
      my: 'right bottom'
      at: 'right top'
      collision: 'flipfit'
  if $_this.hasClass('position-left')
    position =
      my: 'left bottom'
      at: 'left top'
      of: '.navbar'
      collision: 'flipfit'
  title = '<i class="fa fa-arrows"></i>'
  if $_this.data('popup-title')
    title = $_this.data('popup-title')
  $popupWindow = $('#popup-window')
  if $popupWindow.length == 0
    $('#main').prepend '<div id="popup-window" style="display:none;"></div>'
  #create one
  $popupWindow = $('#popup-window')
  $popupWindow.html '<img src=\'' + loadingImageUrl + '\' />'
  $popupWindow.removeAttr 'style'
  $popupWindow.dialog
    height: 'auto'
    minWidth: 700
    position: position
    title: title
    closeOnEscape: false
    resizable: false
    draggable: true
    close: (event, ui) ->
      $popupWindow.dialog 'destroy'
      return
  header = $_this.hasClass('no-header')
  #create a ajax call to get content and show
  originalLink = $_this.hasClass('popup-original-link')
  jqxhr = $.ajax(href + (if originalLink then '' else '?view=content')).done((data) ->
    sourceListHtmlReturned header, data
  ).fail(gettingSourceListHtmlFail)
  false

decko.slotReady (slot) ->
  slot.find('.show-link-in-popup').each ->
    $(this).off('click').click linkOnClick
