# cache # of projects tagged with this metrics (=left) via <project>+metric
include_set Abstract::TaggedByCachedCount, type_to_count: :project,
            tag_pointer: :metric

def cql_content
  super.merge prepend: name.left
end
