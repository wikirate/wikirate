
$(window).ready ->
  $("body").on "change", ".search-box-form .search-box-select-type", (e) ->
    decko.searchBox.select e