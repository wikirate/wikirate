decko.slotReady (_slot) ->
  $('input._research-select').autocomplete
    select: (e, ui) ->
      $target = $(e.target)
      url = $target.data("url")
      url += (if url.match /\?/ then '&' else '?')
      url += $target.data("key") + "=" + encodeURIComponent(ui.item.value)
      $target.updateSlot(url)

$(document).ready ->
  $("#main:has(>#Research_Page.slot_machine-view)").addClass("pl-0 pr-0")


