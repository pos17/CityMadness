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
int time = -1; // n° di click
int timeFromClick = 0;

boolean click = false;
boolean explosions = false;

boolean creatingExplosions = false;
boolean loaded = false;
boolean explosionPaths = true;
boolean showPathToInterestPoint = false;
boolean showUser = false;
boolean showInterestPoint = false;

boolean showChaoticParticles = true;

//Points used to build random particles 
ArrayList<PreParticle> preParticles = new ArrayList<PreParticle>();


// SUPERCOLLIDER CONTROL PARAMETERS 
int filterFreqValDEF = 1000;
int filterFreqVal = filterFreqValDEF;
int filterFreqValRANDOM = 16000;
int filterFreqValATT= 500;
float musicVol = 0;
float scVol = 1;
float grainVol = 1; 
/*
 music_phases:
  0 title: filter static, only noise
  1 randomNoise: filter lifting to filterFreqVal
  2 attracted noise: filter lowering down to 500 Hz
  3 streets phase
*/
int music_phase= 0
OscP5 oscP5;
//OscP5 oscP52;

NetAddress myRemoteLocation;
//NetAddress myRemoteLocation2;
boolean startup = true;

Map map;
int inport = 1235;
int outport = 5005;
//int outport2 = 57120;

PFont font;

void setup(){
  //size(900,800,P2D);
  fullScreen(P2D);
  pixelDensity(displayDensity());
  frameRate(60);
  pixelDensity(1);
  
  
  HALF_WIDTH = width/2;
  HALF_HEIGHT = height/2;
  QUARTER_WIDTH = width/4;
  
  oscP5 = new OscP5(this,inport);
  //oscP52 = new OscP5(this,inport);
  myRemoteLocation = new NetAddress("127.0.0.1", outport);
  //myRemoteLocation2 = new NetAddress("127.0.0.1", outport2);
  OscMessage myMessage = new OscMessage("/reset");
  oscP5.send(myMessage, myRemoteLocation);
  
  strokeJoin(ROUND);
  
  font = createFont("cityscape.ttf", 200);
  textFont(font);
  background(0);
  //fill(255);
  textSize(200);
  String title = "RESFERB";
  //push();
  //translate(HALF_WIDTH,HALF_HEIGHT);
  //translate(-HALF_WIDTH,-HALF_HEIGHT);
  //pop();
  textAlign(CENTER);
  text(title, 0, (height/2)-100, width, (height/2)+100);
  
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      if (get(x, y) == color(255)) {
        preParticles.add(new PreParticle(x,y));
      }
    }
  }
  
  println("preParticles size: "+ preParticles.size());
  background(0);
  map = new Map();
}


void draw(){
  background(0);
  
//windowTitle(String.valueOf(frameRate));
  loaded = true;
  map.show();
  
}

class PreParticle {
  PVector point;
  
  PreParticle(int x,int y){
    this.point = new PVector(x,y);//.mult(0.5);    
  }
  
  PVector getPoint() {
    return point;
  }
}
