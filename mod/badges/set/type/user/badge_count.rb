include_set Abstract::Certificate

BADGE_TYPES = [:metric, :project, :metric_value, :source, :wikirate_company]

def badge_count level=nil
  BADGE_TYPES.each_with_object(0) do |badge_type, count|
    next unless (badge_pointer = field(badge_type, :badges_earned))
    count += badge_pointer.badge_count level
  end
end


format :html do
  delegate :badge_count, to: :card

  view :rich_header do |args|
    bs_layout do
      row 12 do
        col class: "nopadding" do
          text_with_image title: "", text: header_right, size: :large
        end
      end
      row 12 do
        col _render_count
      end
    end
  end
end
