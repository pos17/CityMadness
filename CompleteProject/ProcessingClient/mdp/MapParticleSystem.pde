
class MapParticleSystem{
  ArrayList<Particle> system;
  MapPath path;
  MapPoint current, next;
  MapPathAttractor att;
  
  PGraphics render;
  
  MapParticleSystem(MapPath mp){
    this.path = mp;
    // Initialize the attractors
    att = new MapPathAttractor(this.path);
    
    // Set the first two points
    this.current = this.path.getNextPoint();
    this.next = this.path.getNextPoint();
    
    system = new ArrayList<Particle>();
    for(int i = 0; i < NMAPPARTICLES; i++){
      system.add(new Particle()); 
    }
    
    this.render = createGraphics(width,height,P2D);
    
  }
  
  void show(){
    
    system = att.moveParticle(system);
    
    this.render.beginDraw();
    this.render.clear();
    this.render.noFill();
    this.render.stroke(255);
    this.render.strokeWeight(3);
    ListIterator<Particle> iter = this.system.listIterator();
    while(iter.hasNext()){
      PVector p = iter.next().getPos();
      this.render.point(p.x, p.y);
    }
    
    this.render.endDraw();
    
    image(this.render,0,0);
    
    this.att.show();
    
  }
}
