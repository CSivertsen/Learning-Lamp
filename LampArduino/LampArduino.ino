//include needed libraries
#include <Servo.h>
#include <Adafruit_NeoPixel.h>

Servo servo; //create servo object
Adafruit_NeoPixel strip = Adafruit_NeoPixel(24, 6, NEO_GRB + NEO_KHZ800); //initializ LED strip, 8 leds and pin 6

//set up constants for the pins used
const int LDRPin = A0;
const int micPin = A1;
const int TMPPin = A3;
const int PIRPin = 2;
const int timePotPin = A4;

//create variables to store sensor values
int LDRValue = 0;
int micValue;
int TMPValue;
int PIRValue = 0;
const int TMPLength = 10;
int TMPReadings[TMPLength];
int TMPAvg = 0;
int timePotValue = 0;

int currentTemp;
int currentLight;
int currentSound;
int currentPresence;
int currentTime;

int ledNumber = 0; //create variable for led numbers, initialize led as 0
float temperature; // create variable for temperature

int readCycle;

void setup() {
  // configure pins as input or output
  pinMode(LDRPin, INPUT);
  pinMode(micPin, INPUT);
  pinMode(TMPPin, INPUT);
  pinMode(PIRPin, INPUT);
  pinMode(timePotPin, INPUT);

  servo.attach(9); // create servo object
  servo.write(0);

  strip.begin(); // begin led strip
  strip.show(); // Initialize all pixels to 'off' in case some were left lit by a prior program.

  //strip.setBrightness(20); //brigthness for ledstrips
  //strip.show(); //To “push” the brightness data to the strip, call show():

  Serial.begin(9600); //start serial monitor

}

void loop() {

  readSensors();

  //print sensor values

  //Serial.print(LDRValue);
  //Serial.print("\t");
  LDRState();
  //Serial.print("\t");
  //Serial.print(micValue);
  //Serial.print("\t");
  soundDetect();
  //Serial.print("\t");
  //Serial.print(temperature);
  //Serial.print("\t");
  tempState();
  //Serial.print("\t");
  detectMotion();
  //Serial.print("\t");
  //Serial.println(PIRValue);
  checkTime();


  // turn LED's on
  //for (ledNumber; ledNumber < 24; ledNumber++) {
  //  strip.setPixelColor(ledNumber, 245, 245, 245); //set colors
  //  strip.show(); //  To “push” the color data to the strip, call show():
  //}

  serialSend();

  delay(200);

}

void readSensors() {
  int TMPAccumulated = 0;
  //read sensor values
  micValue = analogRead(micPin);
  LDRValue = analogRead(LDRPin);
  TMPValue = analogRead(TMPPin);
  PIRValue = digitalRead(PIRPin);

  temperature = (((TMPValue / 1024.0) * 5.0) - 0.5) * 100; //   voltage = (sensor value/1024.0) * 5.0) --> temperatue = (voltage - 0.5) * 100

  for (int i = TMPLength - 2; i > 0; i--) {
    TMPReadings[i + 1] = TMPReadings[i];
  }
  TMPReadings[0] = temperature;

  for (int i = 0; i < TMPLength; i++) {
    TMPAccumulated += TMPReadings[i];
  }

  TMPAvg = TMPAccumulated / TMPLength;;

  //10 milivolts change in sensor is 1 degrees change of celcius.
}


// print certain state
void tempState() {
  if (TMPAvg < 21 && TMPAvg > 19) {
    //Serial.print("Temp med");
    currentTemp = 2;
  }
  else if (TMPAvg >= 21) {
    //Serial.print("Temp high");
    currentTemp = 3;
  }
  else if (TMPAvg <= 19) {
    //Serial.print("Temp low");
    currentTemp = 1;
  }

}

void checkTime() {
  if (timePotValue <= 255) {
    currentTime = 1;
  } else if (timePotValue > 255 && timePotValue <= 512) {
    currentTime = 2;
  } else if (timePotValue > 512 && timePotValue <= 768) {
    currentTime = 3;
  } else {
    currentTime = 4;
  }
}

// print certain state
void LDRState() {
  if (LDRValue > 600 && LDRValue < 800) {
    //Serial.print("Light med");
    currentLight = 2;
  }
  else if (LDRValue <= 600) {
    //Serial.print("Light low");
    currentLight = 1;
  }
  else if (LDRValue >= 800) {
    //Serial.print("Light high");
    currentLight = 3;
  }
}

// detect sound
void soundDetect() {
  if (micValue > 78 || micValue < 55) {
    //Serial.print("sound!!!!");
    currentSound = 1;
    //delay(1000);
  }
  else {
    //Serial.print("no sound");
    currentSound = 0;
  }

}

void detectMotion() {
  if (PIRValue == 1) { // if motion is detected move servo to new position
    //Serial.print("Motion detected");
    currentPresence = 1;
  }
  else {
    //Serial.print("No motion");
    currentPresence = 0;
  }

}

void updateState(int bright, int dir) {
  for (ledNumber; ledNumber < 24; ledNumber++) {
    strip.setPixelColor(ledNumber, bright, bright, bright); //set colors
  }
  strip.show(); //  To “push” the color data to the strip, call show():

  if (dir == 0) {
    servo.write(0);
  } else {
    servo.write(180);
  }

}

//Serial communicaton
void serialSend() {

  Serial.print(currentTime);
  Serial.println('\n');

  Serial.print(currentLight);
  Serial.println('\n');

  Serial.print(currentTemp);
  Serial.println('\n');

  Serial.print(currentPresence);
  Serial.println('\n');

  Serial.print(currentSound);
  Serial.println('\n');

  Serial.print("S");
  Serial.println('\n');
}


void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print("A\n");
    delay(300);
  }
}


void serialEvent() {
  int inBright, inDir;
  
  if (Serial.available()) {

    // get the new byte:
    String inString = (String)Serial.readStringUntil('\n');

    if (inString == "A") {
      readCycle = -1;
      serialSend();
    } else {
      if (readCycle == 0) {
        inBright = inString.toInt();
      } else if ( readCycle == 1 ) {
        inDir = inString.toInt();
      }
    }

    updateState(inBright, inDir);

    readCycle++;
  }
}
