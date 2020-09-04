include <nopscad/lib.scad>

use <./uses/printed_flat_hinge.scad>
use <./uses/customizable_aluminium_extrusion_plate_brackets.scad>
use <./uses/alpha/alpha.scad>


// These control the presentation, these variables have to be set.
// They have to be manually changed?
//
// type of view: [ $t, animate, explode_me, label_me ]
function get_tbucks(a) = a[0];
function get_animate(a) = a[1];
function get_explode_me(a) = a[2];
function get_label_me(a) = a[3];

// view point:   [ $vpr, $vpd, $vpt ]
function get_vpr(a) = a[0];
function get_vpd(a) = a[1];
function get_vpt(a) = a[2];


// some pre-defined view types
view_exploded =                  [ 1, 0, 1, 0 ];
view_exploded_assy_lines =       [ 0, 0, 1, 0 ];
view_exploded_labels =           [ 0, 0, 1, 1 ];
view_normal =                    [ 1, 0, 0, 0 ];


// some pre-defined views
iso1 = 45.0;
iso2 = 90.0 - asin(1.0/sqrt(3.0));
view_iso = [ [iso2,0,iso1], 8000, [0,250,250] ];


//========================================================================
// Select view type and view point
//========================================================================

// 1. Select view point
view_point = view_iso;

// 2. Select view type
view_type = view_exploded_assy_lines;
//view_type = view_exploded;
//view_type = view_exploded_labels;
//view_type = view_normal;

// 3. Select optional drawing features
draw_axes = false;
draw_dimensions = false;
draw_iso_grids = false;
draw_ghost = true;

//----------------------------------------
// Apply the view type and view point
$t = get_tbucks(view_type);
animate = get_animate(view_type);
explode_me = get_explode_me(view_type);
label_me = get_label_me(view_type);

$vpr = get_vpr(view_point); // rotation
$vpd = get_vpd(view_point); // camera distance
$vpt = get_vpt(view_point); // translation


//========================================================================
//=== Make a poor-man's BOM of the assembly
//========================================================================
// Normally, this is only generated when run from the command line,
// such as (see script mkbom.sh):
// $ openscad -D 'bom=true' -o bom.echo enc.scad 
TAB = chr(9);
bom=false;
module mkbom( string ) {
  if(bom) echo( str( "BOM", TAB, string ) );
}


//========================================================================
//=== Simple Utility Functions
//========================================================================

// calculates the volume in m^3, 
// note that the inputs are in mm
function volume(a) = a.x*a.y*a.z / 1.0e9;

// calculates mass using volumen (m^3) 
// and density, kg / m^3
function mass(a,d) = d*volume(a);

// calculates the perimeter, 
// used to estimate gasket material qty
function perimeter(a) = a.x+a.x+a.y+a.y;

// calculates the area in m^2, 
// note that the inputs are in mm
function area(a) = a.x*a.y / 1.0e6;

module rounded_tube( length, dia ) {
  translate([0,0,0.5*dia]) {
    sphere(d=dia);
    cylinder( h=length-dia, d=dia, center=false);
    translate([0,0,length-dia]) sphere(d=dia);
  }
}

//========================================================================
//=== Makes a "ghost" cube, useful for checking things
//========================================================================
ghost_dia=3;
ghost_color="GreenYellow";
ghost_alpha=0.25;
ghost_border="Black";
module make_ghost_simple( size, ctr ) {
  %cube([size.x,size.y,size.z], center=ctr);
}

module make_ghost( size, ctr ) {
  color(ghost_color, ghost_alpha) 
    translate(0.5*[gasket_dia,gasket_dia,gasket_dia])
    cube(size-[gasket_dia,gasket_dia,gasket_dia], center=ctr);
    //cube([size.x,size.y,size.z], center=ctr);

