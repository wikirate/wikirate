$ ->
  $("body").on "click", "._custom-item-view-radios input", (e) ->
    value = $(this).val()
    hidden = $("#_custom-filtered-view")

    hidden.val value
    hidden.slot().data("slot").items = { view: value }
    # debugger
    decko.filter.refilter hidden.closest("form")

#  decko.filter.formatters["customItem"] = (form, data)->
#    view = form.find("#_custom-filtered-view").val()
#    if view?
#      data.slot = { items: { view: view } }
