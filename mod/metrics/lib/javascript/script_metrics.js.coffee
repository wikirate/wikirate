decko.editorContentFunctionMap['.pairs-editor'] = ->
  hash = {}
  @find('tbody').first().find('tr').each ->
    cols = $(this).find('td')
    if (key = $(cols[0]).data('key'))
      hash[key] = $(cols[1]).find('input').val()
  JSON.stringify(hash)

$(window).ready ->
  $('body').on 'input', '.metric-weight input', (_event) ->
    result = tallyWeights $(this).closest('tbody')
    updateWikiRatingSubmitButton $(this).closest('form.card-form'), result

tallyWeights = (tbody) ->
  result = 0
  tbody.find('.metric-weight input').each ->
    result += parseInt($(this).val())
  tbody.find('.weight-sum').val result
  result

updateWikiRatingSubmitButton =(form, result) ->
  form.find('button[type=submit]').prop('disabled', result != 100)

$(document).ready ->
  $(".topic-list .RIGHT-topic").readmore(
    {
      maxHeight: 70,
      heightMargin: 16,
      moreLink: '<a href="#" ><small ">View all</small></a>',
      lessLink: '<a href="#"><small>View less</small></a>'
    })

decko.slotReady (slot) ->
  slot.find('[data-tooltip="true"]').tooltip()

  if slot.hasClass "edit_in_wikirating-view"
    addMissingVariables slot

  if $(".new-view.TYPE-metric, .edit-view.TYPE-metric").length > 0
    checkbox = $(".card-editor.RIGHT-hybrid input[type='checkbox']")
    showResearchAttributes(checkbox)

  $('body').on 'change', ".TYPE-metric .card-editor.RIGHT-hybrid input[type=\'checkbox\']", (event) ->
    showResearchAttributes($(event.target))

showResearchAttributes = (checkbox) ->
  form = checkbox.closest("form")
  if checkbox.prop "checked"
    form.find(".card-editor.RIGHT-value_type").show()
    form.find(".card-editor.RIGHT-research_policy").show()
    form.find(".card-editor.RIGHT-report_type").show()
  else
    form.find(".card-editor.RIGHT-value_type").hide()
    form.find(".card-editor.RIGHT-research_policy").hide()
    form.find(".card-editor.RIGHT-report_type").hide()


addMissingVariables = (slot) ->
  pairsEditor = slot.closest(".editor").find ".pairs-editor"
  slot.find(".thumbnail").each ->
    if needsWeightRow pairsEditor, $(this).data("cardId")
      addWeightRow pairsEditor, $(this).closest("tr")

needsWeightRow = (editor, cardId) ->
  editor.find("[data-card-id='" + cardId + "']").length == 0

addWeightRow = (editor, tr) ->
  editor.find("tbody tr:nth-last-child(2)").after tr.clone()
