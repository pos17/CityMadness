import oscP5.*;
import netP5.*;
import java.util.*;

int PATHMAXLENGTH = 60;
int NMAPPARTICLES = 10000;
int NPATHPARTICLES = 1000;
int MAPPARTICLEALPHA = 15;
int TRANSITION_RANGE = 30;
int RETURN_RANGE = 20;
float HALF_WIDTH;
float HALF_HEIGHT;
float QUARTER_WIDTH;
float PMASS = 0.1;
int time = 0;
int timeFromClick = 0;

boolean click = false;


OscP5 oscP5;
OscP5 oscP52;
NetAddress myRemoteLocation;
boolean startup = true;

Map map;
int inport = 1235;
int outport = 5005;

PFont font;

void setup(){
  //size(900,800,P2D);
  fullScreen(P2D);
  //pixelDensity(displayDensity());
  pixelDensity(1);
  frameRate(30);
  HALF_WIDTH = width/2;
  HALF_HEIGHT = height/2;
  QUARTER_WIDTH = width/4;
  
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
  
//windowTitle(String.valueOf(frameRate));
  
  map.show();
  
}
