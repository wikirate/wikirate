
# rubric (Score) editor

decko.editors.content['.pairs-editor'] = ->
  JSON.stringify pairsEditorHash(this)

decko.slot.ready (slot) ->
  ed = slot.find "> form ._scoreVariablesEditor"
  if ed.length > 0
    variabler(ed).updateFormulaInputs()

variabler = (el) -> new deckorate.ScoreVariableEditor el

pairsEditorHash = (table) ->
  hash = {}
  variableMetricRows(table).each ->
    cols = $(this).find('td')
    if (key = $(cols[0]).data('key'))
      hash[key] = $(cols[1]).find('input').val()
  hash

variableMetricRows = (table) ->
  table.find("tbody tr")

class deckorate.ScoreVariableEditor extends deckorate.FormulaVariablesEditor
  variableNames: -> ["record"]

  sampleValueInput: -> @ed.find("._sample-value")

  variableValues: -> [$.parseJSON @sampleValueInput().val()]

  hashList: -> @ed.data "variablesJson"

  showInputs: (inputs) -> @sampleValueInput().val inputs[0]