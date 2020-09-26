NoMultishots
===

Us, poor Hunters, are always blamed for every bad thing that happens, despite the fact that only 0.01%*[1]* of our Multi-Shots cause trouble. Well anyways, **this AddOn notifies you if there is a polymorphed enemy or an attackable friendly player** nearby, so that you won't make that occasional 0.01% mistake.

Keeping track of nearby hazards can be useful for any class, not just Hunters. #NoChainLightnings.

*[1] Source: trust me.*

What it does exactly
---
It scrapes

- the combat log
- your target

for effects such as the Druid's Sleep, the Mage's Polymorph, or the Hunter's Frost Trap, and let's you know you might break the effect with a bad hit.

It also checks

- party members
- raid members

if you can damage them, for example, when they are mind controlled.

Accuracy
---

The WoW API does not make it possible to know with perfect accuracy if your Multi-Shot will actually cause trouble. Thus, the AddOn simply warns you that there *might* be a problem. The rule of thumb is, if you see no warnings, then you can just start blasting like no tomorrow. If, however, you see a warning, things still might be safe, but you better look around before pressing that button and wiping your group. Beware, there are no warnings for pulling mobs!

Development status
---
The AddOn is in alpha phase. It provides useful information and works properly, however, it lacks many settings and features, and may contain some bugs, especially for classes other than Hunters. I would like to see if there is interest for development and get feedback on what features to add. So by all means, give it a try, and write an issue on CurseForge or GitHub.