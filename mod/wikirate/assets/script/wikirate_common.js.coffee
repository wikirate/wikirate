
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
   # TODO: replace this autocomplete with filtered list ui
  slot.find('.wikirate_company_autocomplete').autocomplete
    source: '/Companies+*right+*content_options.json?view=name_match'
    minLength: 2

  slot.find("[data-slick]").each -> loadSlick($(this))

# ~~~~~~~~~~~~~~ slick carousel config

# data-slick should contain json slick config object
# will look for data-slick-selector, if present, within element
loadSlick = (el)->
  return if el.find(".slick-track").length > 0 #already loaded
  config = el.data "slick"
  selector = el.data "slick-selector"
  slickEl = selector && el.find(selector) || el
  slickEl.slick config
# ~~~~~~~~~~~~~~ AJAX Loader anime

# show loader after submitting filter form
$(document).ready ->
  $('body').on "submit", "._filter-form", ->
    loader($(this).slot(), false).prepend()

  $("[data-slick]").each -> loadSlick($(this))

ajaxLoader =
  head: '#ajax_loader'
  child: '.loader- anime'

loader = (target, relative = false) ->
  target = jObj target
  aloader = ajaxLoader
  isLoading: -> @child().exists()
  add: ->
    return if @isLoading()
    target.append($(aloader.head).html())
    @child().addClass("relative") if relative
  prepend: ->
    return if @isLoading()
    target.prepend($(aloader.head).html())
    @child().addClass("relative") if relative
  remove: ->
    @child().remove()
  child: ->
    target.find(aloader.child)

jObj = (ele) ->
  if typeof val == 'string' then $(ele) else ele




# ~~~~ unused (i think)

#  initRowRemove(slot.find("._remove_row"))

#  initRowRemove = ($button) ->
#    $button =  $("._remove_row") unless $button
#    $button.each () ->
#      $this = $(this)
#      $this.on 'click', ->
#        $this.closest('tr').remove()