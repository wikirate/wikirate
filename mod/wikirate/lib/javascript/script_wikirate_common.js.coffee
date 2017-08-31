# Loader animation
$.extend wikirate:
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
#  slot.find('.pointer-multiselect').each (i) ->
#    $(this).attr 'data-placeholder', '　'
#    unless $(this).hasClass("_no-chosen")
#      $(this).chosen
#        no_results_text: 'Press Enter to add new'
#        skip_no_results: true
#        width: '100%'
#
#  slot.find('.pointer-select').each (i) ->
#    $(this).attr 'data-placeholder', '　'
#
#    unless $(this).hasClass("_no-chosen")
#      $(this).chosen
#        no_results_text: 'No Result'
#        disable_search_threshold: 10
#        skip_no_results: true
#        width: '100%'

  slot.find('.company_autocomplete').autocomplete
    source: '/Companies+*right+*options.json?view=name_match'
    minLength: 2
  slot.find('.wikirate_company_autocomplete').autocomplete
    source: '/Companies+*right+*options.json?view=name_match'
    minLength: 2
  slot.find('.wikirate_topic_autocomplete').autocomplete
    source: '/Topic+*right+*options.json?view=name_match'
    minLength: 2
  slot.find('.metric_autocomplete').autocomplete
    source: '/Metric+*right+*options.json?view=name_match'
    minLength: 2

  wikirate.initRowRemove(slot.find("._remove_row"))

# destory modal content after closing modal window (On homepage only)
$(document).ready ->
  if $('#Home').exists()
    $('#modal-main-slot').on 'hidden.bs.modal', ->
      $(this).data 'bs.modal', null
      $(this).find('.modal-body').empty()
