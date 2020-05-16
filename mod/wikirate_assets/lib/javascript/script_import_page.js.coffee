decko.slotReady (slot) ->
$(document).ready ->
  $('body').on 'click', '._import-status-form ._check-all', (_e) ->
    checked = $(this).is(':checked')
    selectImportRows $(this).closest('._import-status-form'), checked

  # $('body').on 'click', "input[name=importMapItem]", () ->
  #   $(this).closest("._map-item").find("")


  selectImportRows = (status_form, checked) ->
    status_form.find("._import-row-checkbox").prop 'checked', checked


  $('body').on 'click', "input[name=allImportMapItems]", () ->
    allItems = $(this)
    allItems.closest("._import-table").find("[name=importMapItem]:visible").each ->
      itemCheckbox = $(this)
      itemCheckbox.prop "checked", allItems.prop("checked")

  $('body').on 'click', "._auto-add", () ->
    table = $(this).closest(".tab-pane").find("._import-table")
    table.find("[name=importMapItem]:visible:checked").each ->
      inp = $(this).closest("._map-item").find("._import-mapping")
      inp.val("AutoAdd") if inp.val() == ''

