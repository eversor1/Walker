#include <Wire.h>
#include "PCA9685.h"

PCA9685 pwmController;                  // Library using default Wire and default linear phase balancing scheme
PCA9685_ServoEvaluator pwmServo1;

void setup() {
  Serial.begin(115200);

  Wire.begin();                       // Wire must be started first
  Wire.setClock(400000);              // Supported baud rates are 100kHz, 400kHz, and 1000kHz

  //pwmController.resetDevices();       // Software resets all PCA9685 devices on Wire line
  //pwmController.init(B000000);        // Address pins A5-A0 set to B010101
  //pwmController.setPWMFrequency(50); // Default is 200Hz, supports 24Hz to 1526Hz
}

class Maps {
  //servo direction {-    +    -   +   -    +   -    + }
public:
  const **trotmap[8][8] = {
                    {-45, 20, -45, 20, -45, -45, 45, 45},
                    {-45, 20, -45, 20, 45, 45, -45, -45},
                    {-20, 45, -20, 45, 45, 45, -45, -45},
                    {-20, 45, -20, 45, 45, 45, -45, -45},
                    {-45, 20, -45, 20, -45, -45, 45, 45},
                    {-45, 20, -45, 20, 45, 45, -45, -45},
                    {-20, 45, -20, 45, 45, 45, -45, -45},
                    {-20, 45, -20, 45, 45, 45, -45, -45}
                  };
                  /*
  const **trotmap[8][8] = {
                          {1,2,3,4,5,6,7,8},
                          {9,10,11,12,13,14,15,16},
                          {17,18,19,20,21,22,23,24},
                          {25,26,27,28,29,30,31,32},
                          {33,34,35,36,37,38,39,40},
                          {41,42,43,44,45,46,47,48},
                          {49,50,51,52,53,54,55,56},
                          {57,58,59,60,61,62,63,64}
                        };
                        */

  int trot() {
    return trotmap;
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
  void Go() {
    //determine walk level (crawl, walk, or trot)
    int* legs=walkMap->trot();
    for (int x=0; x<64; x += 8) {
      delay(minDelay+(walkSpeed * 50));
      Serial.print("sending next set: ");
      Serial.println(x);
      send(&legs[x]);
    };
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
    //pwmController.setChannelsPWM(0,8,sending);
  }
};

Walk *Walker = new Walk(); //instantiate object

void loop() {
  Walker->Go();
}
