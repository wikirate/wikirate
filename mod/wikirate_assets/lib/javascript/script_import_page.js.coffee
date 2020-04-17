decko.slotReady (slot) ->
  selectImportRows = (status_form, checked) ->
    status_form.find("._import-row-checkbox").prop 'checked', checked

  slot.find('input:checkbox#_check-all').change (_eventObject) ->
    checked = $(this).is(':checked')
    selectImportRows $(this).closest('._import-status-form'), checked
