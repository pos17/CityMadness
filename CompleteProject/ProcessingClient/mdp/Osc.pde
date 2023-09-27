
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
    IntList addresses = new IntList();
    
    for(int i = 0; i<msg.arguments().length; i++){
      addresses.append(msg.get(i).intValue()); 
      
      map.explosionsPaths.add(map.getMapPoint(msg.get(i).intValue()).getCoords()); 
    }
      
    //map.explosionParser(addresses);
    map.explosions.add(addresses);
    explosions = true; // IL PARSER EFFETTIVO STA IN MAP RIGA 395 CIRCA
    
  }
  
  else if(msg.checkAddrPattern("/chaoticParticleAlpha")){
    MAPPARTICLEALPHA = msg.get(0).intValue();
    
    if(MAPPARTICLEALPHA <=0){
      showChaoticParticles = false;
      map.chaoticParticles.clear();
    }
  }
  
  else if(msg.checkAddrPattern("/pathToInterestPath")){
     showPathToInterestPoint = msg.get(0).booleanValue();
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
}

void keyPressed(){
  OscMessage myMessage = new OscMessage("/currentNode");
  myMessage.add(55);
  oscP5.send(myMessage, myRemoteLocation);
  
  if(key == LEFT){
    if(explosionPaths)
      explosionPaths = false;
    else
      showInterestPoint = true;
  }
  else if(keyCode == UP){
   if(showPathToInterestPoint)
     showPathToInterestPoint = false;
   else
     showPathToInterestPoint = true;
  }
  else if(keyCode == RIGHT){
   if(showUser)
     showUser = false;
   else
     showUser = true;
  }
  else if(keyCode == DOWN){
   if(showInterestPoint)
     showInterestPoint = false;
   else
     showInterestPoint = true;
  }
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
