$(document).ready ->
  $(".research-layout .tab-pane-answer_phase").on "change", "input, textarea, select", ->
    $(".research-answer .card-form").data "changed", true

  $(".research-layout").on "click", "._research-metric-link, .research-answer-button", (e) ->
    return unless $(".research-answer .card-form").data "changed"
    e.preventDefault()
    leave = $("#confirmLeave")
    leave.trigger "click"
    leave.data "confirmHref", $(this).attr "href"


  $(".research-layout").on "click", "._yes_leave", () ->
    window.location.href = $("#confirmLeave").data "confirmHref"