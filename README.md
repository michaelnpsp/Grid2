<div align="center">

# Grid2

</div>

<p>This is a customized versio of Grid2 that enables players to filter pets by Owner Class</p>

<h3 id="w-walkthrough">Walkthrough</h3>

-   Ingame open Grid2 (/grid)
-   Depending on if you've enabled themes or not, go to:
-   No Themes
    -   Layouts > Editor
-   Themes
    -   Themes > {Profile} > Layout > Editor
-   Select a **name** for your new Layout under **Create New Layout**
-   Click **Okay**
-   At the top where you see **players(1)**, click the **+** sign and select header type **pets**, then click **+Create**
-   In pets under **Name List** create a comma separated list of classes (all caps, e.g. DEATHKNIGHT) + Pet Names (Capital First Letter, e.g. Flatoom) that you want to enable.
-   The pets are displayed in order of your custom list so sort them as you see fit
-   After populating your list go to **Sort By** (placed over the **Groups** header) and select **List**
-   In your **Layouts** tab (Top Menu), to go **By Group Type** and select your newly created layout, for the group types where you want to see pets.
-   Congratulations you are now able to heal pets!

## List Example

In this example my favorite Warlocks pet name is `Flatoom` so I am gonna add that first, so that it displays first

```lua
Flatoom, WARLOCK, HUNTER, DEATHKNIGHT
```

<div align="center">

# Grid2

</div>
<p>Grid2 is a party/raid unit frame addon for World of Warcraft.</p>
<p>Grid2 is fully customizable. New zones (indicators) can be defined in unit frames to display information (statuses). The indicators can be customized and placed anywhere. Grid2 supports several types of indicators: icon, icons, square, text, bar, multibar. You can configure what statuses are displayed on each indicator.</p>
<p>Grid2 includes a huge amount of available statuses, but not all enabled by default, look through the configuration and familiarize yourself with the available options and statuses.</p>
<p>Grid2 is fast: consumes between 4 and 10 times less CPU cycles than other similar addons.</p>
<p>To open the configuration UI type "/grid2", left-click the minimap Icon, DataBroker icon launcher or use WoW addons list window.</p>
<h3 id="w-grid2-components">Grid2 components</h3>
<p>Grid2 package includes:</p>
<ul>
<li>Grid2</li>
<li>Grid2 Options</li>
<li>Grid2 Raid Debuffs</li>
<li>Grid2 Raid Debuffs Options</li>
<li>Grid2 LDB</li>
</ul>
<h3 id="w-grid2-does-not-work-or-i-think-i-found-a-bug">Grid2 does not work or I think I found a bug</h3>
<ul>
<li>Update to the latest versions of Grid2.</li>
<li>If you still get an error, go ahead and log it. Install and use the <a href="http://wow.curse.com/downloads/wow-addons/details/bug-grabber.aspx">BugGrabber</a> and <a href="http://wow.curse.com/downloads/wow-addons/details/bugsack.aspx">BugSack</a> mods to record the error and make it easy to cut and paste it.</li>
<li>Then, <a href="http://www.wowace.com/addons/grid2/tickets/">Post a ticket</a>. Check for existing tickets about your bug first. Remember to check back on your ticket later in case we need more information.</li>
</ul>
<h3 id="w-tutorials-guides">Tutorials/Guides</h3>
<p>https://web.archive.org/web/20200128114353/http://murlocparliament.com/how-2-grid2/</p>
<p>http://murlocparliament.com/how-2-grid2/</p>
<p>(Thanks to Zelmaru)</p>
<h3 id="w-common-issues-faq">Common issues/FAQ</h3>
<h6 id="w-raid-debuffs-not-showing-up">Raid debuffs not showing up !!!:</h6>
<p>Raid debuffs are not enabled by default. Go to statuses -&gt; Raid Debuffs and enable at least the Cataclysm module (if you are inside a instance you must exit and enter the instance or reload the UI after enabling the module)</p>
<h6 id="w-i-cant-push-the-grid-boxes-as-close-together-as-before">I cant push the grid boxes as close together as before:</h6>
<p>The border indicator has 2 pixels size and it has a transparent background color now. If you want the old grid2 appearance. Goto Indicators -&gt; border -&gt; Layout tab: Set a border size 1. And select a black and opaque background color for the border.</p>
<h6 id="w-what-about-mana-bars">What about mana bars ?</h6>
<p>Grid2 supports mana bars, but they are not created by default. If you want mana bars, create a new indicator of type "bar", place it wherever you want and map the "mana" or the "power" status to it (remember you must map some color status to the bar:color indicator too).</p>
<h6 id="w-what-is-the-poweralt-status">What is the poweralt status ?</h6>
<p>Poweralt status is a power type (like mana/rage/energy,etc). This power type is enabled by Wow in some combats. It shows: Atremedes sound, Chog'al corruption, etc. This status is not active by default in Grid2: you must map poweralt to any compatible indicator (text or bar indicator).</p>
