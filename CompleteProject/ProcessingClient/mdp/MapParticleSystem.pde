
class MapParticleSystem{
  ArrayList<Particle> system;
  MapPathAttractor att;
  
  MapParticleSystem(MapPath mp){
    
    // Initialize the attractors
    this.att = new MapPathAttractor(mp);
    
    this.system = new ArrayList<Particle>();
    for(int i = 0; i < NMAPPARTICLES; i++){
      system.add(new Particle()); 
    }
  }
  
  void generateAttractors(MapPath mp){
    this.att = new MapPathAttractor(mp);
  }
  
  ArrayList<Particle> getSystem(){
    return this.system;
  }
  
  void moveParticles(){
    system = att.moveParticle(system);
  }
}
