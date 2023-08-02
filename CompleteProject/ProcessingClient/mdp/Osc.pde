
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
  else if(msg.checkAddrPattern("/RandPath1")){
    // First element is the length, all other elements are the IDs
    //println(msg);
    int len = msg.get(0).intValue();
    IntList addresses = new IntList();
    for(int i = 0; i<len; i++){
      addresses.append(msg.get(i+1).intValue()); 
    }
    map.addRandPath(addresses);
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
  myMessage.add(25);
  oscP52.send(myMessage, myRemoteLocation);
  println("sender target");
  
  
  OscMessage myMessage2 = new OscMessage("/start");  
  myMessage2.add(180);
  oscP5.send(myMessage2, myRemoteLocation);
  println("sender start");
}

void mousePressed(){
  if(!startup){
    
  }
  else{
    OscMessage myMessage = new OscMessage("/start");
    int id = map.getClosestPointId(mouseX, mouseY);
    myMessage.add(id);
    oscP5.send(myMessage, myRemoteLocation);
    println("Random Start Path Sent");
    startup = false;
  }
}