  color(ghost_border) {
    translate([0.5*ghost_dia,0.5*ghost_dia,0])
    rounded_tube(size.z, ghost_dia);
    translate([0.5*ghost_dia,size.y-0.5*ghost_dia,0])
      rounded_tube(size.z, ghost_dia);
    translate([size.x-0.5*ghost_dia,+0.5*ghost_dia,0])
      rounded_tube(size.z, ghost_dia);
    translate([size.x-0.5*ghost_dia,size.y-0.5*ghost_dia,0])
      rounded_tube(size.z, ghost_dia);

    translate([0,0.5*ghost_dia,0.5*ghost_dia])
    rotate(90,[0,1,0])
      rounded_tube(size.x, ghost_dia);

    translate([0.5*ghost_dia,0,0.5*ghost_dia])
      rotate(-90,[1,0,0])
        rounded_tube(size.y, ghost_dia);

    translate([0,size.y-0.5*ghost_dia,0.5*ghost_dia])
    rotate(90,[0,1,0])
      rounded_tube(size.x, ghost_dia);

    translate([size.x-0.5*ghost_dia,0,0.5*ghost_dia])
      rotate(-90,[1,0,0])
        rounded_tube(size.y, ghost_dia);


    translate([0,0.5*ghost_dia,size.z-0.5*ghost_dia])
    rotate(90,[0,1,0])
      rounded_tube(size.x, ghost_dia);

    translate([0.5*ghost_dia,0,size.z-0.5*ghost_dia])
      rotate(-90,[1,0,0])
        rounded_tube(size.y, ghost_dia);

    translate([0,size.y-0.5*ghost_dia,size.z-0.5*ghost_dia])
    rotate(90,[0,1,0])
      rounded_tube(size.x, ghost_dia);

    translate([size.x-0.5*ghost_dia,0,size.z-0.5*ghost_dia])
      rotate(-90,[1,0,0])
        rounded_tube(size.y, ghost_dia);

  }

}



//========================================================================
//=== Aluminum Extrusions
//========================================================================
ex2020 = [20,20, "uses/2020.dxf", "ex2020", 0.38];
ex2040 = [20,40, "uses/2040.dxf", "ex2040", 0.00]; // TODO mass
ex4020 = [40,20, "uses/4020.dxf", "ex4020", 0.00]; // TODO mass
ex4040 = [40,40, "uses/4040.dxf", "ex4040", 0.00]; // TODO mass
function ex_name(ex) = ex[3];
function ex_filename(ex) = ex[2];

color_panel = "Silver";
// extrusion mass is given by the manufacturer
// as kg / length.  Note: length is mm
function ex_mass(ex,l) = (l*ex[4]) / 1.0e3;

//-------
// Generates a piece of AL extrusion along the Z axis
//-------
// Labels are optional and controlled by label_me variable
// used with exploded view to make a diagram helpful for assembly
lasf=7; // label scale factor
lacol="Red"; // label color
lacol2="LimeGreen"; // label background color
lacol3="Purple"; // label border color
module extrusion( ex, h, adj="", overunder=1.0 ) {
  mkbom( str(ex_name(ex), adj, TAB, h, TAB, ex_mass(ex,h)) );
  color(color_panel)
  linear_extrude(height=h)
    import(ex_filename(ex));

  // puts a label by each extrusion, 
  // it is an aid for assembly
  if(label_me) {
    translate([overunder*lasf*10,-0.5*ex.x,0.5*h-0.5*lasf*getwid(str(h)) ])
    rotate(90,[1,0,0])
    rotate(90,[0,0,1])
    scale([lasf,lasf,lasf]) {
      color(lacol)
          alpha_draw_string( 0, -5, 0, str(h), $cross=1);
      color(lacol2)
        translate([1,-4,-0.5])
          cube([getwid(str(h)),9,1]);
      difference() {
      color(lacol3) 
        translate([0,-5,-0])
          cube([2+getwid(str(h)),11,1]);
        translate([1,-4,-2])
          cube([getwid(str(h)),9,4]);
      }
    }
  }
}


//========================================================================
//=== Generate flat 2D corner joiner plates
//========================================================================
// Using corner brackets from user mightynozzle
// https://www.thingiverse.com/thing:2503622
// https://mightynozzle.com
color_corner = "Purple";

module flat_2d_corner(adj="") {
  mkbom(str("corner", adj, TAB, 5)); // number of screws per corner, M5
  aluminium_extrusion_bracket(
    shape = "L", type = "uniform", 
    bracket_height_in_millimeter = 7.0,
    support = "full", preview_color = color_corner
  );
}

// put the corner on the "top" of a panel
module posn_corner_top() {
  translate([60,60,20])
    rotate(180,[0,0,1])
    children();
}

