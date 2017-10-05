What exactly does this mod do?
------------------------------

 1/ Normal behavior of a cop
First, let's define what is the normal behavior of a cop as it's a really
important notion to understand how FSS can affect difficulty, depending on the
hardware you use.

Imagine there are only you and one unique cop all over the map. Unless your
frame rate is really low (below 15 fps), the cop is performing at his maximum
level of planned efficiency (all reaction delays and check intervals specified
by OVERKILL are respected). I consider this as the reference of what OVERKILL
designed and wanted in terms of difficulty.

 2/ Responsiveness is tied to frame rate
The base game only executes 1 or 2 AI tasks per frame (I simplify just a bit)
so more cops on the map means more gap between specified delays/intervals and
what really happens.

With the normal number of cops and a very high frame rate, this effect is
relatively innocuous. But 35 cops operating at their ideal performance level
as defined above requires 200 fps... It gets even more funny if you use mods
to increase the maximum number of cops.

 3/ Unleash'em all!
This is where Full Speed Swarm comes into play: it lets the game execute
more than 1 task per frame (the slider in the options menu sets the maximum
for this ; remember it's a max and not a min). So even with 100 cops on the
map, they can all perform as well as if they were alone (at least, the gap
between what they should be and what they are is greatly reduced).

With this point in mind, you can now understand how Full Speed Swarm does not
add difficulty, it just helps to reach what was originally designed.


Are there any drawbacks?
------------------------

Yes, executing way more tasks put your CPU under heavy workload thus your
frame rate will be a bit lower. To prevent it from dropping too much, I've
optimized a lot of things (unchanged behavior, faster process). Then you can
decrease the maximum number of tasks per frame in the options menu at your
convenience.


Additional features
-------------------

On my way to optimize whatever I could, I've added to some of the rewritten
function a few off-topic things.

 1/ Domination process
Friendly AI don't shoot at cops that players are trying to intimidate.

 2/ BLT's Delayed Calls
As I wasn't happy with the original implementation, I've replaced this library
by one with, on top of being faster, a functional Remove() method and that
supports for repetitive calls.

 3/ Fast-paced game (option)
Disabled by default, this option enhances the difficulty by removing several
delays punctuating cops' behavior. Cops won't run faster, they won't deal more
damage, they'll just wait less between each of their actions.

 4/ Assault behavior (option)
While the base game assigns assault groups to their spawn (a questionable
move), FSS sends them to areas of interest, ie where players/hostages/loot bags
are. You can define how they will advance: cautiously slow or aggressively
fast or a mix of both (which is the setting that renders the best IMO).

 5/ "Big Party" mutator
A mutator inspired by GoonMod's Excessive Force. The original one spawns more
than 2000 cops, nothing can handle that, here you can define how many cops you
want to fight by setting the "insanity level".

 6/ Adaptive LOD updater
It's the thing that gives animation priority to characters in the center of
your screen. If there are too many cops, the original updater can't process it
all in time and the cops you are focusing on look very laggy. Instead of
always processing 1 character per frame, the new system does 1 per group of 25
per frame, giving a much smoother result with very high number of cops.

 7/ Walking quality
Setting this option to "very high" will override the LOD value, making sure a
visible character is moved at least once every 2 frames. "Ultra" does the same
except visible characters are moved at every frame.

