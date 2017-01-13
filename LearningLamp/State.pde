class State {
  int brightness; 
  int position;
  int value;
  
State(int b, int p) {
  brightness = b;
  position = p;
  value = 0;
}

void setValue(int val){
  value = val;
}

void addVal(int val){
  value += val;
}

int getValue(){
  return value;
}
  
}