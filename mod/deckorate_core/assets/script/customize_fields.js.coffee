$ ->
  deckorate.customFields =
    headquarters:
      title: "Company Headquarters"
      selector: ".TYPE-company.thumbnail .RIGHT-headquarter.content-view"
    identifiers:
      title: "Company Identifiers"
      selector: ".TYPE-company.thumbnail .thumbnail-subtitle"
    metric_type:
      title: "Metric Type"
      selector: ".TYPE-metric.thumbnail .thumbnail-title-right"
    metric_designer:
      title: "Metric Designer"
      selector: ".TYPE-metric.thumbnail .thumbnail-subtitle"
    contributor:
      title: "Contributor"
      selector: ".bar-middle .credit"

  $("body").on "change", "._custom-field-checkboxes input", (e) ->
    box = $(this)
    selector = box.data "fieldSelector"
    $(".answer-result-items").find(selector).toggle box.is(":checked")


decko.slot.ready (slot) ->
  for field, config of deckorate.customFields
    addInput slot, field, config

addInput = (slot, field, config) ->
  input = slot.find("._custom-field-template .custom-field").clone()
  id = "custom-field-" + field
  box = input.find "input"
  box.attr "id", id
  box.data "fieldSelector", config["selector"]
  label = input.find "label"
  label.html config["title"]
  label.attr "for", id
  slot.find("._custom-field-checkboxes").append input
