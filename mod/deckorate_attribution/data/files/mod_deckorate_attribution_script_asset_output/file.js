// attribution.js.coffee
(function() {
  $(document).ready(function() {
    return $("body").on("click", "._export-button", function(e) {
      var alert;
      alert = $(this).closest("._attributable-export").find("._attribution-alert");
      if (alert[0]) {
        return alert.showAsModal(alert.slot());
      }
    });
  });

}).call(this);

// clipboard.js.coffee
(function() {
  var copyHtmlToClipboard, copyRichOrPlainText, selectElementContents;

  selectElementContents = function(el) {
    var range, sel;
    range = document.createRange();
    range.selectNode(el);
    sel = window.getSelection();
    sel.removeAllRanges();
    return sel.addRange(range);
  };

  copyHtmlToClipboard = function() {
    var activeTab, dataHtmlElement;
    activeTab = $(this).closest(".tab-pane.active");
    dataHtmlElement = activeTab.find("._clipboard")[0];
    if (dataHtmlElement) {
      dataHtmlElement.contentEditable = true;
      dataHtmlElement.readOnly = false;
      selectElementContents(dataHtmlElement);
      copyRichOrPlainText(dataHtmlElement.innerHTML, dataHtmlElement.textContent);
      dataHtmlElement.contentEditable = false;
      dataHtmlElement.readOnly = true;
      return window.getSelection().removeAllRanges();
    } else {
      return console.error("No ._clipboard element found in the active tab.");
    }
  };

  copyRichOrPlainText = function(html, text) {
    var listener;
    listener = function(ev) {
      ev.originalEvent.clipboardData.setData('text/html', html);
      ev.originalEvent.clipboardData.setData('text/plain', text);
      return ev.preventDefault();
    };
    $(document).on('copy', listener);
    document.execCommand('copy');
    return $(document).off('copy', listener);
  };

  $(function() {
    return $("body").on("click", "._attribution-button", function() {
      var activeTab, content;
      copyHtmlToClipboard.call(this);
      activeTab = $(this).closest(".tab-pane.active");
      content = activeTab.find("._clipboard").html();
      return console.info("Text copied to clipboard: " + content);
    });
  });

}).call(this);
