
onClass = "bg-topic"
inputSelector  = "._tree-input"
filterSelector = "._tree-filter"
hiddenSelector = "._tree-hidden"

$.extend decko.editors.content,
  "#{inputSelector}": -> decko.pointerContent selectedVals(this)

$.extend decko.editors.init,
  "#{inputSelector}": ->
    populateTree this, @contentField().val().split("\n"), true

decko.slot.ready (slot) ->
  treeFilter = slot.find filterSelector
  if treeFilter.length > 0
    vals = treeFilter.find(hiddenSelector + " input").map -> $(this).val()
    populateTree treeFilter, vals, false

    treeFilter.find(".tree-item").data "no-collapse", true

$ ->
  $("body").on "click", "#{inputSelector} .tree-button, #{inputSelector} .tree-leaf", (_e) ->
    toggleTopic $(this), true

  $("body").on "click", "#{filterSelector} .tree-leaf", (_e) ->
    filterByTopic $(this)


  # NOTE: the following four event listeners are a somewhat hacky solution for the
  # topics filter

  # Context:
  #  - the default tree behavior is to expand/collapse whenever anyone clicks on the
  #    topic name, which is within the "tree-button". This is how the tree works in
  #    the topic editor, which uses the same tree as the topic filter
  #  - However, in the filter context, we want clicks on the topic name to turn the
  #    filter on and off and NOT trigger the expand/collapse. (Instead we leave the
  #    expand/collapse to the arrow icon)
  #  - bootstrap's event listener appears to happen  before jQuery's "on" event
  #    handling, so I was unable, despite many attempts, to intercept the click event
  #    in the jQuery on events BEFORE bootstrap's expand/collapse had already happened.
  #  - conversely in the bootstrap events, I was not able to get any information about
  #    original click do determine whether it was on the topic name (.card-title).
  #  - EITHER of these solutions would be nice. Intercepting the click at the button, or
  #    having information about the button click at the time of hide.bs.collapse.
  #  - Alas, without that, I had to implement the following, which, in short, turns
  #    the collapse functionality off with "no-collapse" on the tree-item. Then if a click
  #    on the button outside of the title happens, the no-collapse is turned off and
  #    the collapse is retriggered, and then we reset again.

  $("body").on "click",  "#{filterSelector} .tree-button .card-title", (_e) ->
    item = treeItem this
    filterByTopic item
    item.data "card-title-click", true

  $("body").on "click",  "#{filterSelector} .tree-button", (_e) ->
    item = treeItem this
    if item.data "card-title-click"
      item.data "card-title-click", false
    else
      item.data "no-collapse", false
      $($(this).data("bs-target")).collapse "toggle"

  $("body").on "hide.bs.collapse", "#{filterSelector} .tree-collapse", (event)->
    handleFilterCollapse this, event

  $("body").on "show.bs.collapse", "#{filterSelector} .tree-collapse", (event)->
    handleFilterCollapse this, event

treeItem = (el) ->
  $(el).closest ".tree-item"

handleFilterCollapse = (el, event) ->
  item = treeItem el
  if item.data "no-collapse"
    event.preventDefault()
  else
    item.data "no-collapse", true
    event.stopPropagation()

filterByTopic = (el) ->
  toggleTopic el, false
  updateHiddenFilterInputs el
  el.closest("form").submit()

updateHiddenFilterInputs = (el) ->
  filter = el.closest filterSelector
  hidden = filter.find hiddenSelector
  hidden.find("input").remove()
  name = hidden.data "hidden-name"
  $.each selectedVals(filter), (_i, val) ->
    hidden.append "<input type='hidden' name='#{name}' value='#{val}'>"

selectedVals = (el) ->
   $(el).find(".card-title.#{onClass}").map( -> valFor this )

toggleTopic = (holder, perc) ->
  holder.find("> .card-title, > h2 .card-title").toggleClass onClass
  if perc
    percolate holder
    if holder.hasClass("tree-button") && holder.find(".#{onClass}").length == 0
      holder.closest(".tree-item").find(".tree-body .#{onClass}").removeClass onClass

percolate = (item) ->
  parentItem = item.closest ".tree-item"
  parentItem = parentItem.closest "tree-item" if item.hasClass "tree-button"
  return unless parentItem.length

  if parentItem.find(".tree-body .#{onClass}").length > 0
    parentItem.find("> .tree-header .card-title").addClass onClass
    percolate parentItem.parent()

valFor = (el) ->
  $(el).closest("[data-treeval]").data "treeval"

populateTree = (input, topics, perc) ->
  for topic in topics
    node = input.find("[data-treeval='#{topic}']")
    toggleTopic node, perc

    node.find("> .tree-collapse").collapse "show"
    node.parents(".tree-collapse").collapse "show"
