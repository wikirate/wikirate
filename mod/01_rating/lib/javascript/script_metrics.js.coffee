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
    $(this).closest('form.card-form').find('button[type=submit]').prop('disabled', result != 100)


  $('body').on 'click', '.add-weight', (event) ->
    url  = wagn.rootPath + '/~' + $(this).data('metric-id')
    params = { view: 'weight_row' }
    $.ajax url, {
      type : 'GET'
      data : params
      success : (data) ->
        sum_row = $(".TYPE_PLUS_RIGHT-metric-formula.edit-view table.pairs-editor > tbody > tr:last")
        $(sum_row).before("<tr>" + data + "</tr>")
        rows = $(".TYPE_PLUS_RIGHT-metric-formula.edit-view table.pairs-editor > tbody > tr")
        if rows.size() == 2
          rows.first().find('input').val(100)
          sum_row.find('td').removeClass('hidden')

    }
    add_metric_modal = $(this).closest('.modal')
    add_metric_modal.modal('hide')
    add_metric_modal.find('.modal-dialog > .modal-content').empty()


