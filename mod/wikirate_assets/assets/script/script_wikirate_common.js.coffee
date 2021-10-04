# Loader animation
window.wikirate =
  ajaxLoader: { head: '#ajax_loader', child: '.loader-anime'}

  initRowRemove: ($button) ->
    $button =  $("._remove_row") unless $button
    $button.each () ->
      $this = $(this)
      $this.on 'click', ->
        $this.closest('tr').remove()

  isString: (val) ->
    typeof val == 'string' ? true : false

  jObj: (ele) ->
    if this.isString(ele) then $(ele) else ele

  loader: (target, relative = false) ->
    target = @jObj target
    loader = wikirate.ajaxLoader
    isLoading: ->
      if this.child().exists() then true else false
    add: ->
      return if this.isLoading()
      target.append($(loader.head).html())
      this.child().addClass("relative") if relative
    prepend: ->
      return if this.isLoading()
      target.prepend($(loader.head).html())
      this.child().addClass("relative") if relative
    remove: ->
      this.child().remove()
    child: ->
      target.find(loader.child)

# Check if container exists
$.fn.exists = -> return this.length > 0

decko.slotReady (slot) ->
  slot.find('.wikirate_company_autocomplete').autocomplete
    source: '/Companies+*right+*content_options.json?view=name_match'
    minLength: 2
  slot.find('.wikirate_topic_autocomplete').autocomplete
    source: '/Topic+*right+*content_options.json?view=name_match'
    minLength: 2
  slot.find('.metric_autocomplete').autocomplete
    source: '/Metric+*right+*content_options.json?view=name_match'
    minLength: 2

  wikirate.initRowRemove(slot.find("._remove_row"))

# destroy modal content after closing modal window (On homepage only)
$(document).ready ->
  $('body').on "submit", "._filter-form", ->
    slot = $(this).findSlot($(this).data("slot-selector"))
    wikirate.loader($(slot), false).prepend()
