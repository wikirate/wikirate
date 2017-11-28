decko.slotReady (slot) ->
  slot.find('#_check_all').change (eventObject) ->
    if $(this).is(':checked')
      $('._group_check').prop 'checked', true
      slot.find('.import_table input:checkbox[disabled!="disabled"]').prop 'checked', true
    else
      $('._group_check').removeAttr 'checked'
      slot.find('.import_table input:checkbox').removeAttr 'checked'

  slot.find('._group_check').change (eventObject) ->
    match_type = $(this).data("group")
    if $(this).is(':checked')
      slot.find('.import_table').find("tr._#{match_type}_match").each ->
        $(this).find('input:checkbox').prop 'checked', true
    else
      $('#_check_all').prop 'checked', false
      slot.find('.import_table').find("tr._#{match_type}_match").each ->
        $(this).find('input:checkbox').prop 'checked', false

