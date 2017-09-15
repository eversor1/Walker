#include <Wire.h>
#include "PCA9685.h"

//#define OPERATE_SERVOS 1

PCA9685 pwmController;                  // Library using default Wire and default linear phase balancing scheme
PCA9685_ServoEvaluator pwmServo1;

int step = 0;
int led = 13;

void setup() {
  Serial.begin(115200);
  Serial.println("Begin");

  Wire.begin();                       // Wire must be started first
  Wire.setClock(400000);              // Supported baud rates are 100kHz, 400kHz, and 1000kHz

#ifdef OPERATE_SERVOS
  pwmController.resetDevices();       // Software resets all PCA9685 devices on Wire line
  pwmController.init(B000000);        // Address pins A5-A0 set to B010101
  pwmController.setPWMFrequency(50); // Default is 200Hz, supports 24Hz to 1526Hz
#endif
}

class Maps {
  //servo direction {-    +    -   +   -    +   -    + }
public:
  const **trotmap[8][8] = {
                    {-45, 20, -45, 20, -45, -45, 45, 45},
                    {-45, 20, -45, 20, 45, 45, -45, -45},
                    {-20, 45, -20, 45, 45, 45, -45, -45},
                    {-20, 45, -20, 45, -45, -45, 45, 45},
                    {-45, 20, -45, 20, -45, -45, 45, 45},
                    {-45, 20, -45, 20, 45, 45, -45, -45},
                    {-20, 45, -20, 45, 45, 45, -45, -45},
                    {-20, 45, -20, 45, -45, -45, 45, 45}
                  };

  const **backtrotmap[8][8] = {
                    {-20, 45, -20, 45, -45, -45, 45, 45},
                    {-20, 45, -20, 45, 45, 45, -45, -45},
                    {-45, 20, -45, 20, 45, 45, -45, -45},
                    {-45, 20, -45, 20, -45, -45, 45, 45},
                    {-20, 45, -20, 45, -45, -45, 45, 45},
                    {-20, 45, -20, 45, 45, 45, -45, -45},
                    {-45, 20, -45, 20, 45, 45, -45, -45},
                    {-45, 20, -45, 20, -45, -45, 45, 45}
                  };

