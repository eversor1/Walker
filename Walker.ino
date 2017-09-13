#include <Wire.h>
#include "PCA9685.h"

PCA9685 pwmController;                  // Library using default Wire and default linear phase balancing scheme
PCA9685_ServoEvaluator pwmServo1;

struct step {
  word leg1;
  word leg2;
  word leg3;
  word leg4;
  word hip1;
  word hip2;
  word hip3;
  word hip4;
};

void setup() {
  Serial.begin(115200);

  Wire.begin();                       // Wire must be started first
  Wire.setClock(400000);              // Supported baud rates are 100kHz, 400kHz, and 1000kHz

  pwmController.resetDevices();       // Software resets all PCA9685 devices on Wire line
  pwmController.init(B000000);        // Address pins A5-A0 set to B010101
  pwmController.setPWMFrequency(50); // Default is 200Hz, supports 24Hz to 1526Hz
}

//LIMITS!! 102-500
class Walk {
  int walkSpeed=0; //inverse - lower is faster
  int turnSpeed=0;
  int strafeSpeed=0;
  int minDelay=150;
  int minPWMLimit=102;
  int maxPWMLimit=500;

  void send(step legs) {
    word servo[8]={legs.leg1, legs.leg2, legs.leg3, legs.leg4, legs.hip1, legs.hip2, legs.hip3, legs.hip4};
    delay(minDelay+(walkSpeed * 50));
    pwmController.setChannelsPWM(0,8,servo);
  }

  step trot0() {
    Serial.println("Step0");
    step srv;
    srv.leg1=pwmServo1.pwmForAngle(-45);
    srv.leg2=pwmServo1.pwmForAngle(20);
    srv.leg3=pwmServo1.pwmForAngle(-45);
    srv.leg4=pwmServo1.pwmForAngle(20);
    srv.hip1=pwmServo1.pwmForAngle(-45);
    srv.hip2=pwmServo1.pwmForAngle(-45);
    srv.hip3=pwmServo1.pwmForAngle(45);
    srv.hip4=pwmServo1.pwmForAngle(45);
    return srv;
  }

  step trot1() {
    Serial.println("Step1");
    step srv;
    srv.leg1=pwmServo1.pwmForAngle(-45);
    srv.leg2=pwmServo1.pwmForAngle(20);
    srv.leg3=pwmServo1.pwmForAngle(-45);
    srv.leg4=pwmServo1.pwmForAngle(20);
    srv.hip1=pwmServo1.pwmForAngle(45);
    srv.hip2=pwmServo1.pwmForAngle(45);
    srv.hip3=pwmServo1.pwmForAngle(-45);
    srv.hip4=pwmServo1.pwmForAngle(-45);
    return srv;
  }

  step trot2() {
    Serial.println("Step2");
    step srv;
    srv.leg1=pwmServo1.pwmForAngle(-20);
    srv.leg2=pwmServo1.pwmForAngle(45);
    srv.leg3=pwmServo1.pwmForAngle(-20);
    srv.leg4=pwmServo1.pwmForAngle(45);
    srv.hip1=pwmServo1.pwmForAngle(45);
    srv.hip2=pwmServo1.pwmForAngle(45);
    srv.hip3=pwmServo1.pwmForAngle(-45);
    srv.hip4=pwmServo1.pwmForAngle(-45);
    return srv;
  }

  step trot3() {
    Serial.println("Step3");
    step srv;
    srv.leg1=pwmServo1.pwmForAngle(-20);
    srv.leg2=pwmServo1.pwmForAngle(45);
    srv.leg3=pwmServo1.pwmForAngle(-20);
    srv.leg4=pwmServo1.pwmForAngle(45);
    srv.hip1=pwmServo1.pwmForAngle(-45);
    srv.hip2=pwmServo1.pwmForAngle(-45);
    srv.hip3=pwmServo1.pwmForAngle(45);
    srv.hip4=pwmServo1.pwmForAngle(45);
    return srv;
  }

public:
  void Go() {
    //determine walk level (crawl, walk, or trot)
    step legs[4];
    //influence the result for turning here
    legs[0]=trot0();
    legs[1]=trot1();
    legs[2]=trot2();
    legs[3]=trot3();
    for (int x=0; x<4; x++) {
      delay(minDelay+(walkSpeed * 50));
      send(legs[x]);
    }
  }
};

Walk *Walker = new Walk(); //instantiate object

void loop() {
  Walker->Go();
}
