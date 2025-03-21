# ~~~~~~~~~~~~~~ AJAX Loader anime

# show loader after submitting filter form

#$ ->
#  $('body').on "submit", "._filter-form, .filtered-results-form", ->
#    $(this).slot().loading()

jQuery.fn.extend
  slotReloading: ()->
    console.log "prepend loader called"
    loader(this).prepend()

  slotLoadingComplete: ()->
    loader(this).remove()

loader = (target, relative = false) ->
  target = jObj target
  aloader = ajaxLoader
  isLoading: -> @child().exists()
  add: ->
    console.log "add loader called"
    return if @isLoading()
    target.append($(aloader.head).html())
    @child().addClass("relative") if relative
  prepend: ->
    console.log "prepend loader called"
    return if @isLoading()
    target.prepend($(aloader.head).html())
    @child().addClass("relative") if relative
  remove: ->
    console.log "remove loader called"
    target.children(".loader-anime").remove()
    @child().removeClass("relative") if relative
  child: ->
    target.find(aloader.child)

ajaxLoader =
  head: '#ajax_loader'
  child: '.loader-anime'


jObj = (ele) ->
  if typeof val == 'string' then $(ele) else ele

$ ->
  $('body').on 'show.bs.tab', 'a', (e) ->
#    console.log "show tab"
    #tab_content = $(this).closest(".tab-panel").children ".tab-content"

    # loader(tab_content, true).prepend()


#  $('body').on 'shown.bs.tab', 'a', (e) ->
#    console.log "shown tab"
#    tc = $(this).closest(".tab-panel").children(".tab-content")
#    loader(tc).remove()
