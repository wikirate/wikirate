# answer histograms

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
  vega = initVega spec, el
  handleChartClicks vega, el

handleChartClicks = (vega, el) ->
  vega.addEventListener 'click', (event, item) ->
    return unless el.closest("._filtered-content").exists()

    d = item.datum
    if d.filter
      updateFilter el, d.filter
    else if d.details
      updateDetails d.details

initVega = (spec, el) ->
  runtime = vega.parse spec
  new vega.View(runtime).initialize(el[0]).hover().run()

updateFilter = (el, filterVals) ->
  if filterVals["value"] == "Other"
    alert 'Filtering for "Other" values is not yet supported.'
  else
    filter = new decko.filter el.closest("._filtered-content").find("._filter-widget")
    filter.addRestrictions filterVals

updateDetails = (detailsAnswer) ->
  $("[data-details-mark=\"#{detailsAnswer}\"]").trigger "click"
