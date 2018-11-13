
###
This adds the special source editor (which is overwritten in right/source.rb)
to this long-named map which gets triggered whenever we need javascript
to translate fancy editor content into something friendly to the REST API.

It basically loops through each item in the list and gets the card name from the
standard "data-card-name" attribute.
###

decko.editorContentFunctionMap['.source-editor > .pointer-list'] = ->
  decko.pointerContent @find('.TYPE-source').map( -> $(this).attr 'data-card-name' )


decko.slotReady (slot) ->

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
