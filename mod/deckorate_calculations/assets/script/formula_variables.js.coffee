decko.editorContentFunctionMap['._variablesEditor'] = -> variabler(this).json()

$(window).ready ->
  $('body').on "click", "._remove-variable", ->
    variabler(this).removeVariable this

  $('body').on "change", "._options-scheme", ->
    variabler(this).setOptions $(this).val()

  $('body').on "click", "._edit-variable-options", ->
    variabler(this).editVariableOptions this

decko.slotReady (slot) ->
  if slot.hasClass("RIGHT-Xvariable")
    ed = slot.find "._variablesEditor"
    variabler(ed).initOptions() if ed.length > 0


variabler = (el) ->
  new FormulaVariablesEditor el

class FormulaVariablesEditor extends deckorate.VariablesEditor
  variableClass: -> FormulaVariable

  optionsScheme: -> @ed.find("._options-scheme").val()

  initOptions: ->
    v.initOptions() for v in @variables()

    scheme = @optionsScheme()
    # TODO: detect scheme
    @toggleOptionEdit scheme

  toggleOptionEdit: (scheme)-> $("._edit-variable-options").toggle scheme == "custom"

  setOptions: (scheme)->
    @toggleOptionEdit scheme

    unless scheme == "custom"
      options = @optionsFor scheme
      v.setOptions(options) for v in @variables()

  optionsFor: (scheme) ->
    switch scheme
      when "default" then {}
      when "flexible"
        unknown: "Unknown"
        not_researched: "Unknown"

  editVariableOptions: (el) ->
    v = new FormulaVariable @variable(el)
    tmpl = @ed.find "._formula-options-template"
    tmpl = tmpl.clone()
    # tmpl.show()
    tmpl.showAsModal($(el))


class FormulaVariable extends deckorate.Variable
  variableName:-> @row.find("._variable-name").val()

  hash:->
    metric: "~#{@metricId()}"
    name: @variableName()
    options: @options()

  options:-> @optionsUl().data()

  optionsUl: -> @row.find "._formula_options"

  initOptions: -> @setOptions @options()

  setOptions: (options) ->
    delete options.unknown if options.unknown == "result_unknown"
    delete options.not_researched if options.not_researched == "no_result"

    ul = @optionsUl()
    ul.removeData()
    ul.data options
    @publishOptions()

  publishOptions: ->
    ul = @optionsUl()
    options = ul.data()
    ul.children().remove()
    if @defaultOptions()
      ul.html "<li class='faint'>(default)</li>"
    else
      for key, value of options
        ul.append "<li class='small variable-option'><label>#{key}</label>: #{value}</li>"

  defaultOptions: ->
    Object.keys(@options()).length == 0