// put the corner on the "bottom" of a panel
module posn_corner_bottom() {
  translate([60,60,0])
    rotate(-90,[0,0,1])
    rotate(180,[1,0,0])
    children();
}

// place a corner depending on the argument
module posn_corner(placement, adj="") {
  if( placement == "top" ) posn_corner_top() flat_2d_corner(adj);
  if( placement == "bottom" ) posn_corner_bottom() flat_2d_corner(adj);
}

//========================================================================
//=== Make Gasketing
//========================================================================
gasket_color = "Black";
gasket_dia = 4; // mm
gasket_overlap = 0; // mm
module gasket_strip( length, dia ) {
  rounded_tube( length, dia );
}

module gasket_rectangle( size, dia ) {
  translate([ gasket_overlap, 0.5*dia+gasket_overlap, 0])
  rotate(90,[0,1,0])
    gasket_strip( size.x-2*gasket_overlap, dia);

  translate([ 0.5*dia+gasket_overlap, gasket_overlap, 0])
  rotate(-90,[1,0,0])
    gasket_strip( size.y-2*gasket_overlap, dia);

  translate([ gasket_overlap, size.y-0.5*dia-gasket_overlap, 0])
  rotate(90,[0,1,0])
    gasket_strip( size.x-2*gasket_overlap, dia);

  translate([ size.x-0.5*dia-gasket_overlap, gasket_overlap, 0])
  rotate(-90,[1,0,0])
    gasket_strip( size.y-2*gasket_overlap, dia);

}


//========================================================================
//=== Make Glass Panes
//========================================================================
// glass pane should extend into the extrusion by 5mm
glass_color = "LightSteelBlue";
glass_overlap = 5;
glass_density = 2500; // kg per m^3
// the glass is 5mm thick
glass_thick = 5;
module glass_panel( name, size, ex ) {
  glass = [ size.x - 2.0*(ex.x - glass_overlap), 
         size.y - 2.0*(ex.x - glass_overlap),
         glass_thick ];
  mkbom( str(name, TAB, glass.x, TAB, glass.y, 
                 TAB, area(glass), TAB, perimeter(glass),
                 TAB, mass(glass, glass_density)  ));
  color(glass_color, alpha=0.10)
    translate([ ex.x-glass_overlap, ex.x-glass_overlap, 0.5*ex.y])
      cube( glass, center=false);


  color(gasket_color) {
    translate([ ex.x-glass_overlap, ex.x-glass_overlap, 0.5*ex.y]) {
      translate([ 0, 0, 0.5*gasket_dia+glass.z])
        gasket_rectangle( glass, gasket_dia );
      translate([ 0, 0, -0.5*gasket_dia])
        gasket_rectangle( glass, gasket_dia );
    }
  }

}


//========================================================================
//=== Make Panels
//========================================================================
function vlong(x) = (x=="vlong") ? 1 : (x=="none") ? 1 : 0;
function hlong(x) = (x=="hlong") ? 1 : (x=="none") ? 1 : 0;

assy_line_dia = 3;
assy_line_color = "Maroon";
assy_line_delta = 50;
assy_line_dash = 0.75;
module make_panel_assy_line_bottom( size, length, delta, dash, dia, stagger ) {
  gap = 5;
  fudge_len = length-ex2020.x-2*gap;
  if(abs(length) > 1) {
    //echo("assy line", length);
    color(assy_line_color) {
      translate([0,0,ex2020.x]) {
        translate([0, 0, stagger.y])
        difference() {
        for( z=[gap:delta:fudge_len] )
          translate([0,0,z])
            cylinder(h=dash*delta,d=dia);
          translate([0,0,gap+fudge_len])
            cylinder(h=delta,d=2*dia);
        }
        translate([size.x, 0, stagger.y])
        difference() {
          for( z=[gap:delta:fudge_len] )
            translate([0,0,z])
              cylinder(h=dash*delta,d=dia);
          translate([0,0,gap+fudge_len])
            cylinder(h=delta,d=2*dia);
        }
        translate([size.x, size.y, 0])

        difference() {
          for( z=[gap:delta:fudge_len] )
            translate([0,0,z])
              cylinder(h=dash*delta,d=dia);
          translate([0,0,gap+fudge_len])
            cylinder(h=delta,d=2*dia);
        }
        translate([0, size.y, 0])
        difference() {
          for( z=[gap:delta:fudge_len] )
            translate([0,0,z])
              cylinder(h=dash*delta,d=dia);
          translate([0,0,gap+fudge_len])
            cylinder(h=delta,d=2*dia);
        }
      }
    }
  }

}

