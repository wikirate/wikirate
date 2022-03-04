

window.deckorate =
  VariablesTable: class
    constructor: (el) -> @table = $(el).closest "table"

    form:-> @table.closest "form"
    submitButton:-> @form().find(".submit-button")

    variableClass: -> deckorate.Variable

    variables:->
      for row in @table.find "tbody tr"
        klass = @variableClass()
        new klass row

    hashList:-> v.hash() for v in @variables()

    json:-> JSON.stringify @hashList()

    removeVariable: (el) ->
      $(el).closest("tr").remove()

  Variable: class
    constructor: (tr) -> @row = $(tr)

    metricId:-> @row.find(".TYPE-metric.thumbnail").data "cardId"
