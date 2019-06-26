decko.slotReady (slot) ->
  for vis in slot.find('.vis._load-vis')
    loadVis $(vis)

loadVis = (vis) ->
  vis.removeClass("_load-vis")
  $.ajax
    url: vis.data "url"
    visID: vis.attr('id')
    dataType: "json"
    type: "GET"
    success: (data) -> initChart(data, this.visID)

initChart = (spec, id) ->
  el = $("##{id}")
  initVega(spec, el).addEventListener 'click', (event, item) ->
    d = item.datum
    if d.filter
      updateFilter el, d.filter
    else if d.details
      updateDetails d.details

initVega = (spec, el) ->
  runtime = vega.parse spec
  new vega.View(runtime).initialize(el[0]).hover().run()

updateFilter = (el, filterVals) ->
  filter = new decko.filter el.closest("._filtered-content").find("._filter-widget")
  for key of filterVals
    filter.addRestriction key, filterVals[key]

updateDetails = (detailsAnswer) ->
  $("[data-details-mark=\"#{detailsAnswer}\"]").trigger "click"
