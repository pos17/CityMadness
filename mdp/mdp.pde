import oscP5.*;
import netP5.*;
import java.util.*;


MapPath shortPath = new MapPath();
MapPath musicPath = new MapPath();
ArrayList<MapPoint> mapPoints = new ArrayList<MapPoint>();

OscP5 oscP5;
OscP5 oscP52;
NetAddress myRemoteLocation;

void setup(){
  size(900,800);
  pixelDensity(displayDensity());
  
  oscP5 = new OscP5(this,1234);
  oscP52 = new OscP5(this,1234);
  myRemoteLocation = new NetAddress("127.0.0.1", 5005);
  
  mapPoints = loadMapPoints();
}


void draw(){
  background(0);
  
  ListIterator<MapPoint> iter = mapPoints.listIterator();
  while(iter.hasNext()){
     MapPoint m = iter.next();
     m.show();
  }
  
  
  
}

void keyPressed(){
  if(key == 'p'){
    try{
      musicPath.getNextPoint();
    }
    catch(NullPointerException e){
      println(e);
    }
  }
  
}
