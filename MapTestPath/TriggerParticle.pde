class TriggerParticle{
  
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
  
  TriggerParticle(ArrayList<Node> nodesList) {
    path = nodesList;
    this.x = nodesList.get(0).x;
    this.y = nodesList.get(0).y;
    this.currentPoint = nodesList.get(0);
    
    this.nextPoint = null;
    this.t = 0;
    
    this.c = color(191, 249, 255);
    
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
        } 
        else if(nextPointIndex == this.path.size()-1) {
          shiftIndex = -1;
        }
        
        this.t = 0;
        this.currentPoint = this.nextPoint;
        if(this.path.size()!=1){
          this.nextPoint = path.get(nextPointIndex);
        }
        this.motionTime = (int)(dist(this.currentPoint.x,this.currentPoint.y,this.nextPoint.x,this.nextPoint.y)/(2*scale));
        
        this.sendMessage();
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
  
  void sendMessage(){
   OscMessage msg = new OscMessage("/newNote");
   msg.add(currentPoint.z);
   osc.send(msg, pureData); 
  }
  
}