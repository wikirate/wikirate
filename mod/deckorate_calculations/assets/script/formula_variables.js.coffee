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
    for v in @variables()
      v.hash()

  json:-> JSON.stringify @hashList()

class Variable
  constructor: (tr) ->
    @row = $(tr)

  metricId:-> @row.find(".TYPE-metric.thumbnail").data "cardId"

  variableName:-> @row.find("._variable-name").val()

  hash:-> { metric: "~#{@metricId()}", name: @variableName() }
