$(document).ready ->
  $(".topic-list .RIGHT-topic").readmore(
    maxHeight: 70,
    heightMargin: 16,
    moreLink: '<a href="#" ><small>View all</small></a>',
    lessLink: '<a href="#"><small>View less</small></a>'
  )

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

# WikiRatings Formulae

# WikiRating formulae are stored as a simple JSON hash:
#
# { metric_name: metric_weight }

decko.editorContentFunctionMap['.pairs-editor'] = ->
  JSON.stringify pairsEditorHash(this)

pairsEditorHash = (table) ->
  hash = {}
  table.find("tbody tr").each ->
    tr = $(this)
    if key = tr.find(".metric-label .thumbnail").data "cardName"
      hash[key] = tr.find(".metric-weight input").val()
  hash

$(window).ready ->
  $('body').on 'input', '.metric-weight input', (_event) ->
    validateWikiRating $(this).closest(".pairs-editor")

  $('body').on "click", "._remove-weight", () ->
    removeWeightRow $(this).closest("tr")

validateWikiRating = (table) ->
  hash = pairsEditorHash table
  valid = tallyWeights table, hash
  updateWikiRatingSubmitButton table.closest('form.card-form'), valid


DIGITS_AFTER_DECIMAL = 2

tallyWeights = (tbody, hash) ->
  multiplier = 10**DIGITS_AFTER_DECIMAL
  total =  0
  valid = true
  $.each hash, (_key, val) ->
    num = parseFloat val
    total += num * multiplier
    valid = false unless num > 0
  total = parseInt(total) / multiplier
  publishWeightTotal(tbody, hash, total)
  valid && total == 100

publishWeightTotal = (tbody, hash, total) ->
  sum = tbody.find('.weight-sum')
  sum_row = sum.closest "tr"
  if $.isEmptyObject(hash)
    sum_row.hide()
  else
    sum.val total
    sum_row.show()

# only enable button if weights total 100% and there are no zero weights
updateWikiRatingSubmitButton =(form, valid) ->
  form.find(".submit-button").prop('disabled', !valid)

addMissingVariables = (slot) ->
  pairsEditor = slot.closest(".editor").find ".pairs-editor"
  addNeededWeightRows pairsEditor, slot.find(".thumbnail")
  validateWikiRating pairsEditor

addNeededWeightRows = (editor, thumbnails) ->
  thumbnails.each ->
    nail = $(this)
    if needsWeightRow editor, nail.data("cardId")
      addWeightRow editor, nail

needsWeightRow = (editor, cardId) ->
  findByCardId(editor, cardId).length == 0

addWeightRow = (editor, thumbnail) ->
  templateRow = editor.slot().find ".weight-row-template tr"
  newRow = rowWithThumbnail templateRow, thumbnail
  editor.find("tbody tr:last-child").before newRow

findByCardId = (from, cardId) ->
  $(from).find("[data-card-id='" + cardId + "']")

removeWeightRow = (formulaRow) ->
  editor = formulaRow.closest ".pairs-editor"
  cardId = formulaRow.find(".thumbnail").data("cardId")
  variableItem = variableItemWithId editor.slot(), cardId
  formulaRow.remove()
  variableItem.remove()
  validateWikiRating editor

variableItemWithId = (slot, cardId) ->
  variablesList = slot.find ".edit_in_wikirating-view"
  findByCardId variablesList, cardId

rowWithThumbnail = (templateRow, thumbnail) ->
  row = templateRow.clone()
  row.find(".metric-label").html thumbnail.clone()
  row
