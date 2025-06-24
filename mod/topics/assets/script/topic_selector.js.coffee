
onClass = "bg-topic"
inputSelector = "._topic-tree-input"
filterSelector = "._topic-tree-filter"
hiddenSelector = "._topic-tree-hidden"

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

$ ->
  $("body").on "click", "#{inputSelector} .tree-leaf", (_e) ->
    toggleLeaf $(this), true

  $("body").on "click", "#{filterSelector} .tree-leaf", (_e) ->
    el = $(this)
    toggleLeaf el, false
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

toggleLeaf = (leaf, perc) ->
  leaf.find("> .card-title, > h2 .card-title").toggleClass onClass
  percolate leaf if perc

percolate = (item) ->
  parentItem = item.closest ".tree-item"
  return unless parentItem.length

  hasSelected = parentItem.find(".tree-body .#{onClass}").length > 0
  parentItem.find("> .tree-header .card-title").toggleClass onClass, hasSelected
  percolate parentItem.parent()

valFor = (el) ->
  $(el).closest("[data-treeval]").data "treeval"

populateTree = (input, topics, perc) ->
  for topic in topics
    node = input.find("[data-treeval='#{topic}']")
    toggleLeaf node, perc

    node.parents(".tree-collapse").collapse("show")