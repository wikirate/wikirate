$(document).ready ->
# toggle download and url ui
  $('body').on 'click', "._output-filter-option", (e) ->
    e.preventDefault()
    option = $(this).data "option"
    restrictTo [option]




restrictTo = (types) ->
  url = decko.path "impact" + "?" + $.param(filter: { output_type: types })
  window.location = url
