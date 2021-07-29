// script_new_source_page.js.coffee
(function(){$(document).ready(function(){return $("body").on("click",".toggle-source-option",function(){return $(".download-option input").val(""),$(".source-option").show(),$(this).closest(".source-option").hide()})})}).call(this);
// script_source_preview.js.coffee
(function(){$(document).ready(function(){return resizeIframe($("body"))}),decko.slotReady(function(e){return resizeIframe(e)}),this.resizeIframe=function(e){var i;if((i=e.find(".pdf-source-preview")).exists())return i.height($(window).height()-$(".navbar").height()-1)}}).call(this);