import oscP5.*;
import netP5.*;
import java.util.*;

int PATHMAXLENGTH = 10;
int NMAPPARTICLES = 10000;
int NPATHPARTICLES = 1000;
int MAPPARTICLEALPHA = 100;
int TRANSITION_RANGE = 20;
int RETURN_RANGE = 20;
float HALF_WIDTH;
float HALF_HEIGHT;
float QUARTER_WIDTH;
float PMASS = 0.1;
int time = 0;
boolean click = false;


OscP5 oscP5;
OscP5 oscP52;
NetAddress myRemoteLocation;
boolean startup = true;

Map map;
int inport = 1234;
int outport = 5004;

PFont font;

void setup(){
  size(900,800,P2D);
  //fullScreen(P2D);
  //pixelDensity(displayDensity());
  pixelDensity(1);
  HALF_WIDTH = width/2;
  HALF_HEIGHT = height/2;
  QUARTER_WIDTH = width/4;
  
  //frameRate(1);
  
  oscP5 = new OscP5(this,inport);
  oscP52 = new OscP5(this,inport);
  myRemoteLocation = new NetAddress("127.0.0.1", outport);
  
  OscMessage myMessage = new OscMessage("/reset");
  oscP5.send(myMessage, myRemoteLocation);
  
  strokeJoin(ROUND);
  
  font = createFont("Arial", 15);
  textFont(font);
  
  map = new Map();
}


void draw(){
  background(0);
  
  windowTitle(String.valueOf(frameRate));
  
  map.show();
  
}
