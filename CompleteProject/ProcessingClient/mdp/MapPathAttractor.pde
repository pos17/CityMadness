
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
    
    PVector startCoord = new PVector();
    PVector endCoord = new PVector();
    PVector connecting = new PVector();
    PVector norm = new PVector();
    
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
        //if(PVector.dist(this.quad[j],p[i].getQuad()) < 2*DQUAD){
          acc = PVector.sub(partPos,this.pos.get(j));
          acc.setMag(1/acc.mag());
          if(this.clockwise.get(j).booleanValue())
            acc.rotate(-HALF_PI);
          else
            acc.rotate(HALF_PI);
            
          a.add(acc);
       // }
      }
      //v.sub((PVector.sub(p[i],mid)).setMag(0.01));
      a.div(PMASS);
      part.setA(a);
      part.move();
      //p.set(i,part);
    }
    
    return p;
  }
  
  void show(){
    PGraphics render = createGraphics(width,height,P2D);
    render.beginDraw();
    render.noFill();
    render.stroke(0,0,255);
    render.strokeWeight(2);
    for(int i = 0; i<this.pos.size(); i++){
      PVector p = this.pos.get(i);
      render.point(p.x,p.y);
    }
    render.endDraw();
    image(render,0,0);
  }
  
}
