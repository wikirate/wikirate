# ~~~~~~~~~~~~~~ AJAX Loader anime

# show loader after submitting filter form

#$ ->
#  $('body').on "submit", "._filter-form, .filtered-results-form", ->
#    $(this).slot().loading()

jQuery.fn.slotReloading = ()->
  loader(this).prepend()

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

ajaxLoader =
  head: '#ajax_loader'
  child: '.loader- anime'


jObj = (ele) ->
  if typeof val == 'string' then $(ele) else ele
