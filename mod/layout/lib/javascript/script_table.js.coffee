$(document).ready ->

# details toggle
  active_details = null

  # hack to solve the problem that
  # if you click somewhere in the details area
  # it is closed because it is a child of .tr-details-toggle
  no_toggle = null
  $('body').on 'click', ".tr-details-toggle  td.details", ->
    no_toggle = true

  $('body').on 'click', ".details-close-icon", ->
    trToggleDetails this
  $('body').on 'click', ".tr-details-toggle", ->
    if no_toggle
      no_toggle = null
    else
      trToggleDetails this

  $('body').on 'click', ".tr-link", ->
    window.location.href = $(this).data("link-url")

  trToggleDetails = (toggle) ->
    row = $(toggle).closest('tr')
    active_details = $(row).find('.details')
    if active_details.is(':visible')
      active_details.hide()
      row.removeClass("active")
    else
      active_row = $(".wikirate-table tr.active")
      active_row.find(".details").hide()
      active_row.removeClass("active")
      row.addClass("active")
      active_details.show()

      if !$.trim(active_details.html()) # empty
        loadDetails(toggle)

    stickDetails()

  loadDetails = (toggle) ->
    loader_anime = $("#ajax_loader").html()
    active_details.append(loader_anime)
    $(active_details).load detailsUrl(toggle), ->
      $(active_details).find('.card-slot').trigger('slotReady')

  detailsUrl = (toggle) ->
    if $(toggle).data('details-url')
      $(toggle).data('details-url')
    else
      view = $(toggle).data('view') || 'content'
      right_name = $(toggle).data('append')
      card_name = $(toggle).closest('.card-slot').attr('id')
      "/#{card_name}+#{right_name}?view=#{view}"

  #stick the details when scrolling
  stickDetails = () ->
    is_modal = active_details.closest('.modal-body').exists()
    if $(document).scrollTop() > 56 || is_modal
      active_details.addClass 'stick'
    else
      active_details.removeClass 'stick'

    if($(window).scrollTop() > ($("#main").height() - $(window).height() + 300))
      active_details.removeClass("stick")

  $(window).scroll ->
    if active_details
      stickDetails()
