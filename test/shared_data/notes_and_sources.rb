class SharedData
  # test data for notes and sources
  module NotesAndSources
    def add_notes_and_sources
      Timecop.freeze(Time.now + 1.day) do
        Card.create!(
          type_id: Card::SourceID,
          import: false,
          subcards: {
            "+Link" => { content: "http://www.wikiwand.com/en/Space_opera" },
            "+company" => { content: "Death Star",
                            type_id: Card::PointerID },
            "+topic" => { content: "Force",
                          type_id: Card::PointerID },
            "+title" => { content: "Space Opera" },
            "+description" => { content: "Space Opera Wikipedia article" }
          }
        )
      end

      Timecop.freeze(Time.now + 2.days) do
        Card.create!(
          type_id: Card::SourceID,
          import: false,
          subcards: {
            "+Link" => { content: "http://www.wikiwand.com/en/Opera" },
            "+title" => { content: "Opera" },
            "+description" => { content: "Opera Wikipedia article" }
          }
        )
      end

      Card.create!(
        type_id: Card::SourceID,
        import: false,
        subcards: {
          "+Link" => { content: "http://www.wikiwand.com/en/Darth_Vader" },
          "+company" => { content: "Death Star", type_id: Card::PointerID },
          "+topic" => { content: "Force", type_id: Card::PointerID },
          "+report type" => { content: "Force Report" },
          "+description" => { content: "Darth Vader Wikipedia article" }
        }
      )

      source1 = Card.create!(
        type_id: Card::SourceID,
        import: false,
        subcards: {
          "+Link" => { content: "http://www.wikiwand.com/en/Star_Wars" },
          "+company" => { content: "Death Star", type_id: Card::PointerID },
          "+topic" => { content: "Force", type_id: Card::PointerID },
          "+report type" => { content: "Force Report" },
          "+title" => { content: "Star Wars" },
          "+description" => { content: "Star Wars Wikipedia article" },
          "+year" => { content: "2008" }
        }
      )

      source2 = Card.create!(
        type_id: Card::SourceID,
        import: false,
        subcards: {
          "+Link" => { content: "http://www.wikiwand.com/en/Apple" },
          "+company" => { content: "", type_id: Card::PointerID },
          "+topic" => { content: "", type_id: Card::PointerID },
          "+title" => { content: "Apple" },
          "+description" => { content: "What is an apple?" }
        }
      )

      Card.create!(
        name: "Death Star uses dark side of the Force",
        type_id: Card::ClaimID,
        subcards: {
          "+source" => { content: "[[#{source1.name}]]", type_id: Card::PointerID },
          "+company" => { content: "[[Death Star]]", type_id: Card::PointerID },
          "+topic" => { content: "[[Force]]", type_id: Card::PointerID }
        }
      )

      Card.create!(
        name: "Fruits are round",
        type_id: Card::ClaimID,
        subcards: {
          "+source" => { content: "[[#{source2.name}]]", type_id: Card::PointerID },
          "+company" => { content: "", type_id: Card::PointerID },
          "+topic" => { content: "[[Taming]]", type_id: Card::PointerID }
        }
      )
    end
  end
end
