window.deckorate = {}

$(window).ready ->
  # TODO: consider moving above to decko

  $(".new-metric").on "click", ".metric-type-list .box", (e) ->
    params =
      card:
        fields:
          ":metric_type": $(this).data("cardLinkName")
    window.location = decko.path "new/Metric?#{$.param params}"
    e.stopImmediatePropagation()
    e.preventDefault()

  $("body").on "click", "._filter-year-field input", ->
    box = $(this)
    siblings = box.parent().siblings()
    if box.val() == "latest"
      siblings.find("input").prop "checked", false if box.is(":checked")
    else
      siblings.find("input[value='latest']").prop "checked", false

  $("body").on "click", ".tree-button ._answer-group-modal-link .metric-value", (e) ->
    $(this).closest(".bar").find("._modal-page-link").trigger "click"
    e.stopPropagation()
    e.preventDefault()
