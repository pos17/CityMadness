int iter = 0 ;
int shortPathLen = 0;
void oscEvent(OscMessage msg) {
  String start = "Start";
  String end = "Stop";
  boolean StartedPath = true;
  //println("MessageStart \n");
  //println(msg.toString());
  //println("MessageEnd \n");
  print("msg"+msg);
  
  if(msg.checkAddrPattern("/StartShortPath")==true) {
    
    println(msg.get(0).intValue());
    StartedPath = true;
    shortPathLen = msg.get(0).intValue();
    map.createMapPath();
    println("Started Path Parsing");
    println("iter=" + iter );
    iter++;
    println("Length: " + shortPathLen);
  }
  else if(msg.checkAddrPattern("/ShortPath")){
    println("parsed");
    println("iter=" + iter );
    iter++;
      //println(msg.get(0).stringValue());
      
      //println(parseInt(msg.get(0).stringValue()));
      for(int i = 0; i <shortPathLen; i++) {
        println("parsed");
        map.addToPath(msg.get(i).intValue());
        println(msg.get(i).intValue());
      }  
  }
  else if(msg.checkAddrPattern("/StopShortPath")) {
    println("ended");
    println("iter=" + iter );
    iter++;
    map.endMapPath();
      
  }
  else {
  println("something else");
  println(msg);
  }
  /*
  if(msg.checkAddrPattern("/ShortPath")==true){
    if(start.equalsIgnoreCase(msg.get(0).stringValue())){
      map.createMapPath();
    }
    else if(end.equalsIgnoreCase(msg.get(0).stringValue())){
      map.endMapPath();
    }
    else{
      map.addToPath(msg.get(0).intValue());
    }
  }
  */
}


void keyPressed() {
  OscMessage myMessage = new OscMessage("/target");
  myMessage.add(789);
  oscP52.send(myMessage, myRemoteLocation);
  println("sender target");
  
  
  OscMessage myMessage2 = new OscMessage("/start");
  
  /* Man kan tilføje int, float, text, byte OG arrays*/
  // Denne beskedID indeholder 3 beskeder, hvilket skal tages i mente
  // for den modtagende handler-funktion
  myMessage2.add(500);
  /* Hvad der sendes, og hvor til */
  oscP5.send(myMessage2, myRemoteLocation);
  println("sender start");
}
/*
void mousePressed(){
  OscMessage myMessage = new OscMessage("/start");
  
  Man kan tilføje int, float, text, byte OG arrays
  // Denne beskedID indeholder 3 beskeder, hvilket skal tages i mente
  // for den modtagende handler-funktion
  myMessage.add(500);
   Hvad der sendes, og hvor til 
  oscP5.send(myMessage, myRemoteLocation);
  println("sender start");
}
*/
