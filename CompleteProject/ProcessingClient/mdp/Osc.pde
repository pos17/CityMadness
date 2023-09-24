
void oscEvent(OscMessage msg) {
  
  click = true;

  
  if(msg.checkAddrPattern("/nextNodes")){
    IntList addresses = oscPathParser(msg);
    map.setNextPoints(addresses);
    map.updateCurrentPointConnections(addresses);
    //println("Next Points Set");
    
    //println("Next addresses: " + addresses);
  }
  
  else if(msg.checkAddrPattern("/interestPath")){
    
    //[0] interest node, [1] path len, [...] path

    int interestPointId = msg.get(0).intValue();
    map.setNextInterestPoint(interestPointId);
    
    int len = msg.get(1).intValue();
    IntList addresses = new IntList();
    for(int i = 0; i<len; i++){
      addresses.append(msg.get(i+2).intValue()); 
    }
    
    map.updatePathToInterestPoint(addresses);
  }
  
  else if(msg.checkAddrPattern("/mapDiscoveredPath")){
    println(msg.arguments());
    println("WOW");
    
  }
  
  else {
  println("something else");
  println(msg);
  }
}

void mousePressed(){
  
  // UPDATE THE NUMBER OF TIMES THE USER HAS CLICKED
  if(!map.isMoving()){
    time++;
    timeFromClick = 0;
    
    OscMessage myMessage = new OscMessage("/currentNode");
    int id = map.getClosestPointId(mouseX-HALF_WIDTH, mouseY-HALF_HEIGHT);
    myMessage.add(id);
    oscP5.send(myMessage, myRemoteLocation);
    map.updatePath(id);
    map.setCurrentPoint(id);
  }
  
  //println("Current id: " + id);
    
  
}

void keyPressed(){
  OscMessage myMessage = new OscMessage("/currentNode");
  myMessage.add(55);
  oscP5.send(myMessage, myRemoteLocation);
  
 ;
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
