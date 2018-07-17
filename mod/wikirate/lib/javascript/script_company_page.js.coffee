query_string = null
QueryString = ->
  # This function is anonymous, is executed immediately and
  # the return value is assigned to QueryString!
  if !query_string
    query_string = {}
  else
    return query_string
  query = window.location.search.substring(1)
  vars = query.split('&')
  i = 0
  while i < vars.length
    pair = vars[i].split('=')
    key = pair[0].toLowerCase()
    value = pair[1]
    # If first entry with this name
    if typeof query_string[key] == 'undefined'
      query_string[key] = value
    # If second entry with this name
    else if typeof query_string[key] == 'string'
      arr = [
        query_string[key]
        value
      ]
      query_string[key] = arr
    # If third or later entry with this name
    else
      query_string[key].push value
    i++
  query_string

stringStartsWith = (string, prefix) ->
  string.slice(0, prefix.length) == prefix
showFakeLoader = ->
  $('#fakeLoader').fakeLoader
    timeToHide: 1000000 #Time in milliseconds for fakeLoader disappear
    zIndex: '999' #Default zIndex
    spinner: 'spinner1'#Options: 'spinner1', 'spinner2', 'spinner3', 'spinner4', 'spinner5', 'spinner6', 'spinner7'
    bgColor: 'rgb(255,255,255,0.80)' #Hex, RGB or RGBA colors
  #imagePath:"yourPath/customizedImage.gif" //If you want can you insert your custom image
  return

decko.slotReady (slot) ->
  if (slot.hasClass("TYPE-company") || slot.hasClass("TYPE-topic")) &&
      slot.hasClass("open-view") && slot.hasClass("ALL")
    query_string = null
    currentTab = QueryString().tab
    if $("[data-tab-name='" + currentTab + "']").length == 0
      currentTab = 'metric'
    currentTabAnchor = $("[data-tab-name='" + currentTab + "']")
    currentTabAnchor.closest("li").addClass("active")
    showFakeLoader()
    $("#fakeLoader").hide()

  slot.find(".company-tabs .nav-tabs li a").off("click").click (e) ->
    if (e.shiftKey || e.ctrlKey || e.metaKey)
      return true
    slot.find(".company-tabs .nav-tabs li").removeClass("active")
    $(this).closest("li").addClass("active")

    $this = $(this)
    href = $this.data('tab-content-url')
    loadurl = href + '?view=content'
    targ = '.tab-content'
    if href == undefined
      return true
    $('#fakeLoader').fadeIn()
    history.pushState(null, null, window.location.pathname + "?tab=" + $this.data("tab-name"))
    $.get loadurl, (data) ->
      $(targ).html data
      $(targ).trigger('slotReady')
      $('#fakeLoader').fadeOut()
      return
    false
