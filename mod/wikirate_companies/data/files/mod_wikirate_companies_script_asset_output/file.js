// company_group.js.coffee
(function() {
  var constraintDisabled, constraintEditor, specificationType, updateSpecVisibility, updateValueEditor;

  decko.editors.content['.specification-input'] = function() {
    return specificationType(this);
  };

  $(window).ready(function() {
    $("body").on("change", "input[name=spec-type]", function() {
      return updateSpecVisibility($(this).slot());
    });
    $("body").on("decko.filter.selection", "._metric-selector a", function(event, item) {
      var data, link;
      data = $(item.firstChild).data();
      link = $(this);
      link.text(data.cardName);
      link.siblings().val(data.cardId);
      constraintDisabled(link, false);
      updateValueEditor(link, data.cardId);
      decko.updateAddItemButton(this);
      return link.closest("form").submit();
    });
    return $("body").on("decko.item.added", "._constraint-list-editor li", function() {
      var metric_link;
      metric_link = $(this).find(".constraint-metric a");
      metric_link.text("Choose Metric");
      $(this).find(".constraint-value .card-slot").children().remove();
      return constraintDisabled(metric_link, true);
    });
  });

  decko.slot.ready(function(slot) {
    if (slot.find(".specification-input").length > 0) {
      return updateSpecVisibility(slot);
    }
  });

  constraintDisabled = function(el, toggle) {
    var ed;
    ed = el.closest("._constraint-editor");
    return ed.find("select, input").prop("disabled", toggle);
  };

  updateValueEditor = function(metricLink, metricId) {
    var slot;
    slot = metricLink.closest("li").find(".card-slot");
    return slot.slotReload((slot.cardMark()) + "/value_formgroup?metric=~" + metricId);
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

  constraintEditor = function(el) {
    return $(el).find(".constraint-list-editor");
  };

  specificationType = function(el) {
    return $(el).find("[name=spec-type]:checked").val();
  };

}).call(this);
