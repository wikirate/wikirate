<!--
# @title README - mod: topics
-->

The Topics mod supports the use of Topics and Topic Frameworks to organize
information.

## Topics and Topic Frameworks

### Cards with codenames

| codename         | default name    | purpose                                                     |
|:-----------------|:----------------|:------------------------------------------------------------|
| :topic           | Topic           | use as tag to organize and group data                       |
| :topic_framework | Topic Framework | used to group Topics                                        |
| :category        | Category        | organize topics into trees                                  |
| :subtopic        | Subtopic        | search card used to find cards with given topic as category |
| :topic_family    | Topic Family    | top-level categories                                        |
| :topic_title     | Topic Title     | final component of compound topic names                     |



Topics are given compound names following the pattern `<Topic Framework>+<Topic Title>`. This
means that the same topic title can be given different meanings in different frameworks.

The `:topic_tree` and `:framework_tree` views support tree views for topics and topic 
frameworks respectively. These views can be used in both editing topic mappings and 
filtering for data subjects with a given topic/framework.


## Contributing

Bug reports, feature suggestions requests are welcome on GitHub at
https://github.com/wikirate/wikirate/issues.

## 🎉 Acknowledgements

The development of this module was supported by [NLnet foundation](https://nlnet.nl/).

![Image](https://nlnet.nl/logo/banner-160x60.png)