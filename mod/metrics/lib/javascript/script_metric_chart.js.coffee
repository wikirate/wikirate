decko.slotReady (slot) ->
  for vis in slot.find('.vis._load-vis')
    $(vis).removeClass("_load-vis")
    $.ajax
      url: $(vis).data "url"
      visID: $(vis).attr('id')
      dataType: "json"
      type: "GET"
      success: (data) -> metric_chart(data, this.visID)

    setFilterText($(vis))

setFilterText = ($vis) ->
  text = $vis.data("value-filter-text")
  return unless text
  showMetricValueFilter()
  $vis.closest(".filtered-content").find("#select2-filter_value-container").text(text)

showMetricValueFilter = ->
  decko.filterCategorySelected($('a[data-category="value"]'))

metric_chart = (spec, id) ->
  runtime = vega.parse spec
  view = new vega.View(runtime).initialize($("##{id}")[0]).hover().run()
  view.addEventListener('click', (event, item) ->
    if item.datum.link
      $.ajax item.datum.link,
        success: (data) -> $(event.target).setSlotContent(data)
  )

