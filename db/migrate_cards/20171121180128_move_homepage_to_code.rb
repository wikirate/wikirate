# -*- encoding : utf-8 -*-

class MoveHomepageToCode < Card::Migration
  def up
    ensure_card "homepage top banner", codename: "homepage_top_banner"
    ensure_card "About WikiRate", codename: "about_wikirate"
    ensure_card "wikirate white logo", codename: "wikirate_white_logo"
    ensure_card "homepage: Wikirate gets it right",
                codename: "homepage_communities"
    ensure_card "Community", codename: "community"
    ensure_card "info", codename: "info"
    ensure_card "icon", codename: "icon"

    [
      ["NGOs", "Nonprofits", "building-o", "<h6>Support evidence-based campaigns</h6><h6>Engage volunteers</h6><h6>Develop metrics and ratings</h6>"],
      ["Researchers", "Researchers", "superscript", "<h6>Develop metrics and methodologies</h6><h6>Collaborate in research groups</h6><h6>Share and integrate datasets</h6>"],
      ["Education", "Teachers and Students", "graduation-cap", "<h6>Coordinate team projects</h6><h6>Engage with real data</h6><h6>Contribute new findings</h6>"],
      ["Companies", "Companies", "industry", "<h6>Ensure accurate answers</h6><h6>Communicate priorities</h6><h6>Provide context</h6>"],
      ["Standard Bodies", "Standard Bodies", "university", "<h6>Convey best practices</h6><h6>Reach a wider audience</h6><h6>Generate more reusable data</h6>"],
      ["Volunteers", "Volunteers", "users", "<h6>Join a research group</h6><h6>Verify company answers</h6><h6>Support corporate transparency</h6>"],
      ["Investors", "Investors", "money", "<h6>Assess corporate responsibility</h6><h6>Integrate financial and performance metrics</h6><h6>Press for improved impacts</h6>"],
      ["Press", "Press", "newspaper", "<h6>Ground corporate journalism in data</h6><h6>Link articles to live research</h6><h6>Support push for transparency</h6>",]
    ].each do |name, title, icon, info|
      ensure_card "WikiRate for #{name}", subfields: {
        community: {
          subfields: {
            title: { content: title, type: :phrase },
            icon: { content: icon, type: :phrase },
            info: info
          }
        }
      }
    end
  end
end







