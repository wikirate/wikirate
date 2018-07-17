decko.slotReady (slot) ->
  slot.find('.d0-card-content.TYPE_PLUS_RIGHT-page-description').readmore
    maxHeight: 90
    embedCSS: false
  slot.find('.titled_with_edit-view.RIGHT-about > .d0-card-content').each ->
    $(this).readmore
      maxHeight: 180
      speed: 500
    return
  slot.find('.TYPE-company > .top >  .TYPE_PLUS_RIGHT-company-about.d0-card-content').each ->
    $(this).readmore
      maxHeight: 190
      speed: 500
    return
  slot.find('.TYPE-topic > .top >  .TYPE_PLUS_RIGHT-topic-about.d0-card-content').each ->
    $(this).readmore
      maxHeight: 50
      speed: 500
    return
  slot.find('.details > .RIGHT-topic_detail > .TYPE_PLUS_RIGHT-analysi-overview').each ->
    $(this).readmore
      maxHeight: 50
      speed: 500
    return
  slot.find('.titled_with_edit-view.RIGHT-about > .d0-card-content').each ->
    $(this).readmore 'resizeBoxes'
    return
  return
