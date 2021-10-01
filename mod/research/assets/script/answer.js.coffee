$(document).ready ->
  $(".research-layout .tab-pane-answer_phase").on "change", "input, textarea, select", ->
    $(".research-answer .card-form").data "changed", true

  $(".research-layout").on "click", "._research-metric-link", (e) ->
    if $(".research-answer .card-form").data "changed"
      alert "changed"
      e.preventDefault()
    else
      alert "not changed"