module make_panel_assy_line( size, placement, len, delta=assy_line_delta, dash=assy_line_dash, dia=assy_line_dia, stagger=[0,0] ) {
  if( len < 1 ) 
    translate([0,0,len+(1-dash)*delta])
      make_panel_assy_line_bottom( size, -len, delta, dash, dia, stagger );
  if( len > 1 )
    make_panel_assy_line_bottom( size, len, delta, dash, dia, stagger );
}

module make_panel_edges( name, size, ex, x, topbottom="" ) {
  mkbom( str(name, TAB, size.x, TAB, size.y, TAB, 
       size.x-2*ex.x*vlong(x), TAB, size.y-2*ex.x*hlong(x)) );
  // Horizontal panel pieces
  translate([0+ex.x*vlong(x),0.5*ex.x,0.5*ex.x])
    rotate( 90, [0,1,0])
     rotate( -90, [0,0,1]) // this rotation is for labeling
     extrusion( ex, size.x-2*ex.x*vlong(x), overunder=-1 );
  translate([0+ex.x*vlong(x),size.y-ex.x+0.5*ex.x,0.5*ex.x])
    rotate( 90, [0,1,0])
    rotate( -90, [0,0,1]) // this rotation is for labeling
     extrusion( ex, size.x-2*ex.x*vlong(x) );
  // Vertical panel pieces
  translate([0.5*ex.x,ex.x*hlong(x),0.5*ex.x])
    rotate(-90,[1,0,0])
      extrusion( ex, size.y-2*ex.x*hlong(x) );
  translate([size.x-ex.x+0.5*ex.x,ex.x*hlong(x),0.5*ex.x])
    rotate(-90,[1,0,0])
      extrusion( ex, size.y-2*ex.x*hlong(x), overunder=-1);
}

module make_panel_corners( size, topbottom, adj="" ) {
  posn_corner(topbottom, adj);
  translate([size.x,0,0])
    rotate(90,[0,0,10])
      posn_corner(topbottom, adj);
  translate([size.x,size.y,0])
    rotate(180,[0,0,1])
    posn_corner(topbottom, adj);
  translate([0,size.y,0])
    rotate(-90,[0,0,1])
      posn_corner(topbottom, adj);
}

module make_panel_hinges( type, size, placement, angle ) {
  if( placement == "top" ) {
    translate([0,size.y-ex2020.x,0]) {
      translate([60,hinge_pitch(type),ex2020.x]) 
        rotate(90,[0,0,1])
          make_hinge(type, angle);
      translate([size.x-60,hinge_pitch(type),ex2020.x]) 
        rotate(90,[0,0,1])
          make_hinge(type, angle);
    }
  } else if( placement == "bottom_edge" ) {
    translate([100,0,0])
      rotate(90,[1,0,0])
        rotate(90,[0,0,1])
          make_hinge(type, angle);
    translate([size.x-100,0,0])
      rotate(90,[1,0,0])
        rotate(90,[0,0,1])
          make_hinge(type, angle);
  } else if( placement == "top_edge" ) {
    translate([75+0.5*hinge_width(type),size.y,0])
      rotate(angle,[1,0,0])
      rotate(-90,[0,0,1])
         rotate(-90,[0,1,0])
          make_hinge(type, angle);
    translate([0.5*size.x+0.5*hinge_width(type),size.y,0])
      rotate(angle,[1,0,0])
      rotate(-90,[0,0,1])
         rotate(-90,[0,1,0])
          make_hinge(type, angle);
    translate([size.x-75-0.5*hinge_width(type),size.y,0])
      rotate(angle,[1,0,0])
      rotate(-90,[0,0,1])
         rotate(-90,[0,1,0])
          make_hinge(type, angle);
  } else {
    off = (placement=="left") ? 0 : size.x-ex2020.x+hinge_pitch(type);
    translate([off,0,ex2020.x]) {
      translate([0,100,0])
        make_hinge(type, angle);
      translate([0,size.y-100,0])
        make_hinge(type, angle);
      translate([0,size.y-250,0])
        make_hinge(type, angle);
    }
  }
}

