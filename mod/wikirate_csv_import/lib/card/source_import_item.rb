class Card
  # create a source described by a row in a csv file
  class SourceImportItem < ImportItem
    @columns = { wikirate_company: { map: true, separator: ";" },
                 year: { map: true },
                 report_type: { optional: true }, # FIXME: map after FTI imports finished
                 wikirate_link: {},
                 wikirate_title: { optional: true } }

    def import_hash
      {
        type_id: Card::SourceID,
        subfields: prep_subfields(@row.clone)
      }
    end

    def detect_existing
      results = Card::Set::Self::Source.search_by_url wikirate_link
      results.first&.id
    end
  end
end
