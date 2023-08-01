
class MapPathAttractor{
  ArrayList<PVector> pos;
  ArrayList<Boolean> clockwise;
  
  MapPathAttractor(MapPath mp){

    ArrayList<MapPoint> path = mp.getPath();
    
    this.pos = new ArrayList<PVector>();
    this.clockwise = new ArrayList<Boolean>();
    
    MapPoint start,end;
    PVector p1 = new PVector();
    PVector p2 = new PVector();
    PVector p3 = new PVector();
    PVector p4 = new PVector();
    
    PVector startCoord = new PVector();
    PVector endCoord = new PVector();
    PVector connecting = new PVector();
    PVector norm = new PVector();
    PVector mid = new PVector();
    
    for(int i = 1; i < path.size(); i++){
      start = path.get(i-1);
      end = path.get(i);
      
      startCoord = start.getCoords();
      endCoord = end.getCoords();
      connecting = PVector.sub(startCoord, endCoord);
      norm = new PVector(connecting.y, -connecting.x);
      
      norm.setMag(connecting.mag()/5);
      p1 = PVector.add(startCoord,norm);
      p2 = PVector.sub(startCoord,norm);
      
      this.pos.add(p1);
      this.pos.add(p2);
      this.clockwise.add(new Boolean(false)); // STANDARD ORIENTATION
      this.clockwise.add(new Boolean(true));
      
      mid = PVector.sub(startCoord,PVector.div(connecting,2)); // ADDED MID ATTRACTORS TO HAVE 90° CURVES BE MORE SHARP
      
      p3 = PVector.add(mid,norm);
      p4 = PVector.sub(mid,norm);
      this.pos.add(p3);
      this.pos.add(p4);
      this.clockwise.add(new Boolean(false)); // STANDARD ORIENTATION
      this.clockwise.add(new Boolean(true));
      
    }
    // ADD SAME ATTRACTORS AS SECOND LAST ALSO TO LAST ONE TO ENSURE STRAIGHT PATH
    p1 = PVector.add(endCoord,norm);
    p2 = PVector.sub(endCoord,norm);
    this.pos.add(p1);
    this.pos.add(p2);
    this.clockwise.add(new Boolean(false));
    this.clockwise.add(new Boolean(true));
    
  }
  
  ArrayList<Particle> moveParticle(ArrayList<Particle> p){
    
    for(int i = 0; i<p.size(); i++){
      
      PVector a = new PVector(0,0);
      PVector acc, partPos;
      Particle part;
      part = p.get(i);
      partPos = part.getPos();
      
      for(int j = 0; j<this.pos.size(); j++){
          acc = PVector.sub(partPos,this.pos.get(j));
          acc.setMag(1/acc.mag());
          if(this.clockwise.get(j).booleanValue())
            acc.rotate(-HALF_PI);
          else
            acc.rotate(HALF_PI);
            
          a.add(acc);
      }
      a.div(PMASS);
      part.setA(a);
      part.move();
    }
    
    return p;
  }
  
}
