
$(window).ready ->
  $('body').on "click", "._formula-input-links a", ->
    formEd(this).showInputs $(this).data("inputIndex")

decko.slotReady ->
# this sucks.  need to get rid of the timeout in editor.js.coffee that makes
# this necessary or implement a better solution.
  setTimeout (-> initFormulaEditor()), 20

initFormulaEditor = ->
  textarea = $("._formula-editor .codemirror-editor-textarea")
  return unless (cm = textarea.data "codeMirror")
  getRegionData()

  textarea.closest(".modal-dialog").addClass "modal-full"
  cm.on "changes", ->
    fe = formEd textarea
    fe.runVisibleCalculation()
    fe.runCalculations()

getRegionData = ->
  $.get decko.path("mod/wikirate_companies/region.json"), (json) ->
    deckorate.region = json

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
    $("._ab-result-unknown").toggle i.unknown > 0
    $("._ab-result-unknown-count").html i.unknown
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
    @submitButton false
    if calc._formula
      @runEachCalculation calc, results
      @submitButton true if results["error"].length == 0
    @publishResults results

  runEachCalculation: (calc, results) ->
    for inputList, index in @inputs().sample
      key = "known"
      try
        r = calc._simple_run inputList
        if r == "Unknown"
          key = "unknown"
        else if typeof(r) == "number"
          key = "error" if isNaN(r) || !isFinite(r)
      catch
        key = "error"
      results[key].push index

  submitButton: (enabled) ->
    @form().find(".submit-button").prop("disabled", !enabled)

  publishResults: (results) ->
    for key in Object.keys(results)
      group = $("._ab-sample-#{key}")
      group.find("._result-count").html results[key].length
      linkdiv = group.find "._formula-input-links"
      linkdiv.html ""
      for inputIndex in results[key]
        link = $('<a><i></i></a>')
        link.data "inputIndex", inputIndex
        linkdiv.append link

  calculator: ->
    new drCalculator @rawFormula(), @variableEditor().variableNames(), @ed

  runVisibleCalculation: ->
    result = @calculator()._run @variableEditor().variableValues()
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

# we use underscores here to minimize conflict with user formulae
class drCalculator
  constructor: (@_rawFormula, @_variableNames, @_ed) ->
    @_formula = @_compile()


  _run: (inputList) ->
    return "invalid formula" unless @_formula
    try
      @_simple_run inputList
    catch e
      e.message

  _simple_run: (inputList) ->
#    deckorate._addFormulaFunctions this
#    eval @_formula
    dumbEval @_formula, inputList


  _compile: ->
    f = @_formulaJS()
    f = @_setVariablesJS() + "\n" + f if f
    f

  _setVariablesJS: ->
    string = ""
    for name, index in @_variableNames
      string += "#{name} = inputList[#{index}];\n"
    string

  _formulaJS: ->
    try
      raw = CoffeeScript.compile @_rawFormula, bare: true
      @_publish raw, ""
      raw
    catch e
      @_publish e, e
      ""

  _publish: (js, notify) ->
    @_ed.find("._formula-as-javascript").html js
    @_ed.slot().notify notify

dumbEval = (formula, inputList) ->
  deckorate._addFormulaFunctions this
  eval formula
