copyRichOrPlainText = (text) ->
  listener = (ev) ->
    ev.originalEvent.clipboardData.setData('text/html', text)
    ev.originalEvent.clipboardData.setData('text/plain', text)
    ev.preventDefault()

  $(document).on 'copy', listener
  document.execCommand('copy')
  $(document).off 'copy', listener

$ ->
  $("body").on "click", ".copy-button", ->
    content = $(this).closest(".tab-pane.active").find("._clipboard").html()
    copyRichOrPlainText(content)
    console.info "Text copied to clipboard: #{content}"
