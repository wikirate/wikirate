# answer histograms

# vega.scheme "wikiratescores", ["#ff0000", "#ff5700", "#ff7e00", "#fc9b00", "#f1b000",
#   "#debd00", "#c2c000", "#9ab700", "#65a300", "#008000",
#   "008800"]

window.deckorate = {}

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
  initVega spec, $("##{id}")

handleChartClicks = (vega, el) ->
  vega.addEventListener 'click', (_event, item) ->
    return unless el.closest("._filtered-content").exists()

    d = item.datum
    if d.filter
      updateFilter el, d.filter
    else if d.details
      updateDetails d.details

initVega = (spec, el) ->
  vegaEmbed(el[0], spec).then (result)->
    handleChartClicks result.view, el

updateFilter = (el, filterVals) ->
  filter = new decko.filter el.closest("._filtered-content").find("._compact-filter")
  filter.addRestrictions filterVals

updateDetails = (detailsAnswer) ->
  $(".bar[data-card-link-name=\"#{detailsAnswer}\"]").trigger "click"

$(document).ready ->
  $('body').on 'click', '._filter-bindings', ->
    vis = $(this).closest("._filtered-content").find '.vis'
    klass = 'with-bindings'
    if vis.hasClass(klass) then vis.removeClass(klass) else vis.addClass(klass)
