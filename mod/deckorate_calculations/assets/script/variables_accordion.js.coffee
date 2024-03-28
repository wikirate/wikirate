$ ->
  $("body").on "show.bs.collapse", ".accordion-collapse", (el) ->
    s = $(el.target).find ".card-slot-stub"
    s.slotReload s.data("stubUrl")
