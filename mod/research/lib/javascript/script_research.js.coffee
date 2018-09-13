decko.slotReady (slot) ->
  $('input._research-select').autocomplete
    select: (e, ui) ->
      $target = $(e.target)
      url = $target.data("url")
      url += (if url.match /\?/ then '&' else '?')
      url += $target.data("key") + "=" + encodeURIComponent(ui.item.value)
      $target.updateSlot(url)

  $("._html-select").each ->
    $(this).select2
      minimumInputLength: 0
      #minimumResultsForSearch: 4
      maximumSelectionSize: 1
      dropdownAutoWidth: "true"
      width: "130%"
      templateResult: formatHtmlOptionItem
      templateSelection: formatHtmlSelectedItem
      escapeMarkup: (markup) ->
        markup
      containerCssClass: "html-select2"
      dropdownCssClass: "html-select2"

  $("._html-select").on "select2:select", (event) ->
    url = $(event.params.data.element).data("url")
    window.location = decko.path(url)


  $("body").on "change", "#card_subcards__value_subcards__Unknown_content", ->
    toggleAnswerValueField $(this).is(":checked")

  $("body").on "click", "._methodology-tab", ->
    $('a[href="#research_page-methodology"]').tab("show")

formatHtmlOptionItem = (i) ->
  if i.loading
    return i.text
  selector = $(i.element).data("option-selector")
  $(selector).html()

formatHtmlSelectedItem = (i) ->
  selector = $(i.element).data("selected-option-selector")
  $(selector).html()

$(document).ready ->
  $("#main:has(>#Research_Page.slot_machine-view)").addClass("pl-0 pr-0")

  $('#card_subcards__values_content').on "keyup", () ->
    selector = '#card_subcards__values_subcards__Unknown_content'
    checked = $(this).val().toLowerCase() == 'unknown'
    $(selector).prop 'checked', checked

   $('#card_subcards__values_subcards__Unknown_content').on "click", () ->
    if $(this).prop('checked') == true
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
