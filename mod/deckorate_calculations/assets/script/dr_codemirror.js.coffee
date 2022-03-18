decko.addEditor ".codemirror-editor-textarea",
  -> initCodeMirror $(this),
  -> codeMirrorContent $(this)

initCodeMirror = (textarea) ->
  cm = CodeMirror.fromTextArea textarea[0], mode: "coffeescript", theme: "midnight"
  textarea.data "codeMirror", cm

codeMirrorContent = (textarea)->
  textarea.data("codeMirror").getValue()
