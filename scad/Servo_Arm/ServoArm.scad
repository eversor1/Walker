$fn=128;

include <servo_arm.scad>;

//Servo actuator joint
//TODO: Cleanly break out user variables

Servo_Base_X=24;
Servo_Base_Y=13;
Servo_Base_Z=5.5;
Servo_Gear=5/2;
Servo_Height=32.7; //Alter this with total Servo Height
//Servo_ToMount=(4.4)+15.8; //Alter this last amt to adj servo height //Blue Plastic
Servo_ToMount=(4.4)+18.6; //Alter this last amt to adj servo height //Metal
Connector_Width=10;
Connector_Height=4;
Height_To_Wire=5.5;
Servo_Screw_Offset=2;
Servo_Mount_Screw_Rad=1.9/2;
Servo_Mount_Screw_Height=10;
Depth_To_Cog=10;

M3_HeadHeight=3;
M3_HeadDia=5.75;
M3_Length=[7, 8.75, 14.61, 17, 17.75, 19, 22.79, 25.21, 32.75];
M3_ScrewDia=2.9;

//Arm
Servo_Arm_Gear_Dia=7.5;
Servo_Arm_Tip_Dia=3.5;
Servo_Arm_Length=15;
Arm_Thickness=3;
Arm_Width=(Servo_Base_X+9)*2+Servo_Height+5;
Servo_Arm_Plus_Length=10;
Servo_Arm_Plus_Width=4;
Servo_Arm_Offset=-2;
echo("Arm Width: ", Arm_Width);

Clip_Allowance=.5;

//servo head
FUTABA_3F_SPLINE = [
    [4.7, 4, 1.1, 2.5],
    [20, 0.3, 0.7, 0.1]
];

module ServoHead() {
    head_round=FUTABA_3F_SPLINE[0][0];
    difference() {
        union() {
            difference() {
                //servo spline match
                cylinder(r=head_round, h=7-Arm_Thickness);
                servo_head(FUTABA_3F_SPLINE);
            }
            hull() {
                hull() {
                    translate([0,0,7-Arm_Thickness]) cylinder(r=head_round, h=.1);
                    translate([0,Servo_Arm_Length, 7-Arm_Thickness]) cylinder(r=Servo_Arm_Tip_Dia/2, h=.1);
                }
                hull() {
                    translate([0,0,7-0.1]) cylinder(r=head_round-.5, h=.1);
                    translate([0,Servo_Arm_Length, 7-0.1]) cylinder(r=Servo_Arm_Tip_Dia/2-.5, h=.1);
                }
            }
            translate([0,Servo_Arm_Length*.75,7-.75]) cube([head_round*3, head_round, 1.5], center=true); 
        }
        cylinder(r=1.5, h=7);
        translate([0,0,7-1.5]) cylinder(r=3, h=7);
    }
}

module MountClip() {
    difference() {
        cube([Servo_Base_X+14, Servo_Base_Y+12, Servo_ToMount-4.4]);
        difference() {
            //take out the servo-seat
            translate([2-.4, (Servo_Base_Y+12)/2-(Servo_Base_Y+4+Clip_Allowance)/2, 0]) cube([Servo_Base_X+10+Clip_Allowance, Servo_Base_Y+4+Clip_Allowance, Servo_ToMount-4+Clip_Allowance]);
            //some side knotches for stability
            echo ((Servo_Base_Y+12)/2+(Servo_Base_Y+4+Clip_Allowance)/2-1);
            translate([((Servo_Base_X+11+Clip_Allowance*2)/3)+2-Clip_Allowance, (Servo_Base_Y+12)/2+(Servo_Base_Y+4+Clip_Allowance)/2-1, 0]) cube([((Servo_Base_X+10)/3)-Clip_Allowance*2, 1, Servo_ToMount-6-Clip_Allowance*2]);
            translate([((Servo_Base_X+11+Clip_Allowance*2)/3)+(2-Clip_Allowance), (Servo_Base_Y+12)/2-(Servo_Base_Y+4+Clip_Allowance)/2 , 0]) cube([((Servo_Base_X+10)/3)-Clip_Allowance*2, 1, Servo_ToMount-6-Clip_Allowance*2]);
        }
        //Open up the front
        translate([0, (Servo_Base_Y+12)/2-(Servo_Base_Y+4+Clip_Allowance-4)/2, 0]) cube([2, Servo_Base_Y+4+Clip_Allowance-4, Servo_ToMount-4+Clip_Allowance]);
        //screw Holes
        translate([4.5, Servo_Base_Y+12+Clip_Allowance, Servo_ToMount-8]) rotate([-90,0,0]) M3Screw(0);
        translate([4.5, -Clip_Allowance, Servo_ToMount-8]) rotate([90,0,0]) M3Screw(0);
        translate([Servo_Base_X+9-M3_ScrewDia/2-1+2-.4,Servo_Base_Y+12+Clip_Allowance, 7-4]) rotate([-90,0,0]) M3Screw(0);
        translate([Servo_Base_X+9-M3_ScrewDia/2-1+2-Clip_Allowance,-Clip_Allowance, 7-4]) rotate([90,0,0]) M3Screw(0);
    }
}

