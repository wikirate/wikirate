window.deckorate = {}

decko.slot.ready (slot) ->
  slot.find('[data-tooltip="true"]').tooltip()

$(window).ready ->
  $(".new-metric").on "click", ".metric-type-list .box", (e) ->
    params =
      card:
        fields:
          ":metric_type": $(this).data("cardLinkName")
    window.location = decko.path "new/Metric?#{$.param params}"
    e.stopImmediatePropagation()
    e.preventDefault()





