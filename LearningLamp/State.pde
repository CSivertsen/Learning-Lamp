class State {
  int brightness; 
  int position;
  float value;
  
State(int b, int p) {
  brightness = b;
  position = p;
  value = 0;
}

void setValue(float val){
  value = val;
}

void addVal(float val){
  value += val;
}

float getValue(){
  return value;
}
  
}