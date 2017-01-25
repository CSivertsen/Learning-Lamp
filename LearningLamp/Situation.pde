class Situation {

  // All situation object contains an array of the possible states. 
  final State stateA = new State(0, 0);
  final State stateB = new State(75, 0);
  final State stateC = new State(160, 0);
  final State stateD = new State(255, 0);
  final State stateE = new State(0, 1);
  final State stateF = new State(75, 1);
  final State stateG = new State(160, 1);
  final State stateH = new State(255, 1);

  State[] states;

  int time;
  int light;
  int temp; 
  boolean presence; 
  
  // The situation constructor requires values for the ambient parameters
  Situation (int _time, int _light, int _temp, boolean _presence) {
    time = _time;
    light = _light;
    temp = _temp;
    presence = _presence; 

    states = new State[]{stateA, stateB, stateC, stateD, stateE, stateF, stateG, stateH};
  }

  // This function is called from the reinforce() function in the QLearning class. 
  // The received val is the calculated points for a particular state in this situation.
  void updateStateVal(float val, State currentState) {
    
    // Looks up the right state in the state array
    for (State state : states) {      
      if (currentState.brightness == state.brightness &&
        currentState.position == state.position) {
        
        // When the right state is found the calculated points are being added to the existing weight  
        state.addVal(val);
      }
    }
  }

  // This function returns the currently highest weighted state for this situation
  // except if the highest rated state is the one that was passed to it. Then it 
  // will return the second best. This is to avoid that the lamp does not seem to 
  // respond when a highly weighted state in being negatively reinforced. 
  State findBest(State currentState) {
    ArrayList<State> highValueStates = new ArrayList();
    float highestValue = -1000000; 
    
    // The loop runs through the state array and finds the highest value
    // skipping the state that was passed to the function. 
    for (State state : states) {      

      if (!state.equals(currentState)) {

        if (state.getWeight() > highestValue) {
          highestValue = state.getWeight();
        }
      }
    } 

    // The array is now looped through a second time to find all states 
    // that has the same value as the highestValue. The most highest rated
    // state are put into an ArrayList. 
    for (State state : states) {
      if (!state.equals(currentState)) {
        if (state.getValue() == highestValue) {
          highValueStates.add(state);
        }
      }
    }
    
    // One of the highest rated value are chosen at random. 
    // This is done to handle the case when several cases are 
    // rated equally high. 
    int pick = int(random(highValueStates.size()));

    // The function returns the highest rated state in the Situation
    return highValueStates.get(pick);
  }
}