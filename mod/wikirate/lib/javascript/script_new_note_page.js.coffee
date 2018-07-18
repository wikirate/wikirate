interval = null
byteCount = (s) ->
  encodeURI(s).split(/%..|./).length - 1

updateCharCount = (inputBox) ->
  maxlimit = 100
  countField = $('.note-counting .note-counting-number')
  if byteCount(inputBox.val()) > maxlimit
    inputBox.val inputBox.val().substring(0, maxlimit)
  #Here we can add helptext to recommend users to add basis.
  countField.html maxlimit - byteCount(inputBox.val())
  return

flag_if_not_empty = (slot, text_box) ->
  text = text_box.val()
  flag = slot.find("#input_box_flag")
  if flag.length == 0
    flag = $('<input>').attr(type: 'hidden', id: 'input_box_flag', value: 'false')
    flag.appendTo slot.find("form")
  if text.length != 0
    flag.val("true")
  else
    flag.val("false")

wait_for_source_adding = ->
  if $("#input_box_flag").val() == "false"
    $("#input_box_flag").closest("form").submit()
    clearInterval(interval)

decko.slotReady (slot) ->

  ### commenting it for now.
  $("body").on("blur", "#sourcebox", function() {
    return $(".sourcebox button").trigger("click");
  });
  ###

  ###*
   To remove the source from note form when clicked on 'close' icon
  *
  ###
  $slotContainer = slot.filter('.TYPE-note.related-view, .TYPE-note.new-view, .TYPE-note.edit-view,.TYPE_PLUS_RIGHT-note-source.edit-view, .RIGHT-source.edit-view, .RIGHT-source.new-view')
  $slotContainer.on {
    mouseenter: ->
      $(this).find('.remove-source').show()
      return
    mouseleave: ->
      $(this).find('.remove-source').hide()
      return

  }, '.TYPE-source'
  $slotContainer.on 'click', '.TYPE-source .remove-source', ->
    $(this).slot().remove()
    return

  if slot.hasClass("new-view") && slot.hasClass("TYPE-note")
    nameBox = slot.find('#card_name')
    if nameBox.length
      updateCharCount nameBox

    ###
    To Count number of characters in Note input box
    ###
    slot.find('#card_name').keyup (event) ->
      updateCharCount $(this)
      return

    input_box = slot.find('.RIGHT-source .sourcebox input')
    input_box.keyup (event) ->
      flag_if_not_empty slot, $(this)
      return

    slot.find(":submit.create-submit-button").click ->
      if slot.find("#input_box_flag").val() == 'true'
        interval = setInterval(wait_for_source_adding, 500)
        return false
      true

  ###*
   To replace existing helptext with questionMark icon and
   show the helptext in a popover box
  *
  ###

  # $helpText = slot.find('.instruction')
  # $helpText.each ->
  #   _this = $(this)
  #   if _this.parent('.card-frame')[0] or _this.find('.helpTextQuestionMrk').length > 0
  #     return true
  #   if _this.closest('legend').find('.helpTextQuestionMrk').length == 0
  #     _this.hide()
  #     _this.parent('legend').append '<div class="fa fa-question-circle helpTextQuestionMrk"></div>'
  #     tooltipParent = _this.parent().find('.helpTextQuestionMrk')
  #     tooltipParent.attr 'title', _this.html()
  #     console.log tooltipParent
  #   $.widget 'ui.tooltip', $.ui.tooltip, options: content: ->
  #     $(this).prop 'title'
  #   $('.helpTextQuestionMrk').tooltip position:
  #     my: 'left+18 center'
  #     at: 'right top+6'
  #     collision: 'none'

  #   ###
  #       _this.children().hide();
  #       _this.append('<div class="fa fa-question-circle helpTextQuestionMrk"></div>');
  #       _this.find(".helpTextQuestionMrk").mouseover(function(){
  #         $(this).siblings('p').show();
  #       });
  #       _this.find(".helpTextQuestionMrk").mouseout(function(){
  #         $(this).siblings('p').hide();
  #       });
  #   ###

  #   return

  ###*
   To add progressive disclousure link in the note form to hide least important/optional fields
  *
  ###

  $disclosureLinks = slot.filter('.TYPE-note.new-view').find('._pDisLink')
  if $disclosureLinks.length
    $disclosureLinks.show()
    $('.RIGHT-basi,.RIGHT-tag,.RIGHT-year, .RIGHT-related_overview, .RIGHT-discussion').hide()
    $('#_addBasis').click ->
      $('.RIGHT-basi').show()
      $(this).hide()
      return
    $('#_addMoreInfo').click ->
      $('.RIGHT-tag,.RIGHT-year,.RIGHT-related_overview, .RIGHT-discussion').show()
      $(this).hide()
      return


  ###*
   To close the note tip (which displayed below the note card title)
  *
  ###

  slot.find('#close-tip').click ->
    $('.note-tip').hide()
    return
  return
