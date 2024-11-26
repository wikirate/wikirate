// confirm.js.coffee
(function() {
  var answerReadyForYearChange, changeHiddenName, changeToYear, changeYearInAnswerForm, changeYearInMetricLinks, changeYearInSourceFilter, clearTab, confirmYearChange, editInProgress, fromResearched, tabPane, toResearched;

  $(document).ready(function() {
    $(".research-layout .tab-pane-answer_phase").on("change", "input, textarea, select", function() {
      return $(".research-answer .card-form").data("changed", true);
    });
    $(".research-layout").on("click", "._research-metric-link, .research-answer-button", function(e) {
      var leave;
      if (!editInProgress()) {
        return;
      }
      e.preventDefault();
      leave = $("#confirmLeave");
      leave.trigger("click");
      return leave.data("confirmHref", $(this).attr("href"));
    });
    $(".research-layout").on("click", "._yes_leave", function() {
      return window.location.href = $("#confirmLeave").data("confirmHref");
    });
    $(".research-layout").on("click", "._yes_year", function() {
      var year;
      year = $("#confirmYear").data("year");
      changeToYear(year);
      return clearTab("answer");
    });
    return $("body").on("click", "._research-year-option, ._research-year-option input", function(e) {
      var input, year;
      input = $(this);
      if (!input.is("input")) {
        input = input.find("input");
      }
      year = input.val();
      if (answerReadyForYearChange(input)) {
        return changeToYear(year);
      } else {
        return confirmYearChange(e, year);
      }
    });
  });

  changeToYear = function(year) {
    $("._research-" + year + " input").prop("checked", true);
    changeYearInSourceFilter(year);
    return changeYearInMetricLinks(year);
  };

  editInProgress = function() {
    return $(".research-answer .card-form").data("changed");
  };

  answerReadyForYearChange = function(input) {
    if (editInProgress()) {
      return changeYearInAnswerForm(input);
    } else {
      clearTab("answer");
      return true;
    }
  };

  changeYearInAnswerForm = function(input) {
    var answerName;
    if (fromResearched() || toResearched(input)) {
      return false;
    }
    answerName = tabPane("answer").find("#new_card input#card_name");
    changeHiddenName(answerName, input.val());
    return true;
  };

  changeYearInSourceFilter = function(year) {
    if ($(".RIGHT-source ._compact-filter")[0]) {
      return decko.compactFilter(".RIGHT-source ._compact-filter").addRestrictions({
        year: year
      });
    }
  };

  changeYearInMetricLinks = function(year) {
    return $("._research-metric-link").each(function() {
      var link, url;
      link = $(this);
      url = new URL(link.prop("href"));
      url.searchParams.set("year", year);
      return link.prop("href", url.toString());
    });
  };

  changeHiddenName = function(nameField, year) {
    var newName;
    newName = nameField.val().replace(/\d{4}$/, year);
    return nameField.val(newName);
  };

  fromResearched = function() {
    return tabPane("answer").find(".edit_inline-view")[0];
  };

  toResearched = function(input) {
    return !input.closest("._research-year-option").find(".not-researched")[0];
  };

  clearTab = function(phase) {
    var link;
    link = deckorate.tabPhase(phase);
    link.addClass("load");
    return tabPane(phase).html("");
  };

  tabPane = function(phase) {
    return $(".tab-pane-" + phase + "_phase");
  };

  confirmYearChange = function(event, year) {
    var link;
    link = $("#confirmYear");
    link.trigger("click");
    link.data("year", year);
    event.preventDefault();
    return event.stopPropagation();
  };

}).call(this);

// jpages.js
/**
 * jQuery jPages v0.7
 * Client side pagination with jQuery
 * http://luis-almeida.github.com/jPages
 *
 * Licensed under the MIT license.
 * Copyright 2012 Luís Almeida
 * https://github.com/luis-almeida
 */


