class MapPathParticle{
  
  ArrayList<PVector> path;
  PVector lastPoint;
  boolean onPath;
  
  MapPathParticle(MapPath p){
    this.onPath = true;
    
    ArrayList<MapPoint> m = p.getPath();
    
    for(int i = 0; i<m.size()-1; i++){
      PVector a = m.get(i).getCoords();
      PVector b = m.get(i+1).getCoords();
      
      int numSegments = floor(PVector.dist(a,b)/2);
      for(int j = 0; j<numSegments; j++){
       this.path.add((PVector.lerp(a, b, map(j,0,numSegments,0,1))));
      }
    }
    
    // Save Last Point to use it to create the particle when this one dies
    this.lastPoint = this.path.get(this.path.size()-1);
  }
  
  PVector move(){
    if(this.onPath && this.path.size() > 0){
      PVector p = this.path.get(0);
      this.path.remove(0);
      return p; 
    }
    else{ // QUA SI DOVREBBE DIRE DI POTER DIVENTARE O CAOTICA LIBERA O CAOTICA ONPATH
      this.onPath = false;
      
      float[] f = this.lastPoint.array();
      map.addChaoticParticle(new Particle(f[0], f[1]));
      
      return null; // NON FUNZIONA
    }
  }
  
}
