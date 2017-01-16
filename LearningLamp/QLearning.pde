class QLearning {

  ArrayList<Situation> situations;

  int currentTime;
  int currentLight;
  int currentTemp;
  boolean currentPres;

  SerialSR mySR;

  State currentState; 

  Situation currentSituation;

  QLearning() {
  
  mySR = new SerialSR();
  currentState = new State(0,0);
  
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

  void run() {
    updateSituation();
  }

  void updateSituation() {
    for (Situation situation : situations) {
      if (currentTime == situation.time && currentLight == situation.light && currentTemp == situation.temp && currentPres == situation.presence ) {
        currentSituation = situation;
      }
    }
  }

  void reinforce(int val) {
    State newState = currentSituation.updateStateVal(val, currentState);     
    currentState = newState;
    updateSendState(newState);
  }

  void sendState(State newState) {
    currentState = newState;
    mySR.send(newState);
  }

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