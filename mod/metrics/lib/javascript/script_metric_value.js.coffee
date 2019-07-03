# Handle Answer Checking (Verification) buttons
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

$.extend wikirate,
  valueChecking: (ele, action) ->
    path = encodeURIComponent(ele.data('path'))
    action = '?set_flag=' + action
    load_path = decko.slotPath('update/' + path + action)
    $parent = ele.closest('.double-check')
    $parent = ele.closest('.RIGHT-checked_by') unless $parent.exists()
    $parent.html('loading...')
    $.get(load_path, ((data) ->
      content = $(data).find('.d0-card-body').html()
      $parent.empty().html(content)
    ), 'html').fail((xhr, d, e) ->
      $parent.html('please <a href=/*signin>sign in</a>')
    )

$(document).ready ->
  $('body').on 'click', '._toggle_button_text', ->
    $(this).text (i, old_txt) ->
      new_txt = $(this).data("toggle-text")
      $(this).data("toggle-text", old_txt)
      new_txt

  $('body').on 'click','._value_check_button', ->
    wikirate.valueChecking($(this), 'checked')

  $('body').on 'click','._value_uncheck_button', ->
    wikirate.valueChecking($(this), 'not-checked')
