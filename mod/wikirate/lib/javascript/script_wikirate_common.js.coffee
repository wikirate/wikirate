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
  collapseText = ($this) ->
    if $this.data('collapseintext')?
      collapseOutText = $this.data('collapseouttext')
      collapseInText = $this.data('collapseintext')
      $this.text (i, old) ->
        if old == collapseOutText then collapseInText else collapseOutText


  $('body').on 'click', '[data-toggle="collapse"]', ->
    collapseText($(this))
  #collapseIcon($(this), $target)

  # Collapse next element
  $('body').on 'click.collapse-next', '[data-toggle=collapse-next]', ->
    $this     = $(this)
    parent    = $this.data("parent")
    collapse  = $this.data("collapse")+".collapse"
    $target   = $this.closest(parent).find(collapse)
    collapseText($this)
    if !$target.data('collapse')
      collapseIcon($this, $target, "fa-caret-right", "fa-caret-down")


wagn.slotReady (slot) ->
# Extend bootstrap collapse with in and out text
  slot.find('[data-toggle="collapse"]').each (i) ->
#$(this).click
    target = $(this).data('target')
    $target = $(this).parent().find(target)
    collapseIcon($(this), $target)

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

collapseIcon = ($this, $target, inClass = null, outClass = null) ->
  $parent = $this.parent()
  if $this.data('collapse-icon-in')?
    inClass ||= $this.data('collapse-icon-in')
    outClass ||= $this.data('collapse-icon-out')
  $target.collapse("toggle").on('shown.bs.collapse', ->
    $parent.find("." + inClass).addClass(outClass).removeClass(inClass)
  ).on 'hidden.bs.collapse', ->
    $parent.find("." + outClass).addClass(inClass).removeClass(outClass)
