
$(window).ready ->
  $("._export-button").on "click", (e)->
    ae = $(this).closest "._attributable-export"
    ae.find("._hidden-attribution-alert-link").trigger "click"

