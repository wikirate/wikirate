// search_box.js.coffee
(function(){$(window).ready(function(){return $("body").on("change",".search-box-form .search-box-select-type",function(e){return decko.searchBox.select(e)})})}).call(this);