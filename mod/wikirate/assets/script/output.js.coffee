# TODO: generalize

# This is implemented narrowly and will only work on the impacts page, but the
# pattern could be improved to be more reusable and to use AJAX

$ ->
  # add new output type filter
  $("body").on "click", "._output-filter-option", (e) ->
    e.preventDefault()
    option = $(this).data "option"
    restrictTo [option].concat(currentOptions())

  # remove output type filter
  $("body").on "click", "._remove-output-filter", (e) ->
    e.preventDefault()
    restrictTo currentOptions($(this).parent()[0])

currentOptions = (except)->
  curr = []
  $("._current-output-filter").each ->
    curr.push $(this).data("option") unless this == except
  curr

restrictTo = (types) ->
  url = decko.path "impact" + "?" + $.param(filter: { output_type: types })
  window.location = url
