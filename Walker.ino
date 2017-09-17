#include <Wire.h>
#include "PCA9685.h"

#define OPERATE_SERVOS 1
//#define SERVO_DEBUG 1
#define RCV_DEBUG 1

PCA9685 pwmController;                  // Library using default Wire and default linear phase balancing scheme
PCA9685_ServoEvaluator pwmServo1;

uint8_t step = 0;
uint8_t led = 13;
volatile uint8_t prev; // remembers state of input bits from previous interrupt
volatile uint32_t risingEdge[6]; // time of last rising edge for each channel
volatile uint32_t uSec[6]; // the latest measured pulse width for each channel

struct aryPack {
    uint8_t size;
    int8_t* aryPtr;
};

//Plagerized from: http://ceptimus.co.uk/?p=66 Thanks!
ISR(PCINT2_vect) { // one or more of pins 2~7 have changed state
  //chans: 2:meh, 3: hovpit, 4: left stick horiz, 5: right stk vert, 6: throt, 7: right stk horiz
  uint32_t now = micros();
  uint8_t curr = PIND; // current state of the 6 input bits
  uint8_t changed = curr ^ prev;
  int channel = 0;
  for (uint8_t mask = 0x04; mask; mask <<= 1) {
    if (changed & mask) { // this pin has changed state
      if (curr & mask) { // +ve edge so remember time
        risingEdge[channel] = now;
      } else { // -ve edge so store pulse width
        //TODO: Maybe average this with it's previous value to even it out?
        uSec[channel] = (((now - risingEdge[channel]) + uSec[channel])/2);
      }
    }
    channel++;
  }
  prev = curr;
}

void setup() {
//#if defined(SERVO_DEBUG) || defined(RCV_DEBUG)
  Serial.begin(115200);
  Serial.println("Begin");
//#endif

  Wire.begin();                       // Wire must be started first
  Wire.setClock(400000);              // Supported baud rates are 100kHz, 400kHz, and 1000kHz

#ifdef OPERATE_SERVOS
  pwmController.resetDevices();       // Software resets all PCA9685 devices on Wire line
  pwmController.init(B000000);        // Address pins A5-A0 set to B010101
  pwmController.setPWMFrequency(50); // Default is 200Hz, supports 24Hz to 1526Hz
#endif
  //setup reciever
  for (int pin = 2; pin <= 7; pin++) { // enable pins 2 to 7 as our 6 input bits
    pinMode(pin, INPUT);
  }

  PCMSK2 |= 0xFC; // set the mask to allow those 6 pins to generate interrupts
  PCICR |= 0x04;  // enable interupt for port D
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
  int8_t speed=7; //inverse - lower is faster
  int8_t numSpeeds=6;
  int8_t speedDelay=75;
  int8_t minDelay=75;

  int8_t minPWMLimit=102;
  int8_t maxPWMLimit=500;
  int8_t numSteps = 0;

  //chans: 2:meh, 3: hovpit, 4: left stick horiz, 5: right stk vert, 6: throt, 7: right stk horiz
  //range: 1050 - 1920ish
  //6 speeds
  uint16_t upperLimit = 1930;
  uint16_t lowerLimit = 980;
  uint16_t forwardThreshold = 1550;
  uint16_t reverseThreshold = 1450;
  uint16_t strafeLeftThreshold = 1450;
  uint16_t strafeRightThreshold = 1550;
  uint16_t rotateLeftThreshold = 1450;
  uint16_t rotateRightThreshold = 1550;

public:
  aryPack selectMotion() {
    aryPack motion;

    motion.size=0;
    if (uSec[4] == 0) { //controller not active or init
      return motion;
    }

    //sanity check
    if ((uSec[4] > lowerLimit) && (uSec[4] < upperLimit)) {
      if (uSec[4] > forwardThreshold) { //forward throttle
        motion.size = (sizeof(trotmap)/(sizeof(int8_t)*8));
        motion.aryPtr = *trotmap;
        speed=(numSpeeds - ((uSec[4] - forwardThreshold) / ((upperLimit - forwardThreshold)/numSpeeds)));
        Serial.println("Moving Forward!");
      } else if (uSec[4] < reverseThreshold) { //backward throttle
        motion.size = (sizeof(backtrotmap)/(sizeof(int8_t)*8));
        motion.aryPtr = *backtrotmap;
        speed=((uSec[4] - lowerLimit) / ((reverseThreshold - lowerLimit)/numSpeeds));
        Serial.println("Backing Up - BEEP!");
      };
    };

    if ((uSec[2] > lowerLimit) && (uSec[2] < upperLimit)) {
      if (uSec[2] > strafeRightThreshold) {
        motion.size = (sizeof(rightstrafemap)/(sizeof(int8_t)*8));
        motion.aryPtr = *rightstrafemap;
        speed=(numSpeeds - ((uSec[2] - strafeRightThreshold) / ((upperLimit - strafeRightThreshold)/numSpeeds)));
        Serial.println("Strafe RIGHT");
      } else if (uSec[2] < strafeLeftThreshold) {
        motion.size = (sizeof(leftstrafemap)/(sizeof(int8_t)*8));
        motion.aryPtr = *leftstrafemap;
        speed=((uSec[2] - lowerLimit) / ((strafeLeftThreshold - lowerLimit)/numSpeeds));
        Serial.println("Strafe LEFT");
      };
    };

    if ((uSec[5] > lowerLimit) && (uSec[5] < upperLimit)) {
      if (uSec[5] > rotateRightThreshold) {
        motion.size = (sizeof(rightrotatemap)/(sizeof(int8_t)*8));
        motion.aryPtr = *rightrotatemap;
        speed=(numSpeeds - ((uSec[5] - rotateRightThreshold) / ((upperLimit - rotateRightThreshold)/numSpeeds)));
        Serial.println("Rotate RIGHT");
      } else if (uSec[5] < rotateLeftThreshold) {
        motion.size = (sizeof(leftrotatemap)/(sizeof(int8_t)*8));
        motion.aryPtr = *leftrotatemap;
        speed=((uSec[5] - lowerLimit) / ((rotateLeftThreshold - lowerLimit)/numSpeeds));
        Serial.println("Rotate LEFT");
      };
    };

    Serial.print("Speed: ");
    Serial.println(speed);

    return motion;
  }

  uint8_t Go(int8_t step) {
    //chans: 2:meh, 3: hovpit, 4: left stick horiz, 5: right stk vert, 6: throt, 7: right stk horiz
    aryPack motion = selectMotion();

    if (motion.size == 0) { //nothing to do
      return 0;
    }
    int8_t numSteps = motion.size;
    int8_t legs[numSteps][8];
    memcpy(legs, motion.aryPtr, numSteps*8);

    Serial.println(numSteps);

    //TODO: update delay to move slower instead of jerking
    delay(minDelay+(speed * speedDelay));
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
    if (speed < 7) {
      send(legs[step]);
      step++;
      if (step > (numSteps-1)) {
        step=0;
      };
      if (step%2 == 0) {
        digitalWrite(led, HIGH);
      } else {
        digitalWrite(led, LOW);
      }
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
#ifdef OPERATE_SERVOS
    pwmController.setChannelsPWM(0,8,sending);
#endif
  }
};

Walk *Walker = new Walk(); //instantiate object

void loop() {
  step=Walker->Go(step);
#ifdef RCV_DEBUG
  Serial.flush();
  for (int channel = 0; channel < 6; channel++) {
    Serial.print(uSec[channel]);
    Serial.print("\t");
  }
  Serial.println();
#endif
};
