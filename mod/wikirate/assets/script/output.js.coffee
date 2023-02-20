decko.slot.ready (slot) ->
  $.each slot.find(".TYPE-output.box"), ->
    initBoxImage $(this)

initBoxImage = (box) ->
  top = box.find ".box-top"
  src = top.find("._image_holder").data("image-href")
  # debugger
  top.attr "style", "background-image: url('#{src}')"