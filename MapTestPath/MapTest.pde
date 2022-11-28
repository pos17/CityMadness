import ai.pathfinder.*;

ArrayList<Node> mapDots = new ArrayList<Node>();
ArrayList<Node> mapDotsClicked = new ArrayList<Node>();
ArrayList<Node> mapDotsSource = new ArrayList<Node>();
ArrayList<Particle> particles = new ArrayList<Particle>();
Pathfinder pf = new Pathfinder();

int d = 50;
int pathMaxLength = 10;
int r = 1;
int nParticles = 20000;
int scale = 1;
int instants = 10;

int clickedX = -1;
int clickedY = -1;
int myRad = 100;
boolean done = false;

void setup(){
  size(1069,800,P2D);
  JSONPoints jp = new JSONPoints();
  pf = jp.getPathfinder();
  mapDots = pf.nodes;
  println("waiting for you");
  if(clickedX !=-1 || clickedY !=-1) {
    println("click");
    mapDotsSource = jp.getNodesInArea(parseInt(width/2),parseInt(height/2),50);
    mapDotsClicked = jp.getNodesInArea(clickedX,clickedY,myRad);
    println(mapDotsClicked.size());
    thread("giveDestination");
    noLoop();
    //done = true;
  }
  loop();
  background(0);
  
  //noLoop();
  
}

void draw(){
  //background(0,0.1);
  drawBackground();
  
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
   }
}

void drawBackground(){
  noStroke();
  fill(0,20);
  rect(0,0,width,height);
}

void giveDestination(){
  for(int t = 0; t<instants; t++){
    for(int i = t*nParticles/(instants+1); i<(t+1)*nParticles/(instants+1); i++){
        
        Node cp = mapDotsSource.get((int)random(mapDotsSource.size()));
        Node cptgt = mapDotsClicked.get((int)random(mapDotsClicked.size()));  
        particles.add(new Particle(cp,cptgt,pf));
         //println();
    }
    done = true;
    delay((int)random(60,120));
  }
}


class Particle {

  float x, y;
  Node currentPoint;
  Node nextPoint;
  ArrayList<Node> path = new ArrayList<Node>();
  int t;
  int motionTime;
  color c;
  
  Particle(Node cp){
    this.x = cp.x;
    this.y = cp.y;
    this.currentPoint = cp;
    
    this.nextPoint = null;
    
    path = new ArrayList<Node>();
    path.add(this.currentPoint);
    
    //this.motionTime = (int)random(60,200); 
    this.t = 0;
    
    this.c = color(random(0,255),random(0,255),random(0,255));
    
    //this.generateRandomPath();
  }
  
  Particle(Node cp, Node cptgt,Pathfinder pf) {
    this.x = cp.x;
    this.y = cp.y;
    this.currentPoint = cp;
    
    this.nextPoint = null;
    
    //path = new ArrayList<Node>();
    //path.add(this.currentPoint);
    
    //this.motionTime = (int)random(60,200); 
    this.t = 0;
    
    //this.c = color(random(0,255) ,random(0,255),random(0,255));
    this.c = color(191, 249, 255);
    
    //ArrayList<Node> apath = pf.dijkstra(cp,cptgt);
    ArrayList<Node> apath = pf.bfs(cp,cptgt);
    
    //println(apath.size());
    for(int i =0;i< apath.size();i++) {
      this.path.add(apath.get(apath.size()-1-i));
      //println("path id point: "+ path.get(i).z + ", index: "+(i));
      //println("x: "+ path.get(i).x+", y: "+ path.get(i).y);
      
    }
    this.nextPoint = this.path.get(0);
  }
  
  
  /*
  void generateRandomPath(){
    if(this.nextPoint == null){
      for(int i = 0; i<pathMaxLength; i++){
        ControlPoint pathPoint = this.path.get(0);
        IntList futureConnections = mapDots.get(mapDots.indexOf(pathPoint)).getConnections();
        
        this.path.add(0, mapDots.get(futureConnections.get((int)random(0,futureConnections.size()))));
      }
      
      this.nextPoint = path.get(0);
    }
  }
  */
  
