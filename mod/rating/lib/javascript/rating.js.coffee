handleDropEvent = ( event, ui ) ->
  drag_item = ui.draggable
  old_list = drag_item.parent()
  if $(this).attr('data-bucket-name') != $(old_list).attr('data-bucket-name')    
    # ui.draggable.position( { of: $(this), my: 'left top', at: 'left top' } );
    drag_item.draggable( 'option', 'revert', false );
    if old_list.find('.drag-item').length == 1
      old_list.find('.empty-message').show()
    if old_list.find('.drag-item').length == 2
      old_list.find('.unsaved-message').hide()
    $(this).append(drag_item)
    drag_item.attr("style","")
    $(this).find('.empty-message').hide()
    $(this).find('.unsaved-message').show()

    vote = drag_item.find('.vote-count') 
    update_path = drag_item.attr('data-update-path') + '&' + $(this).attr('data-query')
    $(vote).closest('.card-slot').load(update_path)

$('.list-drag-and-drop').droppable
  accept: '.list-drag-and-drop div.drag-item',
  drop: handleDropEvent

  
#$('.list-drag-and-drop').sortable()
$('.drag-item').draggable
  revert: true


# vote buttons

drop_list = (votee, vote_type) ->
  $(votee).closest('.voting').find(".list-drag-and-drop[data-bucket-name=#{vote_type}]")

$('body').on 'click', '.list-drag-and-drop[data-bucket-name=no_vote] .drag-item .vote-up button.vote-link', ->
  console.log "no -> up"
  drag_up = $(this).closest('.drag-item')
  $(drop_list(drag_up, 'up_vote')).append(drag_up)

$('body').on 'click', '.list-drag-and-drop[data-bucket-name=down_vote] .drag-item .vote-up button.vote-link', ->
  console.log "down -> no"
  drag_up = $(this).closest('.drag-item')
  $(drop_list(drag_up, 'no_vote')).append(drag_up)

$('body').on 'click', '.list-drag-and-drop[data-bucket-name=up_vote] .drag-item .vote-down button.vote-link', ->
  console.log "up -> no"
  drag_down = $(this).closest('.drag-item')
  $(drop_list(drag_down, 'no_vote')).prepend(drag_down)

$('body').on 'click', '.list-drag-and-drop[data-bucket-name=no_vote] .drag-item .vote-down button.vote-link', ->
  console.log "no -> down"
  drag_down = $(this).closest('.drag-item')
  $(drop_list(drag_down, 'down_vote')).prepend(drag_down)

# filter

$('body').on 'click','.filter-toggle', ->
  parent = $(this).parent()
  $(this).find('.glyphicon').toggleClass('glyphicon-triangle-bottom','glyphicon-triangle-right')
  details = $(parent).find('.filter-details').toggle()
  
$('body').on 'click','.details-toggle', ->
  item = $(this).closest('.drag-item')
  $(this).find('.glyphicon').toggleClass('glyphicon-triangle-bottom','glyphicon-triangle-right')
  card_name = $(item).attr('id')
  details = $(item).find('.details')
  if !$.trim(details.html()) # empty
    view = $(this).attr('data-view') || 'content'
    load_path = "/#{card_name}+#{$(this).attr('data-append')}?view=#{view}"
    console.log("loal #{load_path}")
    $(details).load load_path
  else if $(details).is(':visible')
    $(details).hide()
  else
    $(details).show()
  

$('button.recent').on 'click', ->
  console.log "order by recent"
  $(this).closest('.voting').find('.list-drag-and-drop[data-bucket-name=no_vote] .drag-item').sortElements( (a, b) ->
    if $(a).attr('data-sort-recent') > $(b).attr('data-sort-recent') 
      -1 
    else
      1
  )

$('button.importance').on 'click', ->
  console.log "order by importance"
  $(this).closest('.voting').find('.list-drag-and-drop[data-bucket-name=no_vote] .drag-item').sortElements( (a, b) ->
    if $(a).attr('data-sort-importance') > $(b).attr('data-sort-importance') 
      -1
    else
      1
  )


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
  (comparator, getSortable) ->
    getSortable = getSortable or ->
      this
    placements = @map(->
      sortElement = getSortable.call(this)
      parentNode = sortElement.parentNode
      nextSibling = parentNode.insertBefore(document.createTextNode(''), sortElement.nextSibling)
      ->
        if parentNode == this
          throw new Error('You can\'t sort elements if any one is a descendant of another.')
        # Insert before flag:
        parentNode.insertBefore this, nextSibling
        # Remove flag:
        parentNode.removeChild nextSibling
        return
    )
    sort.call(this, comparator).each (i) ->
      placements[i].call getSortable.call(this)
      return