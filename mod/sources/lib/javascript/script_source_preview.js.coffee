
# resize PDF preview iframe to use full available height
$(document).ready ->
  if $('.pdf-source-preview').exists
    resizeIframe($('body'))

@resizeIframe = (slot) ->
  height = $(window).height() - $('.navbar').height() - 1
  slot.find('.pdf-source-preview').height height