$(document).ready ->
  # track whether there are changes in the answer form
  $(".research-layout .tab-pane-answer_phase").on "change", "input, textarea, select", ->
    $(".research-answer .card-form").data "changed", true

  # must confirm links to new answer when answer form is changed
  $(".research-layout").on "click", "._research-metric-link, .research-answer-button", (e) ->
    return unless editInProgress()
    e.preventDefault()
    leave = $("#confirmLeave")
    leave.trigger "click"
    leave.data "confirmHref", $(this).attr "href"

  # handle confirmed link to new answer
  $(".research-layout").on "click", "._yes_leave", () ->
    window.location.href = $("#confirmLeave").data "confirmHref"

  # handle confirmed link to new answer
  $(".research-layout").on "click", "._yes_year", () ->
    year = $("#confirmYear").data "year"
    changeToYear year
    clearTab "answer"

  # click anywhere on year option to select it and (if necessary) trigger confirmation
  $("body").on "click", "._research-year-option, ._research-year-option input", (e) ->
    input = $(this)
    input = input.find "input" unless input.is "input"
    year = input.val()
    if answerReadyForYearChange input
      changeToYear year
    else
      confirmYearChange e, year

changeToYear = (year)->
  $("._research-#{year} input").prop "checked", true
  changeYearInSourceFilter year
  changeYearInMetricLinks year

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

changeYearInSourceFilter = (year)->
  if $(".RIGHT-source ._compact-filter")[0]
    decko.compactFilter(".RIGHT-source ._compact-filter").addRestrictions year: year

changeYearInMetricLinks = (year)->
  $("._research-metric-link").each ->
    link = $(this)
    url = new URL(link.prop("href"))
    url.searchParams.set "year", year
    link.prop "href", url.toString()

changeHiddenName = (nameField, year) ->
  newName = nameField.val().replace /\d{4}$/, year
  nameField.val newName

fromResearched = ->
  tabPane("answer").find(".edit_inline-view")[0]

toResearched = (input) ->
  !input.closest("._research-year-option").find(".not-researched")[0]

clearTab = (phase) ->
  link = deckorate.tabPhase phase
  link.addClass "load"
  tabPane(phase).html ""

tabPane = (phase) ->
  $(".tab-pane-#{phase}_phase")

confirmYearChange = (event, year) ->
  link = $("#confirmYear")
  link.trigger "click"
  link.data "year", year
  event.preventDefault()
  event.stopPropagation()
