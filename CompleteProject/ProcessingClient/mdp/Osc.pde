
int iter = 0 ;
int shortPathLen = 0;
void oscEvent(OscMessage msg) {
  
  if(msg.checkAddrPattern("/ShortPath")==true) {
    IntList addresses = oscPathParser(msg);
    map.addShortPath(addresses);
    println("Short path parsed");
  }
  
  else if(msg.checkAddrPattern("/MusPath")){
   IntList addresses = oscPathParser(msg);
   map.addMusicPath(addresses);
   println("Music path parsed");
  }
  
  else if(msg.checkAddrPattern("/RandPath1")){
    IntList addresses = oscPathParser(msg);
    map.addRandPath(addresses);
    println("Random path parsed");
  }
  
  else {
  println("something else");
  println(msg);
  }
}


void keyPressed() {
}

void mousePressed(){
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
