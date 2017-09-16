#include <Wire.h>
#include "PCA9685.h"

//#define OPERATE_SERVOS 1
#define SERVO_DEBUG 1
#define RCV_DEBUG 1

PCA9685 pwmController;                  // Library using default Wire and default linear phase balancing scheme
PCA9685_ServoEvaluator pwmServo1;

uint8_t step = 0;
uint8_t led = 13;

void setup() {
#if defined(SERVO_DEBUG) || defined(RCV_DEBUG)
  Serial.begin(115200);
  Serial.println("Begin");
#endif

  Wire.begin();                       // Wire must be started first
  Wire.setClock(400000);              // Supported baud rates are 100kHz, 400kHz, and 1000kHz

#ifdef OPERATE_SERVOS
  pwmController.resetDevices();       // Software resets all PCA9685 devices on Wire line
  pwmController.init(B000000);        // Address pins A5-A0 set to B010101
  pwmController.setPWMFrequency(50); // Default is 200Hz, supports 24Hz to 1526Hz
#endif
}

  //servo direction {-    +    -   +   -    +   -    + }
const int8_t trotmap[8][8] = {
                  {-45, 20, -45, 20, -45, -45, 45, 45},
                  {-45, 20, -45, 20, 45, 45, -45, -45},
                  {-20, 45, -20, 45, 45, 45, -45, -45},
                  {-20, 45, -20, 45, -45, -45, 45, 45},
                  {-45, 20, -45, 20, -45, -45, 45, 45},
                  {-45, 20, -45, 20, 45, 45, -45, -45},
                  {-20, 45, -20, 45, 45, 45, -45, -45},
                  {-20, 45, -20, 45, -45, -45, 45, 45}
                };

const int8_t backtrotmap[8][8] = {
                  {-20, 45, -20, 45, -45, -45, 45, 45},
                  {-20, 45, -20, 45, 45, 45, -45, -45},
                  {-45, 20, -45, 20, 45, 45, -45, -45},
                  {-45, 20, -45, 20, -45, -45, 45, 45},
                  {-20, 45, -20, 45, -45, -45, 45, 45},
                  {-20, 45, -20, 45, 45, 45, -45, -45},
                  {-45, 20, -45, 20, 45, 45, -45, -45},
                  {-45, 20, -45, 20, -45, -45, 45, 45}
                };

const int8_t rightstrafemap[8][8] = {
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

const int8_t leftstrafemap[8][8] = {
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
const int8_t leftrotatemap[6][8] = {
//servo direction {-    +    -   +   -    +   -    + }
//servo desig     {ft1, ft2, ft3, ft4, hp1, hp2, hp3, hp4}
                //{-45, 20, -45, 20, -45, 45, 45, -45}, //fd,fu,sd,su
                  {-45, 45, -45, 45, 45, 45, 45, 45},//plant
                  {-45, 45, -45, 45, -45, -45, -45, -45}, //rotate
                  {-20, 45, -20, 45, -45, -45, -45, -45}, //pick up odds
                  {-20, 45, -20, 45, 45, -45, 45, -45}, //adjust odd
                  {-45, 20, -45, 20, 45, -45, 45, -45}, //pick up evens
                  {-45, 20, -45, 20, 45, 45, 45, 45}, //adjust even
                };
const int8_t rightrotatemap[6][8] = {
//servo direction {-    +    -   +   -    +   -    + }
//servo desig     {ft1, ft2, ft3, ft4, hp1, hp2, hp3, hp4}
                //{-45, 20, -45, 20, -45, 45, 45, -45}, //fd,fu,sd,su
                  {-45, 45, -45, 45, -45, -45, -45, -45},//plant
                  {-45, 45, -45, 45, 45, 45, 45, 45}, //rotate
                  {-20, 45, -20, 45, 45, 45, 45, 45}, //pick up odds
                  {-20, 45, -20, 45, -45, 45, -45, 45}, //adjust odd
                  {-45, 20, -45, 20, -45, 45, -45, 45}, //pick up evens
                  {-45, 20, -45, 20, -45, -45, -45, -45}, //adjust even
                };

//LIMITS!! 102-500
class Walk {
  int8_t walkSpeed=4; //inverse - lower is faster
  int8_t turnSpeed=0;
  int8_t strafeSpeed=0;
  int8_t minDelay=150;
  int8_t minPWMLimit=102;
  int8_t maxPWMLimit=500;
  int8_t numSteps = 0;

public:
  uint8_t Go(int8_t step) {
    //determine walk level (crawl, walk, or trot)
    int8_t numSteps = (sizeof(leftrotatemap)/(sizeof(int8_t)*8));
    int8_t legs[8][numSteps];
    memcpy(legs, leftrotatemap, numSteps*8);
    delay(minDelay+(walkSpeed * 50));
#ifdef SERVO_DEBUG
    Serial.print("Sending next set: ");
    Serial.print(step);
    Serial.print(" - ");
    for (int8_t x=0; x<8; x++) {
      Serial.print(x);
      Serial.print(": ");
      Serial.print(legs[step][x]);
      Serial.print(", ");
    }
    Serial.println("");
    Serial.print("Num Steps: ");
    Serial.println(numSteps);
#endif
    send(legs[step]);

    //add something to check the current map length, and reset on that
    step++;
    if (step > (numSteps-1)) {
      step=0;
    };
    if (step%2 == 0) {
      digitalWrite(led, HIGH);
    } else {
      digitalWrite(led, LOW);
    }
    return step;
  }

private:
  void send(int8_t *legs) {
    //word servo[8]={legs.leg1, legs.leg2, legs.leg3, legs.leg4, legs.hip1, legs.hip2, legs.hip3, legs.hip4};
    uint16_t sending[8];
#ifdef SERVO_DEBUG
    Serial.print("Sending ");
#endif
    for (int8_t x=0; x<8; x++) {
      sending[x]=pwmServo1.pwmForAngle(legs[x]);
#ifdef SERVO_DEBUG
      Serial.print(x);
      Serial.print(": ");
      Serial.print(legs[x]);
      Serial.print(" - ");
      Serial.print(sending[x]);
      Serial.print(", ");
#endif
    };
#ifdef SERVO_DEBUG
    Serial.println("");
#endif
    delay(minDelay+(walkSpeed * 50));
#ifdef OPERATE_SERVOS
    pwmController.setChannelsPWM(0,8,sending);
#endif
  }
};

Walk *Walker = new Walk(); //instantiate object

void loop() {
  step=Walker->Go(step);
