// customize_fields.js.coffee
(function() {
  var addIdentifierInputs, addInput, answerSlotData, companyIdentifiers, defaultChecked, fieldCheckboxes, fields, updateCheckAll, updateField, updateIdentCommas, updateSlotItems;

  $(function() {
    deckorate.customFields = {
      headquarters: {
        title: "Company Headquarters",
        selector: ".TYPE-company.thumbnail .RIGHT-headquarter.content-view"
      },
      identifiers: {
        title: "Company Identifiers",
        selector: ".TYPE-company.thumbnail .thumbnail-subtitle"
      },
      metric_type: {
        title: "Metric Type",
        selector: ".TYPE-metric.thumbnail .thumbnail-title-right"
      },
      metric_designer: {
        title: "Metric Designer",
        selector: ".TYPE-metric.thumbnail .thumbnail-subtitle"
      },
      contributor: {
        title: "Contributor",
        selector: ".bar-middle .credit"
      }
    };
    deckorate.updateCustomFieldOptions = function(container) {
      var checked, config, field, ref, results, sampleField;
      container.html("");
      ref = deckorate.customFields;
      results = [];
      for (field in ref) {
        config = ref[field];
        sampleField = fields(config["selector"])[0];
        if (sampleField) {
          checked = defaultChecked(field);
          results.push(addInput(container, field, config, checked));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };
    $("body").on("change", "._custom-field-checkboxes input", function(_e) {
      var box;
      box = $(this);
      updateField(box.data("fieldSelector"), box.is(":checked"));
      updateCheckAll();
      updateIdentCommas();
      return updateSlotItems();
    });
    return $("body").on("change", "input#_all-custom-fields", function(_e) {
      var checkboxes;
      checkboxes = fieldCheckboxes();
      checkboxes.prop("checked", $(this).is(":checked"));
      return checkboxes.trigger("change");
    });
  });

  decko.slot.ready(function(slot) {
    var config, container, field, ref;
    container = slot.find("._custom-field-checkboxes");
    if (container[0]) {
      deckorate.updateCustomFieldOptions(container);
      updateCheckAll();
    }
    if (slot.find(".answer-result-items")[0]) {
      deckorate.updateCustomFieldOptions($("._custom-field-checkboxes"));
      ref = deckorate.customFields;
      for (field in ref) {
        config = ref[field];
        updateField(config["selector"], defaultChecked(field));
      }
    }
    if (slot.find("._ident-field")[0]) {
      return updateIdentCommas();
    }
  });

  updateIdentCommas = function() {
    $("._ident-field:not(:contains(','))").append($("<span class='ident-comma'>, </span>"));
    $(".ident-comma").show();
    return $(".thumbnail-subtitle").find(".ident-comma:visible:last").hide();
  };

  updateSlotItems = function() {
    var hidden, sdata;
    sdata = answerSlotData();
    hidden = fieldCheckboxes().filter(":not(:checked)").map(function() {
      return $(this).data("fieldKey");
    });
    if (!sdata["items"]) {
      sdata["items"] = {};
    }
    sdata["items"]["hide"] = hidden.get();
    return decko.filter.updateUrl($(".answer-result-items"));
  };

  updateField = function(selector, checked) {
    return fields(selector).toggle(checked);
  };

  addInput = function(container, field, config, checked) {
    var box, id, input, label;
    input = $("._custom-field-template .custom-field").clone();
    id = "custom-field-" + field;
    box = input.find("input");
    box.attr("id", id);
    box.data("fieldSelector", config["selector"]);
    box.data("fieldKey", field);
    box.prop("checked", checked);
    label = input.find("label");
    label.html(config["title"]);
    label.attr("for", id);
    if (field === "identifiers") {
      addIdentifierInputs(input);
    }
    return container.append(input);
  };

  addIdentifierInputs = function(allIdInput) {
    var idAbbrev, idInputList, idName, ref;
    idInputList = $('<div class="company-id-input-list ps-4 py-2">');
    ref = companyIdentifiers();
    for (idName in ref) {
      idAbbrev = ref[idName];
      addInput(idInputList, "ID-" + idAbbrev, {
        title: idName + " (" + idAbbrev + ")",
        selector: "._ident-field-" + idAbbrev
      }, defaultChecked("ID-" + idAbbrev));
    }
    return allIdInput.append(idInputList);
  };

  companyIdentifiers = function() {
    var map;
    map = {};
    fields("._ident-field").each(function() {
      var fld, name;
      fld = $(this).data("ci");
      return map[name = fld[0]] || (map[name] = fld[1]);
    });
    return map;
  };

  defaultChecked = function(field) {
    var hide, items, sdata;
    sdata = answerSlotData();
    if (!((items = sdata["items"]) && (hide = items["hide"]))) {
      return true;
    }
    return !hide.includes(field);
  };

  answerSlotData = function() {
    var slot;
    slot = $(".answer-result-items").slot();
    if (!slot.data("slot")) {
      slot.data("slot", {});
    }
    return slot.data("slot");
  };

  fields = function(selector) {
    return $(".answer-result-items").find(selector);
  };

  fieldCheckboxes = function() {
    return $("._custom-field-checkboxes ._custom-field input");
  };

  updateCheckAll = function() {
    var allChecked, allbox, checkedNum, determinate, fieldBoxes;
    fieldBoxes = fieldCheckboxes();
    allbox = $("input#_all-custom-fields");
    checkedNum = fieldBoxes.filter(":checked").length;
    allChecked = checkedNum === fieldBoxes.length;
    determinate = (checkedNum === 0) || allChecked;
    allbox.prop("indeterminate", !determinate);
    if (determinate) {
      return allbox.prop("checked", allChecked);
    }
  };

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
    $("body").on("click", "._filter-year-field input", function() {
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
    return $("body").on("click", ".tree-button ._answer-group-modal-link .metric-value", function(e) {
      $(this).closest(".bar").find("._modal-page-link").trigger("click");
      e.stopPropagation();
      return e.preventDefault();
    });
  });

}).call(this);

// filter_enhancements.js.coffee
(function() {
  $(function() {
    $("body").on("click", "._custom-item-view-radios input", function(e) {
      var button, input, slotData;
      input = $(this);
      button = $("._customize_filtered");
      slotData = button.slot().data("slot");
      slotData.items || (slotData.items = {});
      slotData.items.view = input.val();
      return decko.filter.refilter(button);
    });
    return $("body").on("click", "._sort-buttons a", function(e) {
      var link, query;
      link = $(this);
      query = decko.filter.query(link);
      query.sort_by = link.data("sortBy");
      query.sort_dir = link.data("sortDir");
      decko.filter.refilter(link);
      return e.preventDefault();
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
