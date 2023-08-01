
class MapParticleSystem{
  ArrayList<Particle> system;
  MapPath path;
  MapPoint current, next;
  MapPathAttractor att;
  
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
    
    
  }
  
  ArrayList<Particle> getSystem(){
    return this.system;
  }
  
  void moveParticles(){
    system = att.moveParticle(system);
  }
}
