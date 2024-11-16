<!--
# @title README - mod: badges
-->

# Badges mod

## _Work in progress_: need to abstract 

The badges mod will need a good bit of work before it's of use to other software projects.

Some high-level notes:

1. Badges are grouped in Badge Lines, which are grouped into Badge Squads
2. Badges in a badge line measure the same action but with different amounts.  For example
   if you get badges for creating 1, 5, or 20 pictures, those would be 3 badges in 
   the same badge line.
3. Badge Squads are groups of lines pertaining to the same content type. (Company badges,
   for example, might comprise one squad with separate lines for creating, updating,
   and discussing companies)

Badges are mostly awarded in the "finalize" phase of card actions, meaning that they are 
awarded before changes are committed to the database. While it's understandable that they
are not delayed (because we want to notify users of the award), we should consider moving
them to the integrate phase.

Badges are stored at [User]+[Squad]+:badges_earned, which is just a list of the names
of badges in that squad earned by that user.

The code is this mod is pretty unconventional. Badge cards each have their own codename 
and have a self set defined which connects them to a badge squad via an abstract set
(eg Abstract::CompanyBadge). But the core definition of each badge is an extension of
the BadgeSquad class in the set/type/[squad] directory. Very strange. This code
needs serious reorganization (and, of course, all the deckorate-specific code should be
moved out.)

There is a good bit of code for affinity badges, but this code is currently largely
deactivated. Affinity badges add a layer of specificity.
For example, instead of just receiving badges for adding an Record, you can receive
badges for adding Records about a specific metric or company.