module make_panel( name, size, ex, topbottom, joining, alen=400 ) {
  if(topbottom == "top") {
    translate([size.x,0,ex.x])
      rotate(180,[0,1,0])
        make_panel_edges( name, size, ex, joining );
  } else {
    make_panel_edges( name, size, ex, joining );
  }
  make_panel_corners( size, topbottom );
  make_panel_assy_line( size, topbottom, alen );
}


//========================================================================
//=== Make Hinges
//========================================================================
// Uses flat hinge from NOPSCAD library
// https://github.com/nophead/NopSCADlib
// https://hydraraptor.blogspot.com
color_hinge = "DarkSlateGray";
hc4040 = ["hc4040",   
           40, // width
           15, // depth
            4, // thickness
            4, // pin_diameter
           10, // knuckle_diameter
            4, // knuckles
            M3_dome_screw,
            2, // screws
            0.2, // clearance, 
            1,   // margin, 
            25,  // pitch
            color_hinge
         ];

hc4050 = ["hc4050",   
           40,    // width
           20,    // depth
            5,    // thickness
            4,    // pin_diameter
           11,    // knuckle_diameter
            4,    // knuckles
            M3_dome_screw,
            2,    // screws
            0.2,  // clearance, 
            1,    // margin, 
           32,    // pitch
            color_hinge
         ];

function hinge_dist(h,a) = 0.5*(hinge_depth(h)+hinge_knuckle_dia(h)) - 0.5*a.x;

module make_hinge(type, angle) {
  mkbom( str("hinge", TAB, 4)); // number screws per hinge, M4
  translate([-hinge_dist(type,ex2020),0,0])
    rotate(90,[0,0,1])
      //hinge_assembly(type, angle);
      hinge_fastened_assembly(type, 3, 3, angle);
      // hinge_male( type );
      // hinge_female( type );
      // hinge_both( type );
}


//========================================================================
//=== Now Build the Whole Enclosure
//========================================================================

// enclosure size 500 depth x 600 width x 700 height
// was selected for the Ender 5 Pro
cage = [600,500,700];


// size of panels, gaps, etc...
hingegap=5;
doorgap=5;
topgap=5;
bottomgap=5;
top_panel = [ cage.x, cage.y ]; // also the bottom panel
bot_panel = top_panel;
back_panel = [ cage.x, cage.z ];
side_panel = [ cage.y, cage.z ];
side_door = [ cage.y-2*ex2020.x-2*hingegap, cage.z-2*ex2020.x-topgap-bottomgap ];
front_panel = [ cage.x, cage.z ];
front_door = [ 0.5*cage.x-ex2020.x-doorgap-hingegap, cage.z-2*ex2020.y-topgap-bottomgap ];


module posn_panel_back() {
  translate([0, cage.y, 0])
    rotate(90,[1,0,0]) 
      children();
}

module posn_panel_side_left() {
  translate([ex2020.x,cage.y,0])
    rotate(270,[0,0,1])
      rotate(90,[1,0,0]) 
        children();
}

module posn_panel_side_right() {
  translate([cage.x-ex2020.x,0,0])
    rotate(90,[0,0,1])
      rotate(90,[1,0,0]) 
        children();
}

module posn_panel_front() {
  translate([0, ex2020.x, 0])
    rotate(90,[1,0,0]) 
      children();
}

module posn_panel_top() {
  translate([0,0,cage.z-ex2020.x])
    children();
}

module posn_panel_bottom() {
  children();
}


module line(start, end, thickness = 1) {
    hull() {
        translate(start) sphere(thickness);
        translate(end) sphere(thickness);
    }
}

//========================================================================
//  MAIN ENCLOSURE CAGE 
//  w/ Exploded View Animation Control
//========================================================================
// this animation code really complicates the readability 
// can we write it better?

num_slices = 8;
timeline0 = [ for (i=[0:1:num_slices]) i ];
timeline = [ for (t=[timeline0]) t/num_slices ][0];
echo( timeline );


tPanelLeft       = [ timeline[0],  timeline[1],    [ -700,    0,    0 ]  ];

