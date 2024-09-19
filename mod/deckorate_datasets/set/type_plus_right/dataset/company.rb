# These Dataset+Company (type plus right) cards refer to the list of
# all companies on a given dataset.

include_set Abstract::CompanySearch
include_set Abstract::FilterableList # must come after CompanySearch to override cql
include_set Abstract::DatasetScope
include_set Abstract::IdList
