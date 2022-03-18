
$(window).ready ->
  # this sucks.  need to get rid of the timeout in editor.js.coffee that makes
  # this necessary or implement a better solution.
  setTimeout (-> initFormulaEditor()), 20


initFormulaEditor = ->
  textarea = $("._formula-editor .codemirror-editor-textarea")
  return unless (cm = textarea.data "codeMirror")
  cm.on "changes", ->
    formEd(textarea).runCalculations()


formEd = (el) ->
  new decko.FormulaEditor el

class decko.FormulaEditor
  constructor: (el) ->
    @ed = $(el).closest "._formula-editor"
    @area = @ed.find(".codemirror-editor-textarea").data "codeMirror"

  form: -> @ed.closest "form"

  slot: -> @ed.slot()

  updateInputs: (inputs) ->
    @ed.data "inputs", inputs
    @showInputs 0
    @runCalculations()
    @updateAnswers()

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

  runCalculations: ->
    @runVisibleCalculation()

  calculator: ->
    calc = new drCalculator @rawFormula(), @variableEditor().variableNames()
    @ed.find("._formula-as-javascript").html calc.formula
    calc

  runVisibleCalculation: ->
    result = @calculator().run @variableEditor().variableValues()
    @ed.find("._sample-result-value").html result

  rawFormula: ->
    if @area
      @area.getValue()
    else
      $("._formula-editor .codemirror-editor-textarea").val()

class drCalculator
  constructor: (@rawFormula, @variableNames) ->
    @formula = @setVariablesJS() + "\n" + @formulaJS()

  setVariablesJS: ->
    string = ""
    for name, index in @variableNames
      string += "#{name} = inputList[#{index}];\n"
    string

  formulaJS: -> CoffeeScript.compile @rawFormula, bare: true

  run: (inputList) ->
    try
      @_calculate inputList
    catch e
      e.message


  _calculate: (inputList) -> eval @formula

