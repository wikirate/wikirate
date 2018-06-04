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

$('body').on 'click', '._add-weight', (event) ->
  url  = decko.rootPath + '/~' + $(this).data('metric-id')
  params = { view: 'weight_row' }
  $sum_row = $(".TYPE_PLUS_RIGHT-metric-formula.edit-view table.pairs-editor > tbody > tr:last")
  $new_row = $("<tr></tr>")
  $sum_row.before($new_row)
  wikirate.loader($new_row, true).add()
  $.ajax url, {
    type : 'GET'
    data : params
    success : (data) ->
      rows = $(".TYPE_PLUS_RIGHT-metric-formula.edit-view table.pairs-editor > tbody > tr")
      new_row = $(rows[rows.length - 2])
      $(new_row).html(data)
      wikirate.initRowRemove()
      if rows.size() == 2
        rows.first().find('input').val(100)
        $sum_row.find('td').removeClass('hidden')

  }
  add_metric_modal = $(this).closest('.modal')
  add_metric_modal.modal('hide')
  add_metric_modal.find('.modal-dialog > .modal-content').empty()


$(document).ready ->
  $(".topic-list .RIGHT-topic").readmore(
    {
      maxHeight: 70,
      heightMargin: 16,
      moreLink: '<a href="#" ><small>View all</small></a>',
      lessLink: '<a href="#"><small>View less</small></a>'
    })

decko.slotReady (slot) ->
  slot.find('[data-tooltip="true"]').tooltip()

  if slot.hasClass "edit_in_wikirating-view"
    addMissingVariables slot
    removeClass "hidden"

  if $(".new_tab_pane-view.METRIC_TYPE-formula").length > 0
    show = $(".card-editor.RIGHT-hybrid input[type='checkbox']").prop "checked"
    showResearchAttributes(show)

  $('body').on 'change', ".new_tab_pane-view.METRIC_TYPE-formula .card-editor.RIGHT-hybrid input[type=\'checkbox\']", (event) ->
    show = $(event.target).prop "checked"
    showResearchAttributes(show)


showResearchAttributes = (show) ->
  formula_tab = $(".new_tab_pane-view.METRIC_TYPE-formula")
  if show
    formula_tab.find(".card-editor.RIGHT-value_type").show()
    formula_tab.find(".card-editor.RIGHT-research_policy").show()
    formula_tab.find(".card-editor.RIGHT-report_type").show()
  else
    formula_tab.find(".card-editor.RIGHT-value_type").hide()
    formula_tab.find(".card-editor.RIGHT-research_policy").hide()
    formula_tab.find(".card-editor.RIGHT-report_type").hide()


addMissingVariables = (slot) ->
  pairsEditor = slot.closest(".editor").find ".pairs-editor"
  slot.find(".thumbnail").each ->
    if needsWeightRow pairsEditor, $(this).data("cardId")
      addWeightRow pairsEditor, $(this).closest("tr")

needsWeightRow = (editor, cardId) ->
  editor.find("[data-card-id='" + cardId + "']").length == 0

addWeightRow = (editor, tr) ->
  editor.find("tbody tr:last-child").before tr.clone()
