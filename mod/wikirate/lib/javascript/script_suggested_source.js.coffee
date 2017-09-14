getLocation = (href) ->
  l = document.createElement('a')
  l.href = href
  l

addSuggestedSource = (suggestedSourceField, userId, company, topic) ->
  encodedCompany = encodeURIComponent(company)
  encodedTopic = encodeURIComponent(topic)
  url = 'http://mklab.iti.gr/wikirate-sandbox/api/index.php/recommendations/?company=' + encodedCompany + '&topic=' + encodedTopic + '&user_id=' + userId
  jqxhr = $.getJSON(url).done((data) ->
    $.each data.results, (i, item) ->
      $('#loading_gif').hide()
      $row = $('<div>', class: 'suggested-source-item')
      $imageDiv = $('<div>', class: 'source-link-image')
      $titleDiv = $('<div>', class: 'source-link-title')
      imageSrc = ''
      if item.images.length > 0
        imageSrc = item.images[0].url
      else
        imageSrc = '{{missing image|source;size:small;}}'
      $image = $('<img src="' + imageSrc + '">')
      $imageDiv.append $image
      website = getLocation(item.url).hostname
      # http://127.0.0.1:3000/?card[type]=Page&url=http://www.theguardian.com/commentisfree/2006/jun/13/comment.oil&view=preview&layout=source%20preview%20page%20layout&company=BP&topic=Consumer%20and%20Product%20Responsibility
      $title = $('<a class="preview-page-link" href="/?card[type]=Page&view=preview&layout=source preview page layout&url=' + encodeURIComponent(item.url) + '&company=' + encodedCompany + '&topic=' + encodedTopic + '" target="_blank"> ' + item.title + ' - ' + website + ' </a>')
      $titleDiv.append $title
      $row.append $imageDiv
      $row.append $titleDiv
      suggestedSourceField.append $row
  ).fail((xhr, ajaxOptions, thrownError) ->
    suggestedSourceField.html 'Fail to get suggested sources.'
    console.log 'error with ' + xhr.responseText
  )

$(document).ready ->
  company = $('#company-key-name').html()
  topic = $('#topic-key-name').html()
  userId = $('#user-id').html()
  $('.STRUCTURE-source_link_preview').each ->
    $(this).find('img').each ->
      if $(this).attr('src') == ''
        $(this).attr 'src', '{{missing image|source;size:small;}}'
  $suggested_source = $('.suggested-source:first')
  if $suggested_source.length > 0
    addSuggestedSource $suggested_source, userId, company, topic

