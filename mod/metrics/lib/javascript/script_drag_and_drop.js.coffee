sortDragItems = (list, key, order='desc') ->
  order = if order == 'desc' then 1 else -1
  $(list).find('.yinyang-row').sortElements (a, b) ->
    if $(a).data("sort-#{key}") > $(b).data("sort-#{key}") then -1*order else order
$(document).ready ->
  # vote buttons
  # userUpvotedColor()
  drop_list = (votee, vote_type) ->
    $(votee).closest('.voting').find(".list-drag-and-drop[data-bucket-name=#{vote_type}]")

  appendDragItem = (vote_type, vote_button) ->
    drag_item = $(vote_button).closest('.drag-item')
    old_list = drag_item.parent()
    new_list = drop_list(drag_item, vote_type)
    $(new_list).append(drag_item)
    updateHints(old_list, new_list)

  prependDragItem = (vote_type, vote_button) ->
    drag_item = $(vote_button).closest('.drag-item')
    old_list = drag_item.parent()
    new_list = drop_list(drag_item, vote_type)
    $(new_list).prepend(drag_item)
    updateHints(old_list, new_list)


  # no vote -> up vote
  $('body').on 'click', '.list-drag-and-drop[data-bucket-name=no_vote] .drag-item .vote-up button.vote-link', ->
    appendDragItem('up_vote', this)

  # down vote -> no vote
  $('body').on 'click', '.list-drag-and-drop[data-bucket-name=down_vote] .drag-item .vote-up button.vote-link', ->
    appendDragItem('no_vote', this)

  # up vote -> no vote
  $('body').on 'click', '.list-drag-and-drop[data-bucket-name=up_vote] .drag-item .vote-down button.vote-link', ->
    prependDragItem('no_vote', this)

  # no vote -> down vote
  $('body').on 'click', '.list-drag-and-drop[data-bucket-name=no_vote] .drag-item .vote-down button.vote-link', ->
    prependDragItem('down_vote', this)


  # # details toggle
  # $('body').on 'click',' .metric-item .hide-with-details', ->
  #   $(this).siblings(".details-toggle").trigger("click")
  # $('body').on 'click',".details-toggle", ->
  #   toggleDetails this
  # $('body').on 'click',".metric-details-toggle, .metric-details-close-icon", ->
  #   toggleMetricDetails this
  # $('body').on 'click',".overview-details-toggle, .details-close-icon", ->
  #   toggleMetricDetails this
  # $('body').on 'click', '.yinyang-row > .header', ->
  #   toggleDetails $(this).closest('.yinyang-row').find('.details-toggle')
  #
  # activeDetails = null
  #
  # toggleMetricDetails = (toggle) ->
  #
  #   row = $(toggle).closest('.yinyang-row')
  #   details = $(row).find('.details')
  #   yinyan_list_name = ".yinyang-list .value-item:first-child.active"
  #   if details.is(':visible')
  #     # for hide_with_details in $(row).find('.hide-with-details')
  #     # $(hide_with_details).show()
  #     # for show_with_details in $(row).find('.show-with-details')
  #     # $(show_with_details).hide()
  #     details.hide()
  #     row.find(".value-item, .list-item").first().removeClass("active")
  #   else if !$.trim(details.html()) # empty
  #     loader_anime = $("#ajax_loader").html()
  #     details.append(loader_anime)
  #     activeItem = $(yinyan_list_name +
  #     ", .search-result-list .overview-item:first-child.active")
  #     activeItem.find(".details").hide()
  #     activeItem.removeClass("active")
  #     row.find(".value-item, .list-item").first().addClass("active")
  #     card_slot = $(toggle).closest('.card-slot')
  #     card_name = card_slot.attr('id')
  #     if card_slot.hasClass("LTYPE_RTYPE-metric-company")
  #       # to re order the card name to get the metric details
  #       card_names = card_name.split("+")
  #       if card_names.length == 4
  #         card_name = card_names[3] + "+" + card_names[0] + "+" +
  #                     card_names[1] + "+" + card_names[2] + "+yinyang_drag_item"
  #       else
  #         card_name = card_names[2]+"+"+card_names[0]+"+"+
  #                     card_names[1]+"+yinyang_drag_item"
  #     view = $(toggle).data('view') || 'content'
  #     right_name = $(toggle).data('append')
  #     load_path = "/#{card_name}+#{right_name}?view=#{view}"
  #     details.show()
  #     #for hide_with_details in $(row).find('.hide-with-details')
  #     #$(hide_with_details).hide()
  #     #for show_with_details in $(row).find('.show-with-details')
  #     #$(show_with_details).show()
  #     $(details).load load_path, ->
  #       $(details).trigger('slotReady')
  #   else
  #     activeItem = $(yinyan_list_name +
  #                  ", .search-result-list .list-item:first-child.active")
  #     activeItem.find(".details").hide()
  #     activeItem.removeClass("active")
  #     row.find(".value-item, .list-item").first().addClass("active")
  #     #for hide_with_details in $(row).find('.hide-with-details')
  #     #$(hide_with_details).hide()
  #     #for show_with_details in $(row).find('.show-with-details')
  #     #$(show_with_details).show()
  #     details.show()
  #   activeDetails = $(yinyan_list_name +
  #                   ' > .details,  .search-result-list' +
  #                   ' .list-item:first-child.active > .details')
  #   stickMetricDetails()
  #
  # #stick the metric details when scrolling
  # stickMetricDetails = () ->
  #   isModal = activeDetails.closest('.modal-body').exists()
  #   if $(document).scrollTop() > 56 || isModal
  #     activeDetails.addClass 'stick'
  #   else
  #     activeDetails.removeClass 'stick'
  #
  #   if($(window).scrollTop() > ($("#main").height()-$(window).height()+300))
  #     activeDetails.removeClass("stick")
  #
  #   return
  #
  # $(window).scroll ->
  #   if(activeDetails)
  #     stickMetricDetails()
  #
  #
  # toggleDetails = (toggle) ->
  #   $(toggle).find('.glyphicon')
  #     .toggleClass('glyphicon-triangle-bottom','glyphicon-triangle-right')
  #   row = $(toggle).closest('.yinyang-row')
  #
  #
  #   details = $(row).find('.details')
  #   if details.is(':visible')
  #     for hide_with_details in $(row).find('.hide-with-details')
  #       $(hide_with_details).show()
  #     for show_with_details in $(row).find('.show-with-details')
  #       $(show_with_details).hide()
  #     details.hide()
  #   else if !$.trim(details.html()) # empty
  #     card_slot = $(toggle).closest('.card-slot')
  #     card_name = card_slot.attr('id')
  #     if card_slot.hasClass("LTYPE_RTYPE-metric-company")
  #       # to re order the card name to get the metric details
  #       card_names = card_name.split("+")
  #       card_name = card_names[2]+ "+"
  #       + card_names[0] + "+" + card_names[1] + "+yinyang_drag_item"
  #     view = $(toggle).data('view') || 'content'
  #     right_name = $(toggle).data('append')
  #     load_path = "/#{card_name}+#{right_name}?view=#{view}"
  #     details.show()
  #     for hide_with_details in $(row).find('.hide-with-details')
  #       $(hide_with_details).hide()
  #     for show_with_details in $(row).find('.show-with-details')
  #       $(show_with_details).show()
  #     $(details).load load_path, ->
  #       $(details).trigger('slotReady')
  #   else
  #     for hide_with_details in $(row).find('.hide-with-details')
  #       $(hide_with_details).hide()
  #     for show_with_details in $(row).find('.show-with-details')
  #       $(show_with_details).show()
  #     details.show()


  # filter
  #  $('body').on 'click','.votee-filter .filter-header, ' +
  #        '.filter-container .filter-header', ->
  #    $(this).find('.filter-toggle .glyphicon')
  #    .toggleClass('glyphicon-triangle-bottom','glyphicon-triangle-right')
  #    $(this).next().toggle()
  #
  # $(document).ajaxSuccess ->
  #   userUpvotedColor()
  #
  # userUpvotedColor = () ->
  #   $(".disabled-vote-link").parent()
  #                           .siblings(".vote-count")
  #                           .css("color","#1e90ff")
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
