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

  $('td.metric-weight input').on 'keyup', (event) ->
    activeEqualize()

  $('#equalizer').on 'click', (event) -> 
    if $(this).prop('checked') == true 
      toEqualize( $('.wikiRating-editor') )

showResearchAttributes = (checkbox) ->
  form = checkbox.closest("form")

  show_or_hide = checkbox.prop "checked"
  $.each ["value_type", "research_policy", "report_type", "methodology"], (_i, key) ->
    form.find(".card-editor.RIGHT-" + key).toggle show_or_hide
    

decko.editorContentFunctionMap['.pairs-editor'] = ->
  JSON.stringify pairsEditorHash(this)

pairsEditorHash = (table) ->
  hash = {}
  variableMetricRows(table).each ->
    cols = $(this).find('td')
    if (key = $(cols[0]).data('key'))
      hash[key] = $(cols[1]).find('input').val()
  hash 

# if all values are equals return "true"
valueFormEqual = (table) -> 
  console.log('table', table)
  aux = false 
  values = []
  variableMetricRows(table).each -> 
    tr = $(this) 
    values.push( tr.find('td.metric-weight').find('input').val() )
    
  values = values.splice(0, values.length - 1);
  if values.every( (val, i, arr) => val == arr[0] ) == true  
    aux = true
  return aux


# WikiRatings Formulae

# WikiRating formulae are stored as a simple JSON hash:
#
# { metric_name: metric_weight }

decko.editorContentFunctionMap['.wikiRating-editor'] = ->
  JSON.stringify wikiRatingEditorHash(this)


wikiRatingEditorHash = (table) ->
  hash = {}
  variableMetricRows(table).each ->
    tr = $(this)
    if key = tr.find(".metric-label .thumbnail").data "cardName"
      hash[key] = tr.find(".metric-weight input").val()
  hash 

# if all values are equals active the equalize
activeEqualize = () -> 
  if !valueFormEqual( $('.wikiRating-editor') )  
    $('#equalizer').prop('checked', false)
  else 
    $('#equalizer').prop('checked', true)
    toEqualize( $('.wikiRating-editor') )

toEqualize = (table) -> 
  val = (100 / (variableMetricRows(table).length - 1)).toFixed(2)
    
  variableMetricRows(table).each ->
    tr = $(this)
    tr.find('td.metric-weight').find('input').val(val)

  validateWikiRating(table)

variableMetricRows = (table) ->
  table.find("tbody tr")

$(window).ready ->
  $('body').on 'input', '.metric-weight input', (_event) ->
    validateWikiRating $(this).closest(".wikiRating-editor")

  $('body').on "click", "._remove-weight", () ->
    removeWeightRow $(this).closest("tr")
    toEqualize(  $('.wikiRating-editor') )
  

validateWikiRating = (table) ->
  hash = wikiRatingEditorHash table
  valid = tallyWeights table, hash
  #toEqualize table 
  updateWikiRatingSubmitButton table.closest('form.card-form'), valid


DIGITS_AFTER_DECIMAL = 2

tallyWeights = (tbody, hash) ->
  multiplier = 10**DIGITS_AFTER_DECIMAL
  total = 0
  valid = true
  $.each hash, (_key, val) ->
    num = parseFloat val 
    total += num * multiplier
    valid = false if num <= 0 || !isMaxDigit(val)
  if valid 
    total = total / multiplier
    publishWeightTotal(tbody, hash, total)
    valid && total > 99.90 and total <= 100.09

publishWeightTotal = (tbody, hash, total) ->
  sum = tbody.find('.weight-sum')
  sum_row = sum.closest "tr"
  if $.isEmptyObject(hash)
    sum_row.hide()
  else
    sum.val total
    sum_row.show()

isMaxDigit = (num) -> 
  aux = true 
  val = num.split('.')
  aux = false if val.length > 1 && val[1].length > 2 
  return aux; 

# only enable button if weights total 100% and there are no zero weights
updateWikiRatingSubmitButton =(form, valid) ->
  form.find(".submit-button").prop('disabled', !valid)

addMissingVariables = (slot) ->
  pairsEditor = slot.closest(".editor").find ".wikiRating-editor"
  addNeededWeightRows pairsEditor, slot.find(".thumbnail")
  validateWikiRating pairsEditor
  if $('#equalizer').prop('checked') == true
    toEqualize( $('.wikiRating-editor') )

addNeededWeightRows = (editor, thumbnails) ->
  thumbnails.each ->
    nail = $(this)
    if needsWeightRow editor, nail.data("cardId")
      addWeightRow editor, nail

needsWeightRow = (editor, cardId) ->
  findByCardId(editor, cardId).length == 0

addWeightRow = (editor, thumbnail) ->
  templateRow = editor.slot().find "._weight-row-template tr"
  newRow = rowWithThumbnail templateRow, thumbnail
  editor.find("tbody tr:last-child").before newRow

findByCardId = (from, cardId) ->
  $(from).find("[data-card-id='" + cardId + "']")

removeWeightRow = (formulaRow) ->
  editor = formulaRow.closest ".wikiRating-editor"
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
  