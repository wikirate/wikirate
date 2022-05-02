// toggle_details.js.coffee
(function() {
  $.fn.exists = function() {
    return this.length > 0;
  };

  $(document).ready(function() {
    $('body').on('click', "[data-details-mark]", function() {
      return (new decko.details(this)).toggle($(this));
    });
    $('body').on('click', ".details-close-icon", function(e) {
      (new decko.details(this)).closeLast();
      e.stopPropagation();
      return e.preventDefault();
    });
    return $('body').on('click', '.details ._update-details', function(e) {
      if (!($(this).closest(".relations_table-view").length > 0)) {
        (new decko.details(this)).add($(this));
        return e.preventDefault();
      }
    });
  });

  decko.details = function(el) {
    this.initDSlot = function(el) {
      var innerSlot;
      if (!$(".details").exists()) {
        $("body").append("<div class='details'></div>");
      }
      if (el) {
        innerSlot = $(el).closest(".details-toggle").find(".details");
      }
      return this.dSlot = innerSlot.exists() ? innerSlot : $(".details");
    };
    this.initModal = function() {
      if (!this.inModal()) {
        this.mSlot = this.dSlot.showAsModal($("body"));
        return this.modalDialog().addClass("modal-lg");
      }
    };
    this.inModal = function() {
      return this.modalDialog().exists();
    };
    this.modalDialog = function() {
      return this.dSlot.closest(".modal-dialog");
    };
    this.closeLast = function() {
      if (this.dSlot.children().length === 1) {
        return this.turnOff();
      } else {
        this.lastDetails().remove();
        return this.showLastDetails();
      }
    };
    this.closeAll = function() {
      this.dSlot.children().not(":first").remove();
      return this.turnOff();
    };
    this.turnOff = function() {
      $(".details-toggle").removeClass("active");
      this.dSlot.hide();
      if (this.inModal()) {
        return this.dSlot.closest(".modal").modal('hide');
      }
    };
    this.toggle = function(el) {
      if (el.hasClass("active")) {
        el.removeClass("active");
        return this.closeAll();
      } else {
        this.turnOff();
        el.addClass("active");
        return this.add(el, true);
      }
    };
    this.add = function(el, root) {
      return this.showDetails(this.urlFor(el), root);
    };
    this.urlFor = function(el) {
      var mark;
      mark = el.attr("href") || el.data("details-mark");
      return decko.path(mark + "?view=" + this.config("view"));
    };
    this.config = function(key) {
      this.configHash || (this.configHash = $("[data-details-config]").data("details-config"));
      if (this.configHash) {
        return this.configHash[key];
      }
    };
    this.showDetails = function(url, root) {
      var page;
      if (this.currentURL() !== url) {
        if (root) {
          this.dSlot.html("");
        }
        page = this.loadPage(url);
        this.dSlot.append(page);
        this.setCurrentURL(url);
      }
      return this.showLastDetails();
    };
    this.showLastDetails = function() {
      this.dSlot.children().hide();
      this.lastDetails().show();
      return this.dSlot.show();
    };
    this.currentURL = function() {
      return this.lastDetails().data("currentUrl");
    };
    this.setCurrentURL = function(url) {
      return this.lastDetails().data("currentUrl", url);
    };
    this.lastDetails = function() {
      return this.dSlot.children().last();
    };
    this.loadPage = function(url) {
      var page;
      page = $('<div></div>');
      page.load(url, function() {
        return page.find(".card-slot").trigger("slotReady");
      });
      return page;
    };
    this.initDSlot(el);
    if (this.config("layout") === "modal") {
      this.initModal();
    }
    return this;
  };

}).call(this);
