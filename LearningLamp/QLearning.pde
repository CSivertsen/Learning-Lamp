class QLearning {

  // This arraylist contains all possible situations
  ArrayList<Situation> situations;

  // This variables contain the last received values from the Arduino
  int currentTime;
  int currentLight;
  int currentTemp;
  boolean currentPres;
  
  // ReinforcementVal is the value of which a state in being reinforced
  // either positively or negatively.
  int reinforcementVal = 100;
  // equalPoints are the number of points given for being equal for with the current situation
  // Used when calculating reinforcement for similar situations.
  int equalPoints = 2;

  // Declaring the Serial Interface for communicating with the Arduino
  SerialInterface mySI;
  
  // Holds information about the current state of the lamp
  State currentState; 

  // Holds information about the current situation
  Situation currentSituation;
  // Temporarily holds a newly received situation update
  Situation incomingSituation;

  // QLearning constructor
  QLearning() {

    // Initializing Serial interface
    mySI = new SerialInterface(this);
    // Initializing default state and situations before anything is received from
    // the Arduino
    currentState = new State(0, 0);
    incomingSituation = new Situation(0, 0, 0, false);

    // A situation object is created for all possible combinations
    // of the 4 situation parameters and stored in an ArrayList
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

  // This function is called whenever a situation is received from the Arduino
  void updateSituation(Situation incomingSituation) {
    
    // The incoming situation is compared to all situations in the situations ArrayList
    for (Situation situation : situations) {
      if (incomingSituation.time == situation.time && 
        incomingSituation.light == situation.light && 
        incomingSituation.temp == situation.temp && 
        incomingSituation.presence == situation.presence ) {

        // When the situation have been found that matches the incoming situation we check
        // that this situation isn't already the active situation. If it isn't we update
        // the current situation and check for the highest rated state for that situation.
        if (!situation.equals(currentSituation)) {
          currentSituation = situation;
          // Printing to console for debugging
          println("Updating situation");
          currentState = currentSituation.findBest(currentState);
        }
      }
    }
  }

  // Called when reinforcement happens
  // The parameter multiply is usually 1 or -1 to switch between positive and negative
  // reinforcement. Can also be used to weight the two types of reinforcements differently.
  void reinforce(float multiply) {

    // Printing to console for debugging
    println("Reinforcement: " + multiply );
    
    // This for-loop runs through all the possible situations and compares them to the current 
    // situation. If a property is equal the value equalPoints is given, otherwise the difference in subtracted.
    for (Situation situation : situations) {
      float timePoints = equalPoints - (abs(situation.time - currentSituation.time));
      float lightPoints = equalPoints - (abs(situation.light - currentSituation.light));
      float tempPoints = equalPoints - (abs(situation.temp - currentSituation.temp));

      // For presence equalPoints are given for being equal. Otherwise 0 points are given.
      float presPoints = 0;
      if (situation.presence == currentSituation.presence) {
        presPoints = equalPoints;
      }

      // The total amount of points are being calculated and the final score becomes a percentage of the reinforcementValue.
      // currentSituation where all properties are equal will thus be reinforcementValue * 1 and a situation that is different
      // on all parameters will be reinforcementValue * 0. 
      float totalPoints = (reinforcementVal/(equalPoints * 4)) * (timePoints + lightPoints + tempPoints + presPoints) * multiply;

      // The current state for every situation is being reinforced with the calculated value 
      situation.updateStateVal(totalPoints, currentState);

    } 

    // If the reinforcement was negative, the best state for the current situation is being activated.
    if (multiply < 0){
      currentState = currentSituation.findBest(currentState);
    }
  }

  // Diplays a crude visualization of the lamp state to enable easier debugging and testing. 
  void display() {

    fill(currentState.brightness);
    if (currentState.position == 0) {
      rect(0, height/2, width, height/2);
    } else {
      rect(0, 0, width, height/2);
    }
  }

  // Prints the weight for all states in the current situation to the console. 
  void showPolicy() {
    println("Policy:");

    for ( int i = 0; i < currentSituation.states.length; i++) {
      println(currentSituation.states[i].weight);
    }
  }
}