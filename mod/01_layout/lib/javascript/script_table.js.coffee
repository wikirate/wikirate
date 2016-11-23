$(document).ready ->

# details toggle
  $('body').on 'click', ".tr-details-toggle, .details-close-icon", ->
    trToggleDetails this

  activeDetails = null

  trToggleDetails = (toggle) ->
    row = $(toggle).closest('tr')
    activeDetails = $(row).find('.details')
    if activeDetails.is(':visible')
      activeDetails.hide()
      row.removeClass("active")
    else
      activeRow = $(".wikirate-table tr.active")
      activeRow.find(".details").hide()
      activeRow.removeClass("active")
      row.addClass("active")
      activeDetails.show()

      if !$.trim(activeDetails.html()) # empty
        loadDetails(toggle)

    stickDetails()

  loadDetails = (toggle) ->
    loader_anime = $("#ajax_loader").html()
    activeDetails.append(loader_anime)
    card_slot = $(toggle).closest('.card-slot')
    card_name = card_slot.attr('id')

    #    if card_slot.hasClass("LTYPE_RTYPE-metric-company")
    #      # to re order the card name to get the metric details
    #      card_names = card_name.split("+")
    #      if card_names.length == 4
    #        card_name = card_names[3] + "+" + card_names[0] + "+" +
    #            card_names[1] + "+" + card_names[2] + "+yinyang_drag_item"
    #      else
    #        card_name = card_names[2]+"+"+card_names[0]+"+"+
    #            card_names[1]+"+yinyang_drag_item"

    view = $(toggle).data('view') || 'content'
    right_name = $(toggle).data('append')
    load_path_base = $(toggle).data('load-path')
    load_path = "/#{load_path_base}+#{right_name}?view=#{view}"
    $(activeDetails).load load_path, ->
      $(activeDetails).trigger('slotReady')

  #stick the details when scrolling
  stickDetails = () ->
    isModal = activeDetails.closest('.modal-body').exists()
    if $(document).scrollTop() > 56 || isModal
      activeDetails.addClass 'stick'
    else
      activeDetails.removeClass 'stick'

    if($(window).scrollTop() > ($("#main").height() - $(window).height() + 300))
      activeDetails.removeClass("stick")

    return

  $(window).scroll ->
    if activeDetails
      stickDetails()
