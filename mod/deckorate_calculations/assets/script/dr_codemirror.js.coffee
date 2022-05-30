decko.editors.add ".codemirror-editor-textarea",
  -> initCodeMirror $(this),
  -> codeMirrorContent $(this)

initCodeMirror = (textarea) ->
  cm = CodeMirror.fromTextArea textarea[0], mode: "coffeescript", theme: "midnight"
  textarea.data "codeMirror", cm
  setTimeout (-> cm.refresh()), 200

codeMirrorContent = (textarea)->
  textarea.data("codeMirror").getValue()
