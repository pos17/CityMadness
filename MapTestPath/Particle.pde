class Particle {

  float x, y;
  Node currentPoint;
  Node nextPoint;
  int currentPointIndex =-1;
  int nextPointIndex =-1;
  int shiftIndex = 1;
  
  ArrayList<Node> path = new ArrayList<Node>();
  int t;
  int motionTime;
  color c;
  boolean readyToFinishFirst = false;
  boolean finishedFirst = false;
  /*
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
  */
  
  Particle(Node cp, Node cptgt, Pathfinder pf) {
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
    this.nextPointIndex = 0;
    this.nextPoint = this.path.get(nextPointIndex);
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
  
  /*
  void moveOnPath(){
    if(nextPoint != null && this.t<motionTime){
      this.x = lerp(this.currentPoint.x, this.nextPoint.x, map(this.t,0,this.motionTime,0,1));
      this.y = lerp(this.currentPoint.y, this.nextPoint.y, map(this.t,0,this.motionTime,0,1));
      
      this.t++;
    }
    else if(this.t>=this.motionTime && nextPoint != null){
      this.currentPointIndex = nextPointIndex;
      this.nextPointIndex = nextPointIndex + shiftIndex;
      this.t = 0;
      this.currentPoint = this.nextPoint;
      this.nextPoint = path.get(nextPointIndex);
      this.motionTime = (int)(dist(this.currentPoint.x,this.currentPoint.y,this.nextPoint.x,this.nextPoint.y)/scale);
      //path.remove(0);
    }
    else if(this.t>=this.motionTime && nextPoint != null){
      this.currentPointIndex = nextPointIndex;
      this.nextPointIndex = nextPointIndex + shiftIndex;
      this.t = 0;
      this.currentPoint = this.nextPoint;
      this.nextPoint = null;
    }
    else if(nextPoint == null){
      this.x = this.currentPoint.x + r*cos(radians(frameCount*10)+random(10));
      this.y = this.currentPoint.y + r*sin(radians(frameCount*10)+random(10));
    }
    
  }
  */
  void moveOnPath() {
    if (this.t<motionTime) {
      this.x = lerp(this.currentPoint.x, this.nextPoint.x, map(this.t,0,this.motionTime,0,1));
      this.y = lerp(this.currentPoint.y, this.nextPoint.y, map(this.t,0,this.motionTime,0,1));
      
      this.t++;
    } else if(this.t>=this.motionTime) {
      if(!finishedFirst) {
        if(readyToFinishFirst) {
          finishedFirst = true;
          this.c = color(255,215,0);
         }
      }
      this.currentPointIndex = nextPointIndex;
      this.nextPointIndex = nextPointIndex + shiftIndex;
      
      if(nextPointIndex == 0) {
        shiftIndex = +1;
      } else if(nextPointIndex == this.path.size()-1) {
        shiftIndex = -1;
        readyToFinishFirst = true;
      }
      
      this.t = 0;
      this.currentPoint = this.nextPoint;
      if(this.path.size()!=1) {
        this.nextPoint = path.get(nextPointIndex);
      }
      this.motionTime = (int)(dist(this.currentPoint.x,this.currentPoint.y,this.nextPoint.x,this.nextPoint.y)/scale);
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
