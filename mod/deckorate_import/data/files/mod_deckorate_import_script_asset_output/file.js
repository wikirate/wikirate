// import.js.coffee
(function(){decko.slot.ready(function(){}),$(document).ready(function(){var t,n;return $("body").on("click","._import-status-form ._check-all",function(){var t;return t=$(this).is(":checked"),n($(this).closest("._import-status-form"),t)}),n=function(t,n){return t.find("._import-row-checkbox").prop("checked",n)},$("body").on("click","input[name=allImportMapItems]",function(){var t;return(t=$(this)).closest("._import-table").find("[name=importMapItem]:visible").each(function(){return $(this).prop("checked",t.prop("checked"))})}),$("body").on("change","._import-map-action",function(){var n;if(""!==(n=$(this)).val())return t(n).find("[name=importMapItem]:checked").each(function(){var t;if(t=$(this).closest("._map-item").find("._import-mapping"),"auto-add"===n.val()){if(""===t.val())return t.val("AutoAdd")}else if("clear"===n.val())return t.val("")}),n.val(""),n.trigger("change")}),$("body").on("click","._import-status-refresh",function(){var t,n;return t=(n=$(this).slot()).find(".nav-link.active").data("tab-name"),n.reloadSlot(n.slotUrl()+"&tab="+t)}),$("body").on("click","._toggle-mapping-vis",function(n){var e,i,a;return a=(e=$(this)).find("._mapping-vis-name"),i=t(e).find(".mapped-import-attrib"),"Hide"===a.text()?(i.hide(),i.find("[name=importMapItem]").prop("checked",!1),a.text("Show")):(i.show(),a.text("Hide")),n.preventDefault}),$("body").on("click","._save-mapping",function(){return $(".tab-pane-import_status_tab").html(""),$("._import-core > .tabbable > .nav > .nav-item:nth-child(2) > .nav-link").addClass("load")}),t=function(t){return t.closest(".tab-pane").find("._import-table")}})}).call(this);