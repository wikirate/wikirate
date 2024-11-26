// search_box.js.coffee
(function() {
  var browseType, searchBox, submitIfKeyword;

  searchBox = function() {
    return $('._search-box').data("searchBox");
  };

  $(window).ready(function() {
    $("body").on("change", ".search-box-form .search-box-select-type", function(e) {
      return searchBox().updateType();
    });
    $("body").on("click", ".search-box-form ._search-button", function(e) {
      submitIfKeyword() || browseType();
      return e.preventDefault();
    });
    $("body").on("submit", ".search-box-form", function(e) {
      if (!searchBox().keyword()) {
        e.preventDefault();
        return browseType();
      }
    });
    $("body").on("keypress", ".search-box-form .search-box-select-type", function(e) {
      if (e.which = 13) {
        return $(this).closest("form").submit();
      }
    });
    $("body").on("click", "._hot-keyword", function(e) {
      var sb;
      sb = searchBox();
      sb.keywordBox().val($(this).text());
      return sb.form().submit();
    });
    return searchBox().updateType();
  });

  $.extend(decko.searchBox.prototype, {
    selectedType: function() {
      return this.form().find("#query_type").val();
    },
    typeParams: function() {
      return {
        query: {
          type: this.selectedType()
        }
      };
    },
    updateType: function() {
      this.updateSource();
      this.updatePlaceholder();
      return this.init();
    },
    updateSource: function() {
      return this.config.source = this.selectedType() === "" ? this.originalpath : this.originalpath + "?" + $.param(this.typeParams());
    },
    updatePlaceholder: function() {
      var type;
      type = this.selectedType();
      return this.box.attr("placeholder", "Search for " + (type === "" ? "companies, data sets, and more..." : type));
    }
  });

  submitIfKeyword = function() {
    var sb;
    sb = searchBox();
    return sb.keyword() && sb.form().submit() || false;
  };

  browseType = function() {
    var page, sb, type;
    sb = searchBox();
    type = sb.selectedType();
    page = type === "" && ":search" || type;
    return window.location = decko.path(page + "?" + $.param(sb.typeParams()));
  };

}).call(this);
