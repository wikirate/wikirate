
$(document).ready ->
  # toggle download and url ui
  $('body').on 'click', "._toggle-source-option", ->
    $('.download-option input').val("")
    $('.source-option').show()
    $(this).closest('.source-option').hide()

  $("body").on "change", ".RIGHT-file .download-option .d0-card-content", ->
    el = $(this)
    catcher = el.slot().find ".copy_catcher-view"
    catcher.slotReload catcher.slotUrl() + "&" + $.param(url: el.val())

# Resize PDF preview iframe to use full available height
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  resizeIframe($('body'))

decko.slot.ready (slot) ->
  resizeIframe(slot)

@resizeIframe = (el) ->
  preview = el.find(".pdf-source-preview")
  if preview.exists()
    preview.height ($(window).height() - $('.navbar').height() - 1)

