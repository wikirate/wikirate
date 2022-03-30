$.extend deckorate,
  VariablesEditor: class
    constructor: (el) -> @ed = $(el).closest "._variablesEditor"

    form:-> @ed.closest "form"

    submitButton:-> @form().find(".submit-button")

    variableClass: -> deckorate.Variable

    variables:->
      klass = @variableClass()
      ed = @ed
      for item in ed.find "._filtered-list-item"
        new klass item

    hashList:-> Object.assign({}, v.hash()) for v in @variables()

    json:-> JSON.stringify @hashList()

    variable: (el) -> $(el).closest "._filtered-list-item"

    removeVariable: (el) -> @variable(el).remove()

  Variable: class
    constructor: (item) ->
      @row = $(item)

    metricId:-> @row.find(".TYPE-metric.thumbnail").data "cardId"
