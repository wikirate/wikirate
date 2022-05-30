# special handling for constraints on company group page.

# when saving, convert
decko.editors.content['.specification-input'] = ->
  specificationType this

$(window).ready ->
  # handle changing between explicit and implicit
  $("body").on "change", "input[name=spec-type]", ->
    updateSpecVisibility $(this).slot()

  # when metric changes, update value field according to metric's value type
  $("body").on "change", "._constraint-metric", ->
    input = $(this)
    valueSlot = input.closest("li").find(".card-slot")
    metric = encodeURIComponent input.val()
    url = valueSlot.slotMark() + "?view=value_formgroup&metric=" + metric
    valueSlot.reloadSlot url

decko.slot.ready (slot) ->
  if slot.find(".specification-input").length > 0
    updateSpecVisibility slot

updateSpecVisibility = (slot) ->
  implicit = constraintEditor slot
  explicit = slot.find ".RIGHT-company.card-editor"
  if specificationType(slot) == "explicit"
    explicit.show()
    implicit.hide()
  else
    explicit.hide()
    implicit.show()

constraintEditor = (el) ->
  $(el).find ".constraint-list-editor"

specificationType = (el) ->
  $(el).find("[name=spec-type]:checked").val()
