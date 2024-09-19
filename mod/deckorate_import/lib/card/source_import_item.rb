class Card
  # create a source described by a row in a csv file
  class SourceImportItem < ImportItem
    extend CompanyImportHelper

    @columns = { company: { map: true, separator: ";", auto_add: true, suggest: true },
                 year: { map: true },
                 report_type: { optional: true }, # FIXME: map after FTI imports finished
                 wikirate_link: {},
                 wikirate_title: { optional: true } }

    def import_hash
      {
        type_id: Card::SourceID,
        fields: prep_fields(input.clone)
      }
    end

    def detect_existing
      results = Card::Source.search_by_url wikirate_link
      results.first&.id
    end
  end
end
