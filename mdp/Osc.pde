void oscEvent(OscMessage msg) {
  String start = "start";
  String end = "stop";
  
  if(msg.checkAddrPattern("/MusPath")==true) {
    
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
}
