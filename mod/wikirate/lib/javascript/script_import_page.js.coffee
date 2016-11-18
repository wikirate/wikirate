wagn.slotReady (slot) ->
  slot.find('.company_autocomplete').autocomplete
    source: '/Companies+*right+*options.json?view=name_complete'
    minLength: 2
  slot.find('#uncheck_all').change (eventObject) ->
    if $(this).is(':checked')
      $('#partial').removeAttr 'checked'
      $('#exact').removeAttr 'checked'
      slot.find('.import_table').find('input:checkbox').removeAttr 'checked'
    return
  slot.find('#partial').change (eventObject) ->
    if $(this).is(':checked')
      $('#uncheck_all').removeAttr 'checked'
      slot.find('.import_table').find('tr').each ->
        $this = $(this)
        match = $this.find('td:nth-child(4)').html()
        if match == 'partial'
          $this.find('td:nth-child(1)').find('input:checkbox').prop 'checked', true
        return
    return
  slot.find('#exact').change (eventObject) ->
    if $(this).is(':checked')
      $('#uncheck_all').removeAttr 'checked'
      slot.find('.import_table').find('tr').each ->
        $this = $(this)
        match = $this.find('td:nth-child(4)').html()
        if match == 'exact'
          $this.find('td:nth-child(1)').find('input:checkbox').prop 'checked', true
        return
    return
  return
