require "colorize"

namespace :wikirate do
  desc "test the performance for a list of pages"
  task benchmark: :environment do
    # host = 'http://dev.wikirate.org'
    host = "http://localhost:3000"

    test_pages = ENV["page"] ? [ENV["page"]] : ["Home"]
    # test_pages = ENV['name'] ? [ENV['name']] : ['Home']
    runs = ENV["run"] || 1
    test_pages.each do |page|
      puts page

      log_args = { performance_log: {
          output: :card, output_card: page,
          methods: %i(
          execute rule fetch view
        ), details: true, min_time: 1
      } }
      url = "#{host}/#{page}"
      open "#{url}?#{log_args.to_param}"
      benchmark = WBench::Benchmark.new(url) { "" }
      results   = benchmark.run(runs) # => WBench::Results
      card = Card.fetch "#{page}+#{Card[:performance_log].name}",
                        new: { type_id: Card::PointerID }
      card.add_csv_entry page, results, runs
    end

    # results.app_server # =>
    #   [25, 24, 24]
    #
    # results.browser # =>
    #   {
    #     "navigationStart"            => [0, 0, 0],
    #     "fetchStart"                 => [0, 0, 0],
    #     "domainLookupStart"          => [0, 0, 0],
    #     "domainLookupEnd"            => [0, 0, 0],
    #     "connectStart"               => [12, 12, 11],
    #     "connectEnd"                 => [609, 612, 599],
    #     "secureConnectionStart"      => [197, 195, 194],
    #     "requestStart"               => [609, 612, 599],
    #     "responseStart"              => [829, 858, 821],
    #     "responseEnd"                => [1025, 1053, 1013],
    #     "domLoading"                 => [1028, 1055, 1016],
    #     "domInteractive"             => [1549, 1183, 1136],
    #     "domContentLoadedEventStart" => [1549, 1183, 1136],
    #     "domContentLoadedEventEnd"   => [1549, 1184, 1137],
    #     "domComplete"                => [2042, 1712, 1663],
    #     "loadEventStart"             => [2042, 1712, 1663],
    #     "loadEventEnd"               => [2057, 1730, 1680]
    #   }
  end

  def wbench_results_to_html results
    list = ""
    results.browser.each do |key, value|
      list += %(
                <li class="list-group-item">
                  <span class="badge">#{value}</span>
                  #{key}
                </li>
              )
    end
    %(
        <ul class="list-group">
          #{list}
        </ul>
      )
  end
end
