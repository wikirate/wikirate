
# create a source described by a row in a csv file
class SourceImportItem < ImportItem
  @columns = { wikirate_company: { map: true },
               year: { map: true },
               report_type: { optional: true }, # FIXME: map after FTI imports finished
               source: {},
               wikirate_title: { optional: true } }

  def import_hash
    r = @row.clone
    url = r.delete :source
    {
      type_id: Card::SourceID,
      file: { remote_file_url: url, type_id: Card::FileID },
      subfields: standard_subfields(r)
    }
  end
end
