# WikiRatings

# WikiRating variables are stored as a simple JSON hash:
#
# { metric: metric_name, weight: metric_weight }
decko.editorContentFunctionMap['.wikiRating-editor'] = ->
  weighter(this).json()

decko.slotReady ->
  $('td.metric-weight input').on 'keyup', ->
    weighter(this).checkEqualization()

  $('#equalizer').on 'click', ->
    weighter(this).equalize() if $(this).prop('checked') == true

$(window).ready ->
  $('body').on 'input', '.metric-weight input', ->
    weighter(this).validate()

  $('body').on "click", "._remove-weight", ->
    weighter(this).removeVariable this

weighter = (el) ->
  new WeightsTable el

class WeightsTable extends deckorate.VariablesTable
  variableClass: -> WeightedVariable

  variables:->
    v = super
    v.pop() # last row is total
    v

  weights:-> v.weight() for v in @variables()

  checkEqualization: -> $('#equalizer').prop 'checked', @areEqual()

  areEqual: -> @weights().every( (val, i, arr) => val == arr[0] ) == true

  removeVariable: (el)->
    super el
    @equalize()

  equalize: ->
    vars = @variables()
    weight = (100 / vars.length).toFixed(2)
    v.setWeight(weight) for v in vars
    @validate()

  validate:->
    t = @total()
    valid = t > 99.90 && t <= 100.09
    # only enable submit button if valid
    @submitButton().prop "disabled", !valid

  total:->
    t = (@weights().reduce ((a, b) -> a + b), 0).toFixed(2)
    @table.find('.weight-sum').val t
    t

class WeightedVariable extends deckorate.Variable
  hash:->
    metric: "~#{@metricId()}"
    weight: @weight()

  weightInput:-> @row.find(".metric-weight input")

  weight:-> parseFloat @weightInput().val()

  setWeight: (val)-> @weightInput().val val
