// toggle_details.js.coffee
(function(){$.fn.exists=function(){return 0<this.length},$(document).ready(function(){return $("body").on("click","[data-details-mark]",function(){return new decko.details(this).toggle($(this))}),$("body").on("click",".details-close-icon",function(t){return new decko.details(this).closeLast(),t.stopPropagation(),t.preventDefault()}),$("body").on("click",".details ._update-details",function(t){if(!(0<$(this).closest(".relations_table-view").length))return new decko.details(this).add($(this)),t.preventDefault()})}),decko.details=function(t){return this.initDSlot=function(t){var i;return $(".details").exists()||$("body").append("<div class='details'></div>"),t&&(i=$(t).closest(".details-toggle").find(".details")),this.dSlot=i.exists()?i:$(".details")},this.initModal=function(){if(!this.inModal())return this.mSlot=this.dSlot.showAsModal($("body")),this.modalDialog().addClass("modal-lg")},this.inModal=function(){return this.modalDialog().exists()},this.modalDialog=function(){return this.dSlot.closest(".modal-dialog")},this.closeLast=function(){return 1===this.dSlot.children().length?this.turnOff():(this.lastDetails().remove(),this.showLastDetails())},this.closeAll=function(){return this.dSlot.children().not(":first").remove(),this.turnOff()},this.turnOff=function(){if($(".details-toggle").removeClass("active"),this.dSlot.hide(),this.inModal())return this.dSlot.closest(".modal").modal("hide")},this.toggle=function(t){return t.hasClass("active")?(t.removeClass("active"),this.closeAll()):(this.turnOff(),t.addClass("active"),this.add(t,!0))},this.add=function(t,i){return this.showDetails(this.urlFor(t),i)},this.urlFor=function(t){var i;return i=t.attr("href")||t.data("details-mark"),decko.path(i+"?view="+this.config("view"))},this.config=function(t){if(this.configHash||(this.configHash=$("[data-details-config]").data("details-config")),this.configHash)return this.configHash[t]},this.showDetails=function(t,i){var s;return this.currentURL()!==t&&(i&&this.dSlot.html(""),s=this.loadPage(t),this.dSlot.append(s),this.setCurrentURL(t)),this.showLastDetails()},this.showLastDetails=function(){return this.dSlot.children().hide(),this.lastDetails().show(),this.dSlot.show()},this.currentURL=function(){return this.lastDetails().data("currentUrl")},this.setCurrentURL=function(t){return this.lastDetails().data("currentUrl",t)},this.lastDetails=function(){return this.dSlot.children().last()},this.loadPage=function(t){var i;return(i=$("<div></div>")).load(t,function(){return i.find(".card-slot").trigger("slotReady")}),i},this.initDSlot(t),"modal"===this.config("layout")&&this.initModal(),this}}).call(this);