
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

$.fn.exists = -> return this.length>0

$(document).ready ->
  # Extend bootstrap collapse with in and out text
  $('[data-toggle="collapse"]').click ->
    if typeof $(this).data('collapseintext') != 'undefined'
      collapseOutText = $(this).data('collapseouttext')
      collapseInText = $(this).data('collapseintext')
      $(this).text (i, old) ->
        if old == collapseOutText then collapseInText else collapseOutText
    return

  $('body').on 'click.collapse-next', '[data-toggle=collapse-next]', ->
    $this     = $(this)
    parent    = $this.data("parent")
    collapse  = $this.data("collapse")+".collapse"
    $target   = $this.closest(parent).find(collapse)

    if !$target.data('collapse')
      $target.collapse('toggle').on('shown.bs.collapse', ->
        $this.parent().find('.fa-caret-right ')
                      .removeClass('fa-caret-right ')
                      .addClass 'fa-caret-down'
      ).on 'hidden.bs.collapse', ->
        $this.parent().find('.fa-caret-down')
                      .removeClass('fa-caret-right')
                      .addClass 'fa-caret-right'
