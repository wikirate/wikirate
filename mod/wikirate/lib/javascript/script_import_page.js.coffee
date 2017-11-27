decko.slotReady (slot) ->
  slot.find('checkbox#_check-all').change (eventObject) ->
    checked = $(this).is(':checked')

    $('checkbox._group-check').prop 'checked', checked
    slot.find('._import-table input:checkbox[disabled!="disabled"]').prop 'checked',
                                                                          checked

  slot.find('checkbox._group-check').change (eventObject) ->
    match_type = $(this).data("group")
    checked = $(this).is(':checked')

    $('checkbox#_check-all').prop 'checked', false unless checked
    slot.find("._import-table tr._#{match_type}-match input:checkbox").prop 'checked',
                                                                            checked



