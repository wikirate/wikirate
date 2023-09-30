
$(document).ready ->
  $("body").on "click", "._export-button", (e)->
    ae = $(this).closest "._attributable-export"
    ae.find("._hidden-attribution-alert-link").trigger "click"