module M3Screw(num) {
    translate([0,0,-M3_Length[num]]) union() {
        translate([0,0,M3_Length[num]-M3_HeadHeight]) cylinder(r=M3_HeadDia/2, h=M3_HeadHeight);
        translate([0,0,0]) cylinder(r=M3_ScrewDia/2, h=M3_Length[num]);
    }
}

module MountBox() { 
    difference() {
        cube([Servo_Base_X+9, Servo_Base_Y+4, Servo_Height+6]);
        //take the middle out to fix servo
        hull() {
            translate([5,2,Servo_Height-2]) cube([Servo_Base_X, Servo_Base_Y, 2]);
            translate([5,2,3]) cube([Servo_Base_X-1, Servo_Base_Y, 2]);
        }
        //Take the top off
        translate([0,0,Servo_ToMount]) cube([Servo_Base_X+10, Servo_Base_Y+4, Servo_Height+6]);
        //remove some sides
        translate([((Servo_Base_X+10)/3), 0, 3]) cube([((Servo_Base_X+10)/3), 3, Servo_ToMount-6]);
        translate([((Servo_Base_X+10)/3), Servo_Base_Y+2, 3]) cube([((Servo_Base_X+10)/3), 3, Servo_ToMount-6]);
        //connector sleeve
        translate([0, (((Servo_Base_Y+4)/2)-(Connector_Width/2)), Height_To_Wire+(Connector_Height/2)]) cube([5, Connector_Width, Connector_Height]);
        //Screws
        translate([Servo_Screw_Offset+.5, ((Servo_Base_Y+4)/2), Servo_ToMount-Servo_Mount_Screw_Height]) cylinder(r=Servo_Mount_Screw_Rad, h=Servo_Mount_Screw_Height);
        translate([Servo_Screw_Offset+Servo_Base_X+5-.5, ((Servo_Base_Y+4)/2), Servo_ToMount-Servo_Mount_Screw_Height]) cylinder(r=Servo_Mount_Screw_Rad, h=Servo_Mount_Screw_Height);
        //Blow out the bottom
        translate([4.9,0,0]) cube([Servo_Base_X+.2, Servo_Base_Y+4, 4]);
        translate([0,(Servo_Base_Y+4)/2-(Servo_Base_Y-4)/2,0]) cube([Servo_Base_X+10, Servo_Base_Y-4, 4]);
        //screw Holes
        translate([2.5, (Servo_Base_Y+4)/2, 3]) cylinder(r=M3_ScrewDia/2, h=M3_Length[0]-M3_HeadHeight);
        translate([5+Servo_Base_X+1.5, (Servo_Base_Y+4)/2, 3]) cylinder(r=M3_ScrewDia/2, h=M3_Length[0]-M3_HeadHeight);
        //Allow for insertion with cable
        translate([4, (((Servo_Base_Y+4)/2)-(Connector_Width/2)), Height_To_Wire+(Connector_Height/2)]) cube([1, Connector_Width, 20]);
        
        //Side Mounts // - Left -> Right - Upper -> Lower
        translate([2.5, 0, Servo_ToMount-4]) rotate([-90,0,0]) cylinder(r=M3_ScrewDia/2, h=M3_Length[0]);
        translate([2.5, Servo_Base_Y+4, Servo_ToMount-4]) rotate([90,0,0]) cylinder(r=M3_ScrewDia/2, h=M3_Length[0]);
        translate([Servo_Base_X+9-M3_ScrewDia/2-1, 0, 7]) rotate([-90,0,0]) cylinder(r=M3_ScrewDia/2, h=M3_Length[0]);
        translate([Servo_Base_X+9-M3_ScrewDia/2-1, Servo_Base_Y+4, 7]) rotate([90,0,0]) cylinder(r=M3_ScrewDia/2, h=M3_Length[0]);
    }
}

