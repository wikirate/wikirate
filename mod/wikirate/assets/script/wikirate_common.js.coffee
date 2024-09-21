
# ~~~~~~~~~~~~~~ JQuery extension

# Check if container exists (move to decko?)
$.fn.exists = -> return @length > 0


# ~~~~~~~~~~~~~~ PDFJS config

if PdfjsViewer?
  PdfjsViewer.hosted_viewer_origins = ['http://wikirate.org',
    'https://wikirate.org',
    'http://wikirate.s3.amazonaws.com',
    'https://wikirate.s3.amazonaws.com']

# ~~~~~~~~~~~~~~ old-style company autocomplete

decko.slot.ready (slot) ->
  slot.find("[data-slick]").each -> loadSlick($(this))

# ~~~~~~~~~~~~~~ slick carousel config

$ ->
  $("[data-slick]").each -> loadSlick($(this))

# data-slick should contain json slick config object
# will look for data-slick-selector, if present, within element
loadSlick = (el)->
  return if el.find(".slick-track").length > 0 #already loaded
  config = el.data "slick"
  selector = el.data "slick-selector"
  slickEl = selector && el.find(selector) || el
  slickEl.slick config



# ~~~~ unused (i think)

#  initRowRemove(slot.find("._remove_row"))

#  initRowRemove = ($button) ->
#    $button =  $("._remove_row") unless $button
#    $button.each () ->
#      $this = $(this)
#      $this.on 'click', ->
#        $this.closest('tr').remove()