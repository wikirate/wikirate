# require "ruby-jmeter"

namespace :wikirate do
  namespace :flood do
    def jmeter_flood name, count: 100, host: "http://staging.wikirate.org", duration: 300,
                     rampup: 10,
                     &block
      uri = URI host
      test do
        defaults domain: uri.host, duration: duration, rampup: rampup
        threads count: count do
          instance_exec(&block)
        end
      end.flood(ENV["FLOOD_API_TOKEN"], grid: ENV["FLOOD_GRID"], name: name)
    end

    desc "stress test of main pages "
    task :main_pages do
      jmeter_flood "Main pages", count: 10 do
        visit name: "Homepage", url: "/"
        visit name: "Company page (Apple)", url: "/Apple_Inc"
        visit name: "Topic page (Environment)", url: "/Environment"
        visit name: "Metric page (RDR Total Score)",
              url: "/Ranking_Digital_Rights+RDR_Total_Score"
      end
    end

    desc "stress test of browse pages "
    task :browse_pages do
      jmeter_flood "Browse pages", count: 100 do
        visit name: "Browse Projects", url: "/Projects"
        visit name: "Browse Metrics", url: "/Metrics"
        visit name: "Browse Topics", url: "/Topics"
        visit name: "Browse Companies", url: "/Companies"
      end
    end

    desc "stress test of user logins"
    task :signin do
      jmeter_flood count: 5, duration: 30 do
        visit name: "Homepage", url: "/"
        submit name: "Signin", url: "/update/*signin",  method: "PATCH",
               fill_in: {
                 "card[subcards][*signin+*email][content]" => "flooder@mailinator.com",
                 "card[subcards][*signin+*email][type_id]" => "52",
                 "card[subcards][*signin+*password][content]" => "flooder_pass",
                 "card[subcards][*signin+*password][type_id]" => "52",
                 success: "REDIRECT: *previous"
               }
      end
    end
  end
end
