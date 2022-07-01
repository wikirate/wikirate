if PdfjsViewer?
  PdfjsViewer.hosted_viewer_origins = ['http://wikirate.org',
    'https://wikirate.org',
    'http://wikirate.s3.amazonaws.com',
    'https://wikirate.s3.amazonaws.com']

# Check if container exists
$.fn.exists = -> return @length > 0

decko.slot.ready (slot) ->
   # TODO: replace this autocomplete with filtered list ui
  slot.find('.wikirate_company_autocomplete').autocomplete
    source: '/Companies+*right+*content_options.json?view=name_match'
    minLength: 2

  initRowRemove(slot.find("._remove_row"))

# show loader after submitting filter form
$(document).ready ->
  $('body').on "submit", "._filter-form", ->
    loader($(this).slot(), false).prepend()


ajaxLoader =
  head: '#ajax_loader'
  child: '.loader- anime'

initRowRemove = ($button) ->
  $button =  $("._remove_row") unless $button
  $button.each () ->
    $this = $(this)
    $this.on 'click', ->
      $this.closest('tr').remove()

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
