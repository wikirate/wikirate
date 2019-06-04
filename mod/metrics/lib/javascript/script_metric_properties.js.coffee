
METRIC_PROPERTIES_TABLE = ".metric-properties"
RESEARCHABLE_CHECKBOX = ".RIGHT-hybrid input[type=checkbox]"
VALUE_TYPE_RADIO = ".RIGHT-value_type input[type=radio]"

decko.slotReady (slot) ->
  if slot.hasClass("TYPE-metric") && (slot.hasClass("new_tab_pane-view") || slot.hasClass("edit-view"))
    vizResearchProps slot, slot.find(RESEARCHABLE_CHECKBOX).prop "checked"
    vizPropsFor slot, slot.find(VALUE_TYPE_RADIO + ":checked").val()

  mpt = slot.find METRIC_PROPERTIES_TABLE
  if mpt.length > 0
    vizResearchProps mpt, researchableFromContent(mpt)
    vizPropsFor mpt, mpt.find(".RIGHT-value_type .item-name").text()

  slot.on "change", RESEARCHABLE_CHECKBOX, (_e) ->
    vizResearchProps propScope(this), $(this).prop "checked"

  slot.on "change", VALUE_TYPE_RADIO, (_e) ->
    vizPropsFor propScope(this), $(this).val()

researchableFromContent = (scope) ->
  value = $.trim(scope.find(".RIGHT-hybrid.content-view").text())
  value == "yes"

vizResearchProps = (scope, show_or_hide) ->
  if scope.find(".RIGHT-hybrid")[0]
    $.each ["research_policy", "report_type", "about", "methodology"], (_i, prop) ->
      rowForProp(scope, prop).toggle show_or_hide

propScope = (context) ->
  $(context).closest ".TYPE-metric"

propertiesForValueType = (value) ->
  switch value
    when 'Number', 'Money'
      ['unit','range']
    when 'Category', 'Multi-Category'
      ['value_option']
    else
      []

# make sure the correct properties are visible for the value type
vizPropsFor = (scope, value_type) ->
  hideAllTypeSpecificProperties scope
  showPropsFor scope, value_type

hideAllTypeSpecificProperties = (scope) ->
  ['unit','range','value_option'].forEach (prop) ->
    rowForProp(scope, prop).hide()

showPropsFor= (scope, value_type) ->
  propertiesForValueType(value_type).forEach (prop) ->
    rowForProp(scope, prop).show()

rowForProp = (scope, prop) ->
  set = scope.find('.RIGHT-' + prop)
  if set.closest(METRIC_PROPERTIES_TABLE)[0]
    set.closest('.labeled-view')
  else
    set
