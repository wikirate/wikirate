wagn.editorContentFunctionMap['.pairs-editor'] = ->
  hash = {}
  @find('tbody').first().find('tr').each ->
    cols = $(this).find('td')
    if (key = $(cols[0]).data('key'))
      hash[key] = $(cols[1]).find('input').val()
  JSON.stringify(hash)

$(window).ready ->
  $('body').on 'input', 'input.metric-weight', (event) ->
    result = 0
    $(this).closest('tbody').find('input.metric-weight').each ->
      result += parseInt($(this).val())
    $(this).closest('tbody').find('.weight-sum').val(result)