decko.slotReady (slot) ->
$(document).ready ->
  $('body').on 'click', '._import-status-form ._check-all', (_e) ->
    checked = $(this).is(':checked')
    selectImportRows $(this).closest('._import-status-form'), checked

  $('body').on 'click', "input[name=importMapItem]", () ->
    $(this).closest("._map-item").find("")

  selectImportRows = (status_form, checked) ->
    status_form.find("._import-row-checkbox").prop 'checked', checked

