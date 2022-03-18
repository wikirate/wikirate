formEd = (el) ->
  new decko.FormulaEditor el

class decko.FormulaEditor
  constructor: (el) -> @ed = $(el).closest "._formula-editor"

  form: -> @ed.closest "form"

  slot: -> @ed.slot()

  updateInputs: (inputs) ->
    @ed.data "inputs", inputs
    @updateAnswers()
    @showInputs 0

  inputs: -> @ed.data "inputs"

  updateAnswers: ->
    i = @inputs()
    $("._ab-total").html i.total
    $("._ab-sample-size").html i.sample.length

  variableEditor: ->
    ved = @form().find "._variablesEditor"
    new decko.FormulaVariablesEditor ved

  showInputs: (index) ->
    @variableEditor().showInputs @inputs().sample[index]

