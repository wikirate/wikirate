# Ratings

# Rating variables are stored as a simple JSON hash:
#
# { metric: metric_name, weight: metric_weight }
decko.editors.content['.wikiRating-editor'] = ->
  weighter(this).json()

decko.slot.ready ->
  $('.metric-weight input').on 'keyup', ->
    weighter(this).checkEqualization()

  $('#equalizer').on 'click', ->
    weighter(this).equalize() if $(this).prop('checked') == true

  we = $("._wikiRating-editor")
  if we.length > 0
    weighter(we).validate()


decko.itemsAdded (slot) ->
  ed = slot.find(".wikiRating-editor")
  if ed[0]
    weighter(ed).validate()

$(window).ready ->
  $('body').on 'input', '.metric-weight input', ->
    weighter(this).validate()

  $('body').on "click", "._remove-weight", ->
    weighter(this).removeVariable this


weighter = (el) ->
  new WeightsEditor el

class WeightsEditor extends deckorate.VariablesEditor
  variableClass: -> WeightedVariable

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
    valid = t > 99.90 && t <= 100.09 && !@invalidWeight()

    # only enable submit button if valid
    @submitButton().prop "disabled", !valid

  invalidWeight: ->
    @variables().find (v) -> v.isInvalid()

  total:->
    t = (@weights().reduce ((a, b) -> a + b), 0).toFixed(2)
    @ed.find('.weight-sum').val t
    t

class WeightedVariable extends deckorate.Variable
  hash:->
    metric: "~#{@metricId()}"
    weight: @weight()

  weightInput:-> @row.find(".metric-weight input")

  weight:-> parseFloat @weightInput().val()

  setWeight: (val)-> @weightInput().val val

  isInvalid: ->
    w = @weight()
    isNaN(w) || w <=0 || w > 100
