
class RandomPathParticle{
  ArrayList<PVector> path;
  PVector p;
  int currentID, nextID;
  
  RandomPathParticle(int id){
    this.currentID = id;
    this.path = new ArrayList<PVector>();
    this.getNext();
    
    this.p = this.path.get(0);
    this.path.remove(0);
  }
  
  void move(){
    if(this.path.size()>0){
      this.p = this.path.get(0);
      this.path.remove(0);
    }
    
    else{
      this.path.clear();
      this.currentID = this.nextID;
      this.getNext();
      this.p = this.path.get(0);
      this.path.remove(0);
    }
  }
  
  PVector getP(){
    return this.p; 
  }
  
  void getNext(){
    
    this.nextID = map.getMapPoint(this.currentID).getRandomConnection();
    
    PVector a = map.getMapPoint(currentID).getCoords();
    PVector b = map.getMapPoint(nextID).getCoords();
      
    int numSegments = max(10,floor(PVector.dist(a,b)*1.5));
    for(int j = 0; j<numSegments; j++){
      this.path.add((PVector.lerp(a, b, map(j,0,numSegments,0,1))));
    }
  }
  
}