module MountBase() {
    difference() {
        union() {
            cube([Servo_Base_X+9, Servo_Base_Y+4, 4]);
            translate([5+Servo_Base_Y/2, 2+Servo_Base_Y/2, 4]) cylinder(r1=Servo_Base_Y/2-1.5, r2=Servo_Base_Y/2-1, h=3);
            translate([5+Servo_Base_Y/2, 2+Servo_Base_Y/2,7]) scale([1,1,.3]) sphere(r=Servo_Base_Y/2-1);
        }
        //Screw Holes
        translate([2.5, 2+Servo_Base_Y/2, 1]) rotate([0,0,0]) cylinder(r=M3_HeadDia/2, h=M3_HeadHeight*2);
        translate([5+Servo_Base_X+1.5, 2+Servo_Base_Y/2, 1]) rotate([0,0,0]) cylinder(r=M3_HeadDia/2, h=M3_HeadHeight*2);
        
        translate([2.5, 2+Servo_Base_Y/2, 0]) rotate([0,0,0]) cylinder(r=M3_ScrewDia/2, h=1);
        translate([5+Servo_Base_X+1.5, 2+Servo_Base_Y/2, 0]) rotate([0,0,0]) cylinder(r=M3_ScrewDia/2, h=1);
        
        //corners
        translate([0,Servo_Base_Y-.4,0]) cube([5,4+.4,4]);
        translate([5+Servo_Base_X,0,0]) cube([5,4+.4,4]);
        translate([5+Servo_Base_X,Servo_Base_Y-.4,0]) cube([5,4+.4,4]);
        translate([0,0,0]) cube([5,4+.4,4]);
    }
}

