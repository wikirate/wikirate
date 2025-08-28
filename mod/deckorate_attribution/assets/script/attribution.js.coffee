
$(document).ready ->
  $("body").on "click", "._export-button", (e)->
    s = $(this).closest("._attributable-export").find ".card-slot-stub"
    s.slotReload s.data("stubUrl")
    s.removeClass "card-slot-stub"
    e.preventDefault()
