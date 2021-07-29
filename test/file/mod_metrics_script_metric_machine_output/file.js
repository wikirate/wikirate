// script_metrics.js.coffee
(function() {
  var DIGITS_AFTER_DECIMAL, activeEqualize, addMissingVariables, addNeededWeightRows, addWeightRow, findByCardId, getValuesFromTable, isMaxDigit, needsWeightRow, pairsEditorHash, publishWeightTotal, removeWeightRow, rowWithThumbnail, setAllVariableValuesTo, tallyWeights, toEqualize, updateWikiRatingSubmitButton, validateWikiRating, valuesAreValid, variableItemWithId, variableMetricRows, variableValuesAreEqual, wikiRatingEditorHash;

  $(document).ready(function() {});

  decko.slotReady(function(slot) {
    slot.find('[data-tooltip="true"]').tooltip();
    if (slot.hasClass("edit_in_wikirating-view")) {
      addMissingVariables(slot);
    }
    $('td.metric-weight input').on('keyup', function(event) {
      return activeEqualize();
    });
    return $('#equalizer').on('click', function(event) {
      if ($(this).prop('checked') === true) {
        return toEqualize($('.wikiRating-editor'));
      }
    });
  });

  decko.editorContentFunctionMap['.pairs-editor'] = function() {
    return JSON.stringify(pairsEditorHash(this));
  };

  pairsEditorHash = function(table) {
    var hash;
    hash = {};
    variableMetricRows(table).each(function() {
      var cols, key;
      cols = $(this).find('td');
      if ((key = $(cols[0]).data('key'))) {
        return hash[key] = $(cols[1]).find('input').val();
      }
    });
    return hash;
  };

  getValuesFromTable = function(table) {
    var values;
    values = [];
    variableMetricRows(table).each(function() {
      var tr;
      tr = $(this);
      return values.push(tr.find('td.metric-weight').find('input').val());
    });
    values = values.splice(0, values.length - 1);
    return values;
  };

  variableValuesAreEqual = function(values) {
    return values.every((function(_this) {
      return function(val, i, arr) {
        return val === arr[0];
      };
    })(this)) === true;
  };

  decko.editorContentFunctionMap['.wikiRating-editor'] = function() {
    return JSON.stringify(wikiRatingEditorHash(this));
  };

  wikiRatingEditorHash = function(table) {
    var hash;
    hash = {};
    variableMetricRows(table).each(function() {
      var key, tr;
      tr = $(this);
      if (key = tr.find(".metric-label .thumbnail").data("cardName")) {
        return hash[key] = tr.find(".metric-weight input").val();
      }
    });
    return hash;
  };

  activeEqualize = function() {
    var values;
    values = getValuesFromTable($('.wikiRating-editor'));
    return $('#equalizer').prop('checked', variableValuesAreEqual(values));
  };

  toEqualize = function(table) {
    var val;
    val = (100 / (variableMetricRows(table).length - 1)).toFixed(2);
    setAllVariableValuesTo(table, val);
    return validateWikiRating(table);
  };

  variableMetricRows = function(table) {
    return table.find("tbody tr");
  };

  setAllVariableValuesTo = function(table, val) {
    return variableMetricRows(table).each(function() {
      var tr;
      tr = $(this);
      return tr.find('td.metric-weight').find('input').val(val);
    });
  };

  $(window).ready(function() {
    $('body').on('input', '.metric-weight input', function(_event) {
      return validateWikiRating($(this).closest(".wikiRating-editor"));
    });
    return $('body').on("click", "._remove-weight", function() {
      removeWeightRow($(this).closest("tr"));
      return toEqualize($('.wikiRating-editor'));
    });
  });

  validateWikiRating = function(table) {
    var hash, valid;
    hash = wikiRatingEditorHash(table);
    valid = tallyWeights(table, hash);
    return updateWikiRatingSubmitButton(table.closest('form.card-form'), valid);
  };

  DIGITS_AFTER_DECIMAL = 2;

  tallyWeights = function(tbody, hash) {
    var aux, multiplier, total;
    multiplier = Math.pow(10, DIGITS_AFTER_DECIMAL);
    aux = valuesAreValid(hash, multiplier);
    if (!aux.valid) {
      return false;
    }
    total = aux.total / multiplier;
    publishWeightTotal(tbody, hash, total);
    return total > 99.90 && total <= 100.09;
  };

  valuesAreValid = function(hash, multiplier) {
    var total, valid;
    valid = true;
    total = 0;
    $.each(hash, function(_key, val) {
      var num;
      num = parseFloat(val);
      total += num * multiplier;
      if (num <= 0 || !isMaxDigit(val)) {
        return valid = false;
      }
    });
    return {
      total: total,
      valid: valid
    };
  };

  publishWeightTotal = function(tbody, hash, total) {
    var sum, sum_row;
    sum = tbody.find('.weight-sum');
    sum_row = sum.closest("tr");
    if ($.isEmptyObject(hash)) {
      return sum_row.hide();
    } else {
      sum.val(total);
      return sum_row.show();
    }
  };

  isMaxDigit = function(num) {
    var aux, val;
    aux = true;
    val = num.split('.');
    if (val.length > 1 && val[1].length > 2) {
      aux = false;
    }
    return aux;
  };

  updateWikiRatingSubmitButton = function(form, valid) {
    return form.find(".submit-button").prop('disabled', !valid);
  };

  addMissingVariables = function(slot) {
    var pairsEditor;
    pairsEditor = slot.closest(".editor").find(".wikiRating-editor");
    addNeededWeightRows(pairsEditor, slot.find(".thumbnail"));
    validateWikiRating(pairsEditor);
    if ($('#equalizer').prop('checked') === true) {
      return toEqualize($('.wikiRating-editor'));
    }
  };

  addNeededWeightRows = function(editor, thumbnails) {
    return thumbnails.each(function() {
      var nail;
      nail = $(this);
      if (needsWeightRow(editor, nail.data("cardId"))) {
        return addWeightRow(editor, nail);
      }
    });
  };

  needsWeightRow = function(editor, cardId) {
    return findByCardId(editor, cardId).length === 0;
  };

  addWeightRow = function(editor, thumbnail) {
    var newRow, templateRow;
    templateRow = editor.slot().find("._weight-row-template tr");
    newRow = rowWithThumbnail(templateRow, thumbnail);
    return editor.find("tbody tr:last-child").before(newRow);
  };

  findByCardId = function(from, cardId) {
    return $(from).find("[data-card-id='" + cardId + "']");
  };

  removeWeightRow = function(formulaRow) {
    var cardId, editor, variableItem;
    editor = formulaRow.closest(".wikiRating-editor");
    cardId = formulaRow.find(".thumbnail").data("cardId");
    variableItem = variableItemWithId(editor.slot(), cardId);
    formulaRow.remove();
    variableItem.remove();
    return validateWikiRating(editor);
  };

  variableItemWithId = function(slot, cardId) {
    var variablesList;
    variablesList = slot.find(".edit_in_wikirating-view");
    return findByCardId(variablesList, cardId);
  };

  rowWithThumbnail = function(templateRow, thumbnail) {
    var row;
    row = templateRow.clone();
    row.find(".metric-label").html(thumbnail.clone());
    return row;
  };

}).call(this);

