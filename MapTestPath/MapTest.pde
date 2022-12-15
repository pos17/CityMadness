import netP5.*;
import oscP5.*;

import ai.pathfinder.*;
import java.util.Arrays;

Map myMap;
boolean isMusicOn = false;

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

int d = 100;
int pathMaxLength = 10;
int r = 1;
int nParticles = 2000;
int nStreetParticles = 1000;
int scale = 1;
int instants = 500;

PGraphics bkg;

int clickedX = -1;
int clickedY = -1;
int myRad = 80;
boolean done = false;

//Paolo è molto bello

void setup(){
  size(1382,800,P2D);
  
  //Setup Background
  bkg = createGraphics(width,height,P2D);
  bkg.beginDraw();
  bkg.noStroke();
  bkg.fill(0);
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
    
    
  println(checkedStreets.size());
    
  background(0);
}

void draw(){
  image(bkg,0,0);
  
  /*
  for(int i = 0; i<mapDots.size(); i++){
    Node cp = mapDots.get(i);
    //cp.show();
    point(cp.x,cp.y);
  }
  */
  
 
    for(int i = 0; i<particles.size(); i++){
      Particle p = particles.get(i);
      p.moveOnPath();
      p.show();
    }
    //println(streets.size());
    for(int i = 0; i<streets.size(); i++){
      
      StreetParticle s = streets.get(i);
      s.moveOnPath();
      s.show();
    }
    
  
}


void initializeParticles(){
  for(int t = 0; t<instants; t++){
    for(int i = t*nParticles/(instants+1); i<(t+1)*nParticles/(instants+1); i++){
        Node cp = sourceDot;
        Node cptgt = clickedDot;
        particles.add(new Particle(sourceClickPath));
    }
    
    done = true;
    delay((int)random(60,120));
  }
}
