decko.slot.ready (slot) ->
$(document).ready ->
  $('body').on 'click', '._import-status-form ._check-all', (_e) ->
    checked = $(this).is(':checked')
    selectImportRows $(this).closest('._import-status-form'), checked

  selectImportRows = (status_form, checked) ->
    status_form.find("._import-row-checkbox").prop 'checked', checked

  $('body').on 'click', "input[name=allImportMapItems]", () ->
    allItems = $(this)
    allItems.closest("._import-table").find("[name=importMapItem]:visible").each ->
      itemCheckbox = $(this)
      itemCheckbox.prop "checked", allItems.prop("checked")

  # perform changes on checked items
  $('body').on 'change', "._import-map-action", () ->
    select = $(this)
    return if select.val() == ""

    closestImportTable(select).find("[name=importMapItem]:checked").each ->
      inp = $(this).closest("._map-item").find("._import-mapping")
      if select.val() == "auto-add"
        inp.val("AutoAdd") if inp.val() == ''
      else if select.val() == "clear"
        inp.val("")
    select.val ""
    select.trigger "change"

  $('body').on 'click', '._import-status-refresh', (e) ->
    s = $(this).slot()
    current_tab = s.find(".nav-link.active").data("tab-name")
    s.slotReload(s.slotUrl() + "&tab=" + current_tab)

  # show/hide mapped items
  $('body').on 'click', "._toggle-mapping-vis", (e) ->
    link = $(this)
    name = link.find("._mapping-vis-name")
    mapped = closestImportTable(link).find(".mapped-import-attrib")
    if name.text() == "Hide"
      mapped.hide()
      mapped.find("[name=importMapItem]").prop "checked", false
      name.text "Show"
    else
      mapped.show()
      name.text "Hide"
    e.preventDefault

  # reset status tab so that it updates when navigating there.
  $('body').on 'click', '._save-mapping', () ->
    $(".tab-pane-import_status_tab").html ""

    tab = $("._import-core > .tabbable > .nav > .nav-item:nth-child(2) > .nav-link")
    tab.addClass("load")

  closestImportTable = (el)->
    el.closest(".tab-pane").find "._import-table"

  # handle metric name selection (new text, new hidden value, new value editor)
  $("body").on "decko.filter.selection", "._suggest-link", (event, item) ->
    data = $(item.firstChild).data() # assumes first child has card data
    $(this).siblings().val data.cardName # assumes input field is only sibling
