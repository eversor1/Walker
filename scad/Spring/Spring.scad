include <../Servo_Arm/ServoArm.scad>;
$fn=128;

M3ScrewDia=2.9;

module end(width, height, end_depth, round_rad) {
    difference(width, height, end_depth, round_rad) {
        cube([width-round_rad, end_depth, height]);
        //screw hole
        translate([(width-round_rad)/2, end_depth/2, 0]) cylinder(r=M3ScrewDia/2, h=height);
    }
}

module spring_segment(width, height, thickness, round_rad) {
    difference() {
        union() {
            cylinder(r=round_rad, h=height);
            translate([0, -round_rad, 0]) cube([width-round_rad, round_rad*2, height]);
        }
        union() {
            cylinder(r=round_rad-thickness, h=height);
            translate([0, -(round_rad-thickness), 0]) cube([width-round_rad, (round_rad-1)*2, height]);
        }
    }
}

function calc_spring_length(round_rad, thickness, segments, end_depth) = ((round_rad*2-(thickness))*(segments+1)-(thickness/2)+(end_depth*2));


module spring(width, height, thickness, segments, end_depth, spring_scale=4) { 
    round_rad=width/spring_scale;
    for (x=[0:1:segments]) {
        translate([(width-round_rad)*(x%2), (round_rad*2-thickness)*x, 0]) {
            if (x%2==1) {
                mirror([1,0,0]) spring_segment(width, height, thickness, round_rad);
            } else {
                spring_segment(width, height, thickness, round_rad);
            }
        }
    }
    translate([0, -round_rad-end_depth+thickness, 0]) end(width, height, end_depth, round_rad);
    translate([0, (round_rad*2-(thickness))*(segments+.5)-(thickness/2), 0]) end(width, height, end_depth, round_rad);
    spring_length=calc_spring_length(round_rad, thickness, segments, end_depth);
    echo("round_rad: ", round_rad);
    echo("Length: ", spring_length);
}

module spring_box_bottom (spring_width, spring_height, spring_thickness, spring_segments, end_depth, spring_scale=4, box_thickness, length_multiplier) {
    overlap=3;
    round_rad=spring_width/spring_scale;
    spring_length=calc_spring_length(round_rad, spring_thickness, spring_segments, end_depth);
    echo("Spring Length: ", spring_length);
    difference() {
        union() {
             cube([spring_height+(box_thickness*2)+1, spring_length*length_multiplier+end_depth, spring_width+1+box_thickness+round_rad]);
             translate([-(sqrt(9)),0,0]) cube([spring_height+(box_thickness*2)+1+(sqrt(9)*2), end_depth, spring_width+1+box_thickness+round_rad]);
            translate([0,end_depth+(spring_length*length_multiplier)/2, (spring_width+round_rad)/2+1+box_thickness]) rotate([0, 45, 0]) cube([3,spring_length*length_multiplier,3], center=true);
            translate([spring_height+(box_thickness*2)+1,end_depth+(spring_length*length_multiplier)/2, (spring_width+round_rad)/2+1+box_thickness]) rotate([0, 45, 0]) cube([3,spring_length*length_multiplier,3], center=true);
        }
        //cut out spring channel
        translate([box_thickness, end_depth, box_thickness]) cube([spring_height+1, spring_length*length_multiplier, spring_width+1+round_rad]);
        //cut out end clamp
        translate([box_thickness, 0, round_rad]) cube([spring_height+1, end_depth, spring_width+round_rad]);
        //take the top off of the box
        translate([0, end_depth, (spring_width+round_rad)/2+1+box_thickness+overlap]) cube([spring_height+1+(box_thickness*3)+overlap, spring_length, spring_width/2+round_rad]);
        //take the top off of the end
        translate([-(sqrt(9)), 0, (spring_width)+1+box_thickness]) cube([spring_height+1+(box_thickness*3)+overlap+sqrt(9), end_depth, spring_width]);
        //Screw thru-hole
        translate([box_thickness*3+overlap+spring_height+1.01+3, end_depth/2, 1+box_thickness+(spring_width+round_rad)/2]) rotate([0,90,0]) M3Screw(8);
    }
    echo("Bottom Screwdown Width: ", box_thickness*3+overlap+spring_height+1);
}

