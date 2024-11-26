<!--
# @title README - mod: deckorate attribution
-->
# Deckorate Attribution

This mod introduces the Reference card type. The form for generating references
is an attribution generator, and the reference cards themselves comprise reference 
tracking.

Each reference has:
- a :subject, meaning the data in referential use
- a :party, whom the reference attributes
- an :adaptation, noting whether the data was adapted
- a title
- a :url

Two abstract sets facilitate the use of References and their custom views:

- **Card::Set::Abstract::Attributable** - when this abstract set is included in
  a card set, that set has extra UI to support attributions for those cards. 
  Specifically, datasets, metrics, and answer include this set.
- **Card::Set::Abstract::AttributableSearch** - including this abstract set means
  that exports of its searches will be accompanied by a reminder to attribute 
  the results.

### Contributing

Bug reports, feature suggestions requests are welcome on GitHub at
https://github.com/wikirate/wikirate/issues.

### 🎉 Acknowledgements

The development of this module was supported by [NLnet foundation](https://nlnet.nl/).

![Image](https://nlnet.nl/logo/banner-160x60.png)
