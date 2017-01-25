// This class is used for handling serial communication with the Arduino
class SerialInterface {

  // Hold incoming values 
  int inTime = 0;
  int inLight = 0;
  int inTemp = 0; 
  int inSound = 0;
  boolean inPres = false;
  
  // Holds state that should be sent to Arduino
  State sendState;
  
  // Holds reference to the QLearning object that initialized it
  QLearning Qobj;

  // Initializing the Serial interface with a default state
  SerialInterface(QLearning _Qobj) {
    Qobj = _Qobj;
    sendState = new State(0,0);
  }

  // Called after this program has finished receiving data from 
  // the Arduino and is ready to send. 
  void send() {

    // Using try catch to help the program fail gracefully in case
    // there is a problem with the serial connection.
    try {
      // Sends new brightness to Arduino
      myPort.write(str(Qobj.currentState.brightness));
      myPort.write(",");
      // Sends new position to Arduino
      myPort.write(str(Qobj.currentState.position));
      myPort.write("/n");
    } 
    catch (Exception e) {
      println("Some Serial exception");
      printStackTrace(e);
    }
  }

  // The serial communication is highly inspired by the following example: https://www.arduino.cc/en/Tutorial/SerialCallResponseASCII
  void serialEvent(Serial myPort) {

    // Reads the incoming string and splits it into separate values. 
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
            Qobj.reinforce(-1);
          }
          break;
        default: 
          break;
        }
      }
      
      println("Received situation:");
      println(sensors);

      // A new situation object is created from the incoming values and are passed onto updateSituation function.
      // It might be more resource-friendly simply to pass the values directly. 
      Situation inSituation = new Situation(inTime, inLight, inTemp, inPres);
      Qobj.updateSituation(inSituation);
      
      // This programs sends information back to the Arduino
      send();
    }
  }
}