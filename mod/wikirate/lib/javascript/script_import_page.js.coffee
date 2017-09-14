decko.slotReady (slot) ->
  slot.find('#_check_all').change (eventObject) ->
    if $(this).is(':checked')
      $('._group_check').prop 'checked', true
      slot.find('.import_table input:checkbox').prop 'checked', true
    else
      $('._group_check').removeAttr 'checked'
      slot.find('.import_table input:checkbox').removeAttr 'checked'

  slot.find('._group_check').change (eventObject) ->
    attr = $(this).data("group")
    if $(this).is(':checked')
      slot.find('.import_table').find('tr.' + attr).each ->
        $(this).find('input:checkbox').prop 'checked', true
    else
      $('#_check_all').prop 'checked', false
      slot.find('.import_table').find('tr.' + attr).each ->
        $(this).find('input:checkbox').prop 'checked', false

