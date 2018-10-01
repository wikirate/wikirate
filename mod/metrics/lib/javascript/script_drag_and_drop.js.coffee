
  ###*
  # jQuery.fn.sortElements
  # --------------
  # @param Function comparator:
  #   Exactly the same behaviour as [1,2,3].sort(comparator)
  #
  # @param Function getSortable
  #   A function that should return the element that is
  #   to be sorted. The comparator will run on the
  #   current collection, but you may want the actual
  #   resulting sort to occur on a parent or another
  #   associated element.
  #
  #   E.g. $('td').sortElements(comparator, function(){
  #      return this.parentNode;
  #   })
  #
  #   The <td>'s parent (<tr>) will be sorted instead
  #   of the <td> itself.
  ###

  jQuery.fn.sortElements = do ->
    sort = [].sort
    err_msg = 'You can\'t sort elements if any one is a descendant of another.'
    (comparator, getSortable) ->
      getSortable = getSortable or ->
          this
      placements = @map(->
        sortElement = getSortable.call(this)
        parentNode = sortElement.parentNode
        nextSibling = parentNode.insertBefore(document.createTextNode(''),
                                              sortElement.nextSibling)
        ->
          if parentNode == this
            error =
            throw new Error(err_msg)
          # Insert before flag:
          parentNode.insertBefore this, nextSibling
          # Remove flag:
          parentNode.removeChild nextSibling
          return
      )
      sort.call(this, comparator).each (i) ->
        placements[i].call getSortable.call(this)
        return


  for list in $('.yinyang-list')
    if sortKey = $(list).data('default-sort')
      sortDragItems(list, sortKey)
      $(list).closest('.voting').find(".filter-details .#{sortKey}").tab('show')
    if $(list).find('.drag-item:visible').length == 0
      $(list).find('.empty-message').show()

decko.slotReady (slot) ->
  handleDropEvent = ( event, ui ) ->
    drag_item = ui.item
    new_list = drag_item.parent()
    if new_list.parent().is(old_list.parent()) # don't mix topics and metrics
      updateHints(old_list, new_list)
      update_path = drag_item.data('update-path')
      + '&' + $(new_list).data('query')
      if next_item = $(drag_item).next('.drag-item')
        update_path += '&insert-before=' + next_item.data('votee-id')
      vote = drag_item.find('.vote-count')
      $(vote).closest('.card-slot').load(update_path)
    else
      $( this ).sortable( "cancel" )

  old_list = null

  handleStopEvent = (event, ui) ->
    new_list = ui.item.parent()
    if !new_list.parent().is(old_list.parent())
      $( this ).sortable( "cancel" )

  handleStartEvent = (event, ui) ->
    old_list = ui.item.parent()


  updateHints = (old_list, new_list) ->
    if $(old_list).find('.drag-item:visible').length == 0
      $(old_list).find('.unsaved-message').hide()
      $(old_list).find('.empty-message').show()
    $(new_list).find('.empty-message').hide()
    $(new_list).find('.unsaved-message').show()


  slot.find('.filter-details .filter').on 'click', ->
    list = $(this).closest('.votee-filter').next().next()
    sortDragItems(list, $(this).data('sort-key'), $(this).data('sort-order'))

  slot.find('.voting .list-drag-and-drop').sortable
    connectWith: '.voting .list-drag-and-drop'
    items: ".drag-item"
    update: handleDropEvent
    start: handleStartEvent
    stop: handleStopEvent
    dropOnEmpty: true
    revert: false
