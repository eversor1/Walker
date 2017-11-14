include <../Servo_Arm/ServoArm.scad>;
include <honeycomb.scad>;

$fn=128;

Bot_Length=150;
Bot_Width=100;
Bot_Height=Servo_ToMount;

Battery_Height=14;
Battery_Width=28.5;
Battery_Depth=70;
Battery_Wall=2;

Board_Width=68;
Board_Depth=85;
Board_Mount_Depth=75;
Board_Mount_Width=55;

Battery_Connector_Height=4;
Battery_Connector_Width=7;
Battery_Connector_Depth=19;

Cell_Size=5;
Fill_Percent=25;
//legs
Lower_Leg_Dia=8;


module Body() {
    difference() {
        hull() {
            translate([-Bot_Width/4, Bot_Length/4, 0]) rotate([0,0,-30]) cube([Bot_Width/2, Bot_Length/2, Bot_Height], center=true);
            translate([-Bot_Width/4,-Bot_Length/4, 0]) rotate([0,0,30]) cube([Bot_Width/2, Bot_Length/2, Bot_Height], center=true);
            translate([Bot_Width/4,Bot_Length/4, 0]) rotate([0,0,30]) cube([Bot_Width/2, Bot_Length/2, Bot_Height], center=true);
            translate([Bot_Width/4, -Bot_Length/4, 0]) rotate([0,0,-30]) cube([Bot_Width/2, Bot_Length/2, Bot_Height], center=true);
        }
        //take out the center
        difference() {       
            scale([0.95,0.95,1]) hull() {
                translate([-Bot_Width/4, Bot_Length/4, 0]) rotate([0,0,-30]) cube([Bot_Width/2, Bot_Length/2, Bot_Height], center=true);
                translate([-Bot_Width/4,-Bot_Length/4, 0]) rotate([0,0,30]) cube([Bot_Width/2, Bot_Length/2, Bot_Height], center=true);
                translate([Bot_Width/4,Bot_Length/4, 0]) rotate([0,0,30]) cube([Bot_Width/2, Bot_Length/2, Bot_Height], center=true);
                translate([Bot_Width/4, -Bot_Length/4, 0]) rotate([0,0,-30]) cube([Bot_Width/2, Bot_Length/2, Bot_Height], center=true);
            }
            //add support members for battery box
            
            difference() {
                union() {
                    //horizontal support
                    hull() {
                        translate([0, -50, +(Bot_Height/2)]) cube([100, 15, 1], center=true);
                        translate([0, -50, +(Bot_Height/2)-1]) cube([100, 10, 1], center=true);
                    }
                    //Vertical support
                    hull() {
                        translate([0, -30, +(Bot_Height/2)]) cube([15, 40, 1], center=true);
                        translate([0, -30, +(Bot_Height/2)-1]) cube([10, 40, 1], center=true);
                    }
                }
                //screw Holes here
                translate([(Battery_Width+Battery_Wall*1.5)+3, -50, (Bot_Height/2)-5]) rotate([180,0,0]) M3Screw(2);
                translate([-(Battery_Width+Battery_Wall*1.5)-3, -50, (Bot_Height/2)-5]) rotate([180,0,0]) M3Screw(2);
            }
        }
        //Cable Passthru
        rotate([0, 90, 0]) cylinder(r=5, h=150, center=true);
        //Battery Holder Cutout
        translate([-((Battery_Width*2+Battery_Wall*3)+1)/2, -140, -Bot_Height/2]) cube([(Battery_Width*2+Battery_Wall*3)+1, Battery_Depth+Battery_Wall, Bot_Height]);
        //Servo Screw Mounts
        //Front Left
        translate([-50, 33,-(Servo_ToMount/2)]) rotate([0,0,60]) union() {
            translate([2.5, 0, Servo_ToMount-4]) rotate([90,0,0]) M3Screw(1);
            translate([Servo_Base_X+9-M3_ScrewDia/2-1, 0, 7])  rotate([90,0,0]) M3Screw(1);
        }
        //Back Left
        mirror([0,1,0]) translate([-50, 33,-(Servo_ToMount/2)]) rotate([0,0,60]) union() {
            translate([2.5, 0, Servo_ToMount-4]) rotate([90,0,0]) M3Screw(1);
            translate([Servo_Base_X+9-M3_ScrewDia/2-1, 0, 7])  rotate([90,0,0]) M3Screw(1);
        }
        //Front Right
        mirror([1,0,0]) translate([-50, 33,-(Servo_ToMount/2)]) rotate([0,0,60]) union() {
            translate([2.5, 0, Servo_ToMount-4]) rotate([90,0,0]) M3Screw(1);
            translate([Servo_Base_X+9-M3_ScrewDia/2-1, 0, 7])  rotate([90,0,0]) M3Screw(1);
        }
        //Back Right
        mirror([1,0,0]) mirror([0,1,0]) translate([-50, 33,-(Servo_ToMount/2)]) rotate([0,0,60]) union() {
            translate([2.5, 0, Servo_ToMount-4]) rotate([90,0,0]) M3Screw(1);
            translate([Servo_Base_X+9-M3_ScrewDia/2-1, 0, 7])  rotate([90,0,0]) M3Screw(1);
        }
    }
    //Board Mount
    translate([-Board_Depth/2,-11,Servo_ToMount/2-2]) {
        difference() {
            honeycomb(Board_Depth/((Cell_Size/2)*3), Board_Width/((Cell_Size/2)*3), 0, Cell_Size, 2, Fill_Percent);
            difference() {
                cube([100,100,5]);
                cube([Board_Depth, Board_Width, 5]);
            }
        }
        //add a nice border
        difference() {
            cube([Board_Depth, Board_Width, 2]);
            translate([1,1,0]) cube([Board_Depth-2, Board_Width-2, 2]);
        }
        Mount_Height=6;
        //Board Mount Screws
        translate([5,7.5,2]) {
            translate([0, 0, 0]) rotate([180,0,0]) ScrewMount(5,Mount_Height-2,1 ); //reduced for battery box mount
            translate([0, Board_Mount_Width, 0]) rotate([180,0,0]) ScrewMount(5,Mount_Height,1);
            translate([Board_Mount_Depth, 0, 0]) rotate([180,0,0]) ScrewMount(5,Mount_Height-2,1); //reduced for battery box mount
            translate([Board_Mount_Depth, Board_Mount_Width, 0]) rotate([180,0,0]) ScrewMount(5,Mount_Height,1);
        }
    }
    //Lid Screws
    translate([0,0,-(Servo_ToMount/2)+2]) union() {
        translate([-Bot_Width/4,Bot_Length/2,0]) ScrewMount(5, Servo_ToMount-2, 8);
        //mirror([0,1,0]) translate([-Bot_Width/4,Bot_Length/2,0]) ScrewMount(5, 4, 8);
        translate([-59, 16,0]) ScrewMount(5, Servo_ToMount-2, 8);
        mirror([0,1,0]) translate([-59, 16,0]) ScrewMount(5, Servo_ToMount-2, 8);
    }
    mirror([1,0,0]) translate([0,0,-(Servo_ToMount/2)+2]) union() {
        translate([-Bot_Width/4,Bot_Length/2,0]) ScrewMount(5, Servo_ToMount-2, 8);
        //mirror([0,1,0]) translate([-Bot_Width/4,Bot_Length/2,0]) ScrewMount(5, 4, 8);
        translate([-59, 16,0]) ScrewMount(5, Servo_ToMount-2, 8);
        mirror([0,1,0]) translate([-59, 16,0]) ScrewMount(5, Servo_ToMount-2, 8);
    }
}

