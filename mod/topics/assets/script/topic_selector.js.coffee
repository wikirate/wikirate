
onClass = "bg-topic"
inputSelector = ".topic-tree-input"

$.extend decko.editors.content,
  "#{inputSelector}": ->
    decko.pointerContent @find(".card-title.#{onClass}").map( -> valFor this )

$.extend decko.editors.init,
  "#{inputSelector}": ->
    populateTree this, @contentField().val().split "\n"

$ ->
  $("body").on "click", "#{inputSelector} .tree-leaf", (_e) ->
    toggleLeaf $(this)

toggleLeaf = (leaf) ->
  leaf.find("> .card-title").toggleClass onClass
  percolate leaf

percolate = (item) ->
  parentItem = item.closest ".tree-item"
  return unless parentItem.length

  hasSelected = parentItem.find(".tree-body .#{onClass}").length > 0
  parentItem.find("> .tree-header .card-title").toggleClass onClass, hasSelected
  percolate parentItem.parent()

valFor = (el) ->
  $(el).closest("[data-treeval]").data "treeval"

populateTree = (input, topics) ->
  for topic in topics
    node = input.find("[data-treeval='#{topic}']")
    toggleLeaf node, true

    # seems like below should be collapse("show"), but I couldn't get that to work
    # efm
    node.find("> .tree-header .tree-button").trigger("click")