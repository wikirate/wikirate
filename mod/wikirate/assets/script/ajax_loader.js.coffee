# ~~~~~~~~~~~~~~ AJAX Loader anime

# show loader after submitting filter form

#$ ->
#  $('body').on "submit", "._filter-form, .filtered-results-form", ->
#    $(this).slot().loading()

jQuery.fn.extend
  startLoading: (relative=false) -> loader(this, relative).prepend()
  stopLoading: (relative=false) -> loader(this, relative).remove()

loader = (target, relative = false) ->
  target = jObj target
  aloader = ajaxLoader

  isLoading: -> @child().exists()

  add: -> @start "append"

  prepend: -> @start "prepend"

  remove: ->
    target.children(".loader-anime").remove()
    @child().removeClass("relative") if relative

  child: ->
    target.find(aloader.child)

  start: (fnctn) ->
    return if @isLoading()
    target[fnctn] $(aloader.head).html()
    @child().addClass("relative") if relative

ajaxLoader =
  head: '#ajax_loader'
  child: '.loader-anime'


jObj = (ele) ->
  if typeof val == 'string' then $(ele) else ele