module ScrewMount(radius, height, num) {
    difference() {
        cylinder(r=radius, h=height);
        translate([0,0,M3_HeadHeight+height]) M3Screw(num);
    }
}

module BatteryBox() {
    difference() {
        //Main Block
        union() {
            translate([0,0,0]) cube([Battery_Width*2+Battery_Wall*3, Battery_Depth+Battery_Wall, Bot_Height], center=true);
                //Back Mounting fin
            difference() {
                translate([-Board_Depth/2, (Battery_Depth+Battery_Wall)/2-10, -((Battery_Height+Battery_Wall*2)/2)+1.7]) cube([Board_Depth, 25, 2]);
                //taper edges for better printing
                translate([-(Battery_Width+Battery_Wall*1.5)-11, Battery_Depth/2+Battery_Wall-11, 0]) rotate([0,0,45]) cube(center=true, [15,15, Bot_Height]);
                translate([+(Battery_Width+Battery_Wall*1.5)+11, Battery_Depth/2+Battery_Wall-11, 0]) rotate([0,0,45]) cube(center=true, [15,15, Bot_Height]);
                //add screw holes
                translate([Board_Mount_Depth/2, (Battery_Depth+Battery_Wall)/2+7.5, 0]) rotate([0,0,0]) M3Screw(2);
                translate([-Board_Mount_Depth/2, (Battery_Depth+Battery_Wall)/2+7.5, 0]) rotate([0,0,0]) M3Screw(2);
            }
            //Battery and lower lid mounting
            difference() {
                hull() {
                    translate([-(Battery_Width+Battery_Wall*1.5)-3, -(Battery_Depth/2)+32, -(Bot_Height/2)]) ScrewMount(5, 6, 2);
                    translate([-(Battery_Width+Battery_Wall*1.5), -(Battery_Depth/2)+22, -(Bot_Height/2)]) cylinder(r=1, h=6);
                }
                translate([-(Battery_Width+Battery_Wall*1.5)-3, -(Battery_Depth/2)+32, -(Bot_Height/2)-3]) rotate([180,0,0]) M3Screw(2);
            }
            difference() {
                hull() {
                    translate([(Battery_Width+Battery_Wall*1.5)+3, -(Battery_Depth/2)+32, -(Bot_Height/2)]) ScrewMount(5, 6, 2);
                    translate([(Battery_Width+Battery_Wall*1.5), -(Battery_Depth/2)+22, -(Bot_Height/2)]) cylinder(r=1, h=6);
                }
                translate([(Battery_Width+Battery_Wall*1.5)+3, -(Battery_Depth/2)+32, -(Bot_Height/2)-3]) rotate([180,0,0]) M3Screw(2);
            }
        }
        //cutout for Battery1
        translate([-(Battery_Width+Battery_Wall)/2, -Battery_Wall/2, -(Bot_Height/2-((Battery_Height+Battery_Wall*2)/2))]) cube([Battery_Width, Battery_Depth, Battery_Height], center=true);
        //Cutout for Battery2
        translate([(Battery_Width+Battery_Wall)/2, -Battery_Wall/2, -(Bot_Height/2-((Battery_Height+Battery_Wall*2)/2))]) cube([Battery_Width, Battery_Depth, Battery_Height], center=true);
        //take the back half of the top off (past the connector holders
        translate([0,Battery_Wall/2+Battery_Connector_Depth+Battery_Wall, Battery_Height+Battery_Wall*2]) cube([Battery_Width*2+Battery_Wall*3, Battery_Depth, Bot_Height], center=true);
        //cut out left of the connector
        translate([-(Battery_Wall*1.5+Battery_Width), -(Battery_Depth/2)+Battery_Wall+10, -Bot_Height/2+Battery_Height+Battery_Wall*2]) cube([(Battery_Width*2+Battery_Wall*3)/4-(Battery_Connector_Width+Battery_Wall*2)/2, Battery_Depth, (Bot_Height-Battery_Height+Battery_Wall*2)/2]);
        //cut out between connectors
        translate([-(Battery_Wall*1.5+Battery_Width)/2+(Battery_Connector_Width+Battery_Wall*2)/2, -(Battery_Depth/2)+Battery_Wall, -Bot_Height/2+Battery_Height+Battery_Wall*2]) cube([((((Battery_Width*2+Battery_Wall*3))-(Battery_Connector_Width*2+Battery_Wall*4))/4)*2, Battery_Depth, (Bot_Height-Battery_Height+Battery_Wall*2)/2]);
        //cut out right of connector
        translate([(Battery_Wall*1.5+Battery_Width)/2+(Battery_Connector_Width+Battery_Wall*2)/2, -(Battery_Depth/2)+Battery_Wall+10, -Bot_Height/2+Battery_Height+Battery_Wall*2]) cube([(Battery_Width*2+Battery_Wall*3)/4-(Battery_Connector_Width+Battery_Wall*2)/2, Battery_Depth, (Bot_Height-Battery_Height+Battery_Wall*2)/2]);
        //cut out left connector insert
        translate([-(Battery_Wall*1.5+Battery_Width)/2-Battery_Connector_Width/2, -(Battery_Depth/2)+Battery_Wall, -Bot_Height/2+Battery_Height+Battery_Wall*2]) cube([Battery_Connector_Width, Battery_Connector_Depth, (Bot_Height-Battery_Height+Battery_Wall*2)/2]);
        //cut out right connector insert
        translate([(Battery_Wall*1.5+Battery_Width)/2-Battery_Connector_Width/2, -(Battery_Depth/2)+Battery_Wall, -Bot_Height/2+Battery_Height+Battery_Wall*2]) cube([Battery_Connector_Width, Battery_Connector_Depth, (Bot_Height-Battery_Height+Battery_Wall*2)/2]);
        //cut out right Battery connector passthru
        translate([-(Battery_Wall*1.5+Battery_Width)/2-Battery_Connector_Width/2, -(Battery_Depth/2)-2, -Bot_Height/2+Battery_Height+Battery_Wall*2]) cube([Battery_Connector_Width, Battery_Connector_Depth, Battery_Connector_Height]);
        //cut out left Battery connector passthru
        translate([(Battery_Wall*1.5+Battery_Width)/2-Battery_Connector_Width/2, -(Battery_Depth/2)-2, -Bot_Height/2+Battery_Height+Battery_Wall*2]) cube([Battery_Connector_Width, Battery_Connector_Depth, Battery_Connector_Height]);
        //cut out left Battery Wire passthru
        translate([-(Battery_Wall*1.5+Battery_Width)/2-(Battery_Connector_Width-Battery_Wall*2)/2, -(Battery_Depth/2)+4, -Bot_Height/2+Battery_Height+Battery_Wall*2]) cube([Battery_Connector_Width-(Battery_Wall*2), Battery_Connector_Depth, (Bot_Height-Battery_Height+Battery_Wall*2)/2]);
        //cut out right Battery Wire Passthru
        translate([(Battery_Wall*1.5+Battery_Width)/2-(Battery_Connector_Width-Battery_Wall*2)/2, -(Battery_Depth/2)+4, -Bot_Height/2+Battery_Height+Battery_Wall*2]) cube([Battery_Connector_Width-(Battery_Wall*2), Battery_Connector_Depth, (Bot_Height-Battery_Height+Battery_Wall*2)/2]);
        //cut out any portion in conflict with the body
        translate([0,47,-0.01]) rotate([0,180,0]) Body();
    }
    //Add some lid mounts
    //top lid
    translate([-(Battery_Width+Battery_Wall*1.5)+5, -(Battery_Depth/2)+14, (Bot_Height/2)-5]) ScrewMount(5, 3, 2);
     translate([(Battery_Width+Battery_Wall*1.5)-5, -(Battery_Depth/2)+14, (Bot_Height/2)-5]) ScrewMount(5, 3, 2);
    //bottom lid
}


//ScrewMount(5,6,2);
//Body();
//translate([0,-47,0]) rotate([0,180,0]) BatteryBox();
//BatteryBox();
