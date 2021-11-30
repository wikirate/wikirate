// confirm.js.coffee
(function(){var a,n,t,e,c,i,o,u,f,s,d;$(document).ready(function(){return $(".research-layout .tab-pane-answer_phase").on("change","input, textarea, select",function(){return $(".research-answer .card-form").data("changed",!0)}),$(".research-layout").on("click","._research-metric-link, .research-answer-button",function(r){var e;if(u())return r.preventDefault(),(e=$("#confirmLeave")).trigger("click"),e.data("confirmHref",$(this).attr("href"))}),$(".research-layout").on("click","._yes_leave",function(){return window.location.href=$("#confirmLeave").data("confirmHref")}),$(".research-layout").on("click","._yes_year",function(){var r;return r=$("#confirmYear").data("year"),t(r),i("answer")}),$("body").on("click","._research-year-option, ._research-year-option input",function(r){var e,n;return(e=$(this)).is("input")||(e=e.find("input")),n=e.val(),a(e)?t(n):o(r,n)})}),t=function(r){return $("._research-"+r+" input").prop("checked",!0),c(r)},u=function(){return $(".research-answer .card-form").data("changed")},a=function(r){return u()?e(r):(i("answer"),!0)},e=function(r){var e;return!f()&&!d(r)&&(e=s("answer").find("#new_card input#card_name"),n(e,r.val()),!0)},c=function(r){if($(".RIGHT-source ._filter-widget")[0])return decko.filter(".RIGHT-source ._filter-widget").addRestrictions({year:r})},n=function(r,e){var n;return n=r.val().replace(/\d{4}$/,e),r.val(n)},f=function(){return s("answer").find(".edit_inline-view")[0]},d=function(r){return!r.closest("._research-year-option").find(".not-researched")[0]},i=function(r){return wikirate.tabPhase(r).addClass("load"),s(r).html("")},s=function(r){return $(".tab-pane-"+r+"_phase")},o=function(r,e){var n;return(n=$("#confirmYear")).trigger("click"),n.data("year",e),r.preventDefault(),r.stopPropagation()}}).call(this);
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
!function(n,s,e,a){function h(t,i){this.options=n.extend({},d,i),this._container=n("#"+this.options.containerID),this._container.length&&(this.jQwindow=n(s),this.jQdocument=n(e),this._holder=n(t),this._nav={},this._first=n(this.options.first),this._previous=n(this.options.previous),this._next=n(this.options.next),this._last=n(this.options.last),this._items=this._container.children(":visible"),this._itemsShowing=n([]),this._itemsHiding=n([]),this._numPages=Math.ceil(this._items.length/this.options.perPage),this._currentPageNum=this.options.startPage,this._clicked=!1,this._cssAnimSupport=this.getCSSAnimationSupport(),this.init())}var o="jPages",r=null,d={containerID:"",first:!1,previous:"\u2190 previous",next:"next \u2192",last:!1,links:"numeric",startPage:1,perPage:10,midRange:5,startRange:1,endRange:1,keyBrowse:!1,scrollBrowse:!1,pause:0,clickStop:!1,delay:50,direction:"forward",animation:"",fallback:400,minHeight:!0,callback:a};h.prototype={constructor:h,getCSSAnimationSupport:function(){var t=!1,i="Webkit Moz O ms Khtml".split(" "),s="",e=this._container.get(0);if(e.style.animationName&&(t=!0),!1===t)for(var n=0;n<i.length;n++)if(e.style[i[n]+"AnimationName"]!==a){(s=i[n])+"Animation","-"+s.toLowerCase()+"-",t=!0;break}return t},init:function(){this.setStyles(),this.setNav(),this.paginate(this._currentPageNum),this.setMinHeight()},setStyles:function(){n("<style>.jp-invisible { visibility: hidden !important; } .jp-hidden { display: none !important; }</style>").appendTo("head"),this._cssAnimSupport&&this.options.animation.length?this._items.addClass("animated jp-hidden"):this._items.hide()},setNav:function(){var e=this.writeNav();this._holder.each(this.bind(function(t,i){var s=n(i);s.html(e),this.cacheNavElements(s,t),this.bindNavHandlers(t),this.disableNavSelection(i)},this)),this.options.keyBrowse&&this.bindNavKeyBrowse(),this.options.scrollBrowse&&this.bindNavScrollBrowse()},writeNav:function(){var t,i=1;for(t=this.writeBtn("first")+this.writeBtn("previous");i<=this._numPages;i++){switch(1===i&&0===this.options.startRange&&(t+="<span class='p-2'>...</span>"),i>this.options.startRange&&i<=this._numPages-this.options.endRange?t+="<a href='#' class='page-link jp-hidden'>":t+="<a href= '#' class='page-link'>",this.options.links){case"numeric":t+=i;break;case"blank":break;case"title":var s=this._items.eq(i-1).attr("data-title");t+=s!==a?s:""}t+="</a>",i!==this.options.startRange&&i!==this._numPages-this.options.endRange||(t+="<span class='p-2'>...</span>")}return t+=this.writeBtn("next")+this.writeBtn("last")+"</div>"},writeBtn:function(t){return!1===this.options[t]||n(this["_"+t]).length?"":"<a class='page-link jp-"+t+"'>"+this.options[t]+"</a>"},cacheNavElements:function(t,i){this._nav[i]={},this._nav[i].holder=t,this._nav[i].first=this._first.length?this._first:this._nav[i].holder.find("a.jp-first"),this._nav[i].previous=this._previous.length?this._previous:this._nav[i].holder.find("a.jp-previous"),this._nav[i].next=this._next.length?this._next:this._nav[i].holder.find("a.jp-next"),this._nav[i].last=this._last.length?this._last:this._nav[i].holder.find("a.jp-last"),this._nav[i].fstBreak=this._nav[i].holder.find("span:first"),this._nav[i].lstBreak=this._nav[i].holder.find("span:last"),this._nav[i].pages=this._nav[i].holder.find("a").not(".jp-first, .jp-previous, .jp-next, .jp-last"),this._nav[i].permPages=this._nav[i].pages.slice(0,this.options.startRange).add(this._nav[i].pages.slice(this._numPages-this.options.endRange,this._numPages)),this._nav[i].pagesShowing=n([]),this._nav[i].currentPage=n([])},bindNavHandlers:function(t){var s=this._nav[t];s.holder.bind("click.jPages",this.bind(function(t){var i=this.getNewPage(s,n(t.target));this.validNewPage(i)&&(this._clicked=!0,this.paginate(i)),t.preventDefault()},this)),this._first.length&&this._first.bind("click.jPages",this.bind(function(){this.validNewPage(1)&&(this._clicked=!0,this.paginate(1))},this)),this._previous.length&&this._previous.bind("click.jPages",this.bind(function(){var t=this._currentPageNum-1;this.validNewPage(t)&&(this._clicked=!0,this.paginate(t))},this)),this._next.length&&this._next.bind("click.jPages",this.bind(function(){var t=this._currentPageNum+1;this.validNewPage(t)&&(this._clicked=!0,this.paginate(t))},this)),this._last.length&&this._last.bind("click.jPages",this.bind(function(){this.validNewPage(this._numPages)&&(this._clicked=!0,this.paginate(this._numPages))},this))},disableNavSelection:function(t){"undefined"!=typeof t.onselectstart?t.onselectstart=function(){return!1}:"undefined"!=typeof t.style.MozUserSelect?t.style.MozUserSelect="none":t.onmousedown=function(){return!1}},bindNavKeyBrowse:function(){this.jQdocument.bind("keydown.jPages",this.bind(function(t){var i=t.target.nodeName.toLowerCase();if(this.elemScrolledIntoView()&&"input"!==i&&"textarea"!=i){var s=this._currentPageNum;37==t.which&&(s=this._currentPageNum-1),39==t.which&&(s=this._currentPageNum+1),this.validNewPage(s)&&(this._clicked=!0,this.paginate(s))}},this))},elemScrolledIntoView:function(){var t,i,s;return i=(t=this.jQwindow.scrollTop())+this.jQwindow.height(),t<=(s=this._container.offset().top)+this._container.height()&&s<=i},bindNavScrollBrowse:function(){this._container.bind("mousewheel.jPages DOMMouseScroll.jPages",this.bind(function(t){var i=0<(t.originalEvent.wheelDelta||-t.originalEvent.detail)?this._currentPageNum-1:this._currentPageNum+1;return this.validNewPage(i)&&(this._clicked=!0,this.paginate(i)),t.preventDefault(),!1},this))},getNewPage:function(t,i){return i.is(t.currentPage)?this._currentPageNum:i.is(t.pages)?t.pages.index(i)+1:i.is(t.first)?1:i.is(t.last)?this._numPages:i.is(t.previous)?t.pages.index(t.currentPage):i.is(t.next)?t.pages.index(t.currentPage)+2:void 0},validNewPage:function(t){return t!==this._currentPageNum&&0<t&&t<=this._numPages},paginate:function(t){var i,s;i=this.updateItems(t),s=this.updatePages(t),this._currentPageNum=t,n.isFunction(this.options.callback)&&this.callback(t,i,s),this.updatePause()},updateItems:function(t){var i=this.getItemRange(t);return this._itemsHiding=this._itemsShowing,this._itemsShowing=this._items.slice(i.start,i.end),this._cssAnimSupport&&this.options.animation.length?this.cssAnimations(t):this.jQAnimations(t),i},getItemRange:function(t){var i={};return i.start=(t-1)*this.options.perPage,i.end=i.start+this.options.perPage,i.end>this._items.length&&(i.end=this._items.length),i},cssAnimations:function(t){clearInterval(this._delay),this._itemsHiding.removeClass(this.options.animation+" jp-invisible").addClass("jp-hidden"),this._itemsShowing.removeClass("jp-hidden").addClass("jp-invisible"),this._itemsOriented=this.getDirectedItems(t),this._index=0,this._delay=setInterval(this.bind(function(){this._index===this._itemsOriented.length?clearInterval(this._delay):this._itemsOriented.eq(this._index).removeClass("jp-invisible").addClass(this.options.animation),this._index=this._index+1},this),this.options.delay)},jQAnimations:function(t){clearInterval(this._delay),this._itemsHiding.addClass("jp-hidden"),this._itemsShowing.fadeTo(0,0).removeClass("jp-hidden"),this._itemsOriented=this.getDirectedItems(t),this._index=0,this._delay=setInterval(this.bind(function(){this._index===this._itemsOriented.length?clearInterval(this._delay):this._itemsOriented.eq(this._index).fadeTo(this.options.fallback,1),this._index=this._index+1},this),this.options.delay)},getDirectedItems:function(t){var i;switch(this.options.direction){case"backwards":i=n(this._itemsShowing.get().reverse());break;case"random":i=n(this._itemsShowing.get().sort(function(){return Math.round(Math.random())-.5}));break;case"auto":i=t>=this._currentPageNum?this._itemsShowing:n(this._itemsShowing.get().reverse());break;default:i=this._itemsShowing}return i},updatePages:function(t){var i,s,e;for(s in i=this.getInterval(t),this._nav)this._nav.hasOwnProperty(s)&&(e=this._nav[s],this.updateBtns(e,t),this.updateCurrentPage(e,t),this.updatePagesShowing(e,i),this.updateBreaks(e,i));return i},getInterval:function(t){var i,s;return i=Math.ceil(this.options.midRange/2),s=this._numPages-this.options.midRange,{start:i<t?Math.max(Math.min(t-i,s),0):0,end:i<t?Math.min(t+i-(0<this.options.midRange%2?1:0),this._numPages):Math.min(this.options.midRange,this._numPages)}},updateBtns:function(t,i){1===i&&(t.first.addClass("jp-disabled"),t.previous.addClass("jp-disabled")),i===this._numPages&&(t.next.addClass("jp-disabled"),t.last.addClass("jp-disabled")),1===this._currentPageNum&&1<i&&(t.first.removeClass("jp-disabled"),t.previous.removeClass("jp-disabled")),this._currentPageNum===this._numPages&&i<this._numPages&&(t.next.removeClass("jp-disabled"),t.last.removeClass("jp-disabled"))},updateCurrentPage:function(t,i){t.currentPage.removeClass("jp-current"),t.currentPage=t.pages.eq(i-1).addClass("jp-current")},updatePagesShowing:function(t,i){var s=t.pages.slice(i.start,i.end).not(t.permPages);t.pagesShowing.not(s).addClass("jp-hidden"),s.not(t.pagesShowing).removeClass("jp-hidden"),t.pagesShowing=s},updateBreaks:function(t,i){i.start>this.options.startRange||0===this.options.startRange&&0<i.start?t.fstBreak.removeClass("jp-hidden"):t.fstBreak.addClass("jp-hidden"),i.end<this._numPages-this.options.endRange?t.lstBreak.removeClass("jp-hidden"):t.lstBreak.addClass("jp-hidden")},callback:function(t,i,s){var e={current:t,interval:s,count:this._numPages},n={showing:this._itemsShowing,oncoming:this._items.slice(i.start+this.options.perPage,i.end+this.options.perPage),range:i,count:this._items.length};e.interval.start=e.interval.start+1,n.range.start=n.range.start+1,this.options.callback(e,n)},updatePause:function(){if(this.options.pause&&1<this._numPages){if(clearTimeout(this._pause),this.options.clickStop&&this._clicked)return;this._pause=setTimeout(this.bind(function(){this.paginate(this._currentPageNum!==this._numPages?this._currentPageNum+1:1)},this),this.options.pause)}},setMinHeight:function(){this.options.minHeight&&!this._container.is("table, tbody")&&setTimeout(this.bind(function(){this._container.css({"min-height":this._container.css("height")})},this),1e3)},bind:function(t,i){return function(){return t.apply(i,arguments)}},destroy:function(){this.jQdocument.unbind("keydown.jPages"),this._container.unbind("mousewheel.jPages DOMMouseScroll.jPages"),this.options.minHeight&&this._container.css("min-height",""),this._cssAnimSupport&&this.options.animation.length?this._items.removeClass("animated jp-hidden jp-invisible "+this.options.animation):this._items.removeClass("jp-hidden").fadeTo(0,1),this._holder.unbind("click.jPages").empty()}},n.fn[o]=function(t){var i=n.type(t);return"object"===i?this.length&&!n.data(this,o)&&(r=new h(this,t),this.each(function(){n.data(this,o,r)})):"string"===i&&"destroy"===t?(r.destroy(),this.each(function(){n.removeData(this,o)})):"number"===i&&t%1==0&&r.validNewPage(t)&&r.paginate(t),this}}(jQuery,window,document);
// research.js.coffee
(function(){var r,o,t,n,a,i,c,s,u,l,d,f,h,_,p,v,e,m,y,k;decko.editorInitFunctionMap["._removable-content-list ul"]=function(){return this.sortable({handle:"._handle",cancel:""})},decko.editorContentFunctionMap["._removable-content-list ul"]=function(){return decko.pointerContent(i($(this)))},decko.slotReady(function(e){var t,n;if(e.closest(".research-layout")[0]&&(e.hasClass("_overlay")&&_(e),e.find("._new_source").length&&(c(e),new decko.filter($(".RIGHT-source.filtered_content-view ._filter-widget")).update()),e.find("#jPages")[0]&&$("#jPages").jPages({containerID:"research-year-list",perPage:5,previous:!1,next:!1}),e.hasClass("edit_inline-view")&&$("#_select_source").data("stash")&&($("#_select_source").data("stash",!1),r()),(n=e.find(".answer-success-in-project"))[0]&&$("._company-project-research")[0]&&n.show(),(t=$("._next-question-button")).length&&e.find("._edit-answer-button").length))return t=t.clone(),e.find(".button-form-group").append(t)}),$(document).ready(function(){return $("body").on("click","#_select_year",function(e){var t;if(v())return t=m()?"source":"answer",k(t,e)}),$("body").on("click","._to_question_phase",function(e){return k("question",e)}),$("body").on("click","._to_source_phase",function(e){return k("source",e)}),$("body").on("click","#_select_source",function(e){return y("answer").hasClass("load")||r(),k("answer",e)}),$("body").on("click","._add_source_modal_link",function(){var e,t;return(t=(e=$(this)).data("sourceFields"))._Year=v,n(e,t)}),$(".research-layout #main").on("click",".TYPE-source.box, .TYPE-source.bar",function(e){return k("source",e),d($(this).data("cardName")),e.stopPropagation()}),$("body").on("click","._remove-removable",function(){return $(this).closest("li").remove()}),$(".research-layout #main").on("click",'[data-dismiss="overlay"]',function(e){var t;return(t=$(this)).overlaySlot().hide("slide",{direction:"down",complete:function(){return t.removeOverlay()}},600),e.stopPropagation()}),$(".research-layout #main .nav-item:not(.tab-li-question_phase)").on("click",".nav-link:not(.active)",function(e){if($(this).hasClass("load"))return v()?t($(this),{year:v(),source:p()}):s(e)}),$(".research-layout").on("click","._copy_caught_source",function(e){var t,n;return n=(t=$(this)).data("cardName"),c(t),d(n),e.preventDefault()})}),c=function(e){return e.closest("._modal-slot").find("._close-modal").trigger("click")},a=function(e,t){return e+"&"+$.param(t)},t=function(e,t){var n;return n=u(e,e.data("url")),e.data("url",a(n,t))},n=function(e,t){var n;return n=u(e,e.attr("href")),e.attr("href",a(n,t))},s=function(e){return alert("Please select a year"),e.preventDefault(),e.stopPropagation()},k=function(e,t){return y(e).trigger("click"),t.preventDefault()},y=function(e){return $(".tab-li-"+e+"_phase a")},r=function(){var e,t,n;if(!l())return e=$(".RIGHT-source.card-editor"),n=o(e,p()),t=e.find(".card-slot.removable_content-view"),f(t,n)},l=function(){var e;return!!(e=$("._edit-answer-button"))[0]&&(e.trigger("click"),$("#_select_source").data("stash",!0),!0)},o=function(e,t){var n,r;return(r=i(e)).push(t),n=decko.pointerContent($.uniqueSort(r)),e.find(".d0-card-content").val(n),n},f=function(e,t){var n;return n=$.param({assign:!0,card:{content:t}}),e.reloadSlot(e.data("cardName")+"?"+n)},p=function(){return $("#_select_source").data("source")},i=function(e){return e.find("._removable-content-item").map(function(){return $(this).data("cardName")})},v=function(){return e().val()},m=function(){return e().closest("._research-year-option").find(".not-researched")[0]},e=function(){return $("input[name='year']:checked")},u=function(e,t){return e.data("initialUrl")||e.data("initialUrl",t),e.data("initialUrl")},_=function(e){return e.hide(),$("html, body").animate({scrollTop:0},300),$(window).scrollTop,e.show("slide",{direction:"down"},600)},h=function(e){var t;return t=window.location.pathname.replace(/\/\w+$/,""),decko.path(t+"/"+e)},d=function(e){var t,n;if((t=$(".source_phase-view"))[0]&&e!==p)return n=h("source_selector")+"?"+$.param({source:e}),t.addClass("slotter"),t[0].href=n,$.rails.handleRemote(t)},wikirate.tabPhase=y}).call(this);
// sources.js.coffee
(function(){$(document).ready(function(){return $("body").on("click",".toggle-source-option",function(){return $(".download-option input").val(""),$(".source-option").show(),$(this).closest(".source-option").hide()}),$("body").on("click",".TYPE-source.bar",function(){return window.location=decko.path($(this).data("cardLinkName"))}),$("body").on("change",".RIGHT-file .download-option .d0-card-content",function(){var o,n;return(o=(n=$(this)).slot().find(".copy_catcher-view")).reloadSlot(o.slotUrl()+"&"+$.param({url:n.val()}))})}),decko.slotReady(function(o){return o.find(".TYPE-source .meatball-button").on("click",function(o){return $(this).dropdown("toggle"),o.stopImmediatePropagation()}),o.find(".TYPE-source.box a, .TYPE-source.bar a").on("click",function(o){return o.preventDefault()}),resizeIframe($("body"))}),decko.slotReady(function(o){return resizeIframe(o)}),this.resizeIframe=function(o){var n;if((n=o.find(".pdf-source-preview")).exists())return n.height($(window).height()-$(".navbar").height()-1)}}).call(this);
// unknown.js.coffee
(function(){var e,n,c,i,o,r;decko.editorContentFunctionMap["._unknown-checkbox input:checked"]=function(){return this.val()},decko.slotReady(function(t){return o(t).on("change",function(){if($(this).is(":checked"))return n(r(t))}),r(t).find(i+", select").on("change",function(){var n;if(!(n=o(t)).is(":checked")||$(this).val())return n.prop("checked",c($(this)))})}),r=function(n){return n.find(".card-editor.RIGHT-value .content-editor")},o=function(n){return n.find("._unknown-checkbox input[type=checkbox]")},c=function(n){return"unknown"===n.val().toString().toLowerCase()},i="input:not([name=_unknown]):visible",n=function(n){var t;return(t=n.find("select"))[0]?t.val(null).change():e(n)},e=function(n){return $.each(n.find(i),function(){var n;return"text"===(n=$(this)).prop("type")?n.val(null):n.prop("checked",!1)})}}).call(this);