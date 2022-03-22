
$(window).ready ->
  # this sucks.  need to get rid of the timeout in editor.js.coffee that makes
  # this necessary or implement a better solution.
  setTimeout (-> initFormulaEditor()), 20

  $('body').on "click", "._formula-input-links a", ->
    formEd(this).showInputs $(this).data("inputIndex")

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
    @runVisibleCalculation()

  runCalculations: ->
    calc = @calculator()
    results = { known: [], unknown: [], error: [] }
    if calc.formula
      for inputList, index in @inputs().sample
        key = "known"
        try
          r = calc._calculate inputList
          if r == "Unknown"
            key = "unknown"
          else if typeof(r) == "number"
            key = "error" if isNaN(r) || !isFinite(r)
        catch
          key = "error"
        results[key].push index

    @publishResults results

  publishResults: (results) ->
    for key in Object.keys(results)
      group = $("._ab-sample-#{key}")
      group.find("._result-count").html results[key].length
      linkdiv = group.find "._formula-input-links"
      for inputIndex in results[key]
        link = $('<a><i></i></a>')
        link.data "inputIndex", inputIndex
        linkdiv.append link

  calculator: ->
    new drCalculator @rawFormula(), @variableEditor().variableNames(), @ed

  runVisibleCalculation: ->
    result = @calculator().run @variableEditor().variableValues()
    @ed.find("._sample-result-value").html result

  rawFormula: ->
    if @area
      @area.getValue()
    else
      $("._formula-editor .codemirror-editor-textarea").val()

  updateVariableName: (oldval, newval) ->
    return if !oldval || oldval == newval

    re = new RegExp oldval, "g"
    newFormula = @rawFormula().replace re, newval
    @area.getDoc().setValue newFormula

class drCalculator
  constructor: (@rawFormula, @variableNames, @ed) ->
    @formula = @compile()

  compile: ->
    f = @formulaJS()
    f = @setVariablesJS() + "\n" + f if f
    f

  setVariablesJS: ->
    string = ""
    for name, index in @variableNames
      string += "#{name} = inputList[#{index}];\n"
    string

  formulaJS: ->
    try
      raw = CoffeeScript.compile @rawFormula, bare: true
      @publish raw, ""
      raw
    catch e
      @publish e, e
      ""

  publish: (js, notify) ->
    @ed.find("._formula-as-javascript").html js
    @ed.slot().notify notify

  run: (inputList) ->
    return "invalid formula" unless @formula
    try
      @_calculate inputList
    catch e
      e.message

  _calculate: (inputList) -> eval @formula
