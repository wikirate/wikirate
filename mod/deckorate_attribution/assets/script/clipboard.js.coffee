$ ->
  $("body").on "click", ".copy-button", ->
    clipboardContent = $("#clipboard").text()
    
    navigator.clipboard.writeText(clipboardContent)
      .then ->
        console.log "Text copied to clipboard: #{clipboardContent}"
      .catch (error) ->
        console.error "Copy to clipboard failed:", error
