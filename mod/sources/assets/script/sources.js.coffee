$(document).ready ->
  # toggle download and url ui
  $('body').on 'click', ".toggle-source-option", ->
    $('.download-option input').val("")
    $('.source-option').show()
    $(this).closest('.source-option').hide()

  $('body').on 'click', ".TYPE-source.box, .TYPE-source.bar", ->
    window.location = decko.path $(this).data("cardLinkName")

  $("body").on "change", ".RIGHT-file .download-option .d0-card-content", ->
    el = $(this)
    catcher = el.slot().find ".copy_catcher-view"
    catcher.reloadSlot catcher.slotUrl() + "&" + $.param(url: el.val())

decko.slotReady (slot) ->
  slot.find(".TYPE-source .meatball-button").on "click", (e) ->
    $(this).dropdown "toggle"
    e.stopImmediatePropagation()

  slot.find(".TYPE-source.box a, .TYPE-source.bar a").on "click", (e) ->
    e.preventDefault()


# Resize PDF preview iframe to use full available height
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  resizeIframe($('body'))

decko.slotReady (slot) ->
  resizeIframe(slot)

@resizeIframe = (el) ->
  preview = el.find(".pdf-source-preview")
  if preview.exists()
    preview.height ($(window).height() - $('.navbar').height() - 1)

