
/*
class ChaoticParticleSystem{
  
  ArrayList<Particle> system;
  boolean left, top;
  Distanciator d;
  int maxSize;
  
  ChaoticParticleSystem(MapPath p, boolean l, boolean t, int max){
    this.left = l;
    this.top = t;
    this.maxSize = max;
    
    ArrayList<MapPoint> path = p.getPath();
    ArrayList<PVector> pos = new ArrayList<PVector>();
    for(int i = 0; i<path.size(); i++){
       pos.add(path.get(i).getCoords());
    }
    if(this.top && this.left)
      this.d = new DistanciatorTL(pos);
      
    else if(this.top && !this.left)
      this.d = new DistanciatorTR(pos);
      
    else if(!this.top && this.left)
      this.d = new DistanciatorBL(pos);
      
    else if(!this.top && !this.left)
      this.d = new DistanciatorBR(pos);
  }
  
}

class Distanciator{
  ArrayList<PVector> p;
}

class DistanciatorTL extends Distanciator{
  DistanciatorTL(ArrayList<PVector> p){
    this.p = p;
  }
  
  ArrayList<Particle> moveParticles(ArrayList<Particle>){
    ListIterator<Particle> iter = this.p.listIterator();
      while(iter.hasNext()){
        Particle p = iter.next();
        
      }
  }
}

class DistanciatorTR extends Distanciator{
  DistanciatorTR(ArrayList<PVector> p){
    this.p = p;
  }
}

class DistanciatorBL extends Distanciator{
  DistanciatorBL(ArrayList<PVector> p){
    this.p = p;   
  }
}

class DistanciatorBR extends Distanciator{
  DistanciatorBR(ArrayList<PVector> p){
    this.p = p;
  }
}

*/
