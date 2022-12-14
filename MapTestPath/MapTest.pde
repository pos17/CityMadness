import ai.pathfinder.*;
import java.util.Arrays;

ArrayList<Node> mapDots = new ArrayList<Node>();
ArrayList<Node> mapDotsClicked = new ArrayList<Node>();
ArrayList<Node> mapDotsSource = new ArrayList<Node>();
ArrayList<Particle> particles = new ArrayList<Particle>();
ArrayList<StreetParticle> streets = new ArrayList<StreetParticle>();
Pathfinder pf = new Pathfinder();

IntList checkedStreets = new IntList();

int d = 100;
int pathMaxLength = 10;
int r = 1;
int nParticles = 20000;
int nStreetParticles = 10000;
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
  
  JSONPoints jp = new JSONPoints();
  pf = jp.getPathfinder();
  mapDots = pf.nodes;
  println("waiting for you");
  if(clickedX !=-1 || clickedY !=-1) {
    println("click");
    mapDots = pf.nodes;
    mapDotsSource = jp.getNodesInArea(parseInt(width/5),parseInt(height/2),20);
    mapDotsClicked = jp.getNodesInArea(clickedX,clickedY,myRad);
    println(mapDotsClicked.size());
    
    thread("initializeParticles");
    
    
    //Initialize a list to check if the point has already been considered for the street representation
    for(int i = 0; i<mapDots.size(); i++){
      checkedStreets.append(i);
    }
    
    println(checkedStreets.size());
    /*
    for(int i = 0; i<nStreetParticles; i++){
      streets.add(new StreetParticle(pf)); 
    }
    */
    noLoop();
    //done = true;
  }
  
  loop();
  background(0);
  
  //noLoop();
  
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
  
 
  if(done) {
    for(int i = 0; i<particles.size(); i++){
      Particle p = particles.get(i);
      p.moveOnPath();
      p.show();
    }
    
    
    for(int i = 0; i<streets.size(); i++){
      StreetParticle s = streets.get(i);
      s.moveOnPath();
      s.show();
    }
    
  }
}


void initializeParticles(){
  for(int t = 0; t<instants; t++){
    for(int i = t*nParticles/(instants+1); i<(t+1)*nParticles/(instants+1); i++){
        
        Node cp = mapDotsSource.get((int)random(mapDotsSource.size()));
        Node cptgt = mapDotsClicked.get((int)random(mapDotsClicked.size()));  
        particles.add(new Particle(cp,cptgt,pf));
    }
    for(int i = t*nStreetParticles/(instants+1); i<(t+1)*nStreetParticles/(instants+1); i++){
      streets.add(new StreetParticle(pf)); 
    }
    done = true;
    delay((int)random(60,120));
  }
}

void initializeStreets(){
  
  for(int i = 0; i<nStreetParticles; i++){
    streets.add(new StreetParticle(pf)); 
  }
  println("Streets: " + streets.size());
}
