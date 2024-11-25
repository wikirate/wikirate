<!--
# @title README - mod: deckorate_graphql
-->

# Deckorate GraphQL

This mod extends decko's default graphql mod by:

1. Extending Decko's data model to support wikirate's cards and their associated search
   features. `GraphQL::Types::DeckorateSearch` for GraphQL facilitates wikirate card and lookup searches.
2. Extending the GraphQL schema to define additional types and queries linked to all wikirate specific cardtypes such as
   metrics, companies, datasets etc. `GraphQL::Types::DeckorateFields` for GraphQL contains a number of functions to
   facilitate the definition of different wikirate entities as GraphQL types.
3. Supporting a number of data types that extend the enum `FilterType` class and providing to users a number of
   a range of options for real-time filtering when conducting queries.

### Extending GraphQL Functionality

Even though `deckorate_graphql` focuses on the wikirate specific card types, it allows extending its functionality to
the development of additional card types if such a need occurs. For example, we could extend wikirate to support a new
card type for `benchmarks`. A new GraphQL type should be developed as follows:

```ruby
module GraphQL
  module Types
    # Example Benchmark type for GraphQL
    class Benchmark < WikirateCard
      field :designer, Card, null: false
      field :years, [Integer], null: false
      cardtype_field :company, Company, :company, true
      lookup_field :metric, Metric, nil, true
      lookup_field :answer, Answer, :answer, true
    end
  end
end
```

Note that, `cardtype_field` and `lookup_field` allow filtering to the defined subcards of the `benchmark` card.

Finally, the following lines of code should be included to the root Query class for GraphQL `GraphQL::Types::Query`

```ruby
card_field :benchmark, Benchmark
cardtype_field :benchmark, Benchmark
```

### Contributing

Bug reports, feature suggestions requests are welcome on GitHub at https://github.com/wikirate/wikirate/issues.

### 🎉 Acknowledgements

The development of this module was supported by [NLnet foundation](https://nlnet.nl/).

![Image](https://nlnet.nl/logo/banner-160x60.png)
