#! no set module

# module AffinityBadgeHierarchy
#   include BadgeHierarchy
#
#   def hierarchy map
#     @map = {}
#     map.each do |action, badge_set|
#       if badge_set.values.first.is_a? Hash
#         @map[action] = {}
#         badge_set.each do |affinity, affinity_badge_set|
#           @map[action][affinity] = Abstract::BadgeSet.new affinity_badge_set
#         end
#       else
#         @map[action] = Abstract::BadgeSet.new badge_set
#       end
#     end
#   end
#
#   # returns a badge if the threshold is reached
#   def earns_badge count, action, affinity_type=nil
#     badge_set(action, affinity_type).earns_badge count
#   end
#
#   [:threshold, :level, :level_index].each do |method_name|
#     define_method method_name do |action, affinity_type, badge_key|
#       badge_set(action, affinity_type).send method_name, badge_key
#     end
#   end
#
#   def badge_set action, affinity_type
#     validate_badge_args action, affinity_type
#     affinity_type ? @map[action][affinity_type] : @map[action]
#   end
#
#   def validate_badge_args action, affinity_type
#     unless @map[action]
#       raise StandardError, "not supported action: #{action}"
#     end
#     if affinity_type && !@map[action][affinity_type].is_a?(Abstract::BadgeSet)
#       raise StandardError,
#             "affinity type #{affinity_type} not supported for action #{action}"
#     end
#   end
#
#   def map
#     @map
#   end
#
#   def badge_names
#     @map.values.
#   end
#
#   def badge_actions
#     @badge_actions ||= @map.keys
#   end
#
#   def change_thresholds action, affinity_type, *thresholds
#     if affinity_type
#       @map[action][affinity_type].change_thresholds(*thresholds)
#     else
#       @map[action].change_thresholds(*thresholds)
#     end
#   end
# end
