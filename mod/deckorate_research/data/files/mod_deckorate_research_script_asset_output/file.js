// confirm.js.coffee
(function(){var r,e,n,a,t,c,i,o,u,s,f,h;$(document).ready(function(){return $(".research-layout .tab-pane-answer_phase").on("change","input, textarea, select",function(){return $(".research-answer .card-form").data("changed",!0)}),$(".research-layout").on("click","._research-metric-link, .research-answer-button",function(r){var e;if(u())return r.preventDefault(),(e=$("#confirmLeave")).trigger("click"),e.data("confirmHref",$(this).attr("href"))}),$(".research-layout").on("click","._yes_leave",function(){return window.location.href=$("#confirmLeave").data("confirmHref")}),$(".research-layout").on("click","._yes_year",function(){var r;return r=$("#confirmYear").data("year"),n(r),i("answer")}),$("body").on("click","._research-year-option, ._research-year-option input",function(e){var a,t;return(a=$(this)).is("input")||(a=a.find("input")),t=a.val(),r(a)?n(t):o(e,t)})}),n=function(r){return $("._research-"+r+" input").prop("checked",!0),c(r),t(r)},u=function(){return $(".research-answer .card-form").data("changed")},r=function(r){return u()?a(r):(i("answer"),!0)},a=function(r){var n;return!s()&&!h(r)&&(n=f("answer").find("#new_card input#card_name"),e(n,r.val()),!0)},c=function(r){if($(".RIGHT-source ._compact-filter")[0])return decko.compactFilter(".RIGHT-source ._compact-filter").addRestrictions({year:r})},t=function(){return $("._research-metric-link").each(function(){var r,e;return r=$(this),(e=new URL(r.prop("href"))).searchParams.set("year","2020"),r.prop("href",e.toString())})},e=function(r,e){var n;return n=r.val().replace(/\d{4}$/,e),r.val(n)},s=function(){return f("answer").find(".edit_inline-view")[0]},h=function(r){return!r.closest("._research-year-option").find(".not-researched")[0]},i=function(r){return deckorate.tabPhase(r).addClass("load"),f(r).html("")},f=function(r){return $(".tab-pane-"+r+"_phase")},o=function(r,e){var n;return(n=$("#confirmYear")).trigger("click"),n.data("year",e),r.preventDefault(),r.stopPropagation()}}).call(this);
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
!function(t,i,s,e){function n(e,n){this.options=t.extend({},o,n),this._container=t("#"+this.options.containerID),this._container.length&&(this.jQwindow=t(i),this.jQdocument=t(s),this._holder=t(e),this._nav={},this._first=t(this.options.first),this._previous=t(this.options.previous),this._next=t(this.options.next),this._last=t(this.options.last),this._items=this._container.children(":visible"),this._itemsShowing=t([]),this._itemsHiding=t([]),this._numPages=Math.ceil(this._items.length/this.options.perPage),this._currentPageNum=this.options.startPage,this._clicked=!1,this._cssAnimSupport=this.getCSSAnimationSupport(),this.init())}var a="jPages",h=null,o={containerID:"",first:!1,previous:"\u2190 previous",next:"next \u2192",last:!1,links:"numeric",startPage:1,perPage:10,midRange:5,startRange:1,endRange:1,keyBrowse:!1,scrollBrowse:!1,pause:0,clickStop:!1,delay:50,direction:"forward",animation:"",fallback:400,minHeight:!0,callback:e};n.prototype={constructor:n,getCSSAnimationSupport:function(){var t=!1,i="Webkit Moz O ms Khtml".split(" "),s="",n=this._container.get(0);if(n.style.animationName&&(t=!0),!1===t)for(var a=0;a<i.length;a++)if(n.style[i[a]+"AnimationName"]!==e){(s=i[a])+"Animation","-"+s.toLowerCase()+"-",t=!0;break}return t},init:function(){this.setStyles(),this.setNav(),this.paginate(this._currentPageNum),this.setMinHeight()},setStyles:function(){t("<style>.jp-invisible { visibility: hidden !important; } .jp-hidden { display: none !important; }</style>").appendTo("head"),this._cssAnimSupport&&this.options.animation.length?this._items.addClass("animated jp-hidden"):this._items.hide()},setNav:function(){var i=this.writeNav();this._holder.each(this.bind(function(s,e){var n=t(e);n.html(i),this.cacheNavElements(n,s),this.bindNavHandlers(s),this.disableNavSelection(e)},this)),this.options.keyBrowse&&this.bindNavKeyBrowse(),this.options.scrollBrowse&&this.bindNavScrollBrowse()},writeNav:function(){var t,i=1;for(t=this.writeBtn("first")+this.writeBtn("previous");i<=this._numPages;i++){switch(1===i&&0===this.options.startRange&&(t+="<span class='p-2'>...</span>"),i>this.options.startRange&&i<=this._numPages-this.options.endRange?t+="<a href='#' class='page-link jp-hidden'>":t+="<a href= '#' class='page-link'>",this.options.links){case"numeric":t+=i;break;case"blank":break;case"title":var s=this._items.eq(i-1).attr("data-title");t+=s!==e?s:""}t+="</a>",i!==this.options.startRange&&i!==this._numPages-this.options.endRange||(t+="<span class='p-2'>...</span>")}return t+=this.writeBtn("next")+this.writeBtn("last")+"</div>"},writeBtn:function(i){return!1===this.options[i]||t(this["_"+i]).length?"":"<a class='page-link jp-"+i+"'>"+this.options[i]+"</a>"},cacheNavElements:function(i,s){this._nav[s]={},this._nav[s].holder=i,this._nav[s].first=this._first.length?this._first:this._nav[s].holder.find("a.jp-first"),this._nav[s].previous=this._previous.length?this._previous:this._nav[s].holder.find("a.jp-previous"),this._nav[s].next=this._next.length?this._next:this._nav[s].holder.find("a.jp-next"),this._nav[s].last=this._last.length?this._last:this._nav[s].holder.find("a.jp-last"),this._nav[s].fstBreak=this._nav[s].holder.find("span:first"),this._nav[s].lstBreak=this._nav[s].holder.find("span:last"),this._nav[s].pages=this._nav[s].holder.find("a").not(".jp-first, .jp-previous, .jp-next, .jp-last"),this._nav[s].permPages=this._nav[s].pages.slice(0,this.options.startRange).add(this._nav[s].pages.slice(this._numPages-this.options.endRange,this._numPages)),this._nav[s].pagesShowing=t([]),this._nav[s].currentPage=t([])},bindNavHandlers:function(i){var s=this._nav[i];s.holder.bind("click.jPages",this.bind(function(i){var e=this.getNewPage(s,t(i.target));this.validNewPage(e)&&(this._clicked=!0,this.paginate(e)),i.preventDefault()},this)),this._first.length&&this._first.bind("click.jPages",this.bind(function(){this.validNewPage(1)&&(this._clicked=!0,this.paginate(1))},this)),this._previous.length&&this._previous.bind("click.jPages",this.bind(function(){var t=this._currentPageNum-1;this.validNewPage(t)&&(this._clicked=!0,this.paginate(t))},this)),this._next.length&&this._next.bind("click.jPages",this.bind(function(){var t=this._currentPageNum+1;this.validNewPage(t)&&(this._clicked=!0,this.paginate(t))},this)),this._last.length&&this._last.bind("click.jPages",this.bind(function(){this.validNewPage(this._numPages)&&(this._clicked=!0,this.paginate(this._numPages))},this))},disableNavSelection:function(t){"undefined"!=typeof t.onselectstart?t.onselectstart=function(){return!1}:"undefined"!=typeof t.style.MozUserSelect?t.style.MozUserSelect="none":t.onmousedown=function(){return!1}},bindNavKeyBrowse:function(){this.jQdocument.bind("keydown.jPages",this.bind(function(t){var i=t.target.nodeName.toLowerCase();if(this.elemScrolledIntoView()&&"input"!==i&&"textarea"!=i){var s=this._currentPageNum;37==t.which&&(s=this._currentPageNum-1),39==t.which&&(s=this._currentPageNum+1),this.validNewPage(s)&&(this._clicked=!0,this.paginate(s))}},this))},elemScrolledIntoView:function(){var t,i,s;return i=(t=this.jQwindow.scrollTop())+this.jQwindow.height(),(s=this._container.offset().top)+this._container.height()>=t&&s<=i},bindNavScrollBrowse:function(){this._container.bind("mousewheel.jPages DOMMouseScroll.jPages",this.bind(function(t){var i=(t.originalEvent.wheelDelta||-t.originalEvent.detail)>0?this._currentPageNum-1:this._currentPageNum+1;return this.validNewPage(i)&&(this._clicked=!0,this.paginate(i)),t.preventDefault(),!1},this))},getNewPage:function(t,i){return i.is(t.currentPage)?this._currentPageNum:i.is(t.pages)?t.pages.index(i)+1:i.is(t.first)?1:i.is(t.last)?this._numPages:i.is(t.previous)?t.pages.index(t.currentPage):i.is(t.next)?t.pages.index(t.currentPage)+2:void 0},validNewPage:function(t){return t!==this._currentPageNum&&t>0&&t<=this._numPages},paginate:function(i){var s,e;s=this.updateItems(i),e=this.updatePages(i),this._currentPageNum=i,t.isFunction(this.options.callback)&&this.callback(i,s,e),this.updatePause()},updateItems:function(t){var i=this.getItemRange(t);return this._itemsHiding=this._itemsShowing,this._itemsShowing=this._items.slice(i.start,i.end),this._cssAnimSupport&&this.options.animation.length?this.cssAnimations(t):this.jQAnimations(t),i},getItemRange:function(t){var i={};return i.start=(t-1)*this.options.perPage,i.end=i.start+this.options.perPage,i.end>this._items.length&&(i.end=this._items.length),i},cssAnimations:function(t){clearInterval(this._delay),this._itemsHiding.removeClass(this.options.animation+" jp-invisible").addClass("jp-hidden"),this._itemsShowing.removeClass("jp-hidden").addClass("jp-invisible"),this._itemsOriented=this.getDirectedItems(t),this._index=0,this._delay=setInterval(this.bind(function(){this._index===this._itemsOriented.length?clearInterval(this._delay):this._itemsOriented.eq(this._index).removeClass("jp-invisible").addClass(this.options.animation),this._index=this._index+1},this),this.options.delay)},jQAnimations:function(t){clearInterval(this._delay),this._itemsHiding.addClass("jp-hidden"),this._itemsShowing.fadeTo(0,0).removeClass("jp-hidden"),this._itemsOriented=this.getDirectedItems(t),this._index=0,this._delay=setInterval(this.bind(function(){this._index===this._itemsOriented.length?clearInterval(this._delay):this._itemsOriented.eq(this._index).fadeTo(this.options.fallback,1),this._index=this._index+1},this),this.options.delay)},getDirectedItems:function(i){var s;switch(this.options.direction){case"backwards":s=t(this._itemsShowing.get().reverse());break;case"random":s=t(this._itemsShowing.get().sort(function(){return Math.round(Math.random())-.5}));break;case"auto":s=i>=this._currentPageNum?this._itemsShowing:t(this._itemsShowing.get().reverse());break;default:s=this._itemsShowing}return s},updatePages:function(t){var i,s,e;for(s in i=this.getInterval(t),this._nav)this._nav.hasOwnProperty(s)&&(e=this._nav[s],this.updateBtns(e,t),this.updateCurrentPage(e,t),this.updatePagesShowing(e,i),this.updateBreaks(e,i));return i},getInterval:function(t){var i,s;return i=Math.ceil(this.options.midRange/2),s=this._numPages-this.options.midRange,{start:t>i?Math.max(Math.min(t-i,s),0):0,end:t>i?Math.min(t+i-(this.options.midRange%2>0?1:0),this._numPages):Math.min(this.options.midRange,this._numPages)}},updateBtns:function(t,i){1===i&&(t.first.addClass("jp-disabled"),t.previous.addClass("jp-disabled")),i===this._numPages&&(t.next.addClass("jp-disabled"),t.last.addClass("jp-disabled")),1===this._currentPageNum&&i>1&&(t.first.removeClass("jp-disabled"),t.previous.removeClass("jp-disabled")),this._currentPageNum===this._numPages&&i<this._numPages&&(t.next.removeClass("jp-disabled"),t.last.removeClass("jp-disabled"))},updateCurrentPage:function(t,i){t.currentPage.removeClass("jp-current"),t.currentPage=t.pages.eq(i-1).addClass("jp-current")},updatePagesShowing:function(t,i){var s=t.pages.slice(i.start,i.end).not(t.permPages);t.pagesShowing.not(s).addClass("jp-hidden"),s.not(t.pagesShowing).removeClass("jp-hidden"),t.pagesShowing=s},updateBreaks:function(t,i){i.start>this.options.startRange||0===this.options.startRange&&i.start>0?t.fstBreak.removeClass("jp-hidden"):t.fstBreak.addClass("jp-hidden"),i.end<this._numPages-this.options.endRange?t.lstBreak.removeClass("jp-hidden"):t.lstBreak.addClass("jp-hidden")},callback:function(t,i,s){var e={current:t,interval:s,count:this._numPages},n={showing:this._itemsShowing,oncoming:this._items.slice(i.start+this.options.perPage,i.end+this.options.perPage),range:i,count:this._items.length};e.interval.start=e.interval.start+1,n.range.start=n.range.start+1,this.options.callback(e,n)},updatePause:function(){if(this.options.pause&&this._numPages>1){if(clearTimeout(this._pause),this.options.clickStop&&this._clicked)return;this._pause=setTimeout(this.bind(function(){this.paginate(this._currentPageNum!==this._numPages?this._currentPageNum+1:1)},this),this.options.pause)}},setMinHeight:function(){this.options.minHeight&&!this._container.is("table, tbody")&&setTimeout(this.bind(function(){this._container.css({"min-height":this._container.css("height")})},this),1e3)},bind:function(t,i){return function(){return t.apply(i,arguments)}},destroy:function(){this.jQdocument.unbind("keydown.jPages"),this._container.unbind("mousewheel.jPages DOMMouseScroll.jPages"),this.options.minHeight&&this._container.css("min-height",""),this._cssAnimSupport&&this.options.animation.length?this._items.removeClass("animated jp-hidden jp-invisible "+this.options.animation):this._items.removeClass("jp-hidden").fadeTo(0,1),this._holder.unbind("click.jPages").empty()}},t.fn[a]=function(i){var s=t.type(i);return"object"===s?(this.length&&!t.data(this,a)&&(h=new n(this,i),this.each(function(){t.data(this,a,h)})),this):"string"===s&&"destroy"===i?(h.destroy(),this.each(function(){t.removeData(this,a)}),this):"number"===s&&i%1==0?(h.validNewPage(i)&&h.paginate(i),this):this}}(jQuery,window,document);
// research.js.coffee
(function(){var e,t,n,r,o,a,c,i,s,u,l,d,f,h,_,p,m,v,b,y;decko.editors.init["._removable-content-list ul"]=function(){return this.sortable({handle:"._handle",cancel:""})},decko.editors.content["._removable-content-list ul"]=function(){var e;return e=$(this).find("._removable-content-item").map(function(){return $(this).data("cardName")}),decko.pointerContent($.unique(e))},decko.slot.ready(function(t){var n,r;if(t.closest(".research-layout")[0]&&(t.hasClass("_overlay")&&h(t),t.find("._new_source").length&&(c(t),new decko.compactFilter($(".RIGHT-source.filtered_content-view ._compact-filter")).update()),t.find("#jPages")[0]&&$("#jPages").jPages({containerID:"research-year-list",perPage:5,previous:!1,next:!1}),t.hasClass("edit_inline-view")&&$("#_select_source").data("stash")&&($("#_select_source").data("stash",!1),e()),(r=t.find(".answer-success-in-project"))[0]&&$("._company-project-research")[0]&&r.show(),(n=$("._next-question-button")).length&&t.find("._edit-answer-button").length))return n=n.clone(),t.find(".button-form-group").append(n)}),$(document).ready(function(){return $("body").on("click","#_select_year",function(e){var t;if(p())return t=v()?"source":"answer",y(t,e)}),$("body").on("click","._to_question_phase",function(e){return y("question",e)}),$("body").on("click","._to_source_phase",function(e){return y("source",e)}),$("body").on("click","#_select_source",function(t){return b("answer").hasClass("load")||e(),y("answer",t)}),$("body").on("click","._add_source_modal_link",function(){var e,t;return(t=(e=$(this)).data("sourceFields"))._Year=p,r(e,t)}),$(".research-layout #main").on("click",".TYPE-source.box, .TYPE-source.bar",function(e){return y("source",e),l($(this).data("cardName")),e.stopPropagation()}),$("body").on("click","._remove-removable",function(){return $(this).closest("li").remove()}),$(".research-layout #main").on("click",'[data-bs-dismiss="overlay"]',function(e){var t;return(t=$(this)).overlaySlot().hide("slide",{direction:"down",complete:function(){return t.removeOverlay()}},600),e.stopPropagation()}),$(".research-layout #main .nav-item:not(.tab-li-question_phase)").on("show.bs.tab",".nav-link",function(e){if($(this).hasClass("load"))return p()?n($(this),{year:p(),source:_()}):i(e)}),$(".research-layout").on("click","._copy_caught_source",function(e){var t,n;return n=(t=$(this)).data("cardName"),c(t),l(n),e.preventDefault()}),$(".research-layout").on("click","._methodology-link",function(e){return y("question",e),$("._methodology-button").click()})}),c=function(e){return e.closest("._modal-slot").find("._close-modal").trigger("click")},o=function(e,t){return e+"&"+$.param(t)},n=function(e,t){var n;return n=s(e,e.data("url")),e.data("url",o(n,t))},r=function(e,t){var n;return n=s(e,e.attr("href")),e.attr("href",o(n,t))},i=function(e){return alert("Please select a year"),e.preventDefault(),e.stopPropagation()},y=function(e,t){return new bootstrap.Tab(b(e)).show(),t.preventDefault()},b=function(e){return $(".tab-li-"+e+"_phase a")},e=function(){var e,n,r;if(!u())return e=$(".RIGHT-source.card-editor"),r=t(e,_()),n=e.find(".card-slot.removable_content-view"),d(n,r)},u=function(){var e;return!!(e=$("._edit-answer-button"))[0]&&(e.trigger("click"),$("#_select_source").data("stash",!0),!0)},t=function(e,t){var n,r;return(r=a()).push(t),n=decko.pointerContent($.uniqueSort(r)),e.find(".d0-card-content").val(n),n},d=function(e,t){var n;return n=$.param({assign:!0,card:{content:t}}),e.slotReload(e.data("cardLinkName")+"?"+n)},_=function(){return $("#_select_source").data("source")},a=function(){return $(".RIGHT-source .bar").map(function(){return $(this).data("cardName")})},p=function(){return m().val()},v=function(){return m().closest("._research-year-option").find(".not-researched")[0]},m=function(){return $("input[name='year']:checked")},s=function(e,t){return e.data("initialUrl")||e.data("initialUrl",t),e.data("initialUrl")},h=function(e){return e.hide(),$("html, body").animate({scrollTop:0},300),$(window).scrollTop,e.show("slide",{direction:"down"},600)},f=function(e){var t;return t=window.location.pathname.replace(/\/\w+$/,""),decko.path(t+"/"+e)},l=function(e){var t,n,r;if((t=$(".source_phase-view"))[0]&&e!==_)return n={source:e},a().toArray().includes(e)&&(n.slot={hide:"select_source_button"}),r=f("source_selector")+"?"+$.param(n),t.addClass("slotter"),t[0].href=r,$.rails.handleRemote(t)},deckorate.tabPhase=b}).call(this);
// sources.js.coffee
(function(){$(document).ready(function(){return $("body").on("click",".toggle-source-option",function(){return $(".download-option input").val(""),$(".source-option").show(),$(this).closest(".source-option").hide()}),$("body").on("change",".RIGHT-file .download-option .d0-card-content",function(){var o,e;return(o=(e=$(this)).slot().find(".copy_catcher-view")).slotReload(o.slotUrl()+"&"+$.param({url:e.val()}))}),resizeIframe($("body"))}),decko.slot.ready(function(o){return resizeIframe(o)}),this.resizeIframe=function(o){var e;if((e=o.find(".pdf-source-preview")).exists())return e.height($(window).height()-$(".navbar").height()-1)}}).call(this);
// unknown.js.coffee
(function(){var n,t,e,c,i,o;decko.editors.content["._unknown-checkbox input:checked"]=function(){return this.val()},decko.slot.ready(function(n){return i(n).on("change",function(){if($(this).is(":checked"))return t(o(n))}),o(n).find(c+", select").on("change",function(){var t;if(!(t=i(n)).is(":checked")||$(this).val())return t.prop("checked",e($(this)))})}),o=function(n){return n.find(".card-editor.RIGHT-value .content-editor")},i=function(n){return n.find("._unknown-checkbox input[type=checkbox]")},e=function(n){return"unknown"===n.val().toString().toLowerCase()},c="input:not([name=_unknown]):visible",t=function(t){var e;return(e=t.find("select"))[0]?e.val(null).change():n(t)},n=function(n){return $.each(n.find(c),function(){var n;return"text"===(n=$(this)).prop("type")?n.val(null):n.prop("checked",!1)})}}).call(this);