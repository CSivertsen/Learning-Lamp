class QLearning {

  ArrayList<Situation> situations;

  int currentTime;
  int currentLight;
  int currentTemp;
  boolean currentPres;

  SerialSR mySR;

  State currentState; 

  Situation currentSituation;
  Situation incomingSituation;

  QLearning() {
  
  mySR = new SerialSR(this);
  currentState = new State(0,0);
  incomingSituation = new Situation(0,0,0,false);
  
  situations = new ArrayList();

    //time
    for (int time = 0; time < 4; time++) {
      //light
      for (int light = 0; light < 3; light++) {
        //temp
        for (int temp = 0; temp < 3; temp++) {
          //presence
          for (int pres = 0; pres < 2; pres++) {

            boolean boolPres;
            if (pres == 0) {
              boolPres = true;
            } else {
              boolPres = false;
            }

            situations.add(new Situation(time, light, temp, boolPres));
          }
        }
      }
    }
  }

  /*void run() {
    updateSituation();
  }*/

  void updateSituation(Situation incomingSituation) {
    for (Situation situation : situations) {
      if (incomingSituation.time == situation.time && 
          incomingSituation.light == situation.light && 
          incomingSituation.temp == situation.temp && 
          incomingSituation.presence == situation.presence ) {
        
        if (!situation.equals(currentSituation)){
          currentSituation = situation;
          println("Updating situation");
          currentState = currentSituation.findBest();
        }    
        
      }
    }
  }
  
  /*void setSituation(Situation _situation) {
    incomingSituation = _situation;
  }*/

  void reinforce(int val) {
    State newState = currentSituation.updateStateVal(val, currentState);     
    currentState = newState; 
    //sendState(newState);
  }

  /*void sendState(State newState) {
    mySR.sendState = newState;
  }*/

  void display() {

    fill(currentState.brightness);
    if (currentState.position == 0) {
      rect(0, height/2, width, height/2);
    } else {
      rect(0, 0, width, height/2);
    }
    
  }
  
  void showPolicy(){
    println("Policy:");
    
    for( int i = 0; i < currentSituation.states.length-1; i++){
      println(currentSituation.states[i].value);
    }
    
  }
}