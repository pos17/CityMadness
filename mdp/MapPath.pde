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
  }
  
  boolean hasEnd(){
    return finished; 
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
}
