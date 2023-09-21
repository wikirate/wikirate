$ ->
  $("body").on "click", ".copy-button", ->
    content = $(this).closest(".tab-pane.active").find("._clipboard").html()
    blob = new Blob([content], { type: "text/html" });
    richTextInput = new ClipboardItem({ "text/html": blob });
    navigator.clipboard.write([richTextInput])
      .then ->
        console.log "Text copied to clipboard: #{content}"
      .catch (error) ->
        console.error "Copy to clipboard failed:", error
