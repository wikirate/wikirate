$ ->
  $("body").on "shown.bs.collapse", ".accordion-collapse", (el) ->
    expandNextStubs $(el.target)

decko.slot.ready (slot)->
  expandNextStubs slot

# the idea here is to avoid the expend of expanding all levels of a multi-level
# acccordion, because that is pretty resource-intensive. But instead to make sure
# *next* level of accordion content is ready to go.
expandNextStubs = (container)->
  container.find(".card-slot-stub").each ->
    s = $(this)
    return unless s.
      closest(".accordion-item").
      children(".accordion-header").is(":visible")
    console.log "loading " + s.data("stubUrl")
    s.slotReload s.data("stubUrl")
    s.removeClass "card-slot-stub"
