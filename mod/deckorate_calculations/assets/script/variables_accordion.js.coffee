$ ->
  $("body").on "shown.bs.collapse", ".accordion-collapse", (el) ->
    expandNextStubs $(el.target)

decko.slot.ready (slot)->
  expandNextStubs slot

expandNextStubs = (container)->
  container.find(".card-slot-stub").each ->
    s = $(this)
    return unless s.
      closest(".accordion-item").
      children(".accordion-header").is(":visible")
    console.log "loading " + s.data("stubUrl")
    s.slotReload s.data("stubUrl")
    s.removeClass "card-slot-stub"
