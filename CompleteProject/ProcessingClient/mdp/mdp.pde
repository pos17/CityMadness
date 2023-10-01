import controlP5.*;
import oscP5.*;
import netP5.*;
import java.util.*;

final int NMAPPARTICLES = 20000;
int MAPPARTICLEALPHA = 30; //valore iniziale
final  int PATHMAXLENGTH = 15;
float HALF_WIDTH;
float HALF_HEIGHT;
float QUARTER_WIDTH;
final float  PMASS = 0.1;
int time; // n° di click
int timeFromClick;


boolean click;
boolean allowClick; 
boolean explosions;
boolean creatingExplosions;
boolean loaded;
boolean explosionPaths;
boolean showPathToInterestPoint;
boolean showUser;
boolean showInterestPoint;

boolean showChaoticParticles;
boolean resetting;
boolean explosionRunning;

//Points used to build random particles
ArrayList<PVector> preParticles = new ArrayList<PVector>();

PGraphics title;


// SUPERCOLLIDER CONTROL PARAMETERS
int filterFreqValDEF;
int filterFreqVal;
int filterFreqValRANDOM;
int filterFreqValATT;
float musicVol;
float scVol;
float grainVol;
float scMix0Ref = 0;
float scMix1Ref = 0;
float scMix2Ref = 0;
float scMix3Ref = 0;
/*
 music_phases:
 0 title: filter static, only noise
 1 randomNoise: filter lifting to filterFreqVal
 2 attracted noise: filter lowering down to 500 Hz
 3 streets phase
 */
int music_phase;
OscP5 oscP5;
//OscP5 oscP52;

NetAddress myRemoteLocation;
//NetAddress myRemoteLocation2;
boolean startup;

Map map;
int inport = 1235;
int outport = 5005;
//int outport2 = 57120;

PFont font;

PImage sprite;

void setup() {
  //size(900,800,P2D);
  pixelDensity(2);
  fullScreen(P2D);
  //size(900,800,P2D);
  //frameRate(60);
  //pixelDensity(1);


  HALF_WIDTH = width/2;
  HALF_HEIGHT = height/2;
  QUARTER_WIDTH = width/4;

  oscP5 = new OscP5(this, inport);
  //oscP52 = new OscP5(this,inport);
  myRemoteLocation = new NetAddress("127.0.0.1", outport);
  //myRemoteLocation2 = new NetAddress("127.0.0.1", outport2);
  OscMessage myMessage = new OscMessage("/reset");
  oscP5.send(myMessage, myRemoteLocation);

  strokeJoin(ROUND);
  sprite = loadImage("sprite.png");
  sprite.resize(20, 20);
  font = createFont("CfGlitchCityRegular-L1vZ.ttf", 220);
  textFont(font);
  background(0);
  textSize(220);
  String titleString = "SOLI\nVAGANT";
  // QUESTO PGRAPHICS NON FA NULLA MA PER QUALCHE MOTIVO FA FUNZIONARE IL SETUP
  title = createGraphics(width, height, P2D);
  title.beginDraw();
  title.background(0);
  title.textFont(font);
  title.text(titleString, 10, 40);
  title.endDraw();

  background(0);
  textAlign(CENTER);
  text(titleString, width/2, height/2);
  //text(title, 100,900);
  float xRatio = pixelWidth/width;
  float yRatio = pixelHeight/height;
  loadPixels();
  for (int x = 0; x < pixelWidth; x++) {
    for (int y = 0; y < pixelHeight; y++) {
      if (pixels[x+y*pixelWidth] == color(255)) {
        preParticles.add(new PVector(x/xRatio, y/yRatio));
      }
    }
  }
  //save("AAA.png");
  //println("preParticles size: "+ preParticles.size());
  reset();
}


void draw() {
  background(0);
  if (!resetting) {
    //windowTitle(String.valueOf(frameRate));
    loaded = true;
    map.show();
  } else {
    background(0);
  }
}

void reset() {
  resetting = true;
  time = -1; // n° di click
  timeFromClick = 0;
  click = false;
  explosions = false;
  allowClick = true; 
  creatingExplosions = true;
  loaded = false;
  explosionPaths = true;
  showPathToInterestPoint = false;
  showUser = true;
  showInterestPoint = false;
  explosionRunning = false;
  showChaoticParticles = true;
  filterFreqValDEF = 1000;
  filterFreqValRANDOM = 16000;
  filterFreqValATT= 500;
  filterFreqVal = filterFreqValDEF;
  musicVol = 0;
  scVol = 1;
  grainVol = 1;
  music_phase= 0;
  background(0);
  startup = true;
  map = new Map();
  sendReset();
  resetting = false;
}

void scMixFade(float aScMix0,float aScMix1,float aScMix2,float aScMix3) {  
  
  if(aScMix0 != scMix0Ref || aScMix1 != scMix1Ref ||  aScMix2 != scMix2Ref || aScMix3 != scMix3Ref) {
      
  }
}
