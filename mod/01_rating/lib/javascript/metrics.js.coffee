wagn.editorContentFunctionMap['.pairs-editor'] = ->
  hash = {}
  @find('tbody').first().find('tr').each ->
    cols = $(this).find('td')
    hash[($(cols[0]).data('key'))] = $(cols[1]).find('input').val()
  JSON.stringify(hash)

$(window).ready ->
  $('body').on 'input', 'input.metric-weight', (event) ->
    result = 0
    @closest('tbody').find('input').each ->
      result += $(this).val()
    @closest('tbody').find('.weight-sum').val(result)