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

  $("body").on "change", "._custom-field-checkboxes input", (_e) ->
    box = $(this)
    updateField box.data("fieldSelector"), box.is(":checked")
    updateCheckAll()
    updateSlotItems()

  $("body").on "change", "input#_all-custom-fields", (_e) ->
    checkboxes = fieldCheckboxes()
    checkboxes.prop "checked", $(this).is(":checked")
    checkboxes.trigger "change"

decko.slot.ready (slot) ->
  container = slot.find "._custom-field-checkboxes"
  if container[0]
    for field, config of deckorate.customFields
      sampleField = fields(config["selector"])[0]
      if sampleField
        checked = defaultChecked field
        addInput container, field, config, checked
    updateCheckAll()

  if slot.find(".answer-result-items")[0]
    for field, config of deckorate.customFields
      updateField config["selector"], defaultChecked(field)

updateSlotItems = () ->
  sdata = answerSlotData()
  hidden = fieldCheckboxes().filter(":not(:checked)").map ->
    $(this).data "fieldKey"
  sdata["items"] = {} unless sdata["items"]
  sdata["items"]["hide"] = hidden.get()
  decko.filter.updateUrl $(".answer-result-items")

updateField = (selector, checked) ->
  fields(selector).toggle checked

addInput = (container, field, config, checked) ->
  input = $("._custom-field-template .custom-field").clone()
  id = "custom-field-" + field
  box = input.find "input"
  box.attr "id", id
  box.data "fieldSelector", config["selector"]
  box.data "fieldKey", field
  box.prop "checked", checked
  label = input.find "label"
  label.html config["title"]
  label.attr "for", id
  container.append input

defaultChecked = (field) ->
  sdata = answerSlotData()
  return true unless (items = sdata["items"]) && (hide = items["hide"])
  !hide.includes field

answerSlotData = () ->
  slot = $(".answer-result-items").slot()
  slot.data "slot", {} unless slot.data "slot"
  slot.data "slot"

fields = (selector) ->
  $(".answer-result-items").find selector

fieldCheckboxes = () ->
  $("._custom-field-checkboxes ._custom-field input")

updateCheckAll = () ->
  fieldBoxes = fieldCheckboxes()
  allbox = $("input#_all-custom-fields")
  checkedNum = fieldBoxes.filter(":checked").length
  allChecked = (checkedNum == fieldBoxes.length)
  determinate = (checkedNum == 0) || allChecked

  allbox.prop "indeterminate", !determinate
  allbox.prop "checked", allChecked if determinate