// script_metric_properties.js.coffee
(function() {
  var METRIC_PROPERTIES_TABLE, RESEARCHABLE_CHECKBOX, VALUE_TYPE_RADIO, hideAllTypeSpecificProperties, propScope, propertiesForValueType, researchableFromContent, rowForProp, showPropsFor, vizPropsFor, vizResearchProps;

  METRIC_PROPERTIES_TABLE = ".metric-properties";

  RESEARCHABLE_CHECKBOX = ".RIGHT-hybrid input[type=checkbox]";

  VALUE_TYPE_RADIO = ".RIGHT-value_type input[type=radio]";

  decko.slotReady(function(slot) {
    var mpt;
    if (slot.hasClass("TYPE-metric") && (slot.hasClass("new_tab_pane-view") || slot.hasClass("edit-view"))) {
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
    if (filterVals["value"] === "Other") {
      return alert('Filtering for "Other" values is not yet supported.');
    } else {
      filter = new decko.filter(el.closest("._filtered-content").find("._filter-widget"));
      return filter.addRestrictions(filterVals);
    }
  };

  updateDetails = function(detailsAnswer) {
    return $("[data-details-mark=\"" + detailsAnswer + "\"]").trigger("click");
  };

  $(document).ready(function() {
    return $('body').on('click', '._filter-bindings', function() {
      var klass, vis;
      vis = $(this).closest('.filtered-results').find('.vis');
      klass = 'with-bindings';
      if (vis.hasClass(klass)) {
        return vis.removeClass(klass);
      } else {
        return vis.addClass(klass);
      }
    });
  });

}).call(this);
