import oscP5.*;
import netP5.*;
import ai.pathfinder.*;
import java.util.Arrays;

import java.util.Collections;

OscP5 osc;
NetAddress pureData;


Map myMap;
boolean isMusicOn = true;
boolean creatingParticles = false;
boolean goodMusic = false;
boolean sourceChosen = false;

int startPointX = -1;
int startPointY = -1;


int buttonw = 50;
int offset = 10;

ArrayList<Node> mapDots = new ArrayList<Node>();
ArrayList<Node> mapDotsClicked = new ArrayList<Node>();
Node clickedDot = new Node();
Node sourceDot = new Node();
ArrayList<Node> sourceClickPath = new ArrayList<Node>();

ArrayList<Node> mapDotsSource = new ArrayList<Node>();
ArrayList<Particle> particles = new ArrayList<Particle>();
ArrayList<StreetParticle> streets = new ArrayList<StreetParticle>();
Pathfinder pf = new Pathfinder();

IntList checkedStreets = new IntList();

IntList midiList = new IntList();
IntList pathIdList = new IntList();


ArrayList<TriggerParticle> tp = new ArrayList<TriggerParticle>();

int d = 100;
int pathMaxLength = 10;
int r = 1;
int nParticles = 5000;
int nStreetParticles = 5000;
int scale = 1;
int instants = 1000;

PGraphics bkg;

int clickedX = -1;
int clickedY = -1;
int myRad = 80;
boolean done = false;

//Paolo è molto bello

void setup(){
  //size(1382,800,P2D);
  fullScreen(P2D);
  osc = new OscP5(this, 12000);
  pureData = new NetAddress("localhost", 8001);
  
  //Setup Background
  bkg = createGraphics(width,height,P2D);
  bkg.beginDraw();
  bkg.noStroke();
  //bkg.fill(0);
  bkg.fill(2,3,5);
  bkg.rect(0,0,width,height);
  bkg.endDraw();
  tint(0,5); //To draw bkg with an alpha
  
  //JSONPoints jp = new JSONPoints();
  myMap = new Map("graphMilan.json",9.231021608560354,45.49082190275931,9.15040660361177,45.44414445567239);
  
  mapDots = myMap.getMapDots();
  
  for(int i = 0; i<mapDots.size(); i++){
      checkedStreets.append(i);
  }
  for(int i = 0; i<nStreetParticles; i++){
      Node n;
      Node m;
      
      if(checkedStreets.size() > 0){ //Look for points on the map that have not already been chosen
        int index = (int)random(checkedStreets.size());
        n = mapDots.get(checkedStreets.get(index));
        checkedStreets.remove(index);
      }
      else{ // Look for random points
        n = mapDots.get((int)random(mapDots.size()));
      }
      
      if(checkedStreets.size() > 0){ //Look for points on the map that have not already been chosen
        int index = (int)random(checkedStreets.size());
        m = mapDots.get(checkedStreets.get((int)random(checkedStreets.size())));
        checkedStreets.remove(index);
      }
      else{ // Look for random points
        m = mapDots.get((int)random(mapDots.size()));
      }
      ArrayList<Node> myPath = myMap.getPath(m,n,0);
      
      streets.add(new StreetParticle(myPath)); 
  }
 
    //Initialize a list to check if the point has already been considered for the street representation
    
    
  //println(checkedStreets.size());
  
  OscMessage msg = new OscMessage("/mode");
  if(goodMusic){
    msg.add(1);
  }
  else{
    msg.add(0); 
  }
  osc.send(msg, pureData);
    
  background(2,3,5);
  textSize(buttonw);

}

void draw(){
  image(bkg,0,0);
  
  
  stroke(0);
  strokeWeight(3);
  
  if(goodMusic){
    fill(44,100,105,10);
    rect(width-buttonw, height-buttonw, buttonw,buttonw);
    fill(255, 195, 34,10);
    rect(width-2*buttonw, height-buttonw,buttonw, buttonw);
  }
  else{
    fill(255, 195, 34,10);
    rect(width-buttonw, height-buttonw, buttonw,buttonw);
    fill(44,100,105,10);
    rect(width-2*buttonw, height-buttonw,buttonw, buttonw);
  }
  fill(0);
  text("B", width-buttonw+offset, height-offset);
  text("G", width-2*buttonw+offset, height-offset);
  
    
  for(int i = 0; i<streets.size(); i++){  
    StreetParticle s = streets.get(i);
    s.moveOnPath();
    s.show();
  }
  for(int i = 0; i<tp.size(); i++){
    TriggerParticle t = tp.get(i);
    t.moveOnPath();
    t.show();
  }
  
  for(int i = 0; i<particles.size(); i++){
    Particle p = particles.get(i);
    p.moveOnPath();
    p.show();
  }
}


void initializeParticles(){
  creatingParticles = true;
  for(int t = 0; t<instants && creatingParticles; t++){
    for(int i = t*nParticles/(instants+1); i<(t+1)*nParticles/(instants+1); i++){
        particles.add(new Particle(sourceClickPath));
    }
    
    done = true;
    delay((int)random(60,120));
  }
  creatingParticles = false;
}

void keyPressed(){
 if(key == 'r'){
   
     creatingParticles = false;
     particles.clear(); 
     tp.clear();
     
     sourceChosen = false;
 }
}
