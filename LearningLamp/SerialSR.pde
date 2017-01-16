class SerialSR {
  
  // Snippets of this code has been used earlier in Christian Sivertsen M11 Design Project - CRIGS Squad.
  
  boolean firstContact = false;
  int readCycle;

  int inTime = 0;
  int inLight = 0;
  int inTemp = 0; 
  boolean inPres = false;
  State sendState;

  SerialSR() {
  
  }

  void send() {
    
    //brightness
    myPort.write(sendState.brightness);
    
    //position
    myPort.write(sendState.position);
  }
  
  void updateSendState(State newState) {
    sendState = newState;
  }

  void serialEvent(Serial myPort) {


    String inString = myPort.readStringUntil('\n');

    if (inString != null) {
      inString = trim(inString);


      if (firstContact == false) {
        if (inString.equals("A")) { 
          myPort.clear();          // clear the serial port buffer
          firstContact = true;     // you've had first contact from the microcontroller
          myPort.write("A");       // ask for more
          println("Had first contact");
          readCycle = -1;
        }
      } else if (inString.equals("S")) { 

        //Write the new state here

        myPort.write("A" + '\n');
      } else {  

        if ( readCycle == 0) {
          //time 
          inTime = Integer.parseInt(inString);
        } else if ( readCycle == 1 ) {
          //light
          inLight = Integer.parseInt(inString);
        } else if ( readCycle == 2 ) {
          //temperature
          inTemp = Integer.parseInt(inString);
        } else if ( readCycle == 3 ) {
          int tempPres = Integer.parseInt(inString);
          if (tempPres == 1) {
            inPres = true;
          } else {
            inPres = false;
          }
        }


        Situation inSituation = new Situation(inTime, inLight, inTemp, inPres);
      }
      
      // print the values (for debugging purposes only):
      println(readCycle + ": " + inString);
      if (readCycle >= 9) {
        readCycle = 0;
      } else {
        readCycle++;
      }
      
    }
  }
}