tPanelRight      = [ timeline[1],  timeline[2],    [ +600,    0,    0 ]  ];
tDoorSide        = [ timeline[1],  timeline[2],    [ +800,    0,    0 ]  ];

tPanelTop        = [ timeline[2],  timeline[3],    [    0,    0, +175 ]  ];
tCornersTop      = [ timeline[2],  timeline[3],    [    0,    0, +200 ]  ];

tDoorTop         = [ timeline[5],  timeline[6],    [    0,    0, +700 ]  ];

tPanelBottom     = [ timeline[3],  timeline[4],    [    0,    0, -225 ]  ];
tCornersBottom   = [ timeline[3],  timeline[4],    [    0,    0, -250 ]  ];

tPanelBackGlass  = [ timeline[4],  timeline[5],    [    0, +750,    0 ]  ];
tCornersBack     = [ timeline[4],  timeline[5],    [    0, +800,    0 ]  ];

tDoorFrontLeft   = [ timeline[5],  timeline[6],    [    0, -800,    0 ]  ];
tDoorFrontRight  = [ timeline[5],  timeline[6],    [    0, -800,    0 ]  ];

function tSlice(t) = ($t>=t.x) && ($t<t.y) ? 1.0-($t-t.x)/(t.y-t.x) : $t<t.x ? 1.0 : 0.0;
function tLimits(a) = [a[0], a[1]];
function exFrom(a) = a[2];
function offset(a) = tSlice(a)*abs(a[2].x + a[2].y + a[2].z); // assumes explode is only one axie

module explode(time, from) {
  translate(time*from) children();
}

module explode(howto) {
  if(animate==1) {
    translate(tSlice(tLimits(howto))*exFrom(howto)) children();
  } else {
    if(explode_me==1) {
      translate(exFrom(howto)) children();
    } else if(explode_me==0) {
      children();
    }
  }
}

module explode_cage() {

  //====== FIXED PANELS ======

  // Side panel, Left
  explode(tPanelLeft) {
    posn_panel_side_left() {
      make_panel( "panel.side.left", side_panel, ex2020, "top", "vlong", -offset(tPanelLeft) );
      glass_panel( "glass.side.left", side_panel, ex2020 );
    }
  }


  // Side panel, Right, no glass (door goes here)
  explode(tPanelRight) {
    posn_panel_side_right() {
      make_panel( "panel.side.right.noglass", side_panel, ex2020, "none", "vlong", -offset(tPanelRight) );
    }
  }

  // Top pseudo-panel, made from existing sides
  explode(tPanelTop) {
    translate([1*ex2020.x,0.5*ex2020.x,cage.z-0.5*ex2020.x])
      rotate(90,[0,1,0])
        extrusion( ex2020, cage.x - 2*ex2020.x, ".standalone" ); // front top

    translate([1*ex2020.x,cage.y-0.5*ex2020.x,cage.z-0.5*ex2020.x])
      rotate(90,[0,1,0])
        extrusion( ex2020, cage.x - 2*ex2020.x, ".standalone" ); // back top
  }
  // connect pseudo-panel at the top with corners
  explode(tCornersTop) {
    posn_panel_top() {
      make_panel_corners( top_panel, "top", ".standalone" );
      make_panel_assy_line( top_panel, "top", -offset(tCornersTop) );
    }
  }


  // Bottom pseudo-panel, made from existing sides
  explode(tPanelBottom) {
    translate([1*ex2020.x,0.5*ex2020.x,+0.5*ex2020.x])
      rotate(90,[0,1,0])
        extrusion( ex2020, cage.x - 2*ex2020.x, ".standalone" ); // front bot
    translate([1*ex2020.x,cage.y-0.5*ex2020.x,0.5*ex2020.x])
      rotate(90,[0,1,0])
        extrusion( ex2020, cage.x - 2*ex2020.x, ".standalone" ); // back bot
  }
  // connect pseudo-panel at the bottom with corners
  explode(tCornersBottom) {
    make_panel_corners( top_panel, "bottom", ".standalone" );
    make_panel_assy_line( top_panel, "bottom", offset(tCornersBottom) );
  }

