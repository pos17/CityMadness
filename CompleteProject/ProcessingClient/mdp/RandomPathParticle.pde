
class RandomPathParticle{ // PARTICELLE CHE GIRANO A CASO PER I NODI VISTI
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
    this.move(10);
  }
  
  void move(int myNumSegments) {
    if(this.path.size()>0){
      this.p = this.path.get(0);
      this.path.remove(0);
    } else {
      this.path.clear();
      this.currentID = this.nextID;
      this.getNext(myNumSegments);
      this.p = this.path.get(0);
      this.path.remove(0);
    }
  }
  
  PVector getP(){
    return this.p; 
  }
  
  void getNext(){
    getNext(10);
    
  }
  
  void getNext(int myNumSegments) {
    this.nextID = map.getMapPoint(this.currentID).getRandomConnection();
    
    PVector a = map.getMapPoint(currentID).getCoords();
    PVector b = map.getMapPoint(nextID).getCoords();
      
    int numSegments = max(myNumSegments,floor(PVector.dist(a,b)*1.5));
    for(int j = 0; j<numSegments; j++){
      this.path.add((PVector.lerp(a, b, map(j,0,numSegments,0,1))));
    }
  }
  
}
