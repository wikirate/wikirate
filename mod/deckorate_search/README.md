<!--
# @title README - mod: deckorate_search
-->

# DeckoRate Search mod

This mod extends decko's default search mod by:

1. Adding additional views of the `:search` card in order to support type-specific search.
   Most visibly, this involves the primary `:search_box` view, which is featured,
   for example, in the top navbar on every page. It also includes `:result_bar` views,
   which extend standard bar views by listing a type badge in the middle.
2. Overriding the SQL-based search results for the `:search` card with results from a
   (separate) OpenSearch service.