;(function($, window, document, undefined) {
        var name = "jPages",
            instance = null,
            defaults = {
                    containerID: "",
                    first: false,
                    previous: "← previous",
                    next: "next →",
                    last: false,
                    links: "numeric", // blank || title
                    startPage: 1,
                    perPage: 10,
                    midRange: 5,
                    startRange: 1,
                    endRange: 1,
                    keyBrowse: false,
                    scrollBrowse: false,
                    pause: 0,
                    clickStop: false,
                    delay: 50,
                    direction: "forward", // backwards || auto || random ||
                    animation: "", // http://daneden.me/animate/ - any entrance animations
                    fallback: 400,
                    minHeight: true,
                    callback: undefined // function( pages, items ) { }
            };


        function Plugin(element, options) {
                this.options = $.extend({}, defaults, options);

                this._container = $("#" + this.options.containerID);
                if (!this._container.length) return;

                this.jQwindow = $(window);
                this.jQdocument = $(document);

                this._holder = $(element);
                this._nav = {};

                this._first = $(this.options.first);
                this._previous = $(this.options.previous);
                this._next = $(this.options.next);
                this._last = $(this.options.last);

                /* only visible items! */
                this._items = this._container.children(":visible");
                this._itemsShowing = $([]);
                this._itemsHiding = $([]);

                this._numPages = Math.ceil(this._items.length / this.options.perPage);
                this._currentPageNum = this.options.startPage;

                this._clicked = false;
                this._cssAnimSupport = this.getCSSAnimationSupport();

                this.init();
        }

        Plugin.prototype = {

                constructor : Plugin,

                getCSSAnimationSupport : function() {
                        var animation = false,
                            animationstring = 'animation',
                            keyframeprefix = '',
                            domPrefixes = 'Webkit Moz O ms Khtml'.split(' '),
                            pfx = '',
                            elm = this._container.get(0);

                        if (elm.style.animationName) animation = true;

                        if (animation === false) {
                                for (var i = 0; i < domPrefixes.length; i++) {
                                        if (elm.style[domPrefixes[i] + 'AnimationName'] !== undefined) {
                                                pfx = domPrefixes[i];
                                                animationstring = pfx + 'Animation';
                                                keyframeprefix = '-' + pfx.toLowerCase() + '-';
                                                animation = true;
                                                break;
                                        }
                                }
                        }

                        return animation;
                },

                init : function() {
                        this.setStyles();
                        this.setNav();
                        this.paginate(this._currentPageNum);
                        this.setMinHeight();
                },

                setStyles : function() {
                        var requiredStyles = "<style>" +
                            ".jp-invisible { visibility: hidden !important; } " +
                            ".jp-hidden { display: none !important; }" +
                            "</style>";

                        $(requiredStyles).appendTo("head");

                        if (this._cssAnimSupport && this.options.animation.length)
                                this._items.addClass("animated jp-hidden");
                        else this._items.hide();

                },

                setNav : function() {
                        var navhtml = this.writeNav();

                        this._holder.each(this.bind(function(index, element) {
                                var holder = $(element);
                                holder.html(navhtml);
                                this.cacheNavElements(holder, index);
                                this.bindNavHandlers(index);
                                this.disableNavSelection(element);
                        }, this));

                        if (this.options.keyBrowse) this.bindNavKeyBrowse();
                        if (this.options.scrollBrowse) this.bindNavScrollBrowse();
                },

                writeNav : function() {
                        var i = 1, navhtml;
                        navhtml = this.writeBtn("first") + this.writeBtn("previous");

                        for (; i <= this._numPages; i++) {
                                if (i === 1 && this.options.startRange === 0) navhtml += "<span class='p-2'>...</span>";
                                if (i > this.options.startRange && i <= this._numPages - this.options.endRange)
                                        navhtml += "<a href='#' class='page-link jp-hidden'>";
                                else
                                        navhtml += "<a href= '#' class='page-link'>";

                                switch (this.options.links) {
                                        case "numeric":
                                                navhtml += i;
                                                break;
                                        case "blank":
                                                break;
                                        case "title":
                                                var title = this._items.eq(i - 1).attr("data-title");
                                                navhtml += title !== undefined ? title : "";
                                                break;
                                }

                                navhtml += "</a>";
                                if (i === this.options.startRange || i === this._numPages - this.options.endRange)
                                        navhtml += "<span class='p-2'>...</span>";
                        }
                        navhtml += this.writeBtn("next") + this.writeBtn("last") + "</div>";
                        return navhtml;
                },

                writeBtn : function(which) {

                        return this.options[which] !== false && !$(this["_" + which]).length ?
                            "<a class='page-link jp-" + which + "'>" + this.options[which] + "</a>" : "";

                },

                cacheNavElements : function(holder, index) {
                        this._nav[index] = {};
                        this._nav[index].holder = holder;
                        this._nav[index].first = this._first.length ? this._first : this._nav[index].holder.find("a.jp-first");
                        this._nav[index].previous = this._previous.length ? this._previous : this._nav[index].holder.find("a.jp-previous");
                        this._nav[index].next = this._next.length ? this._next : this._nav[index].holder.find("a.jp-next");
                        this._nav[index].last = this._last.length ? this._last : this._nav[index].holder.find("a.jp-last");
                        this._nav[index].fstBreak = this._nav[index].holder.find("span:first");
                        this._nav[index].lstBreak = this._nav[index].holder.find("span:last");
                        this._nav[index].pages = this._nav[index].holder.find("a").not(".jp-first, .jp-previous, .jp-next, .jp-last");
                        this._nav[index].permPages =
                            this._nav[index].pages.slice(0, this.options.startRange)
                                .add(this._nav[index].pages.slice(this._numPages - this.options.endRange, this._numPages));
                        this._nav[index].pagesShowing = $([]);
                        this._nav[index].currentPage = $([]);
                },

                bindNavHandlers : function(index) {
                        var nav = this._nav[index];

                        // default nav
                        nav.holder.bind("click.jPages", this.bind(function(evt) {
                                var newPage = this.getNewPage(nav, $(evt.target));
                                if (this.validNewPage(newPage)) {
                                        this._clicked = true;
                                        this.paginate(newPage);
                                }
                                evt.preventDefault();
                        }, this));

                        // custom first
                        if (this._first.length) {
                                this._first.bind("click.jPages", this.bind(function() {
                                        if (this.validNewPage(1)) {
                                                this._clicked = true;
                                                this.paginate(1);
                                        }
                                }, this));
                        }

                        // custom previous
                        if (this._previous.length) {
                                this._previous.bind("click.jPages", this.bind(function() {
                                        var newPage = this._currentPageNum - 1;
                                        if (this.validNewPage(newPage)) {
                                                this._clicked = true;
                                                this.paginate(newPage);
                                        }
                                }, this));
                        }

                        // custom next
                        if (this._next.length) {
                                this._next.bind("click.jPages", this.bind(function() {
                                        var newPage = this._currentPageNum + 1;
                                        if (this.validNewPage(newPage)) {
                                                this._clicked = true;
                                                this.paginate(newPage);
                                        }
                                }, this));
                        }

                        // custom last
                        if (this._last.length) {
                                this._last.bind("click.jPages", this.bind(function() {
                                        if (this.validNewPage(this._numPages)) {
                                                this._clicked = true;
                                                this.paginate(this._numPages);
                                        }
                                }, this));
                        }

                },

                disableNavSelection : function(element) {
                        if (typeof element.onselectstart != "undefined")
                                element.onselectstart = function() {
                                        return false;
                                };
                        else if (typeof element.style.MozUserSelect != "undefined")
                                element.style.MozUserSelect = "none";
                        else
                                element.onmousedown = function() {
                                        return false;
                                };
                },

                bindNavKeyBrowse : function() {
                        this.jQdocument.bind("keydown.jPages", this.bind(function(evt) {
                                var target = evt.target.nodeName.toLowerCase();
                                if (this.elemScrolledIntoView() && target !== "input" && target != "textarea") {
                                        var newPage = this._currentPageNum;

                                        if (evt.which == 37) newPage = this._currentPageNum - 1;
                                        if (evt.which == 39) newPage = this._currentPageNum + 1;

                                        if (this.validNewPage(newPage)) {
                                                this._clicked = true;
                                                this.paginate(newPage);
                                        }
                                }
                        }, this));
                },

                elemScrolledIntoView : function() {
                        var docViewTop, docViewBottom, elemTop, elemBottom;
                        docViewTop = this.jQwindow.scrollTop();
                        docViewBottom = docViewTop + this.jQwindow.height();
                        elemTop = this._container.offset().top;
                        elemBottom = elemTop + this._container.height();
                        return ((elemBottom >= docViewTop) && (elemTop <= docViewBottom));

                        // comment above and uncomment below if you want keyBrowse to happen
                        // only when container is completely visible in the page
                        /*return ((elemBottom >= docViewTop) && (elemTop <= docViewBottom) &&
                                  (elemBottom <= docViewBottom) &&  (elemTop >= docViewTop) );*/
                },

                bindNavScrollBrowse : function() {
                        this._container.bind("mousewheel.jPages DOMMouseScroll.jPages", this.bind(function(evt) {
                                var newPage = (evt.originalEvent.wheelDelta || -evt.originalEvent.detail) > 0 ?
                                    (this._currentPageNum - 1) : (this._currentPageNum + 1);
                                if (this.validNewPage(newPage)) {
                                        this._clicked = true;
                                        this.paginate(newPage);
                                }
                                evt.preventDefault();
                                return false;
                        }, this));
                },

                getNewPage : function(nav, target) {
                        if (target.is(nav.currentPage)) return this._currentPageNum;
                        if (target.is(nav.pages)) return nav.pages.index(target) + 1;
                        if (target.is(nav.first)) return 1;
                        if (target.is(nav.last)) return this._numPages;
                        if (target.is(nav.previous)) return nav.pages.index(nav.currentPage);
                        if (target.is(nav.next)) return nav.pages.index(nav.currentPage) + 2;
                },

                validNewPage : function(newPage) {
                        return newPage !== this._currentPageNum && newPage > 0 && newPage <= this._numPages;
                },

                paginate : function(page) {
                        var itemRange, pageInterval;
                        itemRange = this.updateItems(page);
                        pageInterval = this.updatePages(page);
                        this._currentPageNum = page;
                        if ($.isFunction(this.options.callback))
                                this.callback(page, itemRange, pageInterval);

                        this.updatePause();
                },

                updateItems : function(page) {
                        var range = this.getItemRange(page);
                        this._itemsHiding = this._itemsShowing;
                        this._itemsShowing = this._items.slice(range.start, range.end);
                        if (this._cssAnimSupport && this.options.animation.length) this.cssAnimations(page);
                        else this.jQAnimations(page);
                        return range;
                },

                getItemRange : function(page) {
                        var range = {};
                        range.start = (page - 1) * this.options.perPage;
                        range.end = range.start + this.options.perPage;
                        if (range.end > this._items.length) range.end = this._items.length;
                        return range;
                },

                cssAnimations : function(page) {
                        clearInterval(this._delay);

                        this._itemsHiding
                            .removeClass(this.options.animation + " jp-invisible")
                            .addClass("jp-hidden");

                        this._itemsShowing
                            .removeClass("jp-hidden")
                            .addClass("jp-invisible");

                        this._itemsOriented = this.getDirectedItems(page);
                        this._index = 0;

                        this._delay = setInterval(this.bind(function() {
                                if (this._index === this._itemsOriented.length) clearInterval(this._delay);
                                else {
                                        this._itemsOriented
                                            .eq(this._index)
                                            .removeClass("jp-invisible")
                                            .addClass(this.options.animation);
                                }
                                this._index = this._index + 1;
                        }, this), this.options.delay);
                },

                jQAnimations : function(page) {
                        clearInterval(this._delay);
                        this._itemsHiding.addClass("jp-hidden");
                        this._itemsShowing.fadeTo(0, 0).removeClass("jp-hidden");
                        this._itemsOriented = this.getDirectedItems(page);
                        this._index = 0;
                        this._delay = setInterval(this.bind(function() {
                                if (this._index === this._itemsOriented.length) clearInterval(this._delay);
                                else {
                                        this._itemsOriented
                                            .eq(this._index)
                                            .fadeTo(this.options.fallback, 1);
                                }
                                this._index = this._index + 1;
                        }, this), this.options.delay);
                },

                getDirectedItems : function(page) {
                        var itemsToShow;

                        switch (this.options.direction) {
                                case "backwards":
                                        itemsToShow = $(this._itemsShowing.get().reverse());
                                        break;
                                case "random":
                                        itemsToShow = $(this._itemsShowing.get().sort(function() {
                                                return (Math.round(Math.random()) - 0.5);
                                        }));
                                        break;
                                case "auto":
                                        itemsToShow = page >= this._currentPageNum ?
                                            this._itemsShowing : $(this._itemsShowing.get().reverse());
                                        break;
                                default:
                                        itemsToShow = this._itemsShowing;
                        }

                        return itemsToShow;
                },

                updatePages : function(page) {
                        var interval, index, nav;
                        interval = this.getInterval(page);
                        for (index in this._nav) {
                                if (this._nav.hasOwnProperty(index)) {
                                        nav = this._nav[index];
                                        this.updateBtns(nav, page);
                                        this.updateCurrentPage(nav, page);
                                        this.updatePagesShowing(nav, interval);
                                        this.updateBreaks(nav, interval);
                                }
                        }
                        return interval;
                },

                getInterval : function(page) {
                        var neHalf, upperLimit, start, end;
                        neHalf = Math.ceil(this.options.midRange / 2);
                        upperLimit = this._numPages - this.options.midRange;
                        start = page > neHalf ? Math.max(Math.min(page - neHalf, upperLimit), 0) : 0;
                        end = page > neHalf ?
                            Math.min(page + neHalf - (this.options.midRange % 2 > 0 ? 1 : 0), this._numPages) :
                            Math.min(this.options.midRange, this._numPages);
                        return {start: start,end: end};
                },

                updateBtns : function(nav, page) {
                        if (page === 1) {
                                nav.first.addClass("jp-disabled");
                                nav.previous.addClass("jp-disabled");
                        }
                        if (page === this._numPages) {
                                nav.next.addClass("jp-disabled");
                                nav.last.addClass("jp-disabled");
                        }
                        if (this._currentPageNum === 1 && page > 1) {
                                nav.first.removeClass("jp-disabled");
                                nav.previous.removeClass("jp-disabled");
                        }
                        if (this._currentPageNum === this._numPages && page < this._numPages) {
                                nav.next.removeClass("jp-disabled");
                                nav.last.removeClass("jp-disabled");
                        }
                },

                updateCurrentPage : function(nav, page) {
                        nav.currentPage.removeClass("jp-current");
                        nav.currentPage = nav.pages.eq(page - 1).addClass("jp-current");
                },

                updatePagesShowing : function(nav, interval) {
                        var newRange = nav.pages.slice(interval.start, interval.end).not(nav.permPages);
                        nav.pagesShowing.not(newRange).addClass("jp-hidden");
                        newRange.not(nav.pagesShowing).removeClass("jp-hidden");
                        nav.pagesShowing = newRange;
                },

                updateBreaks : function(nav, interval) {
                        if (
                            interval.start > this.options.startRange ||
                            (this.options.startRange === 0 && interval.start > 0)
                        ) nav.fstBreak.removeClass("jp-hidden");
                        else nav.fstBreak.addClass("jp-hidden");

                        if (interval.end < this._numPages - this.options.endRange) nav.lstBreak.removeClass("jp-hidden");
                        else nav.lstBreak.addClass("jp-hidden");
                },

                callback : function(page, itemRange, pageInterval) {
                        var pages = {
                                    current: page,
                                    interval: pageInterval,
                                    count: this._numPages
                            },
                            items = {
                                    showing: this._itemsShowing,
                                    oncoming: this._items.slice(itemRange.start + this.options.perPage, itemRange.end + this.options.perPage),
                                    range: itemRange,
                                    count: this._items.length
                            };

                        pages.interval.start = pages.interval.start + 1;
                        items.range.start = items.range.start + 1;
                        this.options.callback(pages, items);
                },

                updatePause : function() {
                        if (this.options.pause && this._numPages > 1) {
                                clearTimeout(this._pause);
                                if (this.options.clickStop && this._clicked) return;
                                else {
                                        this._pause = setTimeout(this.bind(function() {
                                                this.paginate(this._currentPageNum !== this._numPages ? this._currentPageNum + 1 : 1);
                                        }, this), this.options.pause);
                                }
                        }
                },

                setMinHeight : function() {
                        if (this.options.minHeight && !this._container.is("table, tbody")) {
                                setTimeout(this.bind(function() {
                                        this._container.css({ "min-height": this._container.css("height") });
                                }, this), 1000);
                        }
                },

                bind : function(fn, me) {
                        return function() {
                                return fn.apply(me, arguments);
                        };
                },

                destroy : function() {
                        this.jQdocument.unbind("keydown.jPages");
                        this._container.unbind("mousewheel.jPages DOMMouseScroll.jPages");

                        if (this.options.minHeight) this._container.css("min-height", "");
                        if (this._cssAnimSupport && this.options.animation.length)
                                this._items.removeClass("animated jp-hidden jp-invisible " + this.options.animation);
                        else this._items.removeClass("jp-hidden").fadeTo(0, 1);
                        this._holder.unbind("click.jPages").empty();
                }

        };

        $.fn[name] = function(arg) {
                var type = $.type(arg);

                if (type === "object") {
                        if (this.length && !$.data(this, name)) {
                                instance = new Plugin(this, arg);
                                this.each(function() {
                                        $.data(this, name, instance);
                                });
                        }
                        return this;
                }

                if (type === "string" && arg === "destroy") {
                        instance.destroy();
                        this.each(function() {
                                $.removeData(this, name);
                        });
                        return this;
                }

                if (type === 'number' && arg % 1 === 0) {
                        if (instance.validNewPage(arg)) instance.paginate(arg);
                        return this;
                }

                return this;
        };

})(jQuery, window, document);
// research.js.coffee
(function() {
  var addSourceItem, addToSourceContent, appendToDataUrl, appendToHref, appendToUrl, citedSources, closeSourceModal, demandYear, initialUrl, openAnswerFormBeforeAddingSource, openPdf, reloadSourceSlot, researchPath, revealOverlay, selectedSource, selectedYear, selectedYearInput, selectedYearNotResearched, tabPhase, toPhase, whenAvailable;

  decko.editors.init["._removable-content-list ul"] = function() {
    return this.sortable({
      handle: '._handle',
      cancel: ''
    });
  };

  decko.editors.content["._removable-content-list ul"] = function() {
    var itemNames;
    itemNames = $(this).find("._removable-content-item").map(function() {
      return $(this).data("cardName");
    });
    return decko.pointerContent($.unique(itemNames));
  };

  decko.slot.ready(function(slot) {
    var btn, newSource, success_in_project;
    if (slot.closest(".research-layout")[0]) {
      if (slot.hasClass("_overlay")) {
        revealOverlay(slot);
      }
      newSource = slot.find("._new_source");
      if (newSource.length) {
        closeSourceModal(slot);
        (new decko.compactFilter($(".RIGHT-source.filtered_content-view ._compact-filter"))).update();
      }
      if (slot.find("#jPages")[0]) {
        $("#jPages").jPages({
          containerID: "research-year-list",
          perPage: 5,
          previous: false,
          next: false
        });
      }
      if (slot.hasClass("edit_inline-view") && $("#_select_source").data("stash")) {
        $("#_select_source").data("stash", false);
        addSourceItem();
      }
      success_in_project = slot.find(".answer-success-in-project");
      if (success_in_project[0] && $("._company-project-research")[0]) {
        success_in_project.show();
      }
      btn = $("._next-question-button");
      if (btn.length && slot.find("._edit-answer-button").length) {
        btn = btn.clone();
        return slot.find("._research-buttons").append(btn);
      }
    }
  });

  $(document).ready(function() {
    var researchTabSelector;
    $("body").on("click", "#_select_year", function(e) {
      var phase;
      if (!selectedYear()) {
        return;
      }
      phase = selectedYearNotResearched() && "source" || "answer";
      return toPhase(phase, e);
    });
    $("body").on("click", "._to_question_phase", function(e) {
      return toPhase("question", e);
    });
    $("body").on("click", "._to_source_phase", function(e) {
      return toPhase("source", e);
    });
    $("body").on("click", "#_select_source", function(event) {
      if (!tabPhase("answer").hasClass("load")) {
        addSourceItem();
      }
      return toPhase("answer", event);
    });
    $("body").on("click", "._add_source_modal_link", function() {
      var link, params;
      link = $(this);
      params = link.data("sourceFields");
      params._Year = selectedYear;
      return appendToHref(link, params);
    });
    $('.research-layout #main').on('click', ".TYPE-source.box, .TYPE-source.bar", function(e) {
      if ($(this).data("skip") !== "on") {
        toPhase("source", e);
        e.stopPropagation();
        return openPdf($(this).data("cardName"));
      }
    });
    $('body').on('click', '._remove-removable', function() {
      return $(this).closest('li').remove();
    });
    $(".research-layout #main").on("click", '[data-bs-dismiss="overlay"]', function(e) {
      var el;
      el = $(this);
      el.overlaySlot().hide("slide", {
        direction: "down",
        complete: function() {
          return el.removeOverlay();
        }
      }, 600);
      return e.stopPropagation();
    });
    researchTabSelector = ".research-layout #main .nav-item:not(.tab-li-question_phase)";
    $(researchTabSelector).on("show.bs.tab", ".nav-link", function(e) {
      if (!$(this).hasClass("load")) {
        return;
      }
      if (!selectedYear()) {
        return demandYear(e);
      } else {
        return appendToDataUrl($(this), {
          year: selectedYear(),
          source: selectedSource()
        });
      }
    });
    $(".research-layout").on("click", "._copy_caught_source", function(e) {
      var link, sourceMark;
      link = $(this);
      sourceMark = link.data("cardName");
      closeSourceModal(link);
      openPdf(sourceMark);
      return e.preventDefault();
    });
    $(".research-layout").on("click", "._methodology-link", function(e) {
      toPhase("question", e);
      return $("._methodology-button").click();
    });
    return $("body").on("click", "._metric_arrow_button", function(e) {
      return $(this).slot().slotReloading();
    });
  });

  closeSourceModal = function(el) {
    return bootstrap.Modal.getInstance(el.closest("._modal-slot")).hide();
  };

  appendToUrl = function(url, params) {
    var joiner;
    joiner = url.match(/\?/) && "&" || "?";
    return url + joiner + $.param(params);
  };

  appendToDataUrl = function(link, params) {
    var url;
    url = initialUrl(link, link.data("url"));
    return link.data("url", appendToUrl(url, params));
  };

  appendToHref = function(link, params) {
    var href;
    href = initialUrl(link, link.attr("href"));
    return link.attr("href", appendToUrl(href, params));
  };

  demandYear = function(event) {
    alert("Please select a year");
    event.preventDefault();
    return event.stopPropagation();
  };

  toPhase = function(phase, event) {
    (new bootstrap.Tab(tabPhase(phase))).show();
    return event.preventDefault();
  };

  tabPhase = function(phase) {
    return $(".tab-li-" + phase + "_phase a");
  };

  addSourceItem = function() {
    var ed, slot, sourceContent;
    if (openAnswerFormBeforeAddingSource()) {
      return;
    }
    ed = $(".RIGHT-source.card-editor");
    sourceContent = addToSourceContent(ed, selectedSource());
    slot = ed.find(".card-slot.removable_content-view");
    return reloadSourceSlot(slot, sourceContent);
  };

  openAnswerFormBeforeAddingSource = function() {
    var edit_answer;
    edit_answer = $("._edit-answer-button");
    if (!edit_answer[0]) {
      return false;
    }
    edit_answer.trigger("click");
    $("#_select_source").data("stash", true);
    return true;
  };

  addToSourceContent = function(editor, source) {
    var content, sources;
    sources = citedSources();
    sources.push(source);
    content = decko.pointerContent($.uniqueSort(sources));
    editor.find(".d0-card-content").val(content);
    return content;
  };

  reloadSourceSlot = function(slot, content) {
    var query;
    query = $.param({
      assign: true,
      card: {
        content: content
      }
    });
    return slot.slotReload((slot.data('cardLinkName')) + "?" + query);
  };

  selectedSource = function() {
    return $("#_select_source").data("source");
  };

  citedSources = function() {
    return $(".RIGHT-source .bar").map(function() {
      return $(this).data("cardName");
    });
  };

  selectedYear = function() {
    return selectedYearInput().val() || $(".answer-breadcrumb .year").html();
  };

  selectedYearNotResearched = function() {
    return selectedYearInput().closest("._research-year-option").find("._not-researched")[0];
  };

  selectedYearInput = function() {
    return $("input[name='year']:checked");
  };

  initialUrl = function(link, url) {
    if (!link.data("initialUrl")) {
      link.data("initialUrl", url);
    }
    return link.data("initialUrl");
  };

  revealOverlay = function(overlay) {
    overlay.hide();
    $("html, body").animate({
      scrollTop: 0
    }, 300);
    $(window).scrollTop;
    return overlay.show("slide", {
      direction: "down"
    }, 600);
  };

  researchPath = function(view) {
    var path;
    path = window.location.pathname.replace(/\/\w+$/, "");
    return decko.path(path + "/" + view);
  };

  openPdf = function(sourceMark) {
    return whenAvailable(".source_phase-view", function() {
      var el, params, url;
      el = $(".source_phase-view");
      if (sourceMark !== selectedSource) {
        params = {
          source: sourceMark
        };
        if (citedSources().toArray().includes(sourceMark)) {
          params["slot"] = {
            hide: "select_source_button"
          };
        }
        url = researchPath("source_selector") + "?" + $.param(params);
        el.addClass("slotter");
        el[0].href = url;
        return $.rails.handleRemote(el);
      }
    });
  };

  whenAvailable = function(selector, callback, maxTimes) {
    if (maxTimes == null) {
      maxTimes = 100;
    }
    if (jQuery(selector).length) {
      return callback();
    } else if (maxTimes === false || maxTimes > 0) {
      (maxTimes !== false) && maxTimes--;
      return setTimeout((function() {
        return whenAvailable(selector, callback, maxTimes);
      }), 100);
    }
  };

  deckorate.tabPhase = tabPhase;

}).call(this);

