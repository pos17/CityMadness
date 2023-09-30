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
ArrayList<PVector> preParticles = new ArrayList<PVector>();

PGraphics title;


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
int music_phase= 0;
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

PImage sprite;  

void setup(){
  //size(900,800,P2D);
  pixelDensity(2);
  fullScreen(P2D);
  //size(900,800,P2D);
  //frameRate(60);
  //pixelDensity(1);
  
  
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
  sprite = loadImage("sprite.png");
  sprite.resize(20,20);
  font = createFont("cityscape.ttf", 300);
  textFont(font);
  background(0);
  textSize(200);
  
  // QUESTO PGRAPHICS NON FA NULLA MA PER QUALCHE MOTIVO FA FUNZIONARE IL SETUP
  title = createGraphics(width,height,P2D);
  title.beginDraw();
  title.background(0);
  title.textFont(font);
  title.text("RESFERB", 100,400);
  title.endDraw();
  
  background(0);
  textAlign(CENTER);
  text("RESFERB", width/2,height/2);
  //text(title, 100,900);
  float xRatio = pixelWidth/width;
  float yRatio = pixelHeight/height; 
  loadPixels();
  for (int x = 0; x < pixelWidth; x++) {
    for (int y = 10; y < pixelHeight; y++) {
      if(pixels[x+y*pixelWidth] == color(255)){
        preParticles.add(new PVector(x/xRatio,y/yRatio));
      }
    }
  }
  save("AAA.png");
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
  
  PreParticle(float x,float y){
    this.point = new PVector(x,y);//.mult(0.5);    
  }
  
  PVector getPoint() {
    return point;
  }
}
