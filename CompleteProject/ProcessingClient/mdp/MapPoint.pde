
class MapPoint{ //CLASSE DEL MAP POINT
 PVector coordinates;
 int id;
 IntList connections;
 ArrayList<MapPoint> line; 
 
  MapPoint(int id, float x, float y){
    this.coordinates = new PVector(x, y);
    this.connections = new IntList();
    this.id = id;
  }
  
  PVector getCoords(){
   return this.coordinates; 
  }
  
  int getId(){
    return this.id;
  }
  
  void addToConnections(IntList addresses){
    for(int i = 0; i<addresses.size(); i++){
      int add = addresses.get(i);
      if(!this.connections.hasValue(add)){
        this.connections.append(add);
        
        map.getMapPoint(add).addConnection(this.id);
      }
    }
  }
  
  void addConnection(int id){
    if(!this.connections.hasValue(id)){
        this.connections.append(id); 
      }
  }
  
  int getRandomConnection(){
    this.connections.shuffle(); // A WAY TO RANDOMIZE WHAT ELEMENT GETS PICKED EACH TIME;
    return this.connections.get(0);
  }
  
  IntList getConnections(){
    return this.connections; 
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

// SORTER PER VEDERE CHE NODO E' PIU' VICINO AL CLICK
class MapPointDistanceSorter implements Comparator<MapPoint>{
  PVector p;
  
  MapPointDistanceSorter(PVector p){
    this.p = p; 
  }
  
  public int compare(MapPoint m1, MapPoint m2){
    float d1 = PVector.dist(m1.getCoords(),this.p);
    float d2 = PVector.dist(m2.getCoords(),this.p);
    
    if(d1>d2)
      return 1;
    else
      return -1;
  }
}
