searchBox = ->  $('._search-box').data "searchBox"

$(window).ready ->
  $("body").on "change", ".search-box-form .search-box-select-type", (e) ->
    #submitIfKeyword() ||
    searchBox().updateType()

  $("body").on "click", ".search-box-form ._search-button", (e) ->
    submitIfKeyword() || browseType()
    e.preventDefault()

  searchBox().updateType()

$.extend decko.searchBox.prototype,
  selectedType: -> @form().find("#query_type").val()

  typeParams: () -> { query: { type: @selectedType() } }

  updateType: ->
    @updateSource()
    @updatePlaceholder()
    @init()

  updateSource: ->
    @config.source =
      if @selectedType() == ""
        @originalpath
      else
        @originalpath + "?" + $.param @typeParams()

  updatePlaceholder: ->
    type = @selectedType()
    @box.attr "placeholder",
      if type == ""
        "Search within companies, data sets, and more..."
      else
        "Search for " + type

submitIfKeyword = ->
  sb = searchBox()
  sb.keyword() && sb.form().submit() || false

browseType = ->
  sb = searchBox()
  type = sb.selectedType()
  page = type == "" && ":search" || type
  window.location = decko.path page + "?" + $.param sb.typeParams()
