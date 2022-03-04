decko.editorContentFunctionMap['._variablesEditor'] = -> variabler(this).json()

$(window).ready ->
  $('body').on "click", "._remove-variable", ->
    variabler(this).removeVariable this

variabler = (el) ->
  new FormulaVariablesTable el

class FormulaVariablesTable extends deckorate.VariablesTable
  variableClass: -> FormulaVariable

class FormulaVariable extends deckorate.Variable
  variableName:-> @row.find("._variable-name").val()

  hash:->
    metric: "~#{@metricId()}"
    name: @variableName()
