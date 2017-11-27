decko.slotReady (slot) ->
  selectImportRows = (checked, match_type) ->
    selector = "._import-table"
    selector += " tr._#{match_type}-match" if match_type?
    selector += " input:checkbox[disabled!=\"disabled\"]"
    slot.find(selector).prop 'checked', checked

  slot.find('input:checkbox#_check-all').change (eventObject) ->
    checked = $(this).is(':checked')

    $('input:checkbox._group-check').prop 'checked', checked
    selectImportRows checked

  slot.find('input:checkbox._group-check').change (eventObject) ->
    checked = $(this).is(':checked')
    match_type = $(this).data("group")

    $('input:checkbox#_check-all').prop 'checked', false unless checked
    selectImportRows checked, match_type



