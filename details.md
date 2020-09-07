# 3D Printer Enclosure Design Details

## Basic Construction

The basic building block of the enclosure, or cage, is a frame
made of standard 2020 aluminum profile extrusion.  The inside
grooves of these frames are used to hold a tempered glass panel.
The depth of the groove is 6mm, and I specified the glass panels 
to engage 5mm into the groove for a snug fit (see gasketing below).

One advantage of using 2020 extrusions is that accessories can easily be
mounted, such as a Raspi4 running Octoprint, LED light strips, etc.
My initial perception was that these profiles are reasonably cheap for
their functionality, but the key factor was they were easy for me obtain
in pre-cut lengths.

### Enclosure Size and Doors

The first step is to choose the size of the enclosure or cage.
Measuring my Ender 5 Pro printer, I decided on the following:

* 600 mm width, gives enough room for the filament spool
* 500 mm depth
* 700 mm height, should clear the filament feed tube

These dimensions are the outside dimensions in width and depth.
After wrapping up all the documentation, I realized the height was
actually 730 mm, slightly over one extusion width higher than the
"basic" dimension. This sneaked into the design as I was puzzling with
how to arrange all the doors, their frames, and the corners without
blocking the glass groove.  Somehow the top door ended up sitting atop
the whole cage, rather than recessed into the specified envelope.
In hindsight, this could probably be fixed, but at the time I was so
frustrated, I was just happy to get something that worked.

Three doors are included:

* Divided front doors to access the printing stage
* Side door to access to the filament reel and feeder
* Top door opens like a top-loader washing machine


## Joinery

I found several metal joints for 2D and 3D corners, some were really
cool cast aluminum joints.  But these usually interfered with the groove
for the glass.  But eventually I went with flat triangular corner plate.
I bought these, but they could be printed on your 3D printer.
User `Mighty Nozzle` has a library which includes these.

These plates use a lot of bolts, five per corner.  I'm not sure if they
are really necessary or not.  I erred on the side of caution, especially
after I calculated the weight of all this tempered glass.


## Hinges / Doors

Hinges were another concern, but I found some which were suitable sized
and spaced to make the doors. The ones I selected give a 5mm gap between
the frame and the doors.  I think that is a little large, but in the
beginning, I wasn't sure what kind of length tolerances I would get on
the extrusions.  I decided to keep a 5 mm door gap, and also to make all
dimensions a multiple of 5 mm.

Note, if you are using 3D printed corners, the gap could be an issue on
the top door.  In that case, the top door hinges would need to have a
larger gap, or else print those corners thinner. I found some hinges
that gave a 10 mm gap, which I think would be plenty.


## Meta

The design was visualized in OpenSCAD.  This is great for playing around
and experimenting with different options.  But it isn't so great for the
final documentation of the design.  The file becomes cluttered with all
kinds of visual aids and tests, like 

* XYZ axes
* grid lines (regular and isometric)
* overall dimension lines
* individual panel extrusion sizes (for assy help)
* animation to show exploded view, with lines
* poor-man's BOM generation `echo` statements

I tried comment it, but there will surely be questions, even from
myself.  Random remarks.

I wanted to make an isometric assembly drawing, and I will never take
this approach again.  What I did was draw isometric grid lines in
OpenSCAD, then export a PNG file, made the background transparent with
Gimp, and imported it into AutoCAD.  Whereupon I reconstructed the grids
on separate layers which I used as snap points to the Find Number
callouts.  I then replaced the AudoCAD image with another one without
isometric grids, and VOILA.  What a PITA.  It's time to take up bite the
bullet on Fusion 360.

Check out the script `mkbom.sh` which runs OpenSCAD from the command
line, and collects and sorts the output to create a really simple BOM.
The output isn't a perfect BOM, but it is a great starting point
containing the basic information needed on the "real" BOM.  Things like:

* X & Y dimensions of the finished panels
* length of individual extrusions
* X & Y dimensions of the glass panels
* perimeter of the glass panels (for gasket length)
* X + Y (sum) of glass panels (this is how the supplier prices them)
* weight of the extrusions and glass panels

## BOM and Rollups

TBD


## Tools

I tried to use open-source tools in the development of this project, but
failed, sort of.  OpenSCAD is open source, as is Gimp (see above).  I
used Excel for the BOM, but I could have used gnumeric or libreoffice.
The biggest break with open source tools is AutoCAD, or more precisely,
DraftSight.  I've been using them for years, when I lost my two ancient
AutoCAD license during a move.  Until recently, DraftSight was free.
But they have started charging an annual license fee, about $100 for the
entry level.  It is really hard to relearn 25 years of muscle memory of
the AutoCAD commands. And I so rarely use mechanical CAD tools, it's
tough to invest the time and/or money to learn a new tool.  I'm still
undecided on this one.  

The design files, however, should be usable in other open source tools.
The xlsx spreadsheets can be imported in other spreadsheet programs, and
I exported an ASCII DXF file from DraftSight.


## Metric

Because I live in South Korea, the overwhelming majority of material I
can get here is measured in Metric units. This design is dimensioned
accordingly.  Furthermore, fasteners are all metric threads.  I should
be a simple task to tweak the design to the equivalent Imperial units.
For example 

* M3 ~~ #4-40
* M3.5 ~~ #6-32 (oddball size?)
* M4 ~~ #8-32
* M5 ~~ #10-32 or #10-24

