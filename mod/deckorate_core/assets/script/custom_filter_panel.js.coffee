$ ->
  $("body").on "click", "._custom-item-view-radios input", ->
    $("#_custom-filtered-view").val $(this).val()

#  decko.filter.formatters["customItem"] = (form, data)->
#    view = form.find("#_custom-filtered-view").val()
#    if view?
#      data.slot = { items: { view: view } }
