import controlP5.*;
import oscP5.*;
import netP5.*;
import java.util.*;

int PATHMAXLENGTH = 30; // lunghezza massima path ovvero ultimi nodi esplorati
int NMAPPARTICLES = 20000;
int MAPPARTICLEALPHA = 30; //valore iniziale
float HALF_WIDTH;
float HALF_HEIGHT;
float QUARTER_WIDTH;
float PMASS = 0.1;
int time = 0; // n° di click
int timeFromClick = 0;

boolean click = false;
boolean explosions = false;

boolean creatingExplosions = false;

boolean explosionPaths = true;
boolean showPathToInterestPoint = false;
boolean showUser = false;
boolean showInterestPoint = false;

boolean showChaoticParticles = true;

// SUPERCOLLIDER CONTROL PARAMETERS 
int filterFreqValDEF = 1000;
int filterFreqVal = filterFreqValDEF;
int filterFreqValRANDOM = 16000;
float musicVol = 0;
float scVol = 1;
float grainVol = 1; 

OscP5 oscP5;
OscP5 oscP52;

NetAddress myRemoteLocation;
NetAddress myRemoteLocation2;
boolean startup = true;

Map map;
int inport = 1235;
int outport = 5005;
int outport2 = 57120;

PFont font;

void setup(){
  size(900,800,P2D);
  fullScreen(P2D);
  pixelDensity(displayDensity());
  //pixelDensity(1);
  frameRate(60);
  HALF_WIDTH = width/2;
  HALF_HEIGHT = height/2;
  QUARTER_WIDTH = width/4;
  
  oscP5 = new OscP5(this,inport);
  oscP52 = new OscP5(this,inport);
  myRemoteLocation = new NetAddress("127.0.0.1", outport);
  myRemoteLocation2 = new NetAddress("127.0.0.1", outport2);
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
