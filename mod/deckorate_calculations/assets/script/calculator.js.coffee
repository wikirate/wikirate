deckorate._regionLookup = (region, field) ->
  map = deckorate.region || {}
  entry = map[region]
  entry[field] if entry

deckorate._addFormulaFunctions = (context) ->
  for source in [deckorate.calculator, formulajs]
    for key in Object.keys source
      context[key] = source[key]

deckorate.calculator =
  iloRegion: (region) -> deckorate._regionLookup region, "ilo_region"

  country: (region) -> deckorate._regionLookup region, "country"

  isKnown: (answer) -> answer != "Unknown"

  numKnown: (list) -> formulajs.COUNTIF list, "<>Unknown" # list.filter(isKnown).length

  anyKnown: (list) -> list.find isKnown


_calculateAll = (obj) ->
  r = {}
  for key, val of obj
    r[key] = _calculate val
  r

_calculate = (inputList) ->
  deckorate._addFormulaFunctions this
  # (meat of function is appended here)
