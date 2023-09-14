import oscP5.*;
import netP5.*;
import java.util.*;

int NMAPPARTICLES = 5000;
int NPATHPARTICLES = 1000;
int MAPPARTICLEALPHA = 70;
float HALF_WIDTH;
float HALF_HEIGHT;
float QUARTER_WIDTH;
float PMASS = 0.1;

OscP5 oscP5;
OscP5 oscP52;
NetAddress myRemoteLocation;
boolean startup = true;

Map map;
int inport = 57120;
int outport = 5005;

PFont font;

void setup(){
  size(900,800,P2D);
  pixelDensity(displayDensity());
  HALF_WIDTH = width/2;
  HALF_HEIGHT = height/2;
  QUARTER_WIDTH = width/4;
  
  oscP5 = new OscP5(this,inport);
  oscP52 = new OscP5(this,inport);
  myRemoteLocation = new NetAddress("127.0.0.1", outport);
  
  OscMessage myMessage = new OscMessage("/reset");
  oscP5.send(myMessage, myRemoteLocation);
  
  strokeJoin(MITER);
  
  font = createFont("Arial", 15);
  textFont(font);
  
  map = new Map();
}


void draw(){
  background(0);
  
  map.show();
  
}
