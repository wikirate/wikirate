hideAll = (slot)->
  slot.find(".value_type_field").hide()

showField = (divName) ->
  return if divName == ''
  $("." + divName).slideDown(100)

getPropertiesValueType = (value) -> 
  properties = []
  switch value 
    when 'Number', 'Money'
      properties = ['Unit','Range']
    when 'Category', 'Multi-Category'
     properties = ['Options']
    else 
      properties = []
  properties

showAndHideProsTable = (value) ->
  properties = ['Unit','Range','Options']
  showOrHideProperty(properties, 'hide')
  properties = getPropertiesValueType(value)
  showOrHideProperty(properties, 'show') if properties.length > 0

showOrHideProperty = (properties, option) ->
  element = null
  properties.forEach (value) ->
    selector = '#cdp-scope_2_emission-detail_tab td:contains('+value+')'
    if $($(selector)[1]).parent().length > 0
      element = $($(selector)[1]).parent()
    else 
      element = $($(selector)[0]).parent()
    if option == 'show' then element.show() else element.hide()

showAndHide = (slot, value) ->
  div_to_show =
    switch value
      when 'Number', 'Money'
        'number_details'
      when 'Category', 'Multi-Category'
        'category_details'
      else
        ''
  hideAll(slot)
  showAndHideProsTable(value)
  showField(div_to_show)

initializeValueTypeRadio = (radio, slot) ->
  if radio.is(':checked')
    showAndHide slot, radio.val()
  radio.change ->
    showAndHide slot, radio.val()

decko.editorInitFunctionMap['._value-type-editor'] = ->
  slot = $(this).slot()
  hideAll slot
  slot.find('.pointer-radio input:radio').each ->
    initializeValueTypeRadio($(this), slot)
    

# decko.slotReady (slot) ->
#   # hide the related field
#   # if no type is selected, hide all fields
#   if (slot.hasClass("edit-view") && slot.hasClass("RIGHT-value_type")) ||
#      slot.find(".card-editor.RIGHT-value_type").length
#     hideAll(slot)
#     $(slot).find('.pointer-radio input:radio').each(->
#       if $(this).is(':checked')
#         showAndHide slot, $(this).val()
#       $(this).change(->
#         showAndHide slot, $(this).val()
#       )
#     )

#    if slot.parent().hasClass('modal-body')
#      # cancel-button to dismiss the modal
#      slot.find(".cancel-button").data('dismiss','modal')
#      # dismiss and refresh page after submit
#      slot.find('form:first').on 'ajax:success', (_event, data, xhr) ->
#        $('#modal-main-slot').modal('hide')
#        $('#fakeLoader').fakeLoader
#          timeToHide: 1000000 #Time in milliseconds for fakeLoader disappear
#          zIndex: '999' #Default zIndex
#          #Options: 'spinner1', 'spinner2', 'spinner3', 'spinner4', 'spinner5',
#          #         'spinner6', 'spinner7'
#          spinner: 'spinner1'
#          bgColor: 'rgb(255,255,255,0.80)'#Hex, RGB or RGBA colors
#        location.reload()

$(document).ready ->
  valueType = $($('#cdp-scope_2_emission-detail_tab td:contains(Value Type)')).next().find('div.item-name').text()
  showAndHideProsTable(valueType)