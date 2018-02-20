
###
This adds the special source editor (which is overwritten in right/source.rb)
to this long-named map which gets triggered whenever we need javascript
to translate fancy editor content into something friendly to the REST API.

It basically loops through each item in the list and gets the card name from the
standard "data-card-name" attribute.
###

decko.editorContentFunctionMap['.source-editor > .pointer-list'] = ->
  pointerContent @find('.TYPE-source').map( -> $(this).attr 'data-card-name' )

###
FIXME
The following code is cut and pasted from decko_mod.js.coffee.  We need to scope
it so that we can just refer to it and get rid of it here.
###

pointerContent = (vals) ->
  list = $.makeArray(vals)
  list = $.map(list, (v, i) ->
    "[[" + v + "]]"  if v and list.indexOf(v) is i
  )
  $.makeArray(list).join "\n"

$(window).ready ->

  ###
  To trigger click event if user forgets to click on 'add' button
  ###
  $('body').on('blur', '.RIGHT-source .sourcebox input',->
    $('.TYPE-note .sourcebox button')[0].click())

  ###
  The following is what translates the sourcebox into the form that we need
  it for the REST API and handles the request/response.
  ###

  $('body').on 'click', '.RIGHT-source .sourcebox button', ->
    button = $(this)
    field = $(this).closest('.sourcebox').find('input')
    sourceBox =  $(this).closest('.sourcebox')

    #handle Error
    errorDiv = '<div class="sourceErrorMsg"> Invalid URL. (Valid URL looks like "http://www.example.com")</div>'

    errorMsg = sourceBox.find('.sourceErrorMsg')
    if errorMsg.length > 0
      errorMsg.remove()

    #unless field.val().match /^http/
    if field.val().length == 0
      sourceBox.find('.sourceErrorMsg').remove()
      sourceBox.append(errorDiv)
      $("#input_box_flag").val("false")
      return false

    listDiv = field.closest( '.content-editor' ).find '.source-editor > .pointer-list'

    button.html 'Adding...'
    button.attr 'disabled', true

    $.ajax decko.path('card/create'), {
      data : {
        success: { view : 'content' }
        slot: { structure: 'source item' } #fixme -- need codename
        sourcebox: 'true'
        card: {
          type_code: 'source'
          subcards    : { '+Link' : { 'content' : field.val() } }
        }
      }
      success: (data) ->
        itemSlot = $('<div class="card-slot"></div>')
        listDiv.append itemSlot
        itemSlot.slotSuccess data
        field.val ''
      error: (xhr) -> button.slot().slotError xhr.status, xhr.responseText
      complete: ->
        $("#input_box_flag").val("false")
        button.html 'Add'
        button.attr 'disabled', false
    }

    false #disable other events


# we need to replace the following to retain decent 'add source' behavior'

#  $('.TYPE-page .RIGHT-link').on 'change', 'input', ->
#   field = $(this)
#    frameslot = getFrameslot field
#    frameslot.html $('<iframe src="' + field.val()  + '"></iframe>')

# the following may no longer be necessary.  it was a pre-"chosen" attempt at a topics editor"

  $('body').on 'click', '.wikirate-topic-list', (event) ->
    listlink = $(this)
    dialogDiv = listlink.data 'dialog'
    dialogOptions = { minWidth: 400, maxHeight:400, position: { my: "center", at: "center", of: window } }
    if dialogDiv
      dialogDiv.dialog dialogOptions
    else
      $.ajax( url: listlink.attr('href') ).done (data)->
        dialogDiv = listlink.slot().find '.wikirate-topic-dialog'
        decko.dd = dialogDiv
        dialogDiv.html data
        listlink.data 'dialog', dialogDiv
        dialogDiv.dialog dialogOptions
        dialogDiv.find('a').attr 'target','topics'
    event.preventDefault()

  $('#menu-bar').on 'mouseenter', '.main-links > div', ->
    ul = $(this).find('ul').first()
    ul.menu()
    ul.show()
    ul.position my: 'left top', at: 'left bottom', of: this

  $('#menu-bar').on 'mouseleave', '.main-links > div', ->
    ul = $(this).find('ul').first()
    ul.hide()

  $('body').on 'change', '.SELF-company_comparison select', ->
    $(this).closest('form').submit()

  # $("body").on "click", ".TYPE-project , ->
  #   alert "add item link"
  #   anchor = $(this)
  #   parent = anchor.closest(".TYPE-project").
  #   if parent

decko.slotReady (slot) ->
  $('[data-toggle="popover"]').popover()

  return unless slot.hasClass("TYPE-project") && slot.find("form")
  parent = slot.find(".RIGHT-parent .pointer-item-text")
  appendParentToAddItem parent



appendParentToAddItem = (parent) ->
  return unless parent.val()
  parent.slot().find("._add-item-link").each ->
    anchor = $(this)
    new_href =  anchor.attr("href") + "&" + $.param({ "filter[project]" : parent.val() })
    anchor.attr "href", new_href

 #Moving it to newNoteJs
 # To add the source on blur event.
 #$("body").on "blur", "#sourcebox", ->
 #   $(".sourcebox button").trigger "click"

#warn = (stuff) -> console.log stuff if console?
