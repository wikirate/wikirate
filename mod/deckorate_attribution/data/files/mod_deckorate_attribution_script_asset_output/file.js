// attribution.js.coffee
(function(){$(window).ready(function(){return $("._export-button").on("click",function(){return $(this).closest("._attributable-export").find("._hidden-attribution-alert-link").trigger("click")})})}).call(this);
// clipboard.js.coffee
(function(){$(function(){return $("body").on("click",".copy-button",function(){var o;return o=$("#clipboard").text(),navigator.clipboard.writeText(o).then(function(){return console.log("Text copied to clipboard: "+o)})["catch"](function(o){return console.error("Copy to clipboard failed:",o)})})})}).call(this);