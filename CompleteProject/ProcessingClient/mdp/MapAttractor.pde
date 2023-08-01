
class MapAttractor{
  ArrayList<PVector> pos, v;
  ArrayList<Boolean> clockwise;
  
  MapAttractor(int n){
    
    pos = new ArrayList<PVector>();
    v = new ArrayList<PVector>();
    clockwise = new ArrayList<Boolean>();
    
    for(int i = 0; i < n; i++){
      this.pos.add(new PVector(random(0.1,0.9)*width, random(0.1,0.9)*height));
      this.v.add(new PVector(random(-1,1),random(-1,1)));
      if(random(2)>1)
        this.clockwise.add(new Boolean(true));
      else
        this.clockwise.add(new Boolean(false));
    }
  }
  
  void update(){
    for(int i = 0; i<pos.size(); i++){
      PVector p = this.pos.get(i);
      p.add(this.v.get(i));
      
      if(p.x < 0 || p.x > width){
        PVector vel = v.get(i);
        this.v.set(i, new PVector(-vel.x, vel.y));
      }
      if(p.y < 0 || p.y > height){
        PVector vel = v.get(i);
        this.v.set(i, new PVector(vel.x, -vel.y));
      }
    }
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
  
  ArrayList<PVector> getPos(){
    return this.pos; 
  }
}
