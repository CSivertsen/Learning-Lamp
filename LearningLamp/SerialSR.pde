class SerialSR {

  // Snippets of this code has been used earlier in Christian Sivertsen M11 Design Project - CRIGS Squad.

  boolean firstContact = false;
  int readCycle;

  int inTime = 0;
  int inLight = 0;
  int inTemp = 0; 
  int inSound = 0;
  boolean inPres = false;
  State sendState;
  QLearning Qobj;

  SerialSR(QLearning _Qobj) {
    Qobj = _Qobj;
    sendState = new State(0,0);
  }

  void send() {

    try {
      //brightness
      myPort.write(str(sendState.brightness));
      myPort.write(",");
      //position
      myPort.write(str(sendState.position));
      myPort.write("/n");
      //println("--- Sending ---");
      //println("Brightness: " + str(sendState.brightness));
      //println("Direction: " + str(sendState.position));
      //println("--- Receiving ---");
    } 
    catch (Exception e) {
      println("Some Serial exception");
      printStackTrace(e);
    }
  }

  void updateSendState(State newState) {
    sendState = newState;
  }

  void serialEvent(Serial myPort) {

    //The serial communication is highly inspired by the following example: https://www.arduino.cc/en/Tutorial/SerialCallResponseASCII
    String inString = myPort.readStringUntil('\n');    
    if (inString != null) {
      inString = trim(inString);

      int sensors[] = int(split(inString, ','));
  
      for (int i = 0; i < sensors.length; i++) {
        switch (i) {
        case 0: 
          inTime = sensors[i];
          break;

        case 1: 
          inLight = sensors[i];
          break;

        case 2: 
          inTemp = sensors[i];
          break;

        case 3: 
          int tempPres = sensors[i];
          if (tempPres == 1) {
            inPres = true;
          } else {
            inPres = false;
          }
          break;

        case 4: 
          inSound = sensors[i];
          if (inSound == 1) {
            Qobj.reinforce(100);
          }
          break;
        default: 
          break;
        }
      }
      
      //println(sensors);

      Situation inSituation = new Situation(inTime, inLight, inTemp, inPres);
      Qobj.setSituation(inSituation);
      println("has set incoming");
      send();
    }
  }
}