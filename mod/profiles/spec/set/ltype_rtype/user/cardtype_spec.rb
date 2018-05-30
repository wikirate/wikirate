RSpec.describe Card::Set::LtypeRtype::User::Cardtype do
  describe "view :contribution_report" do
    def report_url report
      "/Joe_User+Answer?report_tab=#{report}&view=contribution_report"
    end

    example "metric values report for Joe User" do
      report = Card.fetch("Joe User", :metric_answer).format.render :contribution_report
      expect(report).to have_tag "div.card-slot.contribution-report." \
                                 "metric_answer-contribution-report" do
        with_tag ".contribution-report-header" do
          with_tag "ul.nav.nav-tabs" do
            with_tag "li.contribution-report-title-box" do
              with_tag :a, with: { href: report_url(:badges) } do
                with_tag "h5.contribution-report-title", "Metric values"
              end
            end
            with_tag "li.contribution-report-box.nav-item" do
              with_tag :a, with: { href: report_url(:created) } do
                with_tag "span.count-number", "8"
                with_tag "span.count-label", "Created"
              end
            end
            with_tag "li.contribution-report-toggle.text-center.nav-item" do
              with_tag :a, with: { href: report_url(:created) }
            end
          end
        end
      end
    end
  end
end
