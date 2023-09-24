
class MapPath{
  ArrayList<MapPoint> path;
  boolean finished; // Check if path exists
  int index;
  int len;
  
  MapPath(){
    this.path = new ArrayList<MapPoint>();
    this.finished = false;
    this.index = 0;
    this.len = 0;
  }
  
  MapPath(ArrayList<MapPoint> path){
    this.path = path;
    this.finished = true;
    this.index = 0;
  }
  
  void appendPoint(MapPoint m){
     path.add(m);
  }
  
  void end(){
    this.finished = true;
    println("Ids of the path:");
    for(int i = 0; i<this.path.size(); i++){
      println(this.path.get(i).getId()); 
    }
    println("End IDs of the path");
  }
  
  boolean hasEnd(){
    return finished; 
  }
  
  void show(){
    strokeWeight(5);
    stroke(0,255,0);
    for(int i = 0; i<this.path.size(); i++){
      MapPoint m = path.get(i);
      PVector p = m.getCoords();
      point(p.x, p.y);
      text(i, p.x + 20, p.y + 20);
    }
  }
  
  MapPoint getNextPoint(){
    if(finished){
      if(index < path.size()){
        MapPoint nextPoint = this.path.get(this.index);
        this.index++;
        return nextPoint;
      }
      else{
        this.index = 0;
        return this.path.get(this.index);
      }
    }
    else
      return new MapPoint(0,0,-1); //Path is not finished
  }
  
  ArrayList<MapPoint> getPath(){
    return this.path;
  }
  
  int getLength(){
    return this.len; 
  }
  
  void updatePath(MapPoint p){
    this.path.add(p);
    this.len++;
    
    if(this.len > PATHMAXLENGTH){
      path.remove(0);
      this.len--;
    }
  }
  
  PVector getStartPath(){
    return this.path.get(0).getCoords(); 
  }
  
  PVector getEndPath(){
    return this.path.get(this.path.size()-1).getCoords(); 
  }
  
  int getEndID(){
    return this.path.get(this.path.size()-1).getId(); 
  }
  
  ArrayList<PVector> computeParticleBuffer(){
     ArrayList<PVector> newBuffer = new ArrayList<PVector>();
     ArrayList<PVector> updateToBuffer = new ArrayList<PVector>();
     
     for(int i = 0; i<this.path.size()-1; i++){
       PVector a = this.path.get(i).getCoords();
       PVector b = this.path.get(i+1).getCoords();
      
       int numSegments = floor(PVector.dist(a,b));
       if( i < this.path.size()-2){
         for(int j = 0; j<numSegments; j++){
          newBuffer.add((PVector.lerp(a, b, map(j,0,numSegments,0,1))));
         }
       }
       else{
         for(int j = 0; j<numSegments; j++){
           PVector l = PVector.lerp(a, b, map(j,0,numSegments,0,1));
           newBuffer.add(l);
           updateToBuffer.add(l);
         }
       }
     }
     
     map.updatePathParticles(updateToBuffer, this.getEndID());
     
     return newBuffer;
  }
  
}
