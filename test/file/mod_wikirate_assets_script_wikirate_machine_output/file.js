// script_import_page.js.coffee
(function() {
  decko.slotReady(function(slot) {});

  $(document).ready(function() {
    var closestImportTable, selectImportRows;
    $('body').on('click', '._import-status-form ._check-all', function(_e) {
      var checked;
      checked = $(this).is(':checked');
      return selectImportRows($(this).closest('._import-status-form'), checked);
    });
    selectImportRows = function(status_form, checked) {
      return status_form.find("._import-row-checkbox").prop('checked', checked);
    };
    $('body').on('click', "input[name=allImportMapItems]", function() {
      var allItems;
      allItems = $(this);
      return allItems.closest("._import-table").find("[name=importMapItem]:visible").each(function() {
        var itemCheckbox;
        itemCheckbox = $(this);
        return itemCheckbox.prop("checked", allItems.prop("checked"));
      });
    });
    $('body').on('change', "._import-map-action", function() {
      var select;
      select = $(this);
      if (select.val() === "") {
        return;
      }
      closestImportTable(select).find("[name=importMapItem]:checked").each(function() {
        var inp;
        inp = $(this).closest("._map-item").find("._import-mapping");
        if (select.val() === "auto-add") {
          if (inp.val() === '') {
            return inp.val("AutoAdd");
          }
        } else if (select.val() === "clear") {
          return inp.val("");
        }
      });
      select.val("");
      return select.trigger("change");
    });
    $('body').on('click', '._import-status-refresh', function(e) {
      var current_tab, s;
      s = $(this).slot();
      current_tab = s.find(".nav-link.active").data("tab-name");
      return s.reloadSlot(s.slotUrl() + "&tab=" + current_tab);
    });
    $('body').on('click', "._toggle-mapping-vis", function(e) {
      var link, mapped, name;
      link = $(this);
      name = link.find("._mapping-vis-name");
      mapped = closestImportTable(link).find(".mapped-import-attrib");
      if (name.text() === "Hide") {
        mapped.hide();
        mapped.find("[name=importMapItem]").prop("checked", false);
        name.text("Show");
      } else {
        mapped.show();
        name.text("Hide");
      }
      return e.preventDefault;
    });
    $('body').on('click', '._save-mapping', function() {
      var tab;
      $(".tab-pane-import_status_tab").html("");
      tab = $("._import-core > .tabbable > .nav > .nav-item:nth-child(2) > .nav-link");
      return tab.addClass("load");
    });
    return closestImportTable = function(el) {
      return el.closest(".tab-pane").find("._import-table");
    };
  });

}).call(this);

// script_company_group.js.coffee
(function() {
  var constraintCsv, constraintEditor, constraintToImportItem, groupValue, ignoreConstraintElements, metricValue, specificationType, updateSpecVisibility, valueValue, yearValue;

  decko.editorContentFunctionMap['.specification-input'] = function() {
    var ed;
    ignoreConstraintElements();
    ed = $(this);
    if (specificationType(ed) === "explicit") {
      return "explicit";
    } else {
      return constraintCsv(constraintEditor(ed));
    }
  };

  ignoreConstraintElements = function() {
    return $(".constraint-editor input, .constraint-editor select").attr("form", "ignore");
  };

  constraintCsv = function(constraintListEditor) {
    var rows;
    rows = constraintListEditor.find(".constraint-editor").map(function() {
      return constraintToImportItem($(this));
    });
    return rows.get().join("\n");
  };

  constraintToImportItem = function(con) {
    return [metricValue(con), yearValue(con), valueValue(con), groupValue(con)].join(";|;");
  };

  metricValue = function(con) {
    return con.find(".constraint-metric input").val();
  };

  yearValue = function(con) {
    return con.find(".constraint-year select").val();
  };

  valueValue = function(con) {
    return con.find(".constraint-value input, .constraint-value .constraint-value-fields > select").serialize();
  };

  groupValue = function(con) {
    return con.find(".constraint-related-group select").val();
  };

  specificationType = function(el) {
    return el.find("[name=spec-type]:checked").val();
  };

  constraintEditor = function(el) {
    return el.find(".constraint-list-editor");
  };

  updateSpecVisibility = function(slot) {
    var explicit, implicit;
    implicit = constraintEditor(slot);
    explicit = slot.find(".RIGHT-company.card-editor");
    if (specificationType(slot) === "explicit") {
      explicit.show();
      return implicit.hide();
    } else {
      explicit.hide();
      return implicit.show();
    }
  };

  $(window).ready(function() {
    $("body").on("change", "._constraint-metric", function() {
      var input, metric, url, valueSlot;
      input = $(this);
      valueSlot = input.closest("li").find(".card-slot");
      metric = encodeURIComponent(input.val());
      url = valueSlot.slotMark() + "?view=value_formgroup&metric=" + metric;
      return valueSlot.reloadSlot(url);
    });
    return $("body").on("change", "input[name=spec-type]", function() {
      return updateSpecVisibility($(this).slot());
    });
  });

  decko.slotReady(function(slot) {
    if (slot.find(".specification-input").length > 0) {
      return updateSpecVisibility(slot);
    }
  });

}).call(this);

