class MapPathParticle{
  
  ArrayList<PVector> path;
  PVector p;
  int endingID;
  
  MapPathParticle(ArrayList<PVector> buffer, int id){
    this.path = new ArrayList<PVector>(buffer);
    
    this.p = this.path.get(0);
    this.path.remove(0);
    
    this.endingID = id;
  }
  
  void move(){
    if(this.path.size()>0){
      this.p = this.path.get(0);
      this.path.remove(0);
    }
    
    else{
      map.removePathParticle(this); 
    }
  }
  
  PVector getP(){
   return this.p; 
  }
  
  int getID(){
    return this.endingID; 
  }
  
  void addToPath(ArrayList<PVector> extention, int id){
    this.path.addAll(extention);
    this.endingID = id;
  }
}
