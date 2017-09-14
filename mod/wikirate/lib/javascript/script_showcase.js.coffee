decko.slotReady (slot) ->
  target = null
  old_list = null
  no_sort = false
  startAddingToShowcase = (event, ui) ->
    $('.open-view.editable.RIGHT-showcase .dropzone').show()
    target = $(this).closest('.contribution-tab').data('droptarget')
  hideShowcaseDropzone = () ->
    $('.open-view.editable.RIGHT-showcase .dropzone').hide()
  startRemovingFromShowcase = (event, ui) ->
    old_list = this
    $('.open-view.editable.RIGHT-showcase .removezone').show()
    target = encodeURIComponent($(ui.item).slot().data('card-name'))
  hideShowcaseRemovezone = () ->
    $('.open-view.editable.RIGHT-showcase .removezone').hide()

  getItemName = (drag_item) ->
    encodeURIComponent($(drag_item).find('>.card-slot.content-view').data('card-name'))

  reloadShowcase = () ->
    showcase_slot = $('.open-view.card-slot.RIGHT-showcase')
    card_name = encodeURIComponent(showcase_slot.data('card-name'))
    $(showcase_slot).load "/#{card_name}?view=open&slot[title]=Showcase&slot[hide]=menu%20toggle",
      ->
        $(this).children(':first').unwrap()
        initShowcase()

  addToShowcase = (event, ui) ->
    url = "/#{target}?add_item=#{getItemName(ui.draggable)}"
    # the '#' selector doesn't support ids that contain '+' so we have to use 'div[id=...]'
    $target_list = $(".open-view.RIGHT-showcase div[id='#{target}']")
    $target_list.show().removeClass('hidden')
    $target_list.find('> .pointer-list').append("<div class='pointer-item item-content placeholder'><span class='glyphicon glyphicon-hourglass'></span></div>")

    $.ajax
      url: url
      type: 'PUT'
      success: reloadShowcase

  removeFromShowcase = (event, ui) ->
    ui.draggable.remove()
    if $(old_list).find('.pointer-item').length == 1
      $(old_list).hide()
    no_sort = true
    $.ajax
      url: "/#{target}?drop_item=#{getItemName(ui.draggable)}",
      type: 'PUT',
      greedy: true


  insertIntoShowcase = (event, ui) ->
    hideShowcaseRemovezone()
    if !no_sort
      url = "/#{target}?insert_item=#{getItemName(ui.item)}&item_index=#{ui.item.index()}"
      $.ajax
        url: url,
        type: 'PUT'
    no_sort = false
    return true


  initShowcase = () ->
    $('.open-view.editable.RIGHT-showcase .dropzone').droppable
#accept: ".search-result-item.item-content"
      drop: addToShowcase
    $('.open-view.editable.RIGHT-showcase .removezone').droppable
#accept: ".search-result-item.item-content"
      drop: removeFromShowcase
    $('.open-view.editable.RIGHT-showcase .showcase').sortable
      items: "> .pointer-list > .item-content"
      stop: insertIntoShowcase
      start: startRemovingFromShowcase
  #dropOnEmpty: true
  #revert: false

  initShowcase()

  for item_type in ['note', 'source', 'metric', 'initiative', 'analysi']
    $(".open-view.editable.RIGHT-contributed_#{item_type} .tab-pane > div > .search-result-list > .search-result-item").draggable
      start: startAddingToShowcase
      stop: hideShowcaseDropzone
      connectToSortable: ".open-view.RIGHT-showcase .showcase_list-view.RIGHT-showcase_#{item_type} .showcase"
      revert: "invalid"
      helper: "clone"
      zIndex: 1000
