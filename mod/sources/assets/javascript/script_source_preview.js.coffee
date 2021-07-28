# Resize PDF preview iframe to use full available height
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

$(document).ready ->
  resizeIframe($('body'))

decko.slotReady (slot) ->
  resizeIframe(slot)

@resizeIframe = (el) ->
  preview = el.find(".pdf-source-preview")
  if preview.exists()
    preview.height ($(window).height() - $('.navbar').height() - 1)
