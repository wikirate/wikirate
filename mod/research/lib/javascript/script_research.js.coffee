decko.slotReady (_slot) ->
  $('input._research-select').autocomplete
    select: (e, ui) ->
      $target = $(e.target)
      url = $target.data("url")
      url += (if url.match /\?/ then '&' else '?')
      url += $target.data("key") + "=" + encodeURIComponent(ui.item.value)
      $target.updateSlot(url)

  $('[data-toggle="popover"]').popover()



$(document).ready ->
  $("#main:has(>#Research_Page.slot_machine-view)").addClass("pl-0 pr-0")

  # add related company to name
  # otherwise the card can get the wrong type because it
  # matche the ltype_rtype/record/year pattern
  $("body").on "submit", "form.answer-form", (e) ->
    $form = $(e.target)
    related_company = $form.find("#card_subcards__related_company_content")
    if related_company.length == 1
      name = $form.find("#card_name").val()
      $form.find("#card_name").val(name + "+" + related_company.val())
      $form.find("#success_id").val("_left")





