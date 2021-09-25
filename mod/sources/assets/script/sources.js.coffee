$(document).ready ->
  # toggle download and url ui
  $('body').on 'click', ".toggle-source-option", ->
    $('.download-option input').val("")
    $('.source-option').show()
    $(this).closest('.source-option').hide()

  $('body').on 'click', ".TYPE-source.box", ->
    window.location = decko.path $(this).data("cardLinkName")


# Resize PDF preview iframe to use full available height
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  resizeIframe($('body'))

decko.slotReady (slot) ->
  resizeIframe(slot)

@resizeIframe = (el) ->
  preview = el.find(".pdf-source-preview")
  if preview.exists()
    preview.height ($(window).height() - $('.navbar').height() - 1)

