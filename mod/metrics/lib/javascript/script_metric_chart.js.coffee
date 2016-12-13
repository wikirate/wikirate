wagn.slotReady (slot) ->
  for vis in slot.find('.vis')
    $.ajax
      url: $(vis).data "url"
      type: "GET"
      success: (data) -> metric_chart(data, $(vis).attr('id'))

metric_chart = (spec, id) ->
  vg.parse.spec spec, (error, chart) ->
    chart({el: "##{id}"}).on "click", (event, item) ->
      if item.datum.link
        $.ajax item.datum.link,
          success: (data) -> $(event.target).setSlotContent(data)
    .update()
