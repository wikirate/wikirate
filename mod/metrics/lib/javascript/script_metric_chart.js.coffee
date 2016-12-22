wagn.slotReady (slot) ->
  for vis in slot.find('.vis')
    $.ajax
      url: $(vis).data "url"
      visID: $(vis).attr('id')
      dataType: "json"
      type: "GET"
      success: (data) -> metric_chart(data, this.visID)

metric_chart = (spec, id) ->
  vg.parse.spec spec, (error, chart) ->
    chart({el: "##{id}"}).on "click", (event, item) ->
      if item.datum.link
        $.ajax item.datum.link,
          success: (data) -> $(event.target).setSlotContent(data)
    .update()
