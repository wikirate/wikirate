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
    $(this).closest('form.card-form')
            .find('button[type=submit]')
            .prop('disabled', result != 100)


  $('body').on 'click', '._add-weight', (event) ->
    url  = wagn.rootPath + '/~' + $(this).data('metric-id')
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


hideAll = (slot)->
  slot.find(".value_type_field").hide()

showField = (divName) ->
  return if divName == ''
  $("#" + divName).slideDown(100)

showAndHide = (slot, value) ->
  div_to_show =
    switch value
      when 'Number'
        'number_details'
      when 'Money'
        'currency_details'
      when 'Category', 'Multi-Category'
        'category_details'
      else
        ''
  hideAll(slot)
  showField(div_to_show)

$(document).ready ->
  $(".topic-list .RIGHT-topic").readmore(
    {
      maxHeight: 70,
      heightMargin: 16,
      moreLink: '<a href="#" ><small ">View all</small></a>',
      lessLink: '<a href="#"><small>View less</small></a>'
    })

wagn.slotReady (slot) ->
  slot.find('[data-tooltip="true"]').tooltip()
  slot.find('input[name="intervaltype"]').on 'click', () ->
    #jQuery handles UI toggling correctly when we apply "data-target"
    #attributes and call .tab('show')
    #on the <li> elements' immediate children, e.g the <label> elements:
    $(this).closest('label').tab('show')

  # hide the related field
  # if no type is selected, hide all fields
  if slot.find('.card-editor.RIGHT-value_type').length
    hideAll(slot)
    slot.find('.card-editor.RIGHT-value_type .pointer-radio input:radio').each(->
      if $(this).is(':checked')
        showAndHide slot, $(this).val()
      $(this).change(->
        showAndHide slot, $(this).val()
      )
    )
    if slot.parent().hasClass('modal-body')
      # cancel-button to dismiss the modal
      slot.find(".cancel-button").data('dismiss','modal')
      # dismiss and refresh page after submit
      slot.find('form:first').on 'ajax:success', (_event, data, xhr) ->
        $('#modal-main-slot').modal('hide')
        $('#fakeLoader').fakeLoader
          timeToHide: 1000000 #Time in milliseconds for fakeLoader disappear
          zIndex: '999' #Default zIndex
          #Options: 'spinner1', 'spinner2', 'spinner3', 'spinner4', 'spinner5',
          #         'spinner6', 'spinner7'
          spinner: 'spinner1'
          bgColor: 'rgb(255,255,255,0.80)'#Hex, RGB or RGBA colors
        location.reload()
