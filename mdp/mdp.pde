import oscP5.*;
import netP5.*;
import java.util.*;


OscP5 oscP5;
OscP5 oscP52;
NetAddress myRemoteLocation;

Map map;

void setup(){
  size(900,800);
  pixelDensity(displayDensity());
  
  oscP5 = new OscP5(this,1234);
  oscP52 = new OscP5(this,1234);
  myRemoteLocation = new NetAddress("127.0.0.1", 5005);
  
  strokeJoin(MITER);
  
  
  map = new Map();
  
  map.createMapPath();
  for(int i = 20; i<100; i++){
    map.addToPath(i);
  }
  map.endMapPath();
  
}


void draw(){
  background(0);
  
  map.show();
  
}
