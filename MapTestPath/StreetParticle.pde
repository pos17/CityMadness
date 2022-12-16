class StreetParticle{
  
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
  
  
  StreetParticle(ArrayList<Node> path){
    this.path = path;
    /*
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
    */
    
    this.x = path.get(0).x;
    this.y = path.get(0).y;
    
    //println(this.x+","+this.y);
    
    this.currentPoint = path.get(0);
    
    this.nextPoint = null;
    
    this.t = 0;
    
    //this.c = color(114, 97, 163);
    //this.c = color(40, 75, 113);
    //this.c = color(70, 1, 2);
    this.c = color(44,100,105);

    
    //ArrayList<Node> apath = pf.bfs(n,m);
    
    //println(apath.size());
    this.nextPointIndex = 0;
    this.nextPoint = this.path.get(nextPointIndex);
    
  }
  
  void moveOnPath() {
    if (this.t<motionTime) {
      this.x = lerp(this.currentPoint.x, this.nextPoint.x, map(this.t,0,this.motionTime,0,1));
      this.y = lerp(this.currentPoint.y, this.nextPoint.y, map(this.t,0,this.motionTime,0,1));
      
      this.t++;
    } 
    else if(this.t>=this.motionTime) {
      
      this.currentPointIndex = nextPointIndex;
      this.nextPointIndex = nextPointIndex + shiftIndex;
      
      if(nextPointIndex == 0) {
        shiftIndex = +1;
      } else if(nextPointIndex == this.path.size()-1) {
        shiftIndex = -1;
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
    stroke(this.c, 150);
    point(this.x, this.y);
  }
  
  
}
