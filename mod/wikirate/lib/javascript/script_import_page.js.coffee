wagn.slotReady (slot) ->
  slot.find('.company_autocomplete').autocomplete
    source: '/Companies+*right+*options.json?view=name_complete'
    minLength: 2
  slot.find('.wikirate_company_autocomplete').autocomplete
    source: '/Companies+*right+*options.json?view=name_complete'
    minLength: 2
  slot.find('.wikirate_topic_autocomplete').autocomplete
    source: '/Topic+*right+*options.json?view=name_complete'
    minLength: 2
  slot.find('.metric_autocomplete').autocomplete
    source: '/Metric+*right+*options.json?view=name_complete'
    minLength: 2

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

