# special handling for constraints on company group page.

# when saving, convert
decko.editors.content['.specification-input'] = ->
  specificationType this

$(window).ready ->
  # handle changing between explicit and implicit
  $("body").on "change", "input[name=spec-type]", ->
    updateSpecVisibility $(this).slot()

  # handle metric name selection (new text, new hidden value, new value editor)
  $("body").on "decko.filter.selection", "._metric-selector a", (event, item) ->
    data = $(item.firstChild).data() # assumes first child has card data
    link = $(this)
    link.text data.cardName
    link.siblings().val data.cardId # assumes hidden metric id field is only sibling
    constraintDisabled link, false
    updateValueEditor link, data.cardId
    decko.updateAddItemButton this
    link.closest("form").submit()

  # handle new constraint added
  $("body").on "decko.item.added", "._constraint-list-editor li", ->
    metric_link = $(this).find(".constraint-metric a")
    metric_link.text "Choose Metric"
    $(this).find(".constraint-value").children(":not(.input-group-text)").remove()
    constraintDisabled metric_link, true


decko.slot.ready (slot) ->
  if slot.find(".specification-input").length > 0
    updateSpecVisibility slot

constraintDisabled = (el, toggle) ->
  ed = el.closest "._constraint-editor"
  ed.find("select, input").prop "disabled", toggle

# update value field according to metric's value type
updateValueEditor = (metricLink, metricId) ->
  slot = metricLink.closest("li").find(".card-slot")
  slot.slotReload "#{slot.cardMark()}/value_formgroup?metric=~#{metricId}"

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