  void moveOnPath(){
    if(nextPoint != null && this.t<motionTime){
      this.x = lerp(this.currentPoint.x, this.nextPoint.x, map(this.t,0,this.motionTime,0,1));
      this.y = lerp(this.currentPoint.y, this.nextPoint.y, map(this.t,0,this.motionTime,0,1));
      
      this.t++;
    }
    else if(this.t>=this.motionTime && path.size()>0 && nextPoint != null){
      this.t = 0;
      this.currentPoint = this.nextPoint;
      this.nextPoint = path.get(0);
      this.motionTime = (int)(dist(this.currentPoint.x,this.currentPoint.y,this.nextPoint.x,this.nextPoint.y)/scale);
      path.remove(0);
    }
    else if(this.t>=this.motionTime && path.size()<=0 && nextPoint != null){
      this.t = 0;
      this.currentPoint = this.nextPoint;
      this.nextPoint = null;
    }
    else if(nextPoint == null){
      this.x = this.currentPoint.x + r*cos(radians(frameCount*10)+random(10));
      this.y = this.currentPoint.y + r*sin(radians(frameCount*10)+random(10));
    }
    
  }
  
  void show(){
    strokeWeight(2);
    stroke(this.c);
    point(this.x, this.y);
  }
  
  
  float[] getCoords(){
   float[] a = {this.x, this.y};
   return a;
  }
}









/*
class Particle {

  float x, y;
  ControlPoint currentPoint;
  ControlPoint nextPoint;
  ArrayList<ControlPoint> path;
  int t;
  int motionTime;
  color c;
  
  Particle(ControlPoint cp){
    this.x = cp.getX();
    this.y = cp.getY();
    this.currentPoint = cp;
    
    this.nextPoint = null;
    
    path = new ArrayList<ControlPoint>();
    path.add(this.currentPoint);
    
    //this.motionTime = (int)random(60,200); 
    this.t = 0;
    
    this.c = color(random(0,255),random(0,255),random(0,255));
    
    this.generateRandomPath();
  }
  
  void generateRandomPath(){
    if(this.nextPoint == null){
      for(int i = 0; i<pathMaxLength; i++){
        ControlPoint pathPoint = this.path.get(0);
        IntList futureConnections = mapDots.get(mapDots.indexOf(pathPoint)).getConnections();
        
        this.path.add(0, mapDots.get(futureConnections.get((int)random(0,futureConnections.size()))));
      }
      
      this.nextPoint = path.get(0);
    }
  }
  
  void moveOnPath(){
    if(nextPoint != null && this.t<motionTime){
      this.x = lerp(this.currentPoint.getX(), this.nextPoint.getX(), map(this.t,0,this.motionTime,0,1));
      this.y = lerp(this.currentPoint.getY(), this.nextPoint.getY(), map(this.t,0,this.motionTime,0,1));
      
      this.t++;
    }
    else if(this.t>=this.motionTime && path.size()>0 && nextPoint != null){
      this.t = 0;
      this.currentPoint = this.nextPoint;
      this.nextPoint = path.get(0);
      this.motionTime = (int)(dist(this.currentPoint.getX(),this.currentPoint.getY(),this.nextPoint.getX(),this.nextPoint.getY())/scale);
      path.remove(0);
    }
    else if(this.t>=this.motionTime && path.size()<=0 && nextPoint != null){
      this.t = 0;
      this.currentPoint = this.nextPoint;
      this.nextPoint = null;
    }
    else if(nextPoint == null){
      this.x = this.currentPoint.getX() + r*cos(radians(frameCount));
      this.y = this.currentPoint.getY() + r*sin(radians(frameCount));
    }
    
  }
  
  void show(){
    strokeWeight(4);
    stroke(this.c);
    point(this.x, this.y);
  }
  
  
  float[] getCoords(){
   float[] a = {this.x, this.y};
   return a;
  }
*/
