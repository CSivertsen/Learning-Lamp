// A State object holds a certain combination of lamp position and brightness
// as well as a how highly it is weighted. 
class State {
  int brightness; 
  int position;
  float weight;

// Constructor requires a brightness and position value. The default weight is 0.
State(int b, int p) {
  brightness = b;
  position = p;
  weight = 0;
}

// Used to change the weight when reinforcing
void addVal(float val){
  weight += val;
}

// Returns the current weight of the state
float getWeight(){
  return weight;
}
  
}