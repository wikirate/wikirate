
# create a source described by a row in a csv file
class SourceImportItem < ImportItem
  @columns = { wikirate_company: { map: true, separator: ";" },
               year: { map: true },
               report_type: { optional: true }, # FIXME: map after FTI imports finished
               source: {},
               wikirate_title: { optional: true } }

  def import_hash
    r = @row.clone
    url = r.delete :source
    r[:file] = { remote_file_url: url, type_id: Card::FileID }
    {
      type_id: Card::SourceID,
      subfields: prep_subfields(r)
    }
  end

  def detect_existing
    results = Card::Set::Self::Source.search_by_url source
    return nil unless results.size == 1
    results.first.id
  end
end