  explode(tPanelBackGlass) {
    translate([0, cage.y - 0*ex2020.x, 0])
      rotate(90,[1,0,0]) 
        glass_panel( "glass.back.standalone", back_panel, ex2020 );
  }
  // connect pseudo-panel at the back with corners
  explode(tCornersBack) {
    posn_panel_back() {
      make_panel_corners( back_panel, "bottom", ".standalone" );
      make_panel_assy_line( back_panel, "bottom", offset(tCornersBack) );
    }
  }

  //====== DOORS ======

  // Side door
  explode(tDoorSide) {
    translate([0, ex2020.x+hingegap, ex2020.x+bottomgap])
    posn_panel_side_right() {
      make_panel( "panel.side.door", side_door, ex2020, "bottom", "vlong", -(offset(tDoorSide)-offset(tPanelRight)) );
      make_panel_hinges( hc4040, side_door, "right", 0 );
      glass_panel( "glass.side.door", side_door, ex2020 );
    }
  }

  // Front split doors
  explode(tDoorFrontLeft) {
    translate([ex2020.x+hingegap, 0, ex2020.x+bottomgap])
      posn_panel_front() {
        make_panel( "panel.front.door.left", front_door, ex2020, "bottom", "vlong", -offset(tDoorFrontLeft) );
        make_panel_hinges( hc4040, front_door, "left", 0 );
        glass_panel( "glass.front.door.left", front_door, ex2020 );
      }
  }
  explode(tDoorFrontRight) {
    translate([cage.x-front_door.x-ex2020.x - hingegap, 0, ex2020.x+bottomgap])
      posn_panel_front() {
        make_panel( "panel.front.door.right", front_door, ex2020, "bottom", "vlong", -offset(tDoorFrontRight) );
        make_panel_hinges( hc4040, front_door, "right", 0 );
        glass_panel( "glass.front.door.right", front_door, ex2020 );
      }
  }

//}
//module zebra() {

  // Top door
  explode(tDoorTop) {
    open_angle=20; // TODO this transformation isn't perfect wrt to the hinge
    vpos = top_panel.y+10;
    translate([0,0,ex2020.x+5]) // 10 is hinge gap for hc4050
    posn_panel_top() {
      translate([0,
                 vpos - cos(open_angle)*vpos,
                        sin(open_angle)*vpos          ])
      rotate(-open_angle, [1,0,0]) {
        make_panel( "panel.top.door", top_panel, ex2020, "top", "vlong", 0);
        glass_panel( "glass.top.door", top_panel, ex2020 );
        translate([0,0,5]) // 10 is hinge gap for hc4050
        make_panel_hinges( hc4050, top_panel, "top_edge", open_angle );
      }
    }
    posn_panel_top() {
      make_panel_assy_line( top_panel, "top", -offset(tDoorTop), stagger=[0,200] );
    }
  }

}

//========================================================================
// Draw big XYZ axes
//========================================================================

module axis(lenx, leny, lenz, dia) {
  arrow_d1=2*dia;
  arrow_d2=0.25*dia;
  arrow_len=4*dia;

  color("red") {
    rotate(90, [0,1,0]) cylinder(h=lenx-0.9*arrow_len,d=dia);
    translate([lenx-arrow_len,0,0]) 
      rotate(90, [0,1,0])
        cylinder(h=arrow_len-0.5*arrow_d2, d1=arrow_d1, d2=arrow_d2);
    translate([lenx-0.5*arrow_d2,0,0])
      sphere(d=arrow_d2);
  }

  color("green") {
    rotate(-90, [1,0,0]) cylinder(h=leny-0.9*arrow_len,d=dia);
    translate([0,leny-arrow_len,0]) 
      rotate(-90, [1,0,0])
        cylinder(h=arrow_len-0.5*arrow_d2, d1=arrow_d1, d2=arrow_d2);
    translate([0,leny-0.5*arrow_d2,0])
      sphere(d=arrow_d2);
  }

  color("blue") {
    cylinder(h=lenz-0.9*arrow_len,d=dia);
    translate([0,0,lenz-arrow_len]) 
      cylinder(h=arrow_len-0.5*arrow_d2, d1=arrow_d1, d2=arrow_d2);
    translate([0,0,lenx-0.5*arrow_d2])
      sphere(d=arrow_d2);
  }
}

//========================================================================
// Dimension the outside of the box
//========================================================================
// this is silly, learn 3D CAD, Chris

