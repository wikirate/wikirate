$ ->
  $("body").on "shown.bs.collapse", ".tree-collapse", (event) ->
    expandNextStubs $(event.target)

decko.slot.ready (slot)->
  # expandNextStubs slot

# the idea here is to avoid the expend of expanding all levels of a multi-level
# acccordion, because that is pretty resource-intensive. But instead to make sure
# *next* level of accordion content is ready to go.
expandNextStubs = (container)->
  container.find(".card-slot-stub").each ->
    s = $(this)
    return unless readyToExpand(s)

    # console.log "loading " + s.data("stubUrl")
    s.slotReload s.data("stubUrl")
    s.removeClass "card-slot-stub"

readyToExpand = (stub)->
  item = stub.closest ".tree-item"
  item.children(".tree-header").is(":visible") || item.parent().hasClass("_tree-top")
