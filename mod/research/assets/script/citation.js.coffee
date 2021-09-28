$(document).ready ->
  # open pdf preview when clicking on source box
  $('.tab-pane-source_phase').on 'click', ".TYPE-source.box", (e) ->
    openPdf $(this).data("cardLinkName")
    e.stopPropagation()

researchPath = (view)->
  path = window.location.pathname.replace(/\/\w+$/, "")
  decko.path path + "/" + view

openPdf = (sourceMark) ->
  url = researchPath("source_selector") + "?" + $.param(source: sourceMark)
  el = $(".source_phase-view")
  el.addClass "slotter"
  el[0].href = url
  $.rails.handleRemote el