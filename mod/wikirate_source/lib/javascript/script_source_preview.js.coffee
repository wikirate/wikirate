@testSameOrigin = (testUrl, pageN) ->
  $.getJSON 'Source.json?view=check_iframable&url=' + testUrl, (data) ->
    if !data.result
      #remove iframe and show redirection message
      $('#webpage-preview').html ''
      $redirectNotice = $('<div>', 'class': 'redirect-notice')
      if pageN != ''
        #locally
        #Page_000001545?view=content&slot[structure]=source%20item%20preview
        load_path = '/' + pageN +
          '?view=content&slot[structure]=source_item_preview'
        $.ajax(load_path).done((noteFormHtml) ->

          $redirectNotice.append noteFormHtml
          $redirectNotice.trigger 'slotReady'
          return
        ).fail (xhr, ajaxOptions, thrownError) ->
          html = $(xhr.responseText)
          html.find('.card-header').remove()
          $redirectNotice.append html
          return
      $('#webpage-preview').append $redirectNotice
      $('#webpage-preview').addClass 'non-previewable'
    return
  return

@resizeIframe = (slot) ->
  height = $(window).height() - $('.navbar').height() - 1
  slot.find('.webpage-preview').height height

$(document).ready ->
  if $('.preview-view.TYPE-source').exists
    # closeTabContent()
    $('[data-toggle="source_preview_tab_ajax"]').click (e) ->
      $this = $(this)
      loadurl = $this.attr('href')
      targ = $this.attr('data-target')
      if undefined != loadurl
        $.get loadurl, (data) ->
          $(targ).html data
          return
      $this.tab 'show'
      false
    $('#logo-bar').dblclick ->
      false
    pageName = $('#source-name').html()
    url = $('#source_url').html()
    testSameOrigin(url, pageName) if (url)
    resizeIframe($('body'))
