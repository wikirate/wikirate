// custom_filter_panel.js.coffee
(function() {
  $(function() {
    return $("body").on("click", "._custom-item-view-radios input", function(e) {
      var button, value;
      value = $(this).val();
      button = $("._customize_filtered");
      button.slot().data("slot").items = {
        view: value
      };
      return decko.filter.refilter(button);
    });
  });

}).call(this);

// deckorate.js.coffee
(function() {
  window.deckorate = {};

  $(window).ready(function() {
    $(".new-metric").on("click", ".metric-type-list .box", function(e) {
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
    return $("body").on("click", "._filter-year-field input", function() {
      var box, siblings;
      box = $(this);
      siblings = box.parent().siblings();
      if (box.val() === "latest") {
        if (box.is(":checked")) {
          return siblings.find("input").prop("checked", false);
        }
      } else {
        return siblings.find("input[value='latest']").prop("checked", false);
      }
    });
  });

}).call(this);

// metric_properties.js.coffee
(function() {
  var METRIC_PROPERTIES_TABLE, RESEARCHABLE_CHECKBOX, VALUE_TYPE_RADIO, hideAllTypeSpecificProperties, propScope, propertiesForValueType, researchableFromContent, rowForProp, showPropsFor, vizPropsFor, vizResearchProps;

  METRIC_PROPERTIES_TABLE = ".metric-properties";

  RESEARCHABLE_CHECKBOX = ".RIGHT-hybrid input[type=checkbox]";

  VALUE_TYPE_RADIO = ".RIGHT-value_type input[type=radio]";

  decko.slot.ready(function(slot) {
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
