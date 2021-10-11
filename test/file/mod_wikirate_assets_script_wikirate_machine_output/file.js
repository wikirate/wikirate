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
  decko.slotReady(function(slot) {
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
  window.wikirate = {
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
      var loader;
      if (relative == null) {
        relative = false;
      }
      target = this.jObj(target);
      loader = wikirate.ajaxLoader;
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
  };

  $.fn.exists = function() {
    return this.length > 0;
  };

  decko.slotReady(function(slot) {
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
      return wikirate.loader($(slot), false).prepend();
    });
  });

}).call(this);

// anime.min.js
/*
 2017 Julian Garnier
 Released under the MIT license
*/
var $jscomp$this=this;
(function(u,r){"function"===typeof define&&define.amd?define([],r):"object"===typeof module&&module.exports?module.exports=r():u.anime=r()})(this,function(){function u(a){if(!g.col(a))try{return document.querySelectorAll(a)}catch(b){}}function r(a){return a.reduce(function(a,c){return a.concat(g.arr(c)?r(c):c)},[])}function v(a){if(g.arr(a))return a;g.str(a)&&(a=u(a)||a);return a instanceof NodeList||a instanceof HTMLCollection?[].slice.call(a):[a]}function E(a,b){return a.some(function(a){return a===b})}
function z(a){var b={},c;for(c in a)b[c]=a[c];return b}function F(a,b){var c=z(a),d;for(d in a)c[d]=b.hasOwnProperty(d)?b[d]:a[d];return c}function A(a,b){var c=z(a),d;for(d in b)c[d]=g.und(a[d])?b[d]:a[d];return c}function R(a){a=a.replace(/^#?([a-f\d])([a-f\d])([a-f\d])$/i,function(a,b,c,h){return b+b+c+c+h+h});var b=/^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(a);a=parseInt(b[1],16);var c=parseInt(b[2],16),b=parseInt(b[3],16);return"rgb("+a+","+c+","+b+")"}function S(a){function b(a,b,c){0>
c&&(c+=1);1<c&&--c;return c<1/6?a+6*(b-a)*c:.5>c?b:c<2/3?a+(b-a)*(2/3-c)*6:a}var c=/hsl\((\d+),\s*([\d.]+)%,\s*([\d.]+)%\)/g.exec(a);a=parseInt(c[1])/360;var d=parseInt(c[2])/100,c=parseInt(c[3])/100;if(0==d)d=c=a=c;else{var e=.5>c?c*(1+d):c+d-c*d,k=2*c-e,d=b(k,e,a+1/3),c=b(k,e,a);a=b(k,e,a-1/3)}return"rgb("+255*d+","+255*c+","+255*a+")"}function w(a){if(a=/([\+\-]?[0-9#\.]+)(%|px|pt|em|rem|in|cm|mm|ex|pc|vw|vh|deg|rad|turn)?/.exec(a))return a[2]}function T(a){if(-1<a.indexOf("translate"))return"px";
if(-1<a.indexOf("rotate")||-1<a.indexOf("skew"))return"deg"}function G(a,b){return g.fnc(a)?a(b.target,b.id,b.total):a}function B(a,b){if(b in a.style)return getComputedStyle(a).getPropertyValue(b.replace(/([a-z])([A-Z])/g,"$1-$2").toLowerCase())||"0"}function H(a,b){if(g.dom(a)&&E(U,b))return"transform";if(g.dom(a)&&(a.getAttribute(b)||g.svg(a)&&a[b]))return"attribute";if(g.dom(a)&&"transform"!==b&&B(a,b))return"css";if(null!=a[b])return"object"}function V(a,b){var c=T(b),c=-1<b.indexOf("scale")?
1:0+c;a=a.style.transform;if(!a)return c;for(var d=[],e=[],k=[],h=/(\w+)\((.+?)\)/g;d=h.exec(a);)e.push(d[1]),k.push(d[2]);a=k.filter(function(a,c){return e[c]===b});return a.length?a[0]:c}function I(a,b){switch(H(a,b)){case "transform":return V(a,b);case "css":return B(a,b);case "attribute":return a.getAttribute(b)}return a[b]||0}function J(a,b){var c=/^(\*=|\+=|-=)/.exec(a);if(!c)return a;b=parseFloat(b);a=parseFloat(a.replace(c[0],""));switch(c[0][0]){case "+":return b+a;case "-":return b-a;case "*":return b*
a}}function C(a){return g.obj(a)&&a.hasOwnProperty("totalLength")}function W(a,b){function c(c){c=void 0===c?0:c;return a.el.getPointAtLength(1<=b+c?b+c:0)}var d=c(),e=c(-1),k=c(1);switch(a.property){case "x":return d.x;case "y":return d.y;case "angle":return 180*Math.atan2(k.y-e.y,k.x-e.x)/Math.PI}}function K(a,b){var c=/-?\d*\.?\d+/g;a=C(a)?a.totalLength:a;if(g.col(a))b=g.rgb(a)?a:g.hex(a)?R(a):g.hsl(a)?S(a):void 0;else{var d=w(a);a=d?a.substr(0,a.length-d.length):a;b=b?a+b:a}b+="";return{original:b,
numbers:b.match(c)?b.match(c).map(Number):[0],strings:b.split(c)}}function X(a,b){return b.reduce(function(b,d,e){return b+a[e-1]+d})}function L(a){return(a?r(g.arr(a)?a.map(v):v(a)):[]).filter(function(a,c,d){return d.indexOf(a)===c})}function Y(a){var b=L(a);return b.map(function(a,d){return{target:a,id:d,total:b.length}})}function Z(a,b){var c=z(b);if(g.arr(a)){var d=a.length;2!==d||g.obj(a[0])?g.fnc(b.duration)||(c.duration=b.duration/d):a={value:a}}return v(a).map(function(a,c){c=c?0:b.delay;
a=g.obj(a)&&!C(a)?a:{value:a};g.und(a.delay)&&(a.delay=c);return a}).map(function(a){return A(a,c)})}function aa(a,b){var c={},d;for(d in a){var e=G(a[d],b);g.arr(e)&&(e=e.map(function(a){return G(a,b)}),1===e.length&&(e=e[0]));c[d]=e}c.duration=parseFloat(c.duration);c.delay=parseFloat(c.delay);return c}function ba(a){return g.arr(a)?x.apply(this,a):M[a]}function ca(a,b){var c;return a.tweens.map(function(d){d=aa(d,b);var e=d.value,k=I(b.target,a.name),h=c?c.to.original:k,h=g.arr(e)?e[0]:h,n=J(g.arr(e)?
e[1]:e,h),k=w(n)||w(h)||w(k);d.isPath=C(e);d.from=K(h,k);d.to=K(n,k);d.start=c?c.end:a.offset;d.end=d.start+d.delay+d.duration;d.easing=ba(d.easing);d.elasticity=(1E3-Math.min(Math.max(d.elasticity,1),999))/1E3;g.col(d.from.original)&&(d.round=1);return c=d})}function da(a,b){return r(a.map(function(a){return b.map(function(b){var c=H(a.target,b.name);if(c){var d=ca(b,a);b={type:c,property:b.name,animatable:a,tweens:d,duration:d[d.length-1].end,delay:d[0].delay}}else b=void 0;return b})})).filter(function(a){return!g.und(a)})}
function N(a,b,c){var d="delay"===a?Math.min:Math.max;return b.length?d.apply(Math,b.map(function(b){return b[a]})):c[a]}function ea(a){var b=F(fa,a),c=F(ga,a),d=Y(a.targets),e=[],g=A(b,c),h;for(h in a)g.hasOwnProperty(h)||"targets"===h||e.push({name:h,offset:g.offset,tweens:Z(a[h],c)});a=da(d,e);return A(b,{animatables:d,animations:a,duration:N("duration",a,c),delay:N("delay",a,c)})}function m(a){function b(){return window.Promise&&new Promise(function(a){return P=a})}function c(a){return f.reversed?
f.duration-a:a}function d(a){for(var b=0,c={},d=f.animations,e={};b<d.length;){var g=d[b],h=g.animatable,n=g.tweens;e.tween=n.filter(function(b){return a<b.end})[0]||n[n.length-1];e.isPath$0=e.tween.isPath;e.round=e.tween.round;e.eased=e.tween.easing(Math.min(Math.max(a-e.tween.start-e.tween.delay,0),e.tween.duration)/e.tween.duration,e.tween.elasticity);n=X(e.tween.to.numbers.map(function(a){return function(b,c){c=a.isPath$0?0:a.tween.from.numbers[c];b=c+a.eased*(b-c);a.isPath$0&&(b=W(a.tween.value,
b));a.round&&(b=Math.round(b*a.round)/a.round);return b}}(e)),e.tween.to.strings);ha[g.type](h.target,g.property,n,c,h.id);g.currentValue=n;b++;e={isPath$0:e.isPath$0,tween:e.tween,eased:e.eased,round:e.round}}if(c)for(var k in c)D||(D=B(document.body,"transform")?"transform":"-webkit-transform"),f.animatables[k].target.style[D]=c[k].join(" ");f.currentTime=a;f.progress=a/f.duration*100}function e(a){if(f[a])f[a](f)}function g(){f.remaining&&!0!==f.remaining&&f.remaining--}function h(a){var h=f.duration,
k=f.offset,m=f.delay,O=f.currentTime,p=f.reversed,q=c(a),q=Math.min(Math.max(q,0),h);q>k&&q<h?(d(q),!f.began&&q>=m&&(f.began=!0,e("begin")),e("run")):(q<=k&&0!==O&&(d(0),p&&g()),q>=h&&O!==h&&(d(h),p||g()));a>=h&&(f.remaining?(t=n,"alternate"===f.direction&&(f.reversed=!f.reversed)):(f.pause(),P(),Q=b(),f.completed||(f.completed=!0,e("complete"))),l=0);if(f.children)for(a=f.children,h=0;h<a.length;h++)a[h].seek(q);e("update")}a=void 0===a?{}:a;var n,t,l=0,P=null,Q=b(),f=ea(a);f.reset=function(){var a=
f.direction,b=f.loop;f.currentTime=0;f.progress=0;f.paused=!0;f.began=!1;f.completed=!1;f.reversed="reverse"===a;f.remaining="alternate"===a&&1===b?2:b};f.tick=function(a){n=a;t||(t=n);h((l+n-t)*m.speed)};f.seek=function(a){h(c(a))};f.pause=function(){var a=p.indexOf(f);-1<a&&p.splice(a,1);f.paused=!0};f.play=function(){f.paused&&(f.paused=!1,t=0,l=f.completed?0:c(f.currentTime),p.push(f),y||ia())};f.reverse=function(){f.reversed=!f.reversed;t=0;l=c(f.currentTime)};f.restart=function(){f.pause();
f.reset();f.play()};f.finished=Q;f.reset();f.autoplay&&f.play();return f}var fa={update:void 0,begin:void 0,run:void 0,complete:void 0,loop:1,direction:"normal",autoplay:!0,offset:0},ga={duration:1E3,delay:0,easing:"easeOutElastic",elasticity:500,round:0},U="translateX translateY translateZ rotate rotateX rotateY rotateZ scale scaleX scaleY scaleZ skewX skewY".split(" "),D,g={arr:function(a){return Array.isArray(a)},obj:function(a){return-1<Object.prototype.toString.call(a).indexOf("Object")},svg:function(a){return a instanceof
SVGElement},dom:function(a){return a.nodeType||g.svg(a)},str:function(a){return"string"===typeof a},fnc:function(a){return"function"===typeof a},und:function(a){return"undefined"===typeof a},hex:function(a){return/(^#[0-9A-F]{6}$)|(^#[0-9A-F]{3}$)/i.test(a)},rgb:function(a){return/^rgb/.test(a)},hsl:function(a){return/^hsl/.test(a)},col:function(a){return g.hex(a)||g.rgb(a)||g.hsl(a)}},x=function(){function a(a,c,d){return(((1-3*d+3*c)*a+(3*d-6*c))*a+3*c)*a}return function(b,c,d,e){if(0<=b&&1>=b&&
0<=d&&1>=d){var g=new Float32Array(11);if(b!==c||d!==e)for(var h=0;11>h;++h)g[h]=a(.1*h,b,d);return function(h){if(b===c&&d===e)return h;if(0===h)return 0;if(1===h)return 1;for(var k=0,l=1;10!==l&&g[l]<=h;++l)k+=.1;--l;var l=k+(h-g[l])/(g[l+1]-g[l])*.1,n=3*(1-3*d+3*b)*l*l+2*(3*d-6*b)*l+3*b;if(.001<=n){for(k=0;4>k;++k){n=3*(1-3*d+3*b)*l*l+2*(3*d-6*b)*l+3*b;if(0===n)break;var m=a(l,b,d)-h,l=l-m/n}h=l}else if(0===n)h=l;else{var l=k,k=k+.1,f=0;do m=l+(k-l)/2,n=a(m,b,d)-h,0<n?k=m:l=m;while(1e-7<Math.abs(n)&&
10>++f);h=m}return a(h,c,e)}}}}(),M=function(){function a(a,b){return 0===a||1===a?a:-Math.pow(2,10*(a-1))*Math.sin(2*(a-1-b/(2*Math.PI)*Math.asin(1))*Math.PI/b)}var b="Quad Cubic Quart Quint Sine Expo Circ Back Elastic".split(" "),c={In:[[.55,.085,.68,.53],[.55,.055,.675,.19],[.895,.03,.685,.22],[.755,.05,.855,.06],[.47,0,.745,.715],[.95,.05,.795,.035],[.6,.04,.98,.335],[.6,-.28,.735,.045],a],Out:[[.25,.46,.45,.94],[.215,.61,.355,1],[.165,.84,.44,1],[.23,1,.32,1],[.39,.575,.565,1],[.19,1,.22,1],
[.075,.82,.165,1],[.175,.885,.32,1.275],function(b,c){return 1-a(1-b,c)}],InOut:[[.455,.03,.515,.955],[.645,.045,.355,1],[.77,0,.175,1],[.86,0,.07,1],[.445,.05,.55,.95],[1,0,0,1],[.785,.135,.15,.86],[.68,-.55,.265,1.55],function(b,c){return.5>b?a(2*b,c)/2:1-a(-2*b+2,c)/2}]},d={linear:x(.25,.25,.75,.75)},e={},k;for(k in c)e.type=k,c[e.type].forEach(function(a){return function(c,e){d["ease"+a.type+b[e]]=g.fnc(c)?c:x.apply($jscomp$this,c)}}(e)),e={type:e.type};return d}(),ha={css:function(a,b,c){return a.style[b]=
c},attribute:function(a,b,c){return a.setAttribute(b,c)},object:function(a,b,c){return a[b]=c},transform:function(a,b,c,d,e){d[e]||(d[e]=[]);d[e].push(b+"("+c+")")}},p=[],y=0,ia=function(){function a(){y=requestAnimationFrame(b)}function b(b){var c=p.length;if(c){for(var e=0;e<c;)p[e]&&p[e].tick(b),e++;a()}else cancelAnimationFrame(y),y=0}return a}();m.version="2.0.1";m.speed=1;m.running=p;m.remove=function(a){a=L(a);for(var b=p.length-1;0<=b;b--)for(var c=p[b],d=c.animations,e=d.length-1;0<=e;e--)E(a,
d[e].animatable.target)&&(d.splice(e,1),d.length||c.pause())};m.getValue=I;m.path=function(a,b){var c=g.str(a)?u(a)[0]:a,d=b||100;return function(a){return{el:c,property:a,totalLength:c.getTotalLength()*(d/100)}}};m.setDashoffset=function(a){var b=a.getTotalLength();a.setAttribute("stroke-dasharray",b);return b};m.bezier=x;m.easings=M;m.timeline=function(a){var b=m(a);b.duration=0;b.children=[];b.add=function(a){v(a).forEach(function(a){var c=a.offset,d=b.duration;a.autoplay=!1;a.offset=g.und(c)?
d:J(c,d);a=m(a);a.duration>d&&(b.duration=a.duration);b.children.push(a)});return b};return b};m.random=function(a,b){return Math.floor(Math.random()*(b-a+1))+a};return m});