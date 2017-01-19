class QLearning {

  ArrayList<Situation> situations;

  int currentTime;
  int currentLight;
  int currentTemp;
  boolean currentPres;
  int reinforcementVal = 100;
  int equalPoints = 2;

  SerialInterface mySR;

  State currentState; 

  Situation currentSituation;
  Situation incomingSituation;

  QLearning() {

    mySR = new SerialInterface(this);
    currentState = new State(0, 0);
    incomingSituation = new Situation(0, 0, 0, false);

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

  void updateSituation(Situation incomingSituation) {
    for (Situation situation : situations) {
      if (incomingSituation.time == situation.time && 
        incomingSituation.light == situation.light && 
        incomingSituation.temp == situation.temp && 
        incomingSituation.presence == situation.presence ) {

        if (!situation.equals(currentSituation)) {
          currentSituation = situation;
          println("Updating situation");
          currentState = currentSituation.findBest(currentState);
        }
      }
    }
  }

  void reinforce(float multiply) {

    println("Reinforcement:");
    for (Situation situation : situations) {
      float timePoints = equalPoints - (abs(situation.time - currentSituation.time));
      float lightPoints = equalPoints - (abs(situation.light - currentSituation.light));
      float tempPoints = equalPoints - (abs(situation.temp - currentSituation.temp));

      float presPoints = 0;
      if (situation.presence == currentSituation.presence) {
        presPoints = equalPoints;
      }

      float totalPoints = (reinforcementVal/(equalPoints * 4)) * (timePoints + lightPoints + tempPoints + presPoints) * multiply;

      situation.updateStateVal(totalPoints, currentState);

      //println(timePoints);
      //println(lightPoints);
      //println(tempPoints);
      //println(presPoints);
      println(totalPoints);
    } 

    if (multiply > 0){
      currentState = currentSituation.findBest(currentState);
    }
  }

  void display() {

    fill(currentState.brightness);
    if (currentState.position == 0) {
      rect(0, height/2, width, height/2);
    } else {
      rect(0, 0, width, height/2);
    }
  }

  void showPolicy() {
    println("Policy:");

    for ( int i = 0; i < currentSituation.states.length; i++) {
      println(currentSituation.states[i].value);
    }
  }
}