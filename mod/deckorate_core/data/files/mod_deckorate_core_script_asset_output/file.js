// script_metrics.js.coffee
(function(){var o,n,i,r,e,u,a,c,d,t,f,l,h,s,v,p,g,w,m,k,b,y,R;$(document).ready(function(){}),decko.slotReady(function(t){return t.find('[data-tooltip="true"]').tooltip(),t.hasClass("edit_in_wikirating-view")&&i(t),$("td.metric-weight input").on("keyup",function(){return n()}),$("#equalizer").on("click",function(){if(!0===$(this).prop("checked"))return p($(".wikiRating-editor"))})}),decko.editorContentFunctionMap[".pairs-editor"]=function(){return JSON.stringify(t(this))},t=function(t){var i;return i={},b(t).each(function(){var t,n;if(t=$(this).find("td"),n=$(t[0]).data("key"))return i[n]=$(t[1]).find("input").val()}),i},a=function(t){var n;return n=[],b(t).each(function(){var t;return t=$(this),n.push(t.find("td.metric-weight").find("input").val())}),n=n.splice(0,n.length-1)},y=function(t){return!0===t.every(function(t,n,i){return t===i[0]})},decko.editorContentFunctionMap[".wikiRating-editor"]=function(){return JSON.stringify(R(this))},R=function(t){var i;return i={},b(t).each(function(){var t,n;if(t=(n=$(this)).find(".metric-label .thumbnail").data("cardName"))return i[t]=n.find(".metric-weight input").val()}),i},n=function(){var t;return t=a($(".wikiRating-editor")),$("#equalizer").prop("checked",y(t))},p=function(t){var n;return n=(100/(b(t).length-1)).toFixed(2),s(t,n),w(t)},b=function(t){return t.find("tbody tr")},s=function(t,n){return b(t).each(function(){return $(this).find("td.metric-weight").find("input").val(n)})},$(window).ready(function(){return $("body").on("input",".metric-weight input",function(){return w($(this).closest(".wikiRating-editor"))}),$("body").on("click","._remove-weight",function(){return l($(this).closest("tr")),p($(".wikiRating-editor"))})}),w=function(t){var n,i;return n=R(t),i=v(t,n),g(t.closest("form.card-form"),i)},o=2,v=function(t,n){var i,r,e;return r=Math.pow(10,o),!!(i=m(n,r)).valid&&(e=i.total/r,f(t,n,e),99.9<e&&e<=100.09)},m=function(t,r){var e,o;return o=!0,e=0,$.each(t,function(t,n){var i;if(i=parseFloat(n),e+=i*r,i<=0||!c(n))return o=!1}),{total:e,valid:o}},f=function(t,n,i){var r,e;return e=(r=t.find(".weight-sum")).closest("tr"),$.isEmptyObject(n)?e.hide():(r.val(i),e.show())},c=function(t){var n,i;return n=!0,1<(i=t.split(".")).length&&2<i[1].length&&(n=!1),n},g=function(t,n){return t.find(".submit-button").prop("disabled",!n)},i=function(t){var n;if(n=t.closest(".editor").find(".wikiRating-editor"),r(n,t.find(".thumbnail")),w(n),!0===$("#equalizer").prop("checked"))return p($(".wikiRating-editor"))},r=function(n,t){return t.each(function(){var t;if(t=$(this),d(n,t.data("cardId")))return e(n,t)})},d=function(t,n){return 0===u(t,n).length},e=function(t,n){var i,r;return r=t.slot().find("._weight-row-template tr"),i=h(r,n),t.find("tbody tr:last-child").before(i)},u=function(t,n){return $(t).find("[data-card-id='"+n+"']")},l=function(t){var n,i,r;return i=t.closest(".wikiRating-editor"),n=t.find(".thumbnail").data("cardId"),r=k(i.slot(),n),t.remove(),r.remove(),w(i)},k=function(t,n){var i;return i=t.find(".edit_in_wikirating-view"),u(i,n)},h=function(t,n){var i;return(i=t.clone()).find(".metric-label").html(n.clone()),i}}).call(this);
// script_metric_properties.js.coffee
(function(){var r,n,i,o,c,u,a,s,f,h,l;r=".metric-properties",n=".RIGHT-hybrid input[type=checkbox]",i=".RIGHT-value_type input[type=radio]",decko.slotReady(function(e){var t;return e.hasClass("TYPE-metric")&&(e.hasClass("new_tab_pane-view")||e.hasClass("edit-view"))&&(l(e,e.find(n).prop("checked")),h(e,e.find(i+":checked").val())),0<(t=e.find(r)).length&&(l(t,a(t)),h(t,t.find(".RIGHT-value_type .item-name").text())),e.on("change",n,function(){return l(c(this),$(this).prop("checked"))}),e.on("change",i,function(){return h(c(this),$(this).val())})}),a=function(e){return"yes"===$.trim(e.find(".RIGHT-hybrid.content-view").text())},l=function(n,r){if(n.find(".RIGHT-hybrid")[0])return $.each(["research_policy","report_type","about","methodology","steward"],function(e,t){return s(n,t).toggle(r)})},c=function(e){return $(e).closest(".TYPE-metric")},u=function(e){switch(e){case"Number":case"Money":return["unit","range"];case"Category":case"Multi-Category":return["value_option"];default:return[]}},h=function(e,t){return o(e),f(e,t)},o=function(t){return["unit","range","value_option"].forEach(function(e){return s(t,e).hide()})},f=function(t,e){return u(e).forEach(function(e){return s(t,e).show()})},s=function(e,t){var n;return(n=e.find(".RIGHT-"+t)).closest(r)[0]?n.closest(".labeled-view"):n}}).call(this);
// script_metric_chart.js.coffee
(function(){var n,e,i,d,r,s;window.deckorate={},decko.slotReady(function(t){var e,n,i,r,s;for(r=[],e=0,n=(i=t.find(".vis._load-vis")).length;e<n;e++)s=i[e],r.push(d($(s)));return r}),d=function(t){return t.removeClass("_load-vis"),$.ajax({url:t.data("url"),visID:t.attr("id"),dataType:"json",type:"GET",success:function(t){return e(t,this.visID)}})},e=function(t,e){return i(t,$("#"+e))},n=function(t,i){return t.addEventListener("click",function(t,e){var n;if(i.closest("._filtered-content").exists())return(n=e.datum).filter?s(i,n.filter):n.details?r(n.details):void 0})},i=function(t,e){return vegaEmbed(e[0],t).then(function(t){return n(t.view,e)})},s=function(t,e){return new decko.filter(t.closest("._filtered-content").find("._filter-widget")).addRestrictions(e)},r=function(t){return $('[data-details-mark="'+t+'"]').trigger("click")},$(document).ready(function(){return $("body").on("click","._filter-bindings",function(){var t,e;return t="with-bindings",(e=$(this).closest(".filtered-results").find(".vis")).hasClass(t)?e.removeClass(t):e.addClass(t)})})}).call(this);