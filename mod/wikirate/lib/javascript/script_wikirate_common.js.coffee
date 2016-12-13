# Loader animation
$.extend wikirate:
  ajaxLoader: { head: '#ajax_loader', child: '.loader-anime'}
  isString: (val) ->
    typeof val == 'string' ? true : false
  jObj: (ele) ->
    if this.isString(ele) then $(ele) else ele
  loader: (target, relative = false) ->
    fn = this
    target = fn.jObj(target)
    loader = fn.ajaxLoader
    isLoading: ->
      if this.child().exists() then true else false
    add: ->
      return if this.isLoading()
      target.append($(loader.head).html())
      this.child().addClass("relative") if relative
    remove: ->
      this.child().remove()
    child: ->
      target.find(loader.child)

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

wagn.slotReady (slot) ->
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
