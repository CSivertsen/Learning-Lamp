//include needed libraries
#include <Servo.h>
#include <Adafruit_NeoPixel.h>

Servo servo; //create servo object

//set up constants for the pins used
const int LDRPin = A0;
const int micPin = A1;
const int TMPPin = A3;
const int PIRPin = 2;
const int timePotPin = A5;
const int stripPin = 6;

const int numLeds = 32;
Adafruit_NeoPixel strip = Adafruit_NeoPixel(numLeds, stripPin, NEO_GRB + NEO_KHZ800); //initializ LED strip, 8 leds and pin 6

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

int inBright, inDir;

int ledNumber = 0; //create variable for led numbers, initialize led as 0
float temperature; // create variable for temperature

long lastMovement;

void setup() {
  // configure pins as input or output
  pinMode(LDRPin, INPUT);
  pinMode(micPin, INPUT);
  pinMode(TMPPin, INPUT);
  pinMode(PIRPin, INPUT);
  pinMode(timePotPin, INPUT);

  servo.attach(9); // create servo object
  //servo.write(0);

  strip.begin(); // begin led strip
  for (int i = 0; i < numLeds; i++) {
    strip.setPixelColor(i, 0, 0, 0); //set colors
  }
  strip.show(); // Initialize all pixels to 'off' in case some were left lit by a prior program.

  strip.setBrightness(20); //brigthness for ledstrips
  strip.show(); //To “push” the brightness data to the strip, call show():

  Serial.begin(9600); //start serial monitor
  establishContact();

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

  /*
  strip.setPixelColor(0, 255, 0, 0); //set colors
  strip.show(); //  To “push” the color data to the strip, call show():

  delay(200);

  for (int i = 0; i < 3; i++) {
    strip.setPixelColor(i, 200, 200, 0); //set colors
  }
  strip.show(); //  To “push” the color data to the strip, call show():

  delay(200);*/
}

void readSensors() {
  int TMPAccumulated = 0;
  //read sensor values
  micValue = analogRead(micPin);
  delay(10);
  LDRValue = analogRead(LDRPin);
  delay(10);
  timePotValue = analogRead(timePotPin);
  delay(10);
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
    currentTemp = 1;
  }
  else if (TMPAvg >= 21) {
    //Serial.print("Temp high");
    currentTemp = 2;
  }
  else if (TMPAvg <= 19) {
    //Serial.print("Temp low");
    currentTemp = 0;
  }

}

void checkTime() {
  if (timePotValue <= 255) {
    currentTime = 0;
  } else if (timePotValue > 255 && timePotValue <= 512) {
    currentTime = 1;
  } else if (timePotValue > 512 && timePotValue <= 768) {
    currentTime = 2;
  } else {
    currentTime = 3;
  }
}

// print certain state
void LDRState() {
  if (LDRValue > 600 && LDRValue < 800) {
    //Serial.print("Light med");
    currentLight = 1;
  }
  else if (LDRValue <= 600) {
    //Serial.print("Light low");
    currentLight = 0;
  }
  else if (LDRValue >= 800) {
    //Serial.print("Light high");
    currentLight = 2;
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
    lastMovement = millis();
  }
  else if ( millis() - lastMovement > 60000) {
    //Serial.print("No motion");
    currentPresence = 0;
  }

}

void updateState(int bright, int dir) {

  if (dir == 0) {
    servo.write(0);
  } else {
    //Debugging
    strip.setPixelColor(1, 0, 0, 255); //set color
    strip.show();
    servo.write(180);
    delay(500);
  }
  
  for (int i = 0; i < numLeds; i++) {
    strip.setPixelColor(i, bright, bright, bright); //set colors
    //strip.setPixelColor(i, 245, 245, 245); //set colors
  }
  strip.show(); //  To “push” the color data to the strip, call show():

  //Debugging
  //strip.setPixelColor(1, 0, 0, 255); //set color
  //strip.show();

}

//Serial communicaton
void serialSend() {

  Serial.print(currentTime);
  Serial.print(",");

  Serial.print(currentLight);
  Serial.print(",");

  Serial.print(currentTemp);
  Serial.print(",");

  Serial.print(currentPresence);
  Serial.print(",");

  Serial.println(currentSound);

  //Debugging
  strip.setPixelColor(2, 0, 255, 0); //set colors
  strip.show();
}


void establishContact() {
  while (Serial.available() <= 0) {
    Serial.println("0,0,0,0,0");
    delay(300);
  }
}


void serialEvent() {

  if (Serial.available() > 0) {

    // get the new byte:
    String inString = (String)Serial.readStringUntil('\n');

    String inBrightStr = getValue(inString, ',', 0);
    String inDirStr = getValue(inString, ',', 1);

    int inBright = inBrightStr.toInt();
    int inDir = inDirStr.toInt();

    updateState(inBright, inDir);
    serialSend();

  }
}

//This helper function was copied from http://arduino.stackexchange.com/questions/1013/how-do-i-split-an-incoming-string on the 17/01/2017
//Credit oharkins and H.Pauwelyn
String getValue(String data, char separator, int index)
{
  int found = 0;
  int strIndex[] = { 0, -1 };
  int maxIndex = data.length() - 1;

  for (int i = 0; i <= maxIndex && found <= index; i++) {
    if (data.charAt(i) == separator || i == maxIndex) {
      found++;
      strIndex[0] = strIndex[1] + 1;
      strIndex[1] = (i == maxIndex) ? i + 1 : i;
    }
  }
  return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
}


