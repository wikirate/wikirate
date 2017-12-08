decko.editorContentFunctionMap['.pairs-editor'] = ->
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
    $(this).closest('form.card-form')
            .find('button[type=submit]')
            .prop('disabled', result != 100)


  $('body').on 'click', '._add-weight', (event) ->
    url  = decko.rootPath + '/~' + $(this).data('metric-id')
    params = { view: 'weight_row' }
    $sum_row = $(".TYPE_PLUS_RIGHT-metric-formula.edit-view table.pairs-editor > tbody > tr:last")
    $new_row = $("<tr></tr>")
    $sum_row.before($new_row)
    wikirate.loader($new_row, true).add()
    $.ajax url, {
      type : 'GET'
      data : params
      success : (data) ->
        rows = $(".TYPE_PLUS_RIGHT-metric-formula.edit-view table.pairs-editor > tbody > tr")
        new_row = $(rows[rows.length - 2])
        $(new_row).html(data)
        wikirate.initRowRemove()
        if rows.size() == 2
          rows.first().find('input').val(100)
          $sum_row.find('td').removeClass('hidden')

    }
    add_metric_modal = $(this).closest('.modal')
    add_metric_modal.modal('hide')
    add_metric_modal.find('.modal-dialog > .modal-content').empty()

$(document).ready ->
  $(".topic-list .RIGHT-topic").readmore(
    {
      maxHeight: 70,
      heightMargin: 16,
      moreLink: '<a href="#" ><small ">View all</small></a>',
      lessLink: '<a href="#"><small>View less</small></a>'
    })

decko.slotReady (slot) ->
  slot.find('[data-tooltip="true"]').tooltip()
  slot.find('input[name="intervaltype"]').on 'click', () ->
    #jQuery handles UI toggling correctly when we apply "data-target"
    #attributes and call .tab('show')
    #on the <li> elements' immediate children, e.g the <label> elements:
    $(this).closest('label').tab('show')
