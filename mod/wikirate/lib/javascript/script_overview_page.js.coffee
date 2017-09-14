$(document).ready ->
  $('body').on 'ajax:success', '.slotter', (event, data, c, d) ->
    $_this = $(this)
    slot = $_this.slot()
    # ensure it is a overview form submition
    if $_this.is('form') and $_this.attr('action').indexOf('/card/update/' + slot.attr('id')) > -1 and slot.hasClass('TYPE_PLUS_RIGHT-analysi-overview')
#form returned
      overview_slot = $('.card-frame.TYPE-analysi')
      if overview_slot.size() > 0
        jqxhr = $.ajax('/' + overview_slot.attr('id')).done((data) ->
          $('.card-frame.TYPE-analysi:first').slotSuccess data
        )
