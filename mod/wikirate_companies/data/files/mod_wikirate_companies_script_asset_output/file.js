// company_group.js.coffee
(function(){var t,e,i,r,n,o,c,a,u,d;decko.editorContentFunctionMap[".specification-input"]=function(){var n;return"explicit"===c(this)?"explicit":(n=e(this)).data("locked")?n.find("input.d0-card-content").val():t(n)},$(window).ready(function(){return $("body").on("change","._constraint-metric",function(){var n,t,i,e;return e=(n=$(this)).closest("li").find(".card-slot"),t=encodeURIComponent(n.val()),i=e.slotMark()+"?view=value_formgroup&metric="+t,e.reloadSlot(i)}),$("body").on("change","input[name=spec-type]",function(){return a($(this).slot())}),$("body").on("submit",".card-form",function(){if(0<$(this).find(".specification-input").length)return $(this).setContentFieldsFromMap(),n(e(this))})}),decko.slotReady(function(n){if(0<n.find(".specification-input").length)return a(n)}),t=function(n){return n.find(".constraint-editor").map(function(){return i($(this))}).get().join("\n")},i=function(n){return[o(n),d(n),u(n),r(n)].join(";|;")},o=function(n){return n.find(".constraint-metric input").val()},d=function(n){return n.find(".constraint-year select").val()},u=function(n){return n.find(".constraint-value input, .constraint-value .constraint-value-fields > select").serialize()},r=function(n){return n.find(".constraint-related-group select").val()},c=function(n){return $(n).find("[name=spec-type]:checked").val()},e=function(n){return $(n).find(".constraint-list-editor")},a=function(n){var t,i;return i=e(n),t=n.find(".RIGHT-company.card-editor"),"explicit"===c(n)?(t.show(),i.hide()):(t.hide(),i.show())},n=function(n){return n.data("locked","true"),n.find(".constraint-editor input, .constraint-editor select").prop("disabled",!0)}}).call(this);