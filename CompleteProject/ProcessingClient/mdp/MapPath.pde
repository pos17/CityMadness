
class MapPath{
  ArrayList<MapPoint> path;
  boolean finished; // Check if path exists
  int index;
  int len;
  
  MapPath(){
    this.path = new ArrayList<MapPoint>();
    this.finished = false;
    this.index = 0;
    this.len = 0;
  }
  
  MapPath(ArrayList<MapPoint> path){
    this.path = path;
    this.finished = true;
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
        this.index = 0;
        return this.path.get(this.index);
      }
    }
    else
      return new MapPoint(0,0,-1); //Path is not finished
  }
  
  ArrayList<MapPoint> getPath(){
    return this.path;
  }
  
  int getLength(){
    return this.len; 
  }
  
  void updatePath(MapPoint p){
    this.path.add(p);
    this.len++;
    
    if(this.len > 10){
      path.remove(0);
      this.len--;
    }
  }
}
