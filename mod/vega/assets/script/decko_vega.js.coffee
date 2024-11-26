$(document).ready ->
  $('body').on 'click', '._filter-bindings', ->
    vis = $(this).closest ".vis"
    klass = 'with-bindings'
    if vis.hasClass(klass) then vis.removeClass(klass) else vis.addClass(klass)
    $(this).closest("details").removeAttr "open"

decko.slot.ready (slot) ->
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
  vegaEmbed(el[0], spec).then (result)->
    handleChartClicks result.view, el
    addAction()

handleChartClicks = (vega, el) ->
  vega.addEventListener 'click', (_event, item) ->
    return unless el.closest("._filtered-content").exists()

    d = item.datum
    if d.filter
      updateFilter el, d.filter
    else if d.details
      updateDetails d.details

updateFilter = (el, filterVals) ->
  $.extend decko.filter.query(el).filter, filterVals
  decko.filter.refilter el

updateDetails = (detailsAnswer) ->
  $(".bar[data-card-link-name=\"#{detailsAnswer}\"]").trigger "click"

addAction = () ->
  $(".vega-actions").append "<a class='_filter-bindings'>Tweak</a>"
