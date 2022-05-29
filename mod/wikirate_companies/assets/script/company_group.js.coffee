# special handling for constraints on company group page.

# when saving, convert
decko.editors.content['.specification-input'] = ->
  if specificationType(this) == "explicit"
    "explicit"
#  else
#    conEd = constraintEditor this
#    if conEd.data "locked" # see note about locking constraint editor below
#      conEd.find("input.d0-card-content").val()
#    else
#      constraintCsv conEd

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

#  $("body").on "submit", ".card-form", ->
#    if $(this).find(".specification-input").length > 0
#      $(this).setContentFieldsFromMap()
#      lockConstraintEditor constraintEditor(this)


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

decko.slot.ready (slot) ->
  if slot.find(".specification-input").length > 0
    updateSpecVisibility slot

#constraintCsv = (conEd) ->
#  rows = conEd.find(".constraint-editor").map ()->
#    constraintToImportItem $(this)
#  rows.get().join "\n"
#
#constraintToImportItem = (con)->
#  [metricValue(con), yearValue(con), valueValue(con), groupValue(con)].join ";|;"
#
#metricValue = (con) ->
#  con.find(".constraint-metric input").val()
#
#yearValue = (con) ->
#  con.find(".constraint-year select").val()
#
#valueValue = (con) ->
#  con.find(".constraint-value input, .constraint-value .constraint-value-fields > select").serialize()
#
#groupValue = (con) ->
#  con.find(".constraint-related-group select").val()
#

#
## see note about locking constraint editor below
#lockConstraintEditor = (conEd)->
#  conEd.data "locked", "true"
#  conEd.find(".constraint-editor input, .constraint-editor select")
#    .prop "disabled", true

# note about locking constraint editor
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# When the form with the constraint editor is submitted, the process is to assemble
# the constraint specification in JavaScript and then submit it as content. For this to
# work we have to take weird steps to prevent the form elements themselves from being
# submitted. Otherwise we sometimes get, eg, one constraint setting filter[value] to
# an array and another to a hash, and then rack can't parse what comes through.

# The current approach is to generate the content, then disable the elements and lo

# old approach was to set form attribute of elements to dummy form so they wouldn't
# be submitted. In theory this solution is nice, but it doesn't work with how
# form data is sent by rails.js's handleRemote function, which doesn't respect
# the "form" attributes of input elements.  The relevant code:

# if (element.is('form')) {
#   data = $(element[0]).serializeArray();

# $(".constraint-editor input, .constraint-editor select").attr "form", "ignore"
