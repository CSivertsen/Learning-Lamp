//Include needed libraries
#include <Servo.h>
#include <Adafruit_NeoPixel.h>

//Declare servo object
Servo servo; 

//Declare constants for the pins used
const int ldrPin = A0;
const int micPin = A1;
const int tempPin = A3;
const int pirPin = 2;
const int timePotPin = A5;
const int stripPin = 6;

// Declare variables for LED strip
const int numLeds = 32;
Adafruit_NeoPixel strip = Adafruit_NeoPixel(numLeds, stripPin, NEO_GRB + NEO_KHZ800); //Initialize LED strip, 8 leds and pin 6

// Declare variables to store sensor values
int ldrVal = 0;
int micVal = 0;
int tempVal = 0;
int pirValue = 0;
int timePotVal = 0;
const int tempLength = 10;
int tempReadings[tempLength];
int tempAvg = 0;

int currentTemp = 0;
int currentLight = 0;
int currentSound = 0;
int currentPresence = 0;
int currentTime = 0;

int inBright, inDir;

// Declare variable to store time of last detected movement
long lastMovement;

void setup() {
  
  // Configure pins as input or output
  pinMode(ldrPin, INPUT);
  pinMode(micPin, INPUT);
  pinMode(tempPin, INPUT);
  pinMode(pirPin, INPUT);
  pinMode(timePotPin, INPUT);

  // Initialize servo
  servo.attach(9); 
  servo.write(0);

  // Begin led strip
  strip.begin(); 
  for (int i = 0; i < numLeds; i++) {
    strip.setPixelColor(i, 0, 0, 0); // Set LEDs to off 
  }
  strip.show(); // Update LEDs

  // Start serial monitor
  Serial.begin(9600); 
  // Establish contact with computer running Processing progam
  establishContact();

}

void loop() {

  // Read raw values from sensors
  readSensors();

  // Convert raw values into ranges used in the Processing program
  ldrState);
  soundDetect();
  tempState();
  detectMotion();
  checkTime();

}

void readSensors() {
  
  int tempAccumulated = 0;
  float temperature;
  
  //read sensor values
  micVal = analogRead(micPin);
  delay(10);
  ldrVal = analogRead(ldrPin);
  delay(10);
  timePotVal = analogRead(timePotPin);
  delay(10);
  tempVal = analogRead(tempPin);
  pirValue = digitalRead(pirPin);

  // Temperature conversion fetched from xxx
  // voltage = (sensor value/1024.0) * 5.0) --> temperatue = (voltage - 0.5) * 100
  // 10 milivolts change in sensor is 1 degrees change of celcius.
  temperature = (((tempVal / 1024.0) * 5.0) - 0.5) * 100; 

  // Make room in the array for a new reading
  for (int i = tempLength - 2; i > 0; i--) {
    tempReadings[i + 1] = tempReadings[i];
  }
  // Store the newest reading in the array
  tempReadings[0] = temperature;

  // Sum the last readings 
  for (int i = 0; i < tempLength; i++) {
    tempAccumulated += tempReadings[i];
  }

  // Calculate average temperature
  tempAvg = tempAccumulated / tempLength;;
}

// Determine the temperature range
void tempState() {
  if (tempAvg < 21 && tempAvg > 19) {
    currentTemp = 1;
  }
  else if (tempAvg >= 21) {
    currentTemp = 2;
  }
  else if (tempAvg <= 19) {
    currentTemp = 0;
  }

}

// Determine the time range. 
// For demonstration purposes it is based on the readings from a potentionmeter 
// rather than actual time.
void checkTime() {
  if (timePotVal <= 255) {
    currentTime = 0;
  } else if (timePotVal > 255 && timePotVal <= 512) {
    currentTime = 1;
  } else if (timePotVal > 512 && timePotVal <= 768) {
    currentTime = 2;
  } else {
    currentTime = 3;
  }
}

// Determine the light range. 
void ldrState) {
  if (ldrVal > 600 && ldrVal < 800) {
    currentLight = 1;
  }
  else if (ldrVal <= 600) {
    currentLight = 0;
  }
  else if (ldrVal >= 800) {
    currentLight = 2;
  }
}

// Determine if the behavior is being reinforced.
// For the demonstrator we are only looking at whether the sound level
// raises above a certain threshold
void soundDetect() {
  if (micVal > 78 || micVal < 55) {
    currentSound = 1;
  }
  else {
    currentSound = 0;
  }
}

// Determine if somebody has been present around the lamp
// within the last minute. 
void detectMotion() {
  if (pirValue == 1) { 
    currentPresence = 1;
    lastMovement = millis();
  }
  else if ( millis() - lastMovement > 60000) {
    currentPresence = 0;
  }
}


// Called upon receiving a new state from the serial communication.
// Moves the servo and changes the light brightness accordingly. 
void updateState(int bright, int dir) {

  // Move servo
  if (dir == 0) {
    servo.write(0);
  } else {
    servo.write(180);
    delay(500);
  }

  // Update brightness for all LEDS in the strip
  for (int i = 0; i < numLeds; i++) {
    strip.setPixelColor(i, bright, bright, bright);
  }
  strip.show(); // Updating LED strip with new values

}

// Serial communicaton
// Sends the detected range for each property separated by a comma
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
}

// Established contact with the computer 
void establishContact() {
  while (Serial.available() <= 0) {
    Serial.println("0,0,0,0,0");
    delay(300);
  }
}

// Called upon receiving data via the serial port
// The serial communication is highly inspired by the following example: https://www.arduino.cc/en/Tutorial/SerialCallResponseASCII
void serialEvent() {

  if (Serial.available() > 0) {

    // Get the incoming string
    String inString = (String)Serial.readStringUntil('\n');

    // Use the helper function to split string into separate values
    String inBrightStr = getValue(inString, ',', 0);
    String inDirStr = getValue(inString, ',', 1);

    // Convert strings to integers
    int inBright = inBrightStr.toInt();
    int inDir = inDirStr.toInt();

    // Update the lamp actuators
    updateState(inBright, inDir);

    // Send data back through the serial port
    serialSend();

  }
}

// This helper function was copied from http://arduino.stackexchange.com/questions/1013/how-do-i-split-an-incoming-string on the 17/01/2017
// Credit oharkins and H.Pauwelyn
// The function helps separate a string into a series of values. 
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