module ServoArm() { //TODO: 1. Move the Arm Hull to it's own module. 2. provide for all 3 kinds of servo arms.
    difference() {
        union() {
            //Horizontal member
            cube([Arm_Width, Servo_Base_Y+6, Arm_Thickness]);
            translate([0, (Servo_Base_Y+6)/2, 0]) cylinder(r=(Servo_Base_Y+6)/2, h=Arm_Thickness); 
            translate([Arm_Width, (Servo_Base_Y+6)/2, 0]) cylinder(r=(Servo_Base_Y+6)/2, h=Arm_Thickness);
            //Vertical Member
            translate([((Arm_Width)/2)-(Servo_Base_Y+6)/2, -(((Arm_Width)/2)-((Servo_Base_Y+6)/2)), 0]) cube([Servo_Base_Y+6, Arm_Width, 3]);
            translate([Arm_Width/2, (Arm_Width/2)+((Servo_Base_Y+6)/2), 0]) cylinder(r=(Servo_Base_Y+6)/2, h=Arm_Thickness); 
            translate([Arm_Width/2, -((Arm_Width/2)-(Servo_Base_Y+6)/2), 0]) cylinder(r=(Servo_Base_Y+6)/2, h=Arm_Thickness);
        }
        //Actuiator Holes
        translate([0, Servo_Base_Y/2+3, 0]) cylinder(r1=Servo_Base_Y/2-1+.2,r2=Servo_Base_Y/2-1.5+.2, h=Arm_Thickness);
        translate([Arm_Width/2, (Arm_Width/2)+((Servo_Base_Y+6)/2), 0]) cylinder(r1=Servo_Base_Y/2-1.5+.2, r2=Servo_Base_Y/2-1+.2, h=Arm_Thickness);
        //Servo Arm form Horiz
        translate([Arm_Width-Servo_Arm_Offset, Servo_Base_Y/2+3,0]) cylinder(r=Servo_Arm_Gear_Dia/2, h=Arm_Thickness);
        translate([Arm_Width-Servo_Arm_Offset, Servo_Base_Y/2+3,7.21]) scale([1.05, 1.05, 1.05]) rotate([0,180,90]) ServoHead();
        /*
        hull() {
            translate([Arm_Width-Servo_Arm_Offset, Servo_Base_Y/2+3,0]) cylinder(r=Servo_Arm_Gear_Dia/2, h=Arm_Thickness-1.5);
            translate([Arm_Width-Servo_Arm_Length-Servo_Arm_Offset, Servo_Base_Y/2+3,0]) cylinder(r=Servo_Arm_Tip_Dia/2, h=Arm_Thickness-1.5);
        }
        */
        //Servo Arm form Vertical
        translate([Arm_Width/2, -((Arm_Width/2)-(Servo_Base_Y/2+3))+Servo_Arm_Offset,0]) cylinder(r=Servo_Arm_Gear_Dia/2, h=Arm_Thickness);
        translate([Arm_Width/2, -((Arm_Width/2)-(Servo_Base_Y/2+3))+Servo_Arm_Offset,Arm_Thickness-7.21]) scale([1.05, 1.05, 1.05]) ServoHead();
        /*
        hull() {
            translate([Arm_Width/2, -((Arm_Width/2)-(Servo_Base_Y/2+3))+Servo_Arm_Offset,Arm_Thickness-1.5]) cylinder(r=Servo_Arm_Gear_Dia/2, h=Arm_Thickness-1.5);
            translate([Arm_Width/2, -((Arm_Width/2)-(Servo_Base_Y/2+3)-Servo_Arm_Length)+Servo_Arm_Offset,Arm_Thickness-1.5]) cylinder(r=Servo_Arm_Tip_Dia/2, h=Arm_Thickness-1.5);
        }*/
        //Middle Plus
        translate([Arm_Width/2-Servo_Arm_Plus_Length/2, (Servo_Base_Y+6)/2-Servo_Arm_Plus_Width/2, 0]) cube([Servo_Arm_Plus_Length, Servo_Arm_Plus_Width, Arm_Thickness]);
        translate([Arm_Width/2-Servo_Arm_Plus_Width/2,(Servo_Base_Y+6)/2-Servo_Arm_Plus_Length/2, 0]) cube([Servo_Arm_Plus_Width, Servo_Arm_Plus_Length, Arm_Thickness]);
        //Wire Catch
        translate([Arm_Width/2+Servo_Arm_Plus_Length/2+2, (Servo_Base_Y+6)/2,0]) rotate([0,0,90]) WireCatch();
        translate([Arm_Width/2-Servo_Arm_Plus_Length/2-2, (Servo_Base_Y+6)/2,0]) rotate([0,0,-90]) WireCatch();
        translate([Arm_Width/2, (Servo_Base_Y+6)/2-Servo_Arm_Plus_Length/2-2, 0]) WireCatch();
        translate([Arm_Width/2, (Servo_Base_Y+6)/2+Servo_Arm_Plus_Length/2+2, 0]) rotate([0,0,180]) WireCatch();
    }
    module WireCatch() {
        translate([-1.6/2, 0, 0]) cylinder(r=1.8/2, h=Arm_Thickness);
        translate([0, 0, 0]) cylinder(r=1.8/2, h=Arm_Thickness);
        translate([1.6/2, 0, 0]) cylinder(r=1.8/2, h=Arm_Thickness);
        translate([0,1.6,Arm_Thickness/2]) cube([2,1.8,Arm_Thickness], center=true);
    }
}