module spring_box_top (spring_width, spring_height, spring_thickness, spring_segments, end_depth, spring_scale=4, box_thickness, length_multiplier) {
    overlap=3;
    round_rad=spring_width/spring_scale;
    spring_length=calc_spring_length(round_rad, spring_thickness, spring_segments, end_depth);
    echo("Spring Length: ", spring_length);
    difference() {
        //main box
        translate([-(sqrt(9)),0,0]) cube([spring_height+(box_thickness*2)+1+(sqrt(9)*2), spring_length*length_multiplier+end_depth, spring_width+1+box_thickness+round_rad]);
        
        translate([box_thickness, end_depth, box_thickness]) cube([spring_height+1, spring_length*length_multiplier, spring_width+1+round_rad]);
        //cut out end clamp
        translate([box_thickness, 0, round_rad]) cube([spring_height+1, end_depth, spring_width+round_rad]);
        //take the top off of the box **
        translate([-sqrt(9), end_depth, (spring_width+round_rad)/2+1+box_thickness+overlap]) cube([spring_height+1+(box_thickness*3)+overlap+sqrt(9), spring_length, spring_width/2+round_rad]);
        //take the top off of the end **
        translate([-(sqrt(9)), 0, (spring_width)+1+box_thickness]) cube([spring_height+1+(box_thickness*3)+overlap+sqrt(9), end_depth, spring_width]);
        //Screw thru-hole **
        translate([box_thickness*3+overlap+spring_height+1.01+3, end_depth/2, 1+box_thickness+(spring_width+round_rad)/2]) rotate([0,90,0]) M3Screw(8);
        //take out the slide channels
        translate([0,end_depth+(spring_length*length_multiplier)/2, (spring_width+round_rad)/2+1+box_thickness]) rotate([0, 45, 0]) cube([3.5,spring_length*length_multiplier,3.5], center=true);
        translate([spring_height+(box_thickness*2)+1,end_depth+(spring_length*length_multiplier)/2, (spring_width+round_rad)/2+1+box_thickness]) rotate([0, 45, 0]) cube([3.5,spring_length*length_multiplier,3.5], center=true);
        
        translate([-.5, end_depth, (spring_width/2)+1+box_thickness-1]) cube([spring_height+box_thickness*2+2, spring_length*length_multiplier, spring_width+.5]); 
    }
    echo("Top Screwdown Width: ", box_thickness*2+spring_height+2+(sqrt(9)*2));
}

//USAGE:
//spring(width, height, thickness, segments, end_depth, spring_scale=4)
//spring_box_bottom(spring_width, spring_height, spring_thickness, spring_segments, end_depth, spring_scale=4, box_thickness, length_multiplier)
//spring_box_top(spring_width, spring_height, spring_thickness, spring_segments, end_depth, spring_scale=4, box_thickness, length_multiplier)

//spring(20, 10, 1, 7, 10, 4);

spring_box_top(20, 10, 1, 5, 10, 4, 2, .6);
//spring_box_bottom(20, 10, 1, 5, 10, 4, 2, .6);
//translate([0,91.5+20,26]) rotate([180,0,0]) spring_box_bottom(20, 10, 1, 7, 10, 4, 2, .6);


module demo() {
    spring_box_top(20, 10, 1, 7, 10, 4, 2, .55);
    translate([0,91,31]) rotate([180,0,0]) spring_box_bottom(20, 10, 1, 7, 10, 4, 2, .55);
    translate([2.5,10+4,20+2+1]) rotate([0,90,0]) spring(20, 10, 1, 7, 10, 4);
}
    
//demo();















