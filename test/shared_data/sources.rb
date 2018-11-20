require File.expand_path("spec/source_helper.rb")

class SharedData
  # test data for sources
  module Sources
    include SourceHelper

    def add_sources
      Timecop.freeze(Time.now + 1.day) do
        create_source "http://www.wikiwand.com/en/Space_opera",
                      codename: :space_opera_source,
                      subcards: {
                        "+company"     => { content: "Death Star",
                                            type_id: Card::PointerID },
                        "+topic"       => { content: "Force",
                                            type_id: Card::PointerID },
                        "+title"       => { content: "Space Opera" },
                        "+description" => { content: "Space Opera Wikipedia article" }
                      }
      end

      Timecop.freeze(Time.now + 2.days) do
        create_source "http://www.wikiwand.com/en/Opera",
                      codename: :opera_source,
                      subcards: {
                        "+title"       => { content: "Opera" },
                        "+description" => { content: "Opera Wikipedia article" }
                      }
      end

      create_source "http://www.wikiwand.com/en/Darth_Vader",
                    codename: :darth_vader_source,
                    subcards: {
                      "+company"     => { content: "Death Star",
                                          type_id: Card::PointerID },
                      "+topic"       => { content: "Force",
                                          type_id: Card::PointerID },
                      "+report type" => { content: "Force Report" },
                      "+description" => { content: "Darth Vader Wikipedia article" }
                    }

      create_source "http://www.wikiwand.com/en/Star_Wars",
                    codename: :star_wars_source,
                    subcards: {
                      "+company"     => { content: "Death Star",
                                          type_id: Card::PointerID },
                      "+topic"       => { content: "Force",
                                          type_id: Card::PointerID },
                      "+report type" => { content: "Force Report" },
                      "+title"       => { content: "Star Wars" },
                      "+description" => { content: "Star Wars Wikipedia article" },
                      "+year"        => { content: "2008" }
                    }

      create_source "http://www.wikiwand.com/en/Apple",
                    codename: :apple_source,
                    subcards: {
                      "+company"     => { content: "",
                                          type_id: Card::PointerID },
                      "+topic"       => { content: "",
                                          type_id: Card::PointerID },
                      "+title"       => { content: "Apple" },
                      "+description" => { content: "What is an apple?" }
                    }
    end
  end
end
