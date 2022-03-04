decko.editorContentFunctionMap['._variablesEditor'] = ->
  vt = new VariablesTable this
  vt.json()

class VariablesTable
  constructor: (table) ->
    @table = $(table)

  variables:->
    for row in @table.find "tbody tr"
      new Variable row

  hashList:->
    vars = []
    for v in @variables()
      vars.push v.hash()
    vars

  json:-> JSON.stringify vars

class Variable
  constructor: (tr) ->
    @row = $(tr)

  metricId:-> @row.find(".TYPE-metric.thumbnail").data "cardId"

  variableName:-> @row.find("._variable-name").val()

  hash:-> { metric: "~#{@metricId()}", name: @variableName() }
