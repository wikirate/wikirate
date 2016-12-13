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
    findCollapseTarget($(this)).collapse()


  $('body').on 'click', '[data-toggle="collapse"]', ->
    if $(this).data("url")?
      $target = $(findCollapseTarget(this))
      if !$target.text().length
        loadCollapseTarget($target, $(this).data("url"))


wagn.slotReady (slot) ->
# collapse API
#
# supports the following data attributes:
#
# toggle = "collapse"      -> element triggers collapse. Target is defined
#                             by additional attributes.
# toggle = "collapse-next" -> element triggers collapse. Target is the next
#                             element that has the "collapse" class.
#                             Can be narrowed down with further attributes.
#
# Specify target element:
# target = <selector>
#     collapse element that matches <selector>.
#     Search order is:
#       descendant, sibling, sibling of parent, descendant of parent
# parent = <selector>
#     by default only descendants of the parent of the
#     toggle are searched for the collapse target.
#     You can use this selector to define a different
#     ancestor as parent to climb further up the hierarchy
# collapse = <selector>
#     add ".collapse" to selector and collapse element that matches that
#
# url = <url>
#     load collapsed content from <url> into collapse target element
# collapse-icon-in / collapse-icon-out = <css_class>
#     switch between "in" and "out" classes if toggle is clicked
# collapse-text-in / collapse-text-out = <text>
#     switch text of toggle between "in" and "out"


  # Extend bootstrap collapse with in and out text
  slot.find('[data-toggle="collapse"], [data-toggle="collapse-next"]').each (i) ->
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
  $target = $(findCollapseTarget($this))
  if $this.data('collapse-text-in')?
    inText ||= $this.data('collapse-text-in')
    outText ||= $this.data('collapse-text-out')
  $target.on 'hidden.bs.collapse', ->
    $this.text(outText)
  $target.on 'shown.bs.collapse', ->
    $this.text(inText)


registerIconToggle = ($this, inClass=null, outClass=null) ->
  $parent = $this.parent()
  $target = $(findCollapseTarget(this))
  if $this.data('collapse-icon-in')?
    inClass ||= $this.data('collapse-icon-in') || "fa-caret-right"
    outClass ||= $this.data('collapse-icon-out') || "fa-caret-down"
  $target.on 'hide.bs.collapse', ->
    $parent.find("." + inClass).removeClass(inClass).addClass(outClass)
  $target.on 'show.bs.collapse', ->
    $parent.find("." + outClass).removeClass(outClass).addClass(inClass)


loadCollapseTarget = (target, url) ->
  $target = $(target)
  $target.load url, (el) ->
    child_slot = $(el).children('.card-slot')[0]
    if child_slot?
      $(child_slot).trigger('slotReady')
    else
      $target.slot().trigger('slotReady')

findCollapseTarget = (toggle) ->
  $toggle = $(toggle)
  parent =
    if $toggle.data("parent")?
      $toggle.closest(parent)
    else
      $toggle.parent()

  target = $toggle.data('target') || '.collapse'
  if $toggle.data("collapse")?
    target += ".collapse"

  if $toggle.find(target).length
    $toggle.find(target)
  else if $toggle.siblings(target).length
    $toggle.siblings(target)
  else if parent.siblings(target).length
    parent.siblings(target)
  else
    parent.find(target)

