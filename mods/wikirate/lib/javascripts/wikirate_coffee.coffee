
$(window).ready ->
  getFrameslot = (field)->
    fieldset = field.closest 'fieldset'
    frameslot = fieldset.find '.card-slot'
    if frameslot[0]
      frameslot = $(frameslot[0])
    else
      frameslot = $('<div class="card-slot"></div>')
      fieldset.append frameslot
    frameslot
  

  $('.TYPE-claim .RIGHT-link').on 'change', 'input', ->
    field = $(this)
    frameslot = getFrameslot field
    frameslot.empty()
    $.ajax wagn.rootPath + '/card/create', {
      data : {
        success: { view : 'content' }
        slot: { structure: 'labeled source frame' } #fixme -- need codename
        quickframe: true
        card: {
          type_code: 'webpage'
          cards    : { '+Link' : { 'content' : field.val() } }
        }
      }
      success: (data) -> frameslot.slotSuccess data
      error: (xhr) -> frameslot.slotError xhr.status, xhr.responseText      
    }
    false #disable other events

  $('.TYPE-page .RIGHT-link').on 'change', 'input', ->  
    field = $(this)
    frameslot = getFrameslot field
    frameslot.html $('<iframe src="' + field.val()  + '"></iframe>')


#warn = (stuff) -> console.log stuff if console?