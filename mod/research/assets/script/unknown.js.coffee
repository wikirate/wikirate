# ~~~~~~~~ Handling of Unknown Checkbox ~~~~~~~~~~~~~~~~

# set content value to "Unknown" if unknown checkbox is checked
decko.editorContentFunctionMap["._unknown-checkbox input:checked"] = ->
  @val()

decko.slotReady (slot) ->
  # reset value when "unknown" is checked
  unknownCheckbox(slot).on "change", ->
    clearValue valueEditor(slot) if $(this).is(":checked")

  # reset unknown checkbox when value changes
  valueEditor(slot).find("#{knownInputSelector}, select").on "change", () ->
    unknownCheckbox(slot).prop "checked", isUnknown($(this))

# content editor of +value card
valueEditor = (el) ->
  el.find ".card-editor.RIGHT-value .content-editor"

unknownCheckbox = (el) ->
  el.find "._unknown-checkbox input[type=checkbox]"

isUnknown = (el)->
  el.val().toString().toLowerCase() == 'unknown'

knownInputSelector = "input:not([name=_unknown])"

# reset (known) value
clearValue = (editor) ->
  select = editor.find "select"
  if (select[0])
    select.val(null).change()
  else
    clearInputValue editor

# reset known value for input (ie, NOT select) tags
clearInputValue = (editor) ->
  $.each editor.find("#{knownInputSelector}:not(.current_revision_id)"), ->
    input = $(this)
    if input.prop("type") == "text"
      input.val null
    else
      input.prop "checked", false
