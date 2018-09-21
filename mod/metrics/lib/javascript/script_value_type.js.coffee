
#exports
propertiesForValueType = (value) ->
  switch value
    when 'Number', 'Money'
      ['unit','range']
    when 'Category', 'Multi-Category'
      ['Xoption']
    else 
      []

# make sure the correct properties are visible for the value type
vizPropsFor = (vtype) ->
  hideAllTypeSpecificProperties()
  showPropsFor vtype

hideAllTypeSpecificProperties = ->
  ['unit','range','Xoption'].forEach (prop) ->
    rowForProp(prop).hide()

showPropsFor= (vtype) ->
  propertiesForValueType(vtype).forEach (prop) ->
    rowForProp(prop).show()

rowForProp = (prop) ->
  $('.RIGHT-' + prop).closest('tr')

valueTypeFromContent = ->
  $('.metric-properties.table .RIGHT-value_type .item-name').text()

$(document).ready ->
  if $('.metric-properties.table')[0]
    vizPropsFor valueTypeFromContent()

  $('body').on 'change', '.metric-properties .RIGHT-value_type input[type=radio]', (_e) ->
    vizPropsFor $(this).val()
