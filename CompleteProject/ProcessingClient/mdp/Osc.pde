
void oscEvent(OscMessage msg) {
  
  if(msg.checkAddrPattern("/nextNodes")){
    IntList addresses = oscPathParser(msg);
    map.setNextPoints(addresses);
    map.updateCurrentPointConnections(addresses);
    //println("Next Points Set");
  }
  
  else if(msg.checkAddrPattern("/interestPath")){
    // MSG STRUCTURE: 1-CLOSEST INTERESTING NODE ID 2-NEXTNODE TO ARRIVE TO 1
    int interestPointId = msg.get(0).intValue();
    int toInterestPointId = msg.get(1).intValue();
    
    map.setNextInterestPoint(interestPointId);
    map.updatePathToInterestPoint(toInterestPointId);
  }
  
  else {
  println("something else");
  println(msg);
  }
}


void keyPressed() {
}

void mousePressed(){
  
  // UPDATE THE NUMBER OF TIMES THE USER HAS CLICKED
  time++;
  
  OscMessage myMessage = new OscMessage("/currentNode");
  int id = map.getClosestPointId(mouseX-HALF_WIDTH, mouseY-HALF_HEIGHT);
  myMessage.add(id);
  oscP5.send(myMessage, myRemoteLocation);
  //println("Send Current Node");
  
  map.updatePath(id);
  map.setCurrentPoint(id);
  
  println(id);
    
  
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



void mouseMoved(){
  OscMessage myMessage = new OscMessage("/mousePosition");
  myMessage.add(mouseX/width);
  myMessage.add(mouseY/height);
  oscP5.send(myMessage, myRemoteLocation);
}
