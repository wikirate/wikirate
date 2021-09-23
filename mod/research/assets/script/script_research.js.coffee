# ~~~~~~~~ Handling of Unknown Checkbox ~~~~~~~~~~~~~~~~

decko.slotReady (slot) ->
  slot.find(".RIGHT-unknown input[type=checkbox]").on "change", ->
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
  unknown_checkbox = slot.find(".RIGHT-unknown input[type=checkbox]")
  $(unknown_checkbox).prop 'checked', isUnknown(val)

isUnknown = (val)->
  val.toLowerCase() == 'unknown'

# ~~~~~~~~ Other Research Page Handling ~~~~~~~~~~~~~~~~

revealOverlay = (overlay) ->
  overlay.hide()
  $("html, body").animate { scrollTop: 0 }, 300
  $(window).scrollTop
  overlay.show "slide", { direction: "down" }, 600

decko.slotReady (slot) ->
  if slot.hasClass "_overlay"
    revealOverlay slot

$(document).ready ->
  # toggle more/less years
  $("body").on "click", "._more-years-toggle", () ->
    el = $(this).find "._more-or-fewer"
    if el.text().match(/more/)
      el.text "fewer"
    else
      el.text "more"

  $("body").on "click", "#_select_year", (e) ->
    $(".tab-li-source_phase a").trigger "click"
    e.preventDefault()

  # add related company to name
  # otherwise the card can get the wrong type because it
  # matches the ltype_rtype/record/year pattern
  #  $("body").on "submit", "form.answer-form", (e) ->
  #    $form = $(e.target)
  #    related_company = $form.find("#card_subcards__related_company_content")
  #    if related_company.length == 1
  #      # name = $form.find("#card_name").val()
  #      # $form.find("#card_name").val(name + "+" + related_company.val())
  #      unless $form.find("#success_id").val() == ":research_page"
  #        $form.find("#success_id").val("_left")
