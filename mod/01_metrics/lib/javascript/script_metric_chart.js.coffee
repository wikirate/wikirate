metric_chart = (spec) ->
  vg.parse.spec spec, (error, chart) ->
    chart({el: "#vis"}).on "click", (event, item) ->
      $.ajax item.datum.link,
        success: (data) -> $(event.target).setSlotContent(data)
    .update()
