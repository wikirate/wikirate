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
# href = <(id-)selector>
#      collapse element that matches selector
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

# Extend bootstrap collapse.
$(document).ready ->
# Collapse next element
  $('body').on 'click.collapse-next', '[data-toggle=collapse-next]', ->
    findCollapseTarget($(this)).collapse('toggle')

  $('body').on 'click', '[data-toggle="collapse"]', ->
    if $(this).data("url")?
      $target = $(findCollapseTarget(this))
      if !$target.text().length
        loadCollapseTarget($target, $(this).data("url"))

wagn.slotReady (slot) ->
# Extend bootstrap collapse with in and out text
  slot.find('[data-toggle="collapse"], [data-toggle="collapse-next"]').each (i) ->
    if $(this).data('collapse-icon-in')?
      registerIconToggle $(this)
    if $(this).data('collapse-text-in')?
      registerTextToggle $(this)

registerTextToggle = ($this, inText = null, outText = null) ->
  $target = $(findCollapseTarget($this))
  if $this.data('collapse-text-in')?
    inText ||= $this.data('collapse-text-in')
    outText ||= $this.data('collapse-text-out')
  $target.on 'hidden.bs.collapse', ->
    $this.text(outText)
  $target.on 'shown.bs.collapse', ->
    $this.text(inText)


registerIconToggle = ($this, inClass = null, outClass = null) ->
#$parent = $this.parent()
  $target = $(findCollapseTarget($this))
  if $this.data('collapse-icon-in')?
    inClass ||= $this.data('collapse-icon-in') || "fa-caret-right"
    outClass ||= $this.data('collapse-icon-out') || "fa-caret-down"
  $target.on 'hide.bs.collapse', (e) ->
    $this.parent().find("." + inClass).removeClass(inClass).addClass(outClass)
  $target.on 'show.bs.collapse', (e) ->
    $this.parent().find("." + outClass).removeClass(outClass).addClass(inClass)


loadCollapseTarget = ($target, url) ->
  wikirate.loader($target, true).add()
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
      $toggle.closest($toggle.data("parent"))
    else
      $toggle.parent()

  target = $toggle.attr("href") || $toggle.data('target') || '.collapse'
  if $toggle.data("collapse")
    target += $toggle.data("collapse")

  if $toggle.find(target).length
    $toggle.find(target)
  else if $toggle.siblings(target).length
    $toggle.siblings(target)
  else if parent.find(target).length
    parent.find(target)
  else if parent.siblings(target).length
    parent.siblings(target)
  else
    $(target)
