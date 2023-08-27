
class MapParticleSystem{
  ArrayList<Particle> system;
  MapPathAttractor att;
  int size;
  
  MapParticleSystem(MapPath mp){
    
    // Initialize the attractors
    this.att = new MapPathAttractor(mp);
    
    this.system = new ArrayList<Particle>();
    this.size = 0;
    /*
    for(int i = 0; i < NMAPPARTICLES; i++){
      system.add(new Particle()); 
    }
    */
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
  
  void addParticle(Particle p){
    system.add(p);
    this.size++;
  }
  
  void showAttractors(){
    this.att.show(); 
  }
  int getSize(){
    return this.size; 
  }
  
  
}
