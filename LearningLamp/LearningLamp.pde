int reinforceValue; 
QLearning Qobj;


void setup() {
  size(300, 300);
  
  Qobj = new QLearning();
}

void draw() {
  
  background(255, 0, 255);

  Qobj.run();
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