decko.slotReady (slot) ->
  slot.find('.tab').each ->
    $tabDiv = $(this)
    $tabDiv.find('.search-no-results').each ->
      if $(this).find('.empty-tab').length > 0
        return
      $div = $('<div>', class: 'empty-tab')
      emptyTabContent = $tabDiv.attr('empty-tab-content')
      if emptyTabContent
        $div.append '<span>' + emptyTabContent + '</span>'
        $(this).append $div