module dim_line(length, dia, arrow1, arrow2) {
  arrow_d1=2*dia;
  arrow_d2=0.25*dia;
  arrow_len=4*dia;
  rotate(90,[0,1,0]) {
    translate([0,0,arrow_len])
      cylinder(h=length-2*arrow_len,d=dia);
    if(arrow1==0) {
      translate([0,0,length-arrow_len]) 
        cylinder(h=arrow_len, d=dia);
    } else {
      translate([0,0,length-arrow_len]) 
        cylinder(h=arrow_len-0.5*arrow_d2, d1=arrow_d1, d2=arrow_d2);
      translate([0,0,length-0.5*arrow_d2])
        sphere(d=arrow_d2);
    }
    if(arrow2==0) {
      cylinder(h=arrow_len, d=dia);
    } else {
      translate([0,0,arrow_len])
        rotate(180,[1,0,0])
          cylinder(h=arrow_len-0.5*arrow_d2, d1=arrow_d1, d2=arrow_d2);
      translate([0,0,0.5*arrow_d2])
        sphere(d=arrow_d2);
    }
  }
}

module offset_line(length, dia) {
  rotate(-90,[1,0,0]) {
    translate([0,0,0.5*dia])
      cylinder(h=length-dia,d=dia);
    translate([0,0,length-0.5*dia])
      sphere(d=dia);
    translate([0,0,0.5*dia])
      sphere(d=dia);
  }
}

dimoff=100;
dimdia=8;
dimdia2=6;
dimgap=20;
dmsf=7;
module dimension_thing( val, dtext, dtwid ) {
  translate([0,-dimoff,0]) {
    difference() {
      union() {
        dim_line(val, dimdia, 1, 1);
        translate([0,-dimgap,0])
          offset_line(dimoff, dimdia2);
        translate([val,-dimgap,0])
          offset_line(dimoff, dimdia2);
      }
      translate([0.5*val-0.5*dmsf*dtwid,-dmsf*5,-dmsf*5])
        scale([dmsf,dmsf,dmsf])
          cube([dtwid, 10, 10]);
    }
    translate([0.5*val-0.5*dmsf*dtwid,0,0])
      scale([dmsf,dmsf,dmsf])
        alpha_draw_string( 0, -5, 0, dtext, $cross=1);
  }
}

module make_dimensions() {
  color("blue")
    dimension_thing( cage.x, str(cage.x), getwid(str(cage.x)) );

  translate([cage.x,0,0])
  rotate(90,[0,0,1])
  color("green")
    dimension_thing( cage.y, str(cage.y), getwid(str(cage.y)) );

  translate([cage.x,cage.y,0])
  rotate(90,[0,0,1])
  rotate(-90,[0,1,0])
  color("red")
    dimension_thing( cage.z, str(cage.z), getwid(str(cage.z)) );
}


//========================================================================
// Make ISO grid lines, useful for tracing in 2D CAD 
//========================================================================
module iso_grid_using_line() {
  for(i=[-1000:100:1000]) {
    line([i,-1000,0], [i,1000,0], 2 );
    line([-1000,i,0], [1000,i,0], 2 );
  }
  for(i=[-1000:100*0.5:1000]) {
    line([i,i,-1000], [i,i,1000], 2 );
  }
}

module iso_grid(size=6000, spacing=100, dia=2.5) {
  #union() {
    for(i=[-size:spacing:size]) {
      translate([-0.5*size,i,0])
        rotate(90, [0,1,0]) cylinder(h=size,d=dia, $fn=0); // x
      translate([i,-0.5*size,0])
        rotate(-90, [1,0,0]) cylinder(h=size,d=dia, $fn=0); // y
    }
    for(i=[-0.5*size:0.5*spacing:0.5*size]) {
      translate([i,i,-0.5*size])
        cylinder(h=size,d=dia, $fn=0); // z
    }
  }
}




//========================================================================
// Finally, 900 lines later, let's draw something
//========================================================================

if(draw_axes) axis(1000,1000,1000,10);
if(draw_dimensions) make_dimensions();
if(draw_iso_grids) iso_grid();
if(draw_ghost) make_ghost( cage );

explode_cage();

// various testing turds
// extrusion( ex2020, 300 );
// make_panel( "panel.side.left", side_panel, ex2020, "bottom", "vlong", 0);
// extrusion( ex2020, 300, overunder=1);


