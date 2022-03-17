$(window).ready ->
  $('body').on "click", "._magic", (event) ->
    ed = formEd this
    ed.variableContent()
    event.preventDefault()

formEd = (el) ->
  new FormulaEditor el

class FormulaEditor
  constructor: (el) -> @ed = $(el).closest "._formula-editor"

  form: -> @ed.closest "form"

  variableEditor: ->
    ved = @form().find "._variablesEditor"
    new decko.FormulaVariablesEditor ved

  variableContent: ->
    v = @variableEditor()

    alert v.json()
