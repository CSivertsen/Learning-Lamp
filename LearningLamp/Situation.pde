class Situation {

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
  State[][] state;

  Situation (int _time, int _light, int _temp, boolean _presence) {
    time = _time;
    light = _light;
    temp = _temp;
    presence = _presence; 

    states = new State[]{stateA, stateB, stateC, stateD, stateE, stateF, stateG, stateH};
  }

  State updateStateVal(int val, State currentState) {


    for (State state : states) {      
      if (currentState.equals(state)) {
        state.addVal(val);
      }
    }
    
    return findBest();

  }

  State findBest() {
    ArrayList<State> highValueStates = new ArrayList();
    int highestValue = -100000; 

    for (State state : states) {      


      if (state.getValue() > highestValue) {
        highestValue = state.getValue();
      }
    } 

    for (State state : states) {
      if (state.getValue() == highestValue) {
        highValueStates.add(state);
      }
    }

    int pick = int(random(highValueStates.size()));

    return highValueStates.get(pick);
  }
}