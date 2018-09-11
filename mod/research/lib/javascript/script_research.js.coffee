decko.slotReady (slot) ->
  $('input._research-select').autocomplete
    select: (e, ui) ->
      $target = $(e.target)
      url = $target.data("url")
      url += (if url.match /\?/ then '&' else '?')
      url += $target.data("key") + "=" + encodeURIComponent(ui.item.value)

# now done by reloading the whole page
#  if (slot.hasClass("edit-view") and slot.hasClass("TYPE-metric_value"))
#    enableSourceCitationButtons()
#    wikirate.showResearchDetailsTab("source")

  $("body").on "change", "#card_subcards__value_subcards__Unknown_content", ->
    toggleAnswerValueField $(this).is(":checked")

$(document).ready ->
  $("#main:has(>#Research_Page.slot_machine-view)").addClass("pl-0 pr-0")

  $($('#Research_Page ul.pointer-radio-list')[0]).find('input[type="radio"]').on "click", () ->
    uncheckOrCheckUnknown false
  $($('#Research_Page div.pointer-checkbox-list')[0]).find('input[type="checkbox"]').on "click", () ->
    uncheckOrCheckUnknown false

  $('#card_subcards__values_content').on "keyup", () ->  
    checked = $(this).val().toLowerCase() == 'unknown'
    uncheckOrCheckUnknown checked

   $('#card_subcards__values_subcards__Unknown_content').on "click", () -> 
    if $(this).prop('checked') == true 
      uncheckRadio()
      uncheckCheckbox()
      $('#card_subcards__values_content').val('Unknown')

  # add related company to name
  # otherwise the card can get the wrong type because it
  # match the ltype_rtype/record/year pattern
  $("body").on "submit", "form.answer-form", (e) ->
    $form = $(e.target)
    related_company = $form.find("#card_subcards__related_company_content")
    if related_company.length == 1
      name = $form.find("#card_name").val()
      $form.find("#card_name").val(name + "+" + related_company.val())
      unless $form.find("#success_id").val() == ":research_page"
        $form.find("#success_id").val("_left")

uncheckRadio = () -> 
  $($('ul.pointer-radio-list')[0]).find('input').prop('checked', false);

uncheckCheckbox = () -> 
  $($('div.pointer-checkbox-list')[0]).find('input[type="checkbox"]').prop('checked', false);

uncheckOrCheckUnknown = (val) ->
  selector = '#card_subcards__values_subcards__Unknown_content'
  $(selector).prop 'checked', val

toggleAnswerValueField = (disable) ->
  select = $(".card-editor.RIGHT-value .content-editor select")
  if select[0]
    toggleValueSelect(select, disable)
  else
    input = $(".card-editor.RIGHT-value .content-editor input:not(.current_revision_id)")
    toggleValueInput(input, disable)

toggleValueSelect = (select, disable) ->
  if disable
    select.prop("disabled", true).val(null).trigger("change")
  else
    select.prop("disabled", false)

toggleValueInput = (input, disable) ->
  if disable
    input.prop("checked", false).prop("disabled", true).val("")
  else
    input.prop("disabled", false)

enableSourceCitationButtons = () ->
  $("._cite_button, ._cited_button").removeClass "disabled"
  