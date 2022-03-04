# WikiRatings

# WikiRating are stored as a simple JSON hash:
#
# { metric: metric_name, weight: metric_weight }
decko.editorContentFunctionMap['.wikiRating-editor'] = ->
  rating(this).json()

decko.slotReady ->
  $('td.metric-weight input').on 'keyup', (event) ->
    rating(this).checkEqualization()

  $('#equalizer').on 'click', (event) ->
    rating(this).equalize() if $(this).prop('checked') == true

$(window).ready ->
  $('body').on 'input', '.metric-weight input', (_event) ->
    rating(this).validate()

  $('body').on "click", "._remove-weight", () ->
    rating(this).removeVariable this

rating = (el) ->
  new VariablesTable el

class VariablesTable
  constructor: (el) ->
    @table = $(el).closest ".wikiRating-editor"

    @digitsAfterDecimal = 2
    @multiplier = 10 ** @digitsAfterDecimal

  variables:->
    vars = for row in @table.find "tbody tr"
      new Variable row
    vars.pop() # last row is total
    vars

  hashList:->
    # vars = []
    for v in @variables()
      # vars.push
      v.hash()
    # vars

  weights:->
    # wts = []
    for v in @variables()
      # wts.push
      v.weight()
    # wts

  json:-> JSON.stringify @hashList()

  checkEqualization: ->
    $('#equalizer').prop 'checked', @areEqual()

  areEqual: ->
    @weights().every( (val, i, arr) => val == arr[0] ) == true

  removeVariable: (el) ->
    $(el).closest("tr").remove()
    equalize()

  equalize: ->
    vars = @variables()
    weight = (100 / (vars.length - 1)).toFixed(2)
    for v in vars
      v.setWeight weight
    @validate()

  validate:->
    @totalIsValid()

  totalIsValid:->
    t = @weights().reduce ((a, b) -> a + (parseFloat(b) * @multiplier)), 0
    debugger
    t = t / @multiplier
    alert t
    @publishTotal t
    if t > 99.90 and t <= 100.09
      t
    else
      false

  publishTotal: (total) ->
    @table.find('.weight-sum').val total

class Variable
  constructor: (tr) ->
    @row = $(tr)

  metricId:-> @row.find(".TYPE-metric.thumbnail").data "cardId"

  variableName:-> @row.find("._variable-name").val()

  hash:-> { metric: "~#{@metricId()}", weight: @weight() }

  weightInput:-> @row.find(".metric-weight input")

  weight:-> @weightInput().val()

  setWeight: (val)-> @weightInput().val val




## Validation

validateWikiRating = (table) ->
  hash = wikiRatingEditorHash table
  valid = tallyWeights table, hash
  updateWikiRatingSubmitButton table.closest('form.card-form'), valid


DIGITS_AFTER_DECIMAL = 2

tallyWeights = (tbody, hash) ->
  multiplier = 10**DIGITS_AFTER_DECIMAL
  aux = weightsAreValid(hash, multiplier)
  return false unless aux.valid
  total = aux.total / multiplier
  publishWeightTotal(tbody, hash, total)
  total > 99.90 and total <= 100.09

# exports
weightsAreValid = (hash, multiplier) ->
  valid = true
  total = 0
  $.each hash, (_key, val) ->
    num = parseFloat val
    total += num * multiplier
    valid = false if num <= 0 || !isMaxDigit(val)
  {total: total, valid: valid}

publishWeightTotal = (tbody, hash, total) ->
  sum = tbody.find('.weight-sum')
  sum_row = sum.closest "tr"
  if $.isEmptyObject(hash)
    sum_row.hide()
  else
    sum.val total
    sum_row.show()

isMaxDigit = (num) ->
  aux = true
  val = num.split('.')
  aux = false if val.length > 1 && val[1].length > 2
  return aux;

# only enable button if weights total 100% and there are no zero weights
updateWikiRatingSubmitButton =(form, valid) ->
  form.find(".submit-button").prop('disabled', !valid)

