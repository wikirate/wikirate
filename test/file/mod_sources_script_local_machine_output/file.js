// sources.js.coffee
(function() {
  $(document).ready(function() {
    $('body').on('click', ".toggle-source-option", function() {
      $('.download-option input').val("");
      $('.source-option').show();
      return $(this).closest('.source-option').hide();
    });
    $('body').on('click', ".TYPE-source.box, .TYPE-source.bar", function() {
      return window.location = decko.path($(this).data("cardLinkName"));
    });
    return $("body").on("change", ".RIGHT-file .download-option .d0-card-content", function() {
      var catcher, el;
      el = $(this);
      catcher = el.slot().find(".copy_catcher-view");
      return catcher.reloadSlot(catcher.slotUrl() + "&" + $.param({
        url: el.val()
      }));
    });
  });

  decko.slotReady(function(slot) {
    slot.find(".TYPE-source .meatball-button").on("click", function(e) {
      $(this).dropdown("toggle");
      return e.stopImmediatePropagation();
    });
    slot.find(".TYPE-source.box a, .TYPE-source.bar a").on("click", function(e) {
      return e.preventDefault();
    });
    return resizeIframe($('body'));
  });

  decko.slotReady(function(slot) {
    return resizeIframe(slot);
  });

  this.resizeIframe = function(el) {
    var preview;
    preview = el.find(".pdf-source-preview");
    if (preview.exists()) {
      return preview.height($(window).height() - $('.navbar').height() - 1);
    }
  };

}).call(this);
