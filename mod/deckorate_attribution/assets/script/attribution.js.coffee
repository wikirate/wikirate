
$(document).ready ->
  $("body").on "click", "._export-button", (e)->
    alert = $(this).closest("._attributable-export").find("._attribution-alert")
    alert.showAsModal alert.slot() if alert[0]

