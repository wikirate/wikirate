# ~~~~~~~~ Handling of Unknown Checkbox ~~~~~~~~~~~~~~~~

decko.slotReady (slot) ->
  slot.find("._unknown-checkbox input[type=checkbox]").on "change", ->
    if $(this).is(":checked")
      clearAnswerValue $(this).slot()

  slot.find(".RIGHT-value").find("input, select").on "change", () ->
    updateUnknownness(slot, $(this).val())

clearAnswerValue = (slot) ->
  editor = slot.find ".card-editor.RIGHT-value .content-editor"
  clearValue editor

clearValue = (editor) ->
  select = editor.find "select"
  if (select[0])
    select.val(null).change()
  else
    clearInputValue editor

clearInputValue = (editor) ->
  $.each editor.find("input:not(.current_revision_id)"), ->
    input = $(this)
    if input.prop("type") == "text"
      input.val null
    else
      input.prop "checked", false

updateUnknownness = (slot, val)->
  val = val.toString()
  return if val == ""
  unknown_checkbox = slot.find("._unknown-checkbox input[type=checkbox]")
  $(unknown_checkbox).prop 'checked', isUnknown(val)

isUnknown = (val)->
  val.toLowerCase() == 'unknown'