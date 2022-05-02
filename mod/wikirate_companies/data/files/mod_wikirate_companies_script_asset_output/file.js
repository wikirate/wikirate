// company_group.js.coffee
(function() {
  var constraintCsv, constraintEditor, constraintToImportItem, groupValue, lockConstraintEditor, metricValue, specificationType, updateSpecVisibility, valueValue, yearValue;

  decko.editorContentFunctionMap['.specification-input'] = function() {
    var conEd;
    if (specificationType(this) === "explicit") {
      return "explicit";
    } else {
      conEd = constraintEditor(this);
      if (conEd.data("locked")) {
        return conEd.find("input.d0-card-content").val();
      } else {
        return constraintCsv(conEd);
      }
    }
  };

  $(window).ready(function() {
    $("body").on("change", "._constraint-metric", function() {
      var input, metric, url, valueSlot;
      input = $(this);
      valueSlot = input.closest("li").find(".card-slot");
      metric = encodeURIComponent(input.val());
      url = valueSlot.slotMark() + "?view=value_formgroup&metric=" + metric;
      return valueSlot.reloadSlot(url);
    });
    $("body").on("change", "input[name=spec-type]", function() {
      return updateSpecVisibility($(this).slot());
    });
    return $("body").on("submit", ".card-form", function() {
      if ($(this).find(".specification-input").length > 0) {
        $(this).setContentFieldsFromMap();
        return lockConstraintEditor(constraintEditor(this));
      }
    });
  });

  decko.slotReady(function(slot) {
    if (slot.find(".specification-input").length > 0) {
      return updateSpecVisibility(slot);
    }
  });

  constraintCsv = function(conEd) {
    var rows;
    rows = conEd.find(".constraint-editor").map(function() {
      return constraintToImportItem($(this));
    });
    return rows.get().join("\n");
  };

  constraintToImportItem = function(con) {
    return [metricValue(con), yearValue(con), valueValue(con), groupValue(con)].join(";|;");
  };

  metricValue = function(con) {
    return con.find(".constraint-metric input").val();
  };

  yearValue = function(con) {
    return con.find(".constraint-year select").val();
  };

  valueValue = function(con) {
    return con.find(".constraint-value input, .constraint-value .constraint-value-fields > select").serialize();
  };

  groupValue = function(con) {
    return con.find(".constraint-related-group select").val();
  };

  specificationType = function(el) {
    return $(el).find("[name=spec-type]:checked").val();
  };

  constraintEditor = function(el) {
    return $(el).find(".constraint-list-editor");
  };

  updateSpecVisibility = function(slot) {
    var explicit, implicit;
    implicit = constraintEditor(slot);
    explicit = slot.find(".RIGHT-company.card-editor");
    if (specificationType(slot) === "explicit") {
      explicit.show();
      return implicit.hide();
    } else {
      explicit.hide();
      return implicit.show();
    }
  };

  lockConstraintEditor = function(conEd) {
    conEd.data("locked", "true");
    return conEd.find(".constraint-editor input, .constraint-editor select").prop("disabled", true);
  };

}).call(this);
