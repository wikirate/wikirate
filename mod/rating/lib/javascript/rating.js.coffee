handleDropEvent = ( event, ui ) ->
  drag_item = ui.item 
  new_list = drag_item.parent()
  if new_list.parent().is(old_list.parent()) # don't mix topics and metrics
    updateHints(old_list, new_list)
    update_path = drag_item.attr('data-update-path') + '&' + $(new_list).attr('data-query')
    if next_item = $(drag_item).next('.drag-item')
      update_path += '&insert-before=' + next_item.attr('data-votee-id')
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

$('.voting .list-drag-and-drop').sortable
  connectWith: '.voting .list-drag-and-drop'
  items: ".drag-item"
  update: handleDropEvent
  start: handleStartEvent
  stop: handleStopEvent
  dropOnEmpty: true
  revert: false


updateHints = (old_list, new_list) ->
  if $(old_list).find('.drag-item').length == 0
    $(old_list).find('.unsaved-message').hide()
    $(old_list).find('.empty-message').show()
  $(new_list).find('.empty-message').hide()
  $(new_list).find('.unsaved-message').show()


# vote buttons

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

  
# details toggle
$('body').on 'click','.details-toggle', ->
  toggleDetails this
$('body').on 'click', '.topic-item > .header,  .metric-item > .header', ->
  toggleDetails $(this).closest('.drag-item').find('.details-toggle')
    

toggleDetails = (toggle) ->
  $(toggle).find('.glyphicon').toggleClass('glyphicon-triangle-bottom','glyphicon-triangle-right')
  details = $(toggle).closest('.drag-item').find('.details')
  if !$.trim(details.html()) # empty
    card_name = $(toggle).closest('.card-slot').attr('id')
    view = $(this).attr('data-view') || 'content'
    right_name = $(toggle).attr('data-append') 
    load_path = "/#{card_name}+#{right_name}?view=#{view}"
    $(details).load load_path
    s(details).find('.RIGHT-topic_detail > .TYPE_PLUS_RIGHT-analysi-article').readmore
      maxHeight: 50,
      speed: 500
  else if $(details).is(':visible')
    $(details).hide()
  else
    $(details).show()
    



# filter

$('body').on 'click','.filter-toggle', ->
  $(this).find('.glyphicon').toggleClass('glyphicon-triangle-bottom','glyphicon-triangle-right')
  $(this).parent().find('.filter-details').toggle()

$('button.recent').on 'click', ->
  $(this).closest('.voting').find('.list-drag-and-drop[data-bucket-name=no_vote] .drag-item').sortElements (a, b) ->
    if $(a).attr('data-sort-recent') > $(b).attr('data-sort-recent') then -1 else 1

$('button.importance').on 'click', ->
  $(this).closest('.voting').find('.list-drag-and-drop[data-bucket-name=no_vote] .drag-item').sortElements (a, b) ->
    if $(a).attr('data-sort-importance') > $(b).attr('data-sort-importance') then -1 else 1

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