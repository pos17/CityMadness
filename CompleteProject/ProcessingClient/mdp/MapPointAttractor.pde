class MapPointAttractor{
  PVector[] pos;
  boolean[] clockwise;
  boolean active;
  
  // NULL ATTRACTOR NEEDED FOR LAST ELEMENT IN PATH (NO ATTRACTOR NEEDED THERE)
  MapPointAttractor(){
    this.active = false;
    this.pos = new PVector[4];
    pos[0] = new PVector(0,0);
    pos[1] = new PVector(0,0);
    pos[2] = new PVector(0,0);
    pos[3] = new PVector(0,0);
  }
  
  MapPointAttractor(MapPoint start, MapPoint end){
    this.active = true;
    this.pos = new PVector[4];
    this.clockwise = new boolean[4];
    
    PVector startCoord = start.getCoords();
    PVector endCoord = end.getCoords();
    
    PVector connecting = PVector.sub(startCoord, endCoord);
    PVector norm = new PVector(connecting.y, -connecting.x);
    
    norm.setMag(connecting.mag()/10);
     
    pos[0] = PVector.add(startCoord,norm);
    pos[1] = PVector.sub(startCoord,norm);
    pos[2] = PVector.add(endCoord,norm);
    pos[3] = PVector.sub(endCoord,norm);
     
    clockwise[0] = true;
    clockwise[1] = false;
    clockwise[2] = true;
    clockwise[3] = false;
  }
  
  PVector[] getPos(){
    return this.pos;
  }
  
  
}
