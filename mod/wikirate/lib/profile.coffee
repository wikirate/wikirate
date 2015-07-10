$( document ).ready ->
  target = null
  old_list = null
  no_sort = false
  startAddingToShowcase = (event, ui) ->
    $('.open-view.TYPE_PLUS_RIGHT-user-showcase .dropzone').show()
    target = $(this).closest('.contribution-tab').data('droptarget')
  hideShowcaseDropzone = () ->
    $('.open-view.TYPE_PLUS_RIGHT-user-showcase .dropzone').hide()
  startRemovingFromShowcase = (event, ui) ->
    old_list = this
    $('.open-view.TYPE_PLUS_RIGHT-user-showcase .removezone').show()
    target = "~#{$(ui.item).slot().data('card-id')}"
  hideShowcaseRemovezone = () ->
    $('.open-view.TYPE_PLUS_RIGHT-user-showcase .removezone').hide()

  getItemName = (drag_item) ->
    encodeURIComponent($(drag_item).find('>.card-slot.content-view').data('card-name'))

  reloadShowcase = () ->
    showcase_slot = $('.open-view.card-slot.TYPE_PLUS_RIGHT-user-showcase')
    $(showcase_slot).load "/~#{showcase_slot.data('card-id')}?view=open&slot[title]=Showcase&slot[hide]=menu%20toggle",
      -> $(this).children(':first').unwrap()

  addToShowcase = ( event, ui ) ->
    url = "/#{target}?add_item=#{getItemName(ui.draggable)}"
    console.log url
    # the '#' selector doesn't support ids that contain '+' so we have to use 'div[id=...]'
    $target_list =   $(".open-view.TYPE_PLUS_RIGHT-user-showcase div[id='#{target}']")
    $target_list.show().removeClass('hidden')
    $target_list.find('> .pointer-list').append("<div class='pointer-item item-content placeholder'><span class='glyphicon glyphicon-hourglass'></span></div>")

    #$(".open-view.TYPE_PLUS_RIGHT-user-showcase div[id='#{target}' .pointer-list").append(ui.draggable)
    $.ajax
      url: url
      type: 'PUT'
      success: reloadShowcase

  removeFromShowcase = ( event, ui ) ->
    ui.draggable.remove()
    if $(old_list).find('.pointer-item').length == 1
      $(old_list).hide()
    no_sort = true
    $.ajax
      url: "/#{target}?drop_item=#{getItemName(ui.draggable)}",
      type: 'PUT',
      greedy: true


  insertIntoShowcase = ( event, ui ) ->
    hideShowcaseRemovezone()
    if !no_sort
      url = "/#{target}?insert_item=#{getItemName(ui.item)}&item_index=#{ui.item.index()}"
      console.log url
      $.ajax
        url: url,
        type: 'PUT'
    no_sort = false

  $('.open-view.TYPE_PLUS_RIGHT-user-showcase .dropzone').droppable
    #accept: ".search-result-item.item-content"
    drop: addToShowcase

  $('.open-view.TYPE_PLUS_RIGHT-user-showcase .removezone').droppable
    #accept: ".search-result-item.item-content"
    drop: removeFromShowcase

  $('.open-view.TYPE_PLUS_RIGHT-user-showcase .showcase').sortable
    items: "> .pointer-list > .item-content"
    stop: insertIntoShowcase
    start: startRemovingFromShowcase
    #dropOnEmpty: true
    #revert: false

  for item_type in ['claim', 'source', 'metric', 'campaign','analysi']
    $(".open-view.TYPE_PLUS_RIGHT-user-#{item_type} .tab-pane > div > .search-result-list > .search-result-item").draggable
      start: startAddingToShowcase
      stop: hideShowcaseDropzone
      connectToSortable: ".open-view.TYPE_PLUS_RIGHT-user-showcase .showcase_list-view.RIGHT-showcase_#{item_type} .showcase"
      revert: "invalid"
      helper: "clone"
      zIndex: 1000
