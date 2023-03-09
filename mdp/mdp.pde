import oscP5.*;
import netP5.*;
import java.util.*;


OscP5 oscP5;
OscP5 oscP52;
NetAddress myRemoteLocation;

Map map;
int inport = 1234;
int outport = 5004;

void setup(){
  size(900,800);
  pixelDensity(displayDensity());
  
  oscP5 = new OscP5(this,inport);
  oscP52 = new OscP5(this,inport);
  myRemoteLocation = new NetAddress("127.0.0.1", outport);
  
  strokeJoin(MITER);
  
  map = new Map();
}


void draw(){
  background(0);
  
  map.show();
  
}
