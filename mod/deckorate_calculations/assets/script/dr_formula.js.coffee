
# Translation (Score) editor

decko.editorContentFunctionMap['.pairs-editor'] = ->
  JSON.stringify pairsEditorHash(this)

pairsEditorHash = (table) ->
  hash = {}
  variableMetricRows(table).each ->
    cols = $(this).find('td')
    if (key = $(cols[0]).data('key'))
      hash[key] = $(cols[1]).find('input').val()
  hash