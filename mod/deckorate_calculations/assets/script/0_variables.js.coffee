window.deckorate =
  VariablesEditor: class
    constructor: (el) -> @ed = $(el).closest ".variablesEditor"

    form:-> @ed.closest "form"
    submitButton:-> @form().find(".submit-button")

    variableClass: -> deckorate.Variable

    variables:->
      klass = @variableClass()
      ed = @ed
      for row in ed.find "._filtered-list-item"
          new klass ed, row

    hashList:-> v.hash() for v in @variables()

    json:-> JSON.stringify @hashList()

    removeVariable: (el) ->
      $(el).closest("._filtered-list-item").remove()

  Variable: class
    constructor: (ed, row) ->
      @ed = ed
      @row = $(row)

    metricId:-> @row.find(".TYPE-metric.thumbnail").data "cardId"
