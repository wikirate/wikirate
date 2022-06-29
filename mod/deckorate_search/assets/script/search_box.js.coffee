
$(window).ready ->
  $("body").on "change", ".search-box-form .search-box-select-type", (e) ->
    if hasKeyword this
      decko.searchBox.select e

  $("body").on "click", ".search-box-form ._search-button", (e) ->
    if hasKeyword this
      decko.searchBox.select e
    else
      browseType $(this).closest("form").find("#query_type").val()

    e.preventDefault()


browseType = (type) ->
  page = type == "" && ":search" || type
  window.location = decko.path page + "?" + $.param { query: { type: type } }

hasKeyword = (el) ->
  $(el).closest("form").find("#query_keyword").val()