// script_collapse.js.coffee
(function() {
  var findCollapseTarget, loadCollapseTarget, registerIconToggle, registerTextToggle;

  $(document).ready(function() {
    $('body').on('click.collapse-next', '[data-toggle=collapse-next]', function() {
      return findCollapseTarget($(this)).collapse('toggle');
    });
    return $('body').on('click', '[data-toggle="collapse"]', function() {
      var $target;
      if ($(this).data("url") != null) {
        $target = $(findCollapseTarget(this));
        if (!$target.text().length) {
          return loadCollapseTarget($target, $(this).data("url"));
        }
      }
    });
  });

  decko.slotReady(function(slot) {
    return slot.find('[data-toggle="collapse"], [data-toggle="collapse-next"]').each(function(i) {
      if ($(this).data('collapse-icon-in') != null) {
        registerIconToggle($(this));
      }
      if ($(this).data('collapse-text-in') != null) {
        return registerTextToggle($(this));
      }
    });
  });

  registerTextToggle = function($this, inText, outText) {
    var $target;
    if (inText == null) {
      inText = null;
    }
    if (outText == null) {
      outText = null;
    }
    $target = $(findCollapseTarget($this));
    if ($this.data('collapse-text-in') != null) {
      inText || (inText = $this.data('collapse-text-in'));
      outText || (outText = $this.data('collapse-text-out'));
    }
    $target.on('hidden.bs.collapse', function() {
      return $this.text(outText);
    });
    return $target.on('shown.bs.collapse', function() {
      return $this.text(inText);
    });
  };

  registerIconToggle = function($this, inClass, outClass) {
    var $target;
    if (inClass == null) {
      inClass = null;
    }
    if (outClass == null) {
      outClass = null;
    }
    $target = $(findCollapseTarget($this));
    if ($this.data('collapse-icon-in') != null) {
      inClass || (inClass = $this.data('collapse-icon-in') || "fa-caret-right");
      outClass || (outClass = $this.data('collapse-icon-out') || "fa-caret-down");
    }
    $target.on('hide.bs.collapse', function(e) {
      return $this.parent().find("." + inClass).removeClass(inClass).addClass(outClass);
    });
    return $target.on('show.bs.collapse', function(e) {
      return $this.parent().find("." + outClass).removeClass(outClass).addClass(inClass);
    });
  };

  loadCollapseTarget = function($target, url) {
    wikirate.loader($target, true).add();
    return $target.load(url, function(el) {
      var child_slot;
      child_slot = $(el).children('.card-slot')[0];
      if (child_slot != null) {
        return $(child_slot).trigger('slotReady');
      } else {
        return $target.slot().trigger('slotReady');
      }
    });
  };

  findCollapseTarget = function(toggle) {
    var $toggle, parent, target;
    $toggle = $(toggle);
    parent = $toggle.data("parent") != null ? $toggle.closest($toggle.data("parent")) : $toggle.parent();
    target = $toggle.attr("href") || $toggle.data('target') || '.collapse';
    if ($toggle.data("collapse")) {
      target += $toggle.data("collapse");
    }
    if ($toggle.find(target).length) {
      return $toggle.find(target);
    } else if ($toggle.siblings(target).length) {
      return $toggle.siblings(target);
    } else if (parent.find(target).length) {
      return parent.find(target);
    } else if (parent.siblings(target).length) {
      return parent.siblings(target);
    } else {
      return $(target);
    }
  };

}).call(this);

