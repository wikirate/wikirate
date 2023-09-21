$ ->
  $("body").on "click", ".copy-button", ->
    activeTab = $(this).closest(".tab-pane.active")
    clipBoard = activeTab.find("._clipboard")
    clipBoardContent = clipBoard.text()
    navigator.clipboard.writeText(clipBoardContent)
      .then ->
        console.log "Text copied to clipboard: #{clipBoardContent}"
      .catch (error) ->
        console.error "Copy to clipboard failed:", error