// sources.js.coffee
(function() {
  $(document).ready(function() {
    $('body').on('click', "._toggle-source-option", function() {
      $('.download-option input').val("");
      $('.source-option').show();
      return $(this).closest('.source-option').hide();
    });
    $("body").on("change", ".RIGHT-file .download-option .d0-card-content", function() {
      var catcher, el;
      el = $(this);
      catcher = el.slot().find(".copy_catcher-view");
      return catcher.slotReload(catcher.slotUrl() + "&" + $.param({
        url: el.val()
      }));
    });
    return resizeIframe($('body'));
  });

  decko.slot.ready(function(slot) {
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

// unknown.js.coffee
(function() {
  var clearInputValue, clearValue, isUnknown, knownInputSelector, unknownCheckbox, valueEditor;

  decko.editors.content["._unknown-checkbox input:checked"] = function() {
    return this.val();
  };

  decko.slot.ready(function(slot) {
    unknownCheckbox(slot).on("change", function() {
      if ($(this).is(":checked")) {
        return clearValue(valueEditor(slot));
      }
    });
    return valueEditor(slot).find(knownInputSelector + ", select").on("change", function() {
      var unbox;
      unbox = unknownCheckbox(slot);
      if (!(unbox.is(":checked") && !$(this).val())) {
        return unbox.prop("checked", isUnknown($(this)));
      }
    });
  });

  valueEditor = function(el) {
    return el.find(".card-editor.RIGHT-value .content-editor");
  };

  unknownCheckbox = function(el) {
    return el.find("._unknown-checkbox input[type=checkbox]");
  };

  isUnknown = function(el) {
    return el.val().toString().toLowerCase() === 'unknown';
  };

  knownInputSelector = "input:not([name=_unknown]):visible";

  clearValue = function(editor) {
    var select;
    select = editor.find("select");
    if (select[0]) {
      return select.val(null).change();
    } else {
      return clearInputValue(editor);
    }
  };

  clearInputValue = function(editor) {
    return $.each(editor.find(knownInputSelector), function() {
      var input;
      input = $(this);
      if (input.prop("type") === "text") {
        return input.val(null);
      } else {
        return input.prop("checked", false);
      }
    });
  };

}).call(this);
