
class MapPoint{
 PVector coordinates;
 int id;
 ArrayList<MapPoint> line; 
 
  MapPoint(int id, float x, float y){
    this.coordinates = new PVector(x, y);
    this.id = id;
  }
  
  PVector getCoords(){
   return this.coordinates; 
  }
  
  int getId(){
    return this.id;
  }
  
  void show(){
    stroke(255,0,0);
    strokeWeight(3);
    point(this.coordinates.x,this.coordinates.y);
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
