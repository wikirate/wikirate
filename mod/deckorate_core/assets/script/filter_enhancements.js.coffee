$ ->
  $("body").on "click", "._custom-item-view-radios input", (e) ->
    input = $(this)
    button = $("._customize_filtered")
    slotData = button.slot().data("slot")
    slotData.items ||= {}
    slotData.items.view = input.val()
    #    checkboxContainer = input.closest(".custom-filtered-panel").find "._custom-field-checkboxes"
    #    deckorate.updateCustomFieldOptions checkboxContainer
    decko.filter.refilter button

#  decko.filter.formatters["customItem"] = (form, data)->
#    view = form.find("#_custom-filtered-view").val()
#    if view?
#      data.slot = { items: { view: view } }


  $("body").on "click", "._sort-buttons a", (e) ->
    link = $(this)
    query = decko.filter.query link
    query.sort_by = link.data "sortBy"
    query.sort_dir = link.data "sortDir"
    decko.filter.refilter link
    e.preventDefault()
