// attribution.js.coffee
(function(){$(document).ready(function(){return $("body").on("click","._export-button",function(){var t;return(t=$(this).closest("._attributable-export").find("._attribution-alert")).showAsModal(t.slot())})})}).call(this);
// clipboard.js.coffee
(function(){var t,e,n;n=function(t){var e,n;return(e=document.createRange()).selectNode(t),(n=window.getSelection()).removeAllRanges(),n.addRange(e)},t=function(){var t;return(t=$(this).closest(".tab-pane.active").find("._clipboard")[0])?(t.contentEditable=!0,t.readOnly=!1,n(t),e(t.innerHTML,t.textContent),t.contentEditable=!1,t.readOnly=!0,window.getSelection().removeAllRanges()):console.error("No ._clipboard element found in the active tab.")},e=function(t,e){var n;return n=function(n){return n.originalEvent.clipboardData.setData("text/html",t),n.originalEvent.clipboardData.setData("text/plain",e),n.preventDefault()},$(document).on("copy",n),document.execCommand("copy"),$(document).off("copy",n)},$(function(){return $("body").on("click","._attribution-button",function(){var e;return t.call(this),e=$(this).closest(".tab-pane.active").find("._clipboard").html(),console.info("Text copied to clipboard: "+e)})})}).call(this);