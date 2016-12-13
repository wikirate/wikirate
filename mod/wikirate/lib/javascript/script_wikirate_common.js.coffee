# Loader animation
$.extend wikirate:
  ajaxLoader: { head: '#ajax_loader', child: '.loader-anime'}
  isString: (val) ->
    typeof val == 'string' ? true : false
  jObj: (ele) ->
    if this.isString(ele) then $(ele) else ele
  loader: (target) ->
    fn = this
    Target = fn.jObj(target)
    Loader = fn.ajaxLoader
    isLoading: ->
      if this.child().exists() then true else false
    add: ->
      Target.append($(Loader.head).html()) unless this.isLoading()
    remove: ->
      this.child().remove()
    child: ->
      Target.find(Loader.child)

window.wikirate = $.wikirate

#get url param
$.urlParam = (name) ->
  results = new RegExp('[?&]' + name + '=([^&#]*)').exec(window.location.href)
  if results == null
    null
  else
    results[1] or 0

# Check if container exist
$.fn.exists = -> return this.length>0

# Extend bootstrap collapse.
$(document).ready ->
  # Collapse next element
  $('body').on 'click.collapse-next', '[data-toggle=collapse-next]', ->
    $this     = $(this)
    parent    = $this.data("parent")
    collapse  = $this.data("collapse") + ".collapse"
    $target   = $this.closest(parent).find(collapse)
    collapseText($this)
    if !$target.data('collapse')
      collapseIcon($this, $target, "fa-caret-right", "fa-caret-down")

  $('body').on 'click', '[data-toggle="collapse"]', ->
    if $(this).data("url")?
      $target = $(collapseTarget(this))
      if !$target.text().length
        loadCollapse($target, $(this).data("url"))


wagn.slotReady (slot) ->
  # Extend bootstrap collapse with in and out text
  slot.find('[data-toggle="collapse"]').each (i) ->
    if $(this).data('collapse-icon-in')?
      registerIconToggle $(this)
    if $(this).data('collapse-text-in')?
      registerTextToggle $(this)

  # use jQuery chosen library for select tags
  slot.find('.pointer-multiselect').each (i) ->
    $(this).attr 'data-placeholder', '　'
    $(this).chosen
      no_results_text: 'Press Enter to add new'
      skip_no_results: true
      width: '100%'

  slot.find('.pointer-select').each (i) ->
    $(this).attr 'data-placeholder', '　'
    $(this).chosen
      no_results_text: 'No Result'
      disable_search_threshold: 10
      skip_no_results: true
      width: '100%'

registerTextToggle = ($this, inText=null, outText=null) ->
  $target = $(collapseTarget($this))
  if $this.data('collapse-text-in')?
    inText ||= $this.data('collapse-text-in')
    outText ||= $this.data('collapse-text-out')
  $target.on 'hidden.bs.collapse', ->
    $this.text(outText)
  $target.on 'shown.bs.collapse', ->
    $this.text(inText)


registerIconToggle = ($this, inClass=null, outClass=null) ->
  $parent = $this.parent()
  $target = $(collapseTarget(this))
  if $this.data('collapse-icon-in')?
    inClass ||= $this.data('collapse-icon-in')
    outClass ||= $this.data('collapse-icon-out')
  $target.on 'hide.bs.collapse', ->
    $parent.find("." + inClass).removeClass(inClass).addClass(outClass)
  $target.on 'show.bs.collapse', ->
    $parent.find("." + outClass).removeClass(outClass).addClass(inClass)


loadCollapse = (target, url) ->
  $target = $(target)
  $target.load url, (el) ->
    child_slot = $(el).children('.card-slot')[0]
    if child_slot?
      $(child_slot).trigger('slotReady')
    else
      $target.slot().trigger('slotReady')

collapseTarget = (toggle) ->
  $toggle = $(toggle)
  target = $toggle.data('target') || '.collapse'
  if $toggle.find(target).length
    $toggle.find(target)
  else if $toggle.siblings(target).length
    $toggle.siblings(target)
  else if $toggle.parent().siblings(target).length
    $toggle.parent().siblings(target)
  else
    $toggle.parent().find(target)

