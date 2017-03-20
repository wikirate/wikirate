#! no set module

# module AffinityBadgeSquad
#   include BadgeSquad
#
#   def hierarchy map
#     @map = {}
#     map.each do |action, badge_line|
#       if badge_line.values.first.is_a? Hash
#         @map[action] = {}
#         badge_line.each do |affinity, affinity_badge_line|
#           @map[action][affinity] = Abstract::BadgeLine.new affinity_badge_line
#         end
#       else
#         @map[action] = Abstract::BadgeLine.new badge_line
#       end
#     end
#   end
#
#   # returns a badge if the threshold is reached
#   def earns_badge count, action, affinity_type=nil
#     badge_line(action, affinity_type).earns_badge count
#   end
#
#   [:threshold, :level, :level_index].each do |method_name|
#     define_method method_name do |action, affinity_type, badge_key|
#       badge_line(action, affinity_type).send method_name, badge_key
#     end
#   end
#
#   def badge_line action, affinity_type
#     validate_badge_args action, affinity_type
#     affinity_type ? @map[action][affinity_type] : @map[action]
#   end
#
#   def validate_badge_args action, affinity_type
#     unless @map[action]
#       raise StandardError, "not supported action: #{action}"
#     end
#     if affinity_type && !@map[action][affinity_type].is_a?(Abstract::BadgeLine)
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
