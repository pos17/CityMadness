class MapPoint{
 float x,y;
 int id;
 boolean lineString;
 ArrayList<MapPoint> line;
 
  MapPoint(int id, float x, float y){
    this.x = x;
    this.y = y;
    this.id = id;
  }
  
  float[] getCoords(){
    float[]f = {this.x, this.y};
   return f; 
  }
  
  int getId(){
    return this.id;
  }
  
  void show(){
    stroke(255,0,0);
    strokeWeight(3);
    point(this.x,this.y);
  }
}

class MapPointSorter implements Comparator<MapPoint> {  
    public int compare(MapPoint m1, MapPoint m2)
    {
        if (m1.getId() == m2.getId())
            return 0;
        else if (m1.getId() > m2.getId())
            return 1;
        else
            return -1;
    }
}
