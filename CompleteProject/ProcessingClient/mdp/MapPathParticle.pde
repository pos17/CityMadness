class MapPathParticle{ //PARTICELLE CHE SEGUONO GLI ULTIMI NODI VISITATI
  
  ArrayList<PVector> path;
  PVector p;
  int endingID;
  color c1 = color(255, 195, 34);
  //color c2 = color(255, 100,0);
  color c2 = color(0,255,0);
  
  color c;
  
  boolean extended = false;
  
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
  
  color getColor(){
    if(!this.extended){
      if(this.path.size()<200){
        return lerpColor(c2,c1,float(this.path.size())/200);
      }
      return this.c1;
    }
    return this.c;
 
  }
  
  PVector getP(){
   return this.p; 
  }
  
  int getID(){
    return this.endingID; 
  }
  
  void addToPath(ArrayList<PVector> extention, int id){
    if(this.path.size()<50){
      this.c = lerpColor(c2,c1,float(this.path.size())/50);
      this.extended = true;
    }
      
    this.path.addAll(extention);
    this.endingID = id;
   
    
  }
}
