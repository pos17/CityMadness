class MapParticle{
  ArrayList<Particle> system;
  MapPath path;
  MapPoint current, next;
  ArrayList<MapPointAttractor> attractors;
  
  PGraphics render;
  
  MapParticle(MapPath mp){
    this.path = mp;
    // Initialize the attractors
    attractors = new ArrayList<MapPointAttractor>();
    attractors = this.path.generateAttractors();
    
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
    
    this.render.stroke(0,0,255);
    this.render.strokeWeight(5);
    this.render.noFill();
    ListIterator<MapPointAttractor> iter2 = this.attractors.listIterator();
    while(iter2.hasNext()){
      MapPointAttractor att = iter2.next();
      
      PVector[] p = new PVector [4];
      p = att.getPos();
      this.render.point(p[0].x,p[0].y);
      this.render.point(p[1].x,p[1].y);
      this.render.point(p[2].x,p[2].y);
      this.render.point(p[3].x,p[3].y);
    }
    
    this.render.endDraw();
    
    image(this.render,0,0);
    
  }
  
  void moveParticles(){
    
  }
  
}
