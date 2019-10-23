# special handling for constraints on company group page.

# when saving, convert
decko.editorContentFunctionMap['.specification-input'] = ->
  ignoreConstraintElements()
  ed = $(this)
  if specificationType(ed) == "explicit"
    "explicit"
  else
    constraintCsv constraintEditor(ed)

# sets form of elements to non-existent form so they won't be submitted
ignoreConstraintElements = ()->
  $(".constraint-editor input, .constraint-editor select").attr "form","ignore"

constraintCsv = (constraintListEditor) ->
  rows = constraintListEditor.find(".constraint-editor").map ()->
    constraintToCsvRow $(this)
  rows.get().join "\n"

constraintToCsvRow = (con)->
  [metricValue(con), yearValue(con), valueValue(con)].join ";|;"

metricValue = (con) ->
  con.find(".constraint-metric input").val()

yearValue = (con) ->
  con.find(".constraint-year select").val()

valueValue = (con) ->
  con.find(".constraint-value input, .constraint-value select").serialize()

specificationType = (el) ->
  el.find("[name=spec-type]:checked").val()

constraintEditor = (el) ->
  el.find(".constraint-list-editor")

updateSpecVisibility = (slot) ->
  implicit = constraintEditor slot
  explicit = slot.find ".RIGHT-company.card-editor"
  if specificationType(slot) == "explicit"
    explicit.show()
    implicit.hide()
  else
    explicit.hide()
    implicit.show()

$(window).ready ->
  # when metric changes, update value field according to metric's value type
  $("body").on "change", "._constraint-metric", ->
    input = $(this)
    valueSlot = input.closest("li").find(".card-slot")
    metric = encodeURIComponent input.val()
    url = valueSlot.slotMark() + "?view=value_formgroup&metric=" + metric
    valueSlot.reloadSlot url

  $("body").on "change", "input[name=spec-type]", ->
    updateSpecVisibility $(this).slot()

decko.slotReady (slot) ->
  if slot.find(".specification-input").length > 0
    updateSpecVisibility slot