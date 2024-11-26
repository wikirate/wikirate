// decko_vega.js.coffee
(function() {
  var addAction, handleChartClicks, initChart, loadVis, updateDetails, updateFilter;

  $(document).ready(function() {
    return $('body').on('click', '._filter-bindings', function() {
      var klass, vis;
      vis = $(this).closest(".vis");
      klass = 'with-bindings';
      if (vis.hasClass(klass)) {
        vis.removeClass(klass);
      } else {
        vis.addClass(klass);
      }
      return $(this).closest("details").removeAttr("open");
    });
  });

  decko.slot.ready(function(slot) {
    var i, len, ref, results, vis;
    ref = slot.find('.vis._load-vis');
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      vis = ref[i];
      results.push(loadVis($(vis)));
    }
    return results;
  });

  loadVis = function(vis) {
    vis.removeClass("_load-vis");
    return $.ajax({
      url: vis.data("url"),
      visID: vis.attr('id'),
      dataType: "json",
      type: "GET",
      success: function(data) {
        return initChart(data, this.visID);
      }
    });
  };

  initChart = function(spec, id) {
    var el;
    el = $("#" + id);
    return vegaEmbed(el[0], spec).then(function(result) {
      handleChartClicks(result.view, el);
      return addAction();
    });
  };

  handleChartClicks = function(vega, el) {
    return vega.addEventListener('click', function(_event, item) {
      var d;
      if (!el.closest("._filtered-content").exists()) {
        return;
      }
      d = item.datum;
      if (d.filter) {
        return updateFilter(el, d.filter);
      } else if (d.details) {
        return updateDetails(d.details);
      }
    });
  };

  updateFilter = function(el, filterVals) {
    $.extend(decko.filter.query(el).filter, filterVals);
    return decko.filter.refilter(el);
  };

  updateDetails = function(detailsAnswer) {
    return $(".bar[data-card-link-name=\"" + detailsAnswer + "\"]").trigger("click");
  };

  addAction = function() {
    return $(".vega-actions").append("<a class='_filter-bindings'>Tweak</a>");
  };

}).call(this);