// script_general_popup.js.coffee
(function() {
  var gettingSourceListHtmlFail, linkOnClick, sourceListHtmlReturned;

  sourceListHtmlReturned = function(header, data) {
    var $_data, $popupWindow, height;
    $popupWindow = $('#popup-window');
    $_data = $(data);
    if (header) {
      $_data.find('.d0-card-header').remove();
    }
    $popupWindow.html($_data);
    height = $(window).height() - $('.navbar:first').height() - 1;
    if ($popupWindow.height() > height) {
      $popupWindow.dialog('option', 'height', height);
    }
    decko.initializeEditors($popupWindow.find('div:first'));
    $popupWindow.find('div:first').trigger('slotReady');
  };

  gettingSourceListHtmlFail = function(xhr, ajaxOptions, thrownError) {
    var $popupWindow, html;
    $popupWindow = $('#popup-window');
    html = $(xhr.responseText);
    $popupWindow.html(html);
  };

  linkOnClick = function(e) {
    var $_this, $popupWindow, header, href, jqxhr, loadingImageUrl, originalLink, position, title;
    e.preventDefault();
    $_this = $(this);
    href = $_this.attr('href');
    loadingImageUrl = '{{loading gif|source;size:large}}';
    position = 'center';
    if ($_this.hasClass('position-right')) {
      position = {
        of: '.navbar',
        my: 'right bottom',
        at: 'right top',
        collision: 'flipfit'
      };
    }
    if ($_this.hasClass('position-left')) {
      position = {
        my: 'left bottom',
        at: 'left top',
        of: '.navbar',
        collision: 'flipfit'
      };
    }
    title = '<i class="fa fa-arrows"></i>';
    if ($_this.data('popup-title')) {
      title = $_this.data('popup-title');
    }
    $popupWindow = $('#popup-window');
    if ($popupWindow.length === 0) {
      $('#main').prepend('<div id="popup-window" style="display:none;"></div>');
    }
    $popupWindow = $('#popup-window');
    $popupWindow.html('<img src=\'' + loadingImageUrl + '\' />');
    $popupWindow.removeAttr('style');
    $popupWindow.dialog({
      height: 'auto',
      minWidth: 700,
      position: position,
      title: title,
      closeOnEscape: false,
      resizable: false,
      draggable: true,
      close: function(event, ui) {
        $popupWindow.dialog('destroy');
      }
    });
    header = $_this.hasClass('no-header');
    originalLink = $_this.hasClass('popup-original-link');
    jqxhr = $.ajax(href + (originalLink ? '' : '?view=content')).done(function(data) {
      return sourceListHtmlReturned(header, data);
    }).fail(gettingSourceListHtmlFail);
    return false;
  };

  decko.slotReady(function(slot) {
    slot.find('.show-link-in-popup').each(function() {
      return $(this).off('click').click(linkOnClick);
    });
    return slot.find('[data-toggle="popover"]').popover();
  });

}).call(this);

// script_empty_tab_content.js.coffee
(function() {
  decko.slotReady(function(slot) {
    return slot.find('.tab').each(function() {
      var $tabDiv;
      $tabDiv = $(this);
      return $tabDiv.find('.search-no-results').each(function() {
        var $div, emptyTabContent;
        if ($(this).find('.empty-tab').length > 0) {
          return;
        }
        $div = $('<div>', {
          "class": 'empty-tab'
        });
        emptyTabContent = $tabDiv.attr('empty-tab-content');
        if (emptyTabContent) {
          $div.append('<span>' + emptyTabContent + '</span>');
          return $(this).append($div);
        }
      });
    });
  });

}).call(this);

// script_wikirate_coffee.js.coffee

/*
This adds the special source editor (which is overwritten in right/source.rb)
to this long-named map which gets triggered whenever we need javascript
to translate fancy editor content into something friendly to the REST API.

It basically loops through each item in the list and gets the card name from the
standard "data-card-name" attribute.
 */