module Mold() {
    difference() {
        minkowski() {
            cube([Servo_Height-4, (Servo_Base_Y+6)/2, Servo_Base_X+9-6]);
            rotate([90,0,0]) cylinder(r=3, h=(Servo_Base_Y+6)/2);
        }
        translate([-3, -(Servo_Base_Y+6)/2, Servo_Base_X+9-6]) cube([Servo_Height+8.5, Servo_Base_Y+6, 3]);
    }
    translate([(Servo_Height-4.4)/2-(Servo_Arm_Plus_Width-.4)/2, -(Servo_Arm_Plus_Length)/2, -6]) cube([Servo_Arm_Plus_Width-.4, Servo_Arm_Plus_Length-.4, Arm_Thickness]);
    translate([(Servo_Height-4.4)/2-(Servo_Arm_Plus_Length-.4)/2, -(Servo_Arm_Plus_Width)/2, -6]) cube([Servo_Arm_Plus_Length-.4, Servo_Arm_Plus_Width-.4, Arm_Thickness]);
}

module MountClip2Spring(spring_box_width, end_depth=10) {
    MountClip();
    end_depth=10;
    // clip base - cube([Servo_Base_X+14, Servo_Base_Y+12, Servo_ToMount-4.4]);
    difference() {
        translate([Servo_Base_X+14, 0,0]) cube([end_depth, Servo_Base_Y+12, Servo_ToMount-4.4]);
        translate([Servo_Base_X+14, ((Servo_Base_Y+12)/2-spring_box_width/2), 0]) cube([end_depth, spring_box_width, Servo_ToMount-4.4]);
        //screw holes
        translate([Servo_Base_X+14+end_depth/2, -2, Servo_ToMount-4.4-7.5]) rotate([90,0,0]) M3Screw(8);
    }
}

module Servo2Spring(spring_box_width) {
    distance=14;
    spring_screw=16;
    spring_end_height=24;
    end_depth=10; //from spring
    difference() {
        cube([distance+spring_end_height+(Servo_Base_Y), Servo_Height+(Arm_Thickness*2), Servo_Base_Y+6]);
        //take out the spring side
        translate([distance+(Servo_Base_Y), (Servo_Height+(Arm_Thickness*2))/2-(spring_box_width/2), 0]) cube([spring_end_height, spring_box_width, Servo_Base_Y+6-end_depth+2]);
        //take out the screw holes
        translate([distance+(Servo_Base_Y)+spring_screw, 0, end_depth/2]) rotate([270,0,0])cylinder(r=2.9/2, h=Servo_Height+(Arm_Thickness*2));
        //take out the servo area
        translate([0, Arm_Thickness, 0]) cube([Servo_Base_Y+distance, Servo_Height, Servo_Base_Y+6]);
        //Actuator Hole
        translate([4+(Servo_Base_Y/2-1.5+.2), Servo_Height+3, (Servo_Base_Y+6)/2]) rotate([270,0,0])cylinder(r1=Servo_Base_Y/2-1.5+.2, r2=Servo_Base_Y/2-1+.2, h=Arm_Thickness);
        //Servo Arm Hole
        translate([4+(Servo_Base_Y/2-1.5+.2), 7.25, (Servo_Base_Y+6)/2]) rotate([90,90,0]) scale([1.05, 1.05, 1.05]) ServoHead();
        //Remove Servo Arm Center
        translate([4+(Servo_Base_Y/2-1.5+.2), 0, (Servo_Base_Y+6)/2])rotate([270,0,0]) cylinder(r=5, h=Arm_Thickness+1);
        //Split in half
        translate([0, (Servo_Height+(Arm_Thickness*2))/2 - (Arm_Thickness)/2, 0]) cube([distance+spring_end_height+(Servo_Base_Y), Arm_Thickness, Servo_Base_Y+6]);
    }
}

Servo2Spring(22);
//M3Screw(0);
//MountBox();
//MountClip();
//translate([0, Servo_Base_Y+4, 4]) rotate([180,0,0]) MountBase();
//MountBase();
//ServoArm();
//translate([(Arm_Width/2)-(Servo_Height-.2)/2+.2, (Servo_Base_Y+6)/2+.2, 6]) Mold();
//Mold();
//ServoHead();
//MountClip2Spring(22, 10);
 //       translate([Servo_Base_X+14+10/2, -2, Servo_ToMount-4.4-7.5]) rotate([90,0,0]) M3Screw(8);