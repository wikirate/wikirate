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


hideAll = (slot)->
  slot.find(".value_type_field").hide()

showField = (divName) ->
  return if divName == ''
  $("#" + divName).slideDown(100)

wagn.slotReady (slot) ->
  slot.find('[data-tooltip="true"]').tooltip()
  if(slot.hasClass('STRUCTURE-metric_value_type_edit_structure'))
# hide the related field
# if no type is selected, hide all fields

    slot.find('.RIGHT-value_type #pointer_select').change(->
      div_to_show = ''
      value = $(this).val()

      switch value
        when 'Number'
          div_to_show = 'number_details'
        when 'Monetary'
          div_to_show = 'currency_details'
        when 'Category'
          div_to_show = 'category_details'
        else
          div_to_show = ''
      hideAll(slot)
      showField(div_to_show)
    ).change()
    # cancel-button to dismiss the modal
    slot.find(".cancel-button").data('dismiss','modal')
    # dismiss and refresh page after submit
    slot.find('form:first').on 'ajax:success', (_event, data, xhr) ->
      $('#modal-main-slot').modal('hide');
      $('#fakeLoader').fakeLoader
        timeToHide: 1000000 #Time in milliseconds for fakeLoader disappear
        zIndex: '999' #Default zIndex
        spinner: 'spinner1'#Options: 'spinner1', 'spinner2', 'spinner3', 'spinner4', 'spinner5', 'spinner6', 'spinner7'
        bgColor: 'rgb(255,255,255,0.80)'#Hex, RGB or RGBA colors
      location.reload();