(function() {
  var appendParentToAddItem;

  decko.editorContentFunctionMap['.source-editor > .pointer-list'] = function() {
    return decko.pointerContent(this.find('.TYPE-source').map(function() {
      return $(this).attr('data-card-name');
    }));
  };

  decko.slotReady(function(slot) {
    var parent;
    if (!(slot.hasClass("TYPE-project") && slot.find("form"))) {
      return;
    }
    parent = slot.find(".RIGHT-parent .pointer-item-text");
    return appendParentToAddItem(parent);
  });

  appendParentToAddItem = function(parent) {
    if (!parent.val()) {
      return;
    }
    return parent.slot().find("._add-item-link").each(function() {
      var anchor, new_href;
      anchor = $(this);
      new_href = anchor.attr("href") + "&" + $.param({
        "filter[project]": parent.val()
      });
      return anchor.attr("href", new_href);
    });
  };

  $(window).ready(function() {
    return $("body").on("click", "a.card-paging-link", function() {
      var id;
      id = $(this).slot().attr("id");
      return history.pushState({
        slot_id: id,
        url: this.href
      }, "", location.href);
    });
  });

}).call(this);

// script_wikirate_common.js.coffee
(function() {
  $(function() {
    return $('.modal-window').dialog({
      modal: true,
      width: '46%',
      buttons: {
        Ok: function() {
          return $(this).dialog('close');
        }
      }
    });
  });

  $.extend({
    wikirate: {
      ajaxLoader: {
        head: '#ajax_loader',
        child: '.loader-anime'
      },
      initRowRemove: function($button) {
        if (!$button) {
          $button = $("._remove_row");
        }
        return $button.each(function() {
          var $this;
          $this = $(this);
          return $this.on('click', function() {
            return $this.closest('tr').remove();
          });
        });
      },
      isString: function(val) {
        var ref;
        return (ref = typeof val === 'string') != null ? ref : {
          "true": false
        };
      },
      jObj: function(ele) {
        if (this.isString(ele)) {
          return $(ele);
        } else {
          return ele;
        }
      },
      loader: function(target, relative) {
        var fn, loader;
        if (relative == null) {
          relative = false;
        }
        fn = this;
        target = fn.jObj(target);
        loader = fn.ajaxLoader;
        return {
          isLoading: function() {
            if (this.child().exists()) {
              return true;
            } else {
              return false;
            }
          },
          add: function() {
            if (this.isLoading()) {
              return;
            }
            target.append($(loader.head).html());
            if (relative) {
              return this.child().addClass("relative");
            }
          },
          prepend: function() {
            if (this.isLoading()) {
              return;
            }
            target.prepend($(loader.head).html());
            if (relative) {
              return this.child().addClass("relative");
            }
          },
          remove: function() {
            return this.child().remove();
          },
          child: function() {
            return target.find(loader.child);
          }
        };
      }
    }
  });

  $.urlParam = function(name) {
    var results;
    results = new RegExp('[?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results === null) {
      return null;
    } else {
      return results[1] || 0;
    }
  };

  $.fn.exists = function() {
    return this.length > 0;
  };

  decko.slotReady(function(slot) {
    slot.find('.company_autocomplete').autocomplete({
      source: '/Companies+*right+*content_options.json?view=name_match',
      minLength: 2
    });
    slot.find('.wikirate_company_autocomplete').autocomplete({
      source: '/Companies+*right+*content_options.json?view=name_match',
      minLength: 2
    });
    slot.find('.wikirate_topic_autocomplete').autocomplete({
      source: '/Topic+*right+*content_options.json?view=name_match',
      minLength: 2
    });
    slot.find('.metric_autocomplete').autocomplete({
      source: '/Metric+*right+*content_options.json?view=name_match',
      minLength: 2
    });
    return wikirate.initRowRemove(slot.find("._remove_row"));
  });

  $(document).ready(function() {
    return $('body').on("submit", "._filter-form", function() {
      var slot;
      slot = $(this).findSlot($(this).data("slot-selector"));
      return wikirate.loader($(slot), true).prepend();
    });
  });

}).call(this);
