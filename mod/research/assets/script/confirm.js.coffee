$(document).ready ->
  $(".research-layout .tab-pane-answer_phase").on "change", "input, textarea, select", ->
    $(".research-answer .card-form").data "changed", true

  $(".research-layout").on "click", "._research-metric-link, .research-answer-button", (e) ->
    return unless editInProgress()
    e.preventDefault()
    leave = $("#confirmLeave")
    leave.trigger "click"
    leave.data "confirmHref", $(this).attr "href"

  $(".research-layout").on "click", "._yes_leave", () ->
    window.location.href = $("#confirmLeave").data "confirmHref"

  # click anywhere on year option to select it
  $("body").on "click", "._research-year-option, ._research-year-option input", (e) ->
    input = $(this).find("input")
    if answerReadyForYearChange input
      input.prop "checked", "true"
    else
      confirmYearChange e, input

editInProgress = ->
  $(".research-answer .card-form").data "changed"

answerReadyForYearChange = (input) ->
  if editInProgress()
    changeYearInAnswerForm input
  else
    clearTab "answer"
    true

changeYearInAnswerForm = (input)->
  return false if fromResearched() || toResearched(input)

  answerName = tabPane("answer").find "#new_card input#card_name"
  changeHiddenName answerName, input.val()
  true

changeHiddenName = (nameField, year) ->
  newName = nameField.val().replace /\d{4}$/, year
  nameField.val newName

fromResearched = ->
  tabPane("answer").find(".edit_inline-view")[0]

toResearched = (input) ->
  !input.closest("._research-year-option").find(".not-researched")[0]

clearTab = (phase) ->
  link = wikirate.tabPhase phase
  link.addClass "load"
  tabPane(phase).html ""

tabPane = (phase) ->
  $(".tab-pane-#{phase}_phase")

confirmYearChange = (event, input) ->
  alert "confirm year change: " + input.val()
  event.preventDefault()
