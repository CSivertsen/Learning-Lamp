import processing.serial.*;

int reinforceValue; 
QLearning Qobj;
Serial myPort;

void setup() {
  size(300, 300);
  
  Qobj = new QLearning();
  
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
}

void draw() {
  
  background(255, 0, 255);

  //Qobj.run();
  Qobj.display();
}

void mousePressed(){
  if (mouseButton == LEFT) {
    Qobj.reinforce(-100);
  } 
  else if (mouseButton == RIGHT) {
    Qobj.reinforce(100);
  } 
}

void keyPressed(){
  Qobj.showPolicy();
}

void serialEvent(Serial myPort){
  Qobj.mySR.serialEvent(myPort);
}