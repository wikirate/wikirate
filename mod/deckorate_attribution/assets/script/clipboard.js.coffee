selectElementContents = (el) ->
  range = document.createRange()
  range.selectNode(el)
  sel = window.getSelection()
  sel.removeAllRanges()
  sel.addRange(range)

copyHtmlToClipboard = () -> 
  activeTab = $(this).closest(".tab-pane.active")
  dataHtmlElement = activeTab.find("._clipboard")[0]

  if dataHtmlElement
    dataHtmlElement.contentEditable = true
    dataHtmlElement.readOnly = false

    selectElementContents(dataHtmlElement)
    copyRichOrPlainText(dataHtmlElement.innerHTML, dataHtmlElement.textContent)
    dataHtmlElement.contentEditable = false
    dataHtmlElement.readOnly = true

    window.getSelection().removeAllRanges()
  else
    console.error("No ._clipboard element found in the active tab.")

copyRichOrPlainText = (html, text) ->
  listener = (ev) ->
    ev.originalEvent.clipboardData.setData('text/html', html)
    ev.originalEvent.clipboardData.setData('text/plain', text)
    ev.preventDefault()

  $(document).on 'copy', listener
  document.execCommand('copy')
  $(document).off 'copy', listener

$ ->
  $("body").on "click", "._attribution-button", ->
    copyHtmlToClipboard.call(this)
    activeTab = $(this).closest(".tab-pane.active")
    content = activeTab.find("._clipboard").html()
    console.info "Text copied to clipboard: #{content}"
