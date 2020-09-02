# 3D Printer Enclosure Design Details

_work in progress_


With the conceptual design behind me, the first step was to choose the
size of the enclosure or cage.

The basic design includes a divided front door to access the printing
stage.  A side door allowing access to the filament reel and feeder.
And a top panel which opens like a top-loader washing machine.

Another thing I like about using extrusions for the enclosure is it
allows me to tack on accessories as needed, for example, a Raspi4 
running Octoprint, LED light strips, etc.  


## Basic Frame

The basic idea is a frame is made of 2020 extrusion, and the inside
groove is used to hold a glass panel.  The depth of the groove is 6mm,
and I specified the glass panels to engage 5mm into the groove for a
snug fit.

## Joinery

I found several metal joints for 2D and 3D
corners.  But eventually I went with a 3D-printed corner from `Mighty
Nozzle`.  The advantage of these joints is they leave the interior
groove vacant to hold the glass panels.


## Hinges / Doors

Hinges were another concern, but I also quickly found hinges which were
suitable sized and spaced to make the doors. All hinges except the top
panel result in a 5mm gap.  The top panel hinges give a 10mm gap, to
accomodate the 3D corner joints.  I probably could have shaved them down
to be thinner than the default 7mm, but I decided to play it safe.

I think the gaps around the door panels are a little large, but I wasn't
sure to what accuracy these places could cut my pieces.  I decided to
stick to multiples of 5mm for all dimensions.

## Meta

The design was visualized in OpenSCAD.  I put some `echo` statements
within key modules of the design, showing the part and its key
dimensions.  This allows me to make a poor-man's BOM by some simple
post-processing of the output text.
