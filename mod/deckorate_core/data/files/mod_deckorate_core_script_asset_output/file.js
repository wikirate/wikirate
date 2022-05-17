// script_metrics.js.coffee
(function() {
  decko.slotReady(function(slot) {
    return slot.find('[data-tooltip="true"]').tooltip();
  });

  $(window).ready(function() {
    return $(".new-metric").on("click", ".metric-type-list .box", function(e) {
      var params;
      params = {
        card: {
          fields: {
            ":metric_type": $(this).data("cardLinkName")
          }
        }
      };
      window.location = decko.path("new/Metric?" + ($.param(params)));
      e.stopImmediatePropagation();
      return e.preventDefault();
    });
  });

}).call(this);

// script_metric_properties.js.coffee
(function() {
  var METRIC_PROPERTIES_TABLE, RESEARCHABLE_CHECKBOX, VALUE_TYPE_RADIO, hideAllTypeSpecificProperties, propScope, propertiesForValueType, researchableFromContent, rowForProp, showPropsFor, vizPropsFor, vizResearchProps;

  METRIC_PROPERTIES_TABLE = ".metric-properties";

  RESEARCHABLE_CHECKBOX = ".RIGHT-hybrid input[type=checkbox]";

  VALUE_TYPE_RADIO = ".RIGHT-value_type input[type=radio]";

  decko.slotReady(function(slot) {
    var mpt;
    if (slot.hasClass("TYPE-metric") && (slot.hasClass("new-view") || slot.hasClass("edit-view"))) {
      vizResearchProps(slot, slot.find(RESEARCHABLE_CHECKBOX).prop("checked"));
      vizPropsFor(slot, slot.find(VALUE_TYPE_RADIO + ":checked").val());
    }
    mpt = slot.find(METRIC_PROPERTIES_TABLE);
    if (mpt.length > 0) {
      vizResearchProps(mpt, researchableFromContent(mpt));
      vizPropsFor(mpt, mpt.find(".RIGHT-value_type .item-name").text());
    }
    slot.on("change", RESEARCHABLE_CHECKBOX, function(_e) {
      return vizResearchProps(propScope(this), $(this).prop("checked"));
    });
    return slot.on("change", VALUE_TYPE_RADIO, function(_e) {
      return vizPropsFor(propScope(this), $(this).val());
    });
  });

  researchableFromContent = function(scope) {
    var value;
    value = $.trim(scope.find(".RIGHT-hybrid.content-view").text());
    return value === "yes";
  };

  vizResearchProps = function(scope, show_or_hide) {
    if (scope.find(".RIGHT-hybrid")[0]) {
      return $.each(["research_policy", "report_type", "about", "methodology", "steward"], function(_i, prop) {
        return rowForProp(scope, prop).toggle(show_or_hide);
      });
    }
  };

  propScope = function(context) {
    return $(context).closest(".TYPE-metric");
  };

  propertiesForValueType = function(value) {
    switch (value) {
      case 'Number':
      case 'Money':
        return ['unit', 'range'];
      case 'Category':
      case 'Multi-Category':
        return ['value_option'];
      default:
        return [];
    }
  };

  vizPropsFor = function(scope, value_type) {
    hideAllTypeSpecificProperties(scope);
    return showPropsFor(scope, value_type);
  };

  hideAllTypeSpecificProperties = function(scope) {
    return ['unit', 'range', 'value_option'].forEach(function(prop) {
      return rowForProp(scope, prop).hide();
    });
  };

  showPropsFor = function(scope, value_type) {
    return propertiesForValueType(value_type).forEach(function(prop) {
      return rowForProp(scope, prop).show();
    });
  };

  rowForProp = function(scope, prop) {
    var set;
    set = scope.find('.RIGHT-' + prop);
    if (set.closest(METRIC_PROPERTIES_TABLE)[0]) {
      return set.closest('.labeled-view');
    } else {
      return set;
    }
  };

}).call(this);

// script_metric_chart.js.coffee
(function() {
  var handleChartClicks, initChart, initVega, loadVis, updateDetails, updateFilter;

  window.deckorate = {};

  decko.slotReady(function(slot) {
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
    return initVega(spec, $("#" + id));
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

  initVega = function(spec, el) {
    return vegaEmbed(el[0], spec).then(function(result) {
      return handleChartClicks(result.view, el);
    });
  };

  updateFilter = function(el, filterVals) {
    var filter;
    filter = new decko.filter(el.closest("._filtered-content").find("._compact-filter"));
    return filter.addRestrictions(filterVals);
  };

  updateDetails = function(detailsAnswer) {
    return $("[data-details-mark=\"" + detailsAnswer + "\"]").trigger("click");
  };

  $(document).ready(function() {
    return $('body').on('click', '._filter-bindings', function() {
      var klass, vis;
      vis = $(this).closest("._filtered-content").find('.vis');
      klass = 'with-bindings';
      if (vis.hasClass(klass)) {
        return vis.removeClass(klass);
      } else {
        return vis.addClass(klass);
      }
    });
  });

}).call(this);
