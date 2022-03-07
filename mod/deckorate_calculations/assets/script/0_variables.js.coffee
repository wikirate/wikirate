

window.deckorate =
  VariablesTable: class
    constructor: (el) -> @table = $(el).closest ".variablesEditor"

    form:-> @table.closest "form"
    submitButton:-> @form().find(".submit-button")

    variableClass: -> deckorate.Variable

    variables:->
      for row in @table.find "._filtered-list-item"
        klass = @variableClass()
        new klass row

    hashList:-> v.hash() for v in @variables()

    json:-> JSON.stringify @hashList()

    removeVariable: (el) ->
      $(el).closest("._filtered-list-item").remove()

  Variable: class
    constructor: (row) -> @row = $(row)

    metricId:-> @row.find(".TYPE-metric.thumbnail").data "cardId"
