decko.editorContentFunctionMap['._variablesEditor'] = -> variabler(this).json()

$(window).ready ->
  $('body').on "click", "._remove-variable", ->
    variabler(this).removeVariable this

  $('body').on "change", "._options-scheme", ->
    variabler(this).setOptions $(this).val()

  $('body').on "click", "._edit-variable-options", ->
    variabler(this).editVariableOptions this

  $('body').on "click", "._update-formula-options", ->
    $(this).closest("._formula-options-template").data("opEd").update()
    $(this).closest('.modal').modal "hide"

  $('body').on "change", "._custom-formula-option", ->
    $(this).closest(".vo-radio").find("input[type=radio]").prop "checked", true

decko.slotReady (slot) ->
  if slot.hasClass("RIGHT-Xvariable")
    ed = slot.find "._variablesEditor"
    variabler(ed).initOptions() if ed.length > 0


variabler = (el) ->
  new FormulaVariablesEditor el

class FormulaVariablesEditor extends deckorate.VariablesEditor
  variableClass: -> FormulaVariable

  detectOptionsScheme: ->
    if !@variables().some((v) -> !v.allResearchedOptions())
      "all_researched"
    else if !@variables().some((v) -> !v.anyResearchedOptions())
      "any_researched"
    else
      "custom"

  initOptions: ->
    v.initOptions() for v in @variables()
    scheme =  @detectOptionsScheme()
    schemeSelect = @ed.find "select._options-scheme"
    schemeSelect.val scheme
    schemeSelect.trigger "change"
    @toggleOptionEdit scheme

  toggleOptionEdit: (scheme)->
    $("._edit-variable-options").toggle scheme == "custom"

  setOptions: (scheme)->
    @toggleOptionEdit scheme

    unless scheme == "custom"
      options = @optionsFor scheme
      v.setOptions(options) for v in @variables()

  optionsFor: (scheme) ->
    switch scheme
      when "all_researched" then {}
      when "any_researched"
        unknown: "Unknown"
        not_researched: "Unknown"

  editVariableOptions: (el) ->
    opEd = @ed.find("._formula-options-template").clone()
    v = new FormulaVariable @variable(el)
    v.initOptionEditor opEd

class OptionEditor
  constructor: (opEd, variable) ->
    @opEd = opEd
    @variable = variable
    @opEd.data "opEd", this

  init: ->
    @opEd.showAsModal @variable.row
    @opEd.closest(".modal-dialog").addClass "modal-lg"
    @interpret()

  interpret: ->
    opts = @variable.options()
    @setRadioVal "unknown", (opts.unknown || "result_unknown")
    @setRadioVal "not_researched", (opts.not_researched || "no_result")
    @setTextVal "year", opts.year
    @setTextVal "company", opts.company

  input: (field) -> @opEd.find("[name=vo-#{field}]")

  textVal: (field) -> @input(field).val()

  setTextVal: (field, val) -> @input(field).val val

  radioVal: (field) ->
    val = @input(field).filter(":checked").val()
    if val == "custom"
      @textVal "#{field}-custom"
    else
      val

  setRadioVal: (field, val) ->
    radios = @input field
    radioForVal = radios.filter "[value=#{val}]"
    if radioForVal.length == 0
      radioForVal = radios.filter "[value=custom]"
      @setTextVal "#{field}-custom", val
    radioForVal.prop "checked", true

  hash: ->
    unknown: @radioVal "unknown"
    not_researched: @radioVal "not_researched"
    year: @textVal "year"
    company: @textVal "company"

  update: ->
    @variable.setOptions @hash()

class FormulaVariable extends deckorate.Variable
  variableName:-> @row.find("._variable-name").val()

  hash:->
    hash = @options()
    hash.metric = "~#{@metricId()}"
    hash.name = @variableName()
    hash

  options:-> @optionsList().data "options"

  optionsList: -> @row.find "._formula_options"

  initOptionEditor: (opEd) ->
    @optionEditor = new OptionEditor opEd, this
    @optionEditor.init()

  initOptions: -> @setOptions @options()

  setOptions: (options) ->
    @cleanOptions options
    ul = @optionsList()
    ul.data "options", options
    @publishOptions()

  cleanOptions: (options) ->
    delete options.unknown if options.unknown == "result_unknown"
    delete options.not_researched if options.not_researched == "no_result"
    for key in Object.keys(options)
      delete options[key] if !options[key]

  publishOptions: ->
    list = @optionsList()
    list.children().remove()
    if @allResearchedOptions()
      list.html "<div class='faint'>(default)</div>"
    else
      for key, value of @options()
        list.append "<div class='small'><label>#{key}</label>: #{value}</div>"

  optionsLength: -> Object.keys(@options()).length

  allResearchedOptions: -> @optionsLength() == 0

  anyResearchedOptions: ->
    opts = @options()
    @optionsLength() == 2 && opts.not_researched == "Unknown" && opts.unknown == "Unknown"