
void oscEvent(OscMessage msg) {
  
  if(msg.checkAddrPattern("/ShortPath")==true) {
    IntList addresses = oscPathParser(msg);
   // map.addShortPath(addresses);
    println("Short path parsed");
  }
  
  else if(msg.checkAddrPattern("/MusPath")){
   IntList addresses = oscPathParser(msg);
   //map.addMusicPath(addresses);
   println("Music path parsed");
  }
  
  else if(msg.checkAddrPattern("/RandPath1")){
    IntList addresses = oscPathParser(msg);
    map.addRandPath(addresses);
    println("Random path parsed");
  }
  
  else if(msg.checkAddrPattern("/nextNodes")){
    IntList addresses = oscPathParser(msg);
    map.setNextPoints(addresses);
    println("Next Points Set");
  }
  
  else {
  println("something else");
  println(msg);
  }
}


void keyPressed() {
}

void mousePressed(){
  /*
  if(!startup){
    OscMessage myMessage = new OscMessage("/target");
    int id = map.getClosestPointId(mouseX, mouseY);
    myMessage.add(id);
    oscP5.send(myMessage, myRemoteLocation);
    println("Send Target");
  }
  else{
    OscMessage myMessage = new OscMessage("/start");
    int id = map.getClosestPointId(mouseX, mouseY);
    myMessage.add(id);
    oscP5.send(myMessage, myRemoteLocation);
    println("Random Start Path Sent");
    startup = false;
  }
  */
  //if(!startup){
    OscMessage myMessage = new OscMessage("/currentNode");
    int id = map.getClosestPointId(mouseX, mouseY);
    myMessage.add(id);
    oscP5.send(myMessage, myRemoteLocation);
    println("Send Current Node");
    map.updatePath(id);
    
  //}
}

IntList oscPathParser(OscMessage msg){
  // First element is the length, all other elements are the IDs
  int len = msg.get(0).intValue();
  IntList addresses = new IntList();
  for(int i = 0; i<len; i++){
    addresses.append(msg.get(i+1).intValue()); 
  }
  
  return addresses;
}