  const **rightstrafemap[8][8] = {
  //servo direction {-    +    -   +   -    +   -    + }
  //servo desig     {ft1, ft2, ft3, ft4, hp1, hp2, hp3, hp4}
                    {-45, 20, -45, 20, -45, 45, 45, -45}, //fd,fu,sd,su
                    {-45, 20, -45, 20, 45, -45, -45, 45},
                    {-20, 45, -20, 45, 45, -45, -45, 45},
                    {-20, 45, -20, 45, -45, 45, 45, -45},
                    {-45, 20, -45, 20, -45, 45, 45, -45},
                    {-45, 20, -45, 20, 45, -45, -45, 45},
                    {-20, 45, -20, 45, 45, -45, -45, 45},
                    {-20, 45, -20, 45, -45, 45, 45, -45}
                  };

const **leftstrafemap[8][8] = {
  //servo direction {-    +    -   +   -    +   -    + }
  //servo desig     {ft1, ft2, ft3, ft4, hp1, hp2, hp3, hp4}
                    {-20, 45, -20, 45, -45, 45, 45, -45},
                    {-20, 45, -20, 45, 45, -45, -45, 45},
                    {-45, 20, -45, 20, 45, -45, -45, 45},
                    {-45, 20, -45, 20, -45, 45, 45, -45},
                    {-20, 45, -20, 45, -45, 45, 45, -45},
                    {-20, 45, -20, 45, 45, -45, -45, 45},
                    {-45, 20, -45, 20, 45, -45, -45, 45},
                    {-45, 20, -45, 20, -45, 45, 45, -45}
                  };
const **rightrotatemap[8][8] = { //fixme
  //servo direction {-    +    -   +   -    +   -    + }
  //servo desig     {ft1, ft2, ft3, ft4, hp1, hp2, hp3, hp4}
                  //{-45, 20, -45, 20, -45, 45, 45, -45}, //fd,fu,sd,su
                    {-20, 45, -20, 45, -45, 45, -45, 45},//swap
                    {-20, 45, -20, 45, 45, -45, 45, -45},//turn
                    {-45, 20, -45, 20, 45, -45, 45, -45},//swap
                    {-45, 20, -45, 20, -45, 45, -45, 45},//turn
                    {-20, 45, -20, 45, -45, 45, -45, 45},//swap
                    {-20, 45, -20, 45, 45, -45, 45, -45},//turn
                    {-45, 20, -45, 20, 45, -45, 45, -45},//swap
                    {-45, 20, -45, 20, -45, 45, -45, 45}//turn
                  };
const **leftrotatemap[8][8] = {
  //servo direction {-    +    -   +   -    +   -    + }
  //servo desig     {ft1, ft2, ft3, ft4, hp1, hp2, hp3, hp4}
                  //{-45, 20, -45, 20, -45, 45, 45, -45}, //fd,fu,sd,su
                    {-45, 45, -45, 45, -45, -45, -45, -45},//plant
                    {-45, 45, -45, 45, 45, 45, 45, 45}, //rotate
                    {-20, 45, -20, 45, 45, 45, 45, 45}, //pick up odds
                    {-45, 20, -45, 20, -45, 45, -45, 45}, //adjust odd
                    {-20, 45, -20, 45, -45, 45, -45, 45}, //pick up evens
                    {-20, 45, -20, 45, -45, -45, -45, -45}, //adjust even
                    {-45, 45, -45, 45, -45, -45, -45, -45},//plant
                    {-45, 45, -45, 45, -45, -45, -45, -45}//plant
                  };
  int trot() {
    return trotmap;
  }
  int backtrot() {
    return backtrotmap;
  }
  int rightstrafe() {
    return rightstrafemap;
  }
  int leftstrafe() {
    return leftstrafemap;
  }
  int rightrotate() {
    return rightrotatemap;
  }
  int leftrotate() {
    return leftrotatemap;
  }
  //TODO: Rotation(turn), Strafe, crawl, walk
};

Maps *walkMap = new Maps();

//LIMITS!! 102-500
class Walk {
  int walkSpeed=0; //inverse - lower is faster
  int turnSpeed=0;
  int strafeSpeed=0;
  int minDelay=150;
  int minPWMLimit=102;
  int maxPWMLimit=500;

public:
  int Go(int step) {
    //determine walk level (crawl, walk, or trot)
    int* legs=walkMap->trot();
    delay(minDelay+(walkSpeed * 50));
    Serial.print("sending next set: ");
    Serial.println(step);
    send(&legs[step]);

    //add something to check the current map length, and reset on that
    step=step+8;
    if (step > 63) {
      step=0;
    };
    if (((step/8)%2) == 0) {
      digitalWrite(led, HIGH);
    } else {
      digitalWrite(led, LOW);
    }
    return step;
  }

private:
  void send(int* legs) {
    //word servo[8]={legs.leg1, legs.leg2, legs.leg3, legs.leg4, legs.hip1, legs.hip2, legs.hip3, legs.hip4};
    int sending[8];
    Serial.print("Sending ");
    for (int x=0; x<8; x++) {
      Serial.print(x);
      Serial.print(": ");
      Serial.print(legs[x]);
      Serial.print(" - ");
      sending[x]=pwmServo1.pwmForAngle(legs[x]);
      Serial.print(sending[x]);
      Serial.print(", ");
    };
    Serial.println("");
    delay(minDelay+(walkSpeed * 50));
#ifdef OPERATE_SERVOS
    pwmController.setChannelsPWM(0,8,sending);
#endif
  }
};

Walk *Walker = new Walk(); //instantiate object

void loop() {
  Serial.println(step);
  step=Walker->Go(step);
}
