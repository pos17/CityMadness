
class MapPath{
  ArrayList<MapPoint> path;
  boolean finished;
  int index;
  
  MapPath(){
    this.path = new ArrayList<MapPoint>();
    this.finished = false;
    this.index = 0;
  }
  
  void appendPoint(MapPoint m){
     path.add(m);
  }
  
  void end(){
    this.finished = true;
    println("Ids of the path:");
    for(int i = 0; i<this.path.size(); i++){
      println(this.path.get(i).getId()); 
    }
    println("End IDs of the path");
  }
  
  boolean hasEnd(){
    return finished; 
  }
  
  void show(){
    strokeWeight(5);
    stroke(0,255,0);
    for(int i = 0; i<this.path.size(); i++){
      MapPoint m = path.get(i);
      PVector p = m.getCoords();
      point(p.x, p.y);
      text(i, p.x + 20, p.y + 20);
    }
  }
  
  MapPoint getNextPoint(){
    if(finished){
      if(index < path.size()){
        MapPoint nextPoint = this.path.get(this.index);
        this.index++;
        return nextPoint;
      }
      else{
        this.index--;
        return this.path.get(this.index);
      }
    }
    else
      return new MapPoint(0,0,-1); //Path is not finished
  }
  
  ArrayList<MapPoint> getPath(){
    return this.path;
  }
  
  /*
  ArrayList<MapPointAttractor> generateAttractors(){
    ArrayList<MapPointAttractor> attractorList = new ArrayList<MapPointAttractor>();
    MapPoint a,b;
    for(int i = 1; i<this.path.size(); i++){
       a = this.path.get(i-1);
       b = this.path.get(i);
       MapPointAttractor attractor = new MapPointAttractor(a,b);
       attractorList.add(attractor);
    }
    
    // MANUALLY SET LAST ATTRACTOR TO BE NULL
    a = this.path.get(path.size()-1);
    attractorList.add(new MapPointAttractor());
    return attractorList;
  }
  */
  
}
