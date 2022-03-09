decko.editorContentFunctionMap['._variablesEditor'] = -> variabler(this).json()

$(window).ready ->
  $('body').on "click", "._remove-variable", ->
    variabler(this).removeVariable this

decko.slotReady (slot) ->
  optScheme = slot.find("._options-scheme")


variabler = (el) ->
  new FormulaVariablesEditor el

class FormulaVariablesEditor extends deckorate.VariablesEditor
  variableClass: -> FormulaVariable

  optionsScheme: -> @ed.find("._options-scheme").val()

class FormulaVariable extends deckorate.Variable
  variableName:-> @row.find("._variable-name").val()

  hash:->
    metric: "~#{@metricId()}"
    name: @variableName()
    options: @options()

  options:->
    switch @ed.optionsScheme
      when "default" then {}
      when "flexible" then { }
    else if


