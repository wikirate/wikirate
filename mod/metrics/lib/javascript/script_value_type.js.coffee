hideAll = (slot)->
  slot.find(".value_type_field").hide()

showField = (divName) ->
  return if divName == ''
  $("." + divName).slideDown(100)

showAndHide = (slot, value) ->
  div_to_show =
    switch value
      when 'Number'
        'number_details'
      when 'Money'
        'currency_details'
      when 'Category', 'Multi-Category'
        'category_details'
      else
        ''
  hideAll(slot)
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
