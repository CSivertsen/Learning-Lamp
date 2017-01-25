/*
In the following code we are using the work state and situation different from the common convention surrounding Reinforcement Learning. 
Here a situation refers to the combination of environmental factors measured on the Arduino, which is more commonly referred to as the state.
Furthermore the state refers to the combination of the lamp brightness and lamp head position, which could be likened to the more commonly used action. 
*/
import processing.serial.*;

QLearning Qobj;
Serial myPort;

void setup() {
  size(300, 300);
  
  //The Qobj is instantiated and is where the Q-learning is handled.
  Qobj = new QLearning();
  
  // Setting up the Serial connection
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
}

void draw() {
  
  //The background is pink so it isn't confused with the lamp representation
  background(255, 0, 255);

  // The display function creates a very crude graphical representation of the lamp
  // allowing for debugging without having an Arduino connected
  Qobj.display();

}


// Right and left mousepresses are used to evoke positive and negative reinforcement
// for testing without having the lamp connected. 
void mousePressed(){
  if (mouseButton == LEFT) {
    Qobj.reinforce(-1);
  } 
  else if (mouseButton == RIGHT) {
    Qobj.reinforce(1);
  } 
}

// Press any key to print the Policy for the current situation
void keyPressed(){
  Qobj.showPolicy();
}

// Register Serial events to enable listening for data from the Arduino
void serialEvent(Serial myPort){
  Qobj.mySI.serialEvent(myPort);
}