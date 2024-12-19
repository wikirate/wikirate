searchBox = ->  $('._search-box').data "searchBox"

$(window).ready ->
  $("body").on "change", ".search-box-form .search-box-select-type", (e) ->
    #submitIfKeyword() ||
    searchBox().updateType()

  $("body").on "click", ".search-box-form ._search-button", (e) ->
    submitIfKeyword() || browseType()
    e.preventDefault()

  $("body").on "submit", ".search-box-form", (e) ->
    if !searchBox().keyword()
      e.preventDefault()
      browseType()

  $("body").on "keypress", ".search-box-form .search-box-select-type", (e) ->
    $(this).closest("form").submit() if e.which = 13 # Enter key

  $("body").on "click", "._hot-keyword", (e) ->
    sb = searchBox()
    sb.keywordBox().val $(this).text()
    sb.form().submit()

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
      "Search for " +
        if type == ""
          "companies, datasets, and more..."
        else
           type

submitIfKeyword = ->
  sb = searchBox()
  sb.keyword() && sb.form().submit() || false

browseType = ->
  sb = searchBox()
  type = sb.selectedType()
  page = type == "" && ":search" || type
  window.location = decko.path page + "?" + $.param sb.typeParams()
