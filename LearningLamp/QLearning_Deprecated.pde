//class QLearning {

//  final DecimalFormat df = new DecimalFormat("#.##");

//  // path finding
//  final double alpha = 0.1;
//  final double gamma = 0.9;

//  // states A,B,C,D,E,F,G,H
//  // e.g. from A we can go to B or D
//  // from C we can only go to C 
//  // C is goal state, reward 100 when B->C or F->C
//  // 
//  // ________
//  // |A|B|C|D|
//  // |_______|
//  // |D|E|F|H|
//  // |_______|
//  //

//  final State stateA = new State(0, 0, 0);
//  final State stateB = new State(1, 75, 0);
//  final State stateC = new State(2, 160, 0);
//  final State stateD = new State(3, 255, 0);
//  final State stateE = new State(4, 0, 1);
//  final State stateF = new State(5, 75, 1);
//  final State stateG = new State(6, 160, 1);
//  final State stateH = new State(7, 255, 1);

//  final int statesCount = 8;
//  final State[] states = new State[]{stateA, stateB, stateC, stateD, stateE, stateF, stateG, stateH};

//  // http://en.wikipedia.org/wiki/Q-learning
//  // http://people.revoledu.com/kardi/tutorial/ReinforcementLearning/Q-Learning.htm

//  // Q(s,a)= Q(s,a) + alpha * (R(s,a) + gamma * Max(next state, all actions) - Q(s,a))

//  int[][] R = new int[statesCount][statesCount]; // reward lookup
//  double[][] Q = new double[statesCount][statesCount]; // Q learning

//  int[] actionsFromA = new int[] { stateB.ID, stateE.ID, };
//  int[] actionsFromB = new int[] { stateA.ID, stateC.ID, stateF.ID };
//  int[] actionsFromC = new int[] { stateB.ID, stateD.ID, stateG.ID };
//  int[] actionsFromD = new int[] { stateC.ID, stateH.ID };
//  int[] actionsFromE = new int[] { stateA.ID, stateF.ID };
//  int[] actionsFromF = new int[] { stateB.ID, stateE.ID, stateG.ID };
//  int[] actionsFromG = new int[] { stateC.ID, stateF.ID, stateH.ID };
//  int[] actionsFromH = new int[] { stateD.ID, stateG.ID };
//  int[][] actions = new int[][] { actionsFromA, actionsFromB, actionsFromC, 
//    actionsFromD, actionsFromE, actionsFromF, actionsFromG, actionsFromH };

//  String[] stateNames = new String[] { "A", "B", "C", "D", "E", "F", "G", "H"};

//  int state;
//  int action;

//  QLearning() {

//    state = int(random(1, 8));
//  }

//  void run() {
//  }

//  void reinforce(int val) {

//    R[currentState][action] = -100;

//    int[] actionsFromState = actions[state];

//    double[] possibleRewards;
//    for (int i = 0; i < actionsFromState.length; i++) {
//      possibleRewards[i] = Q(state)(actionsFromState[i]);
//    }

//    int index = 


//      currentState = newState;
//  }
//}

//double getQ(int s, int a) {
//  return Q[s][a]; 
//}

//void setQ(int s, int a, double value){
//  Q[s][a] = value;
//}