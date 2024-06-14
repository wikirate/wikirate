$ ->
  $("body").on "click", "._custom-item-view-radios input", (e) ->
    value = $(this).val()
    button = $("._customize_filtered")
    button.slot().data("slot").items = { view: value }
    # debugger
    decko.filter.refilter button

#  decko.filter.formatters["customItem"] = (form, data)->
#    view = form.find("#_custom-filtered-view").val()
#    if view?
#      data.slot = { items: { view: view } }
