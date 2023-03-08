class Map{
  ArrayList<MapPoint> mapPoints = new ArrayList<MapPoint>();
  MapPath path;
  MapLine line;
  
  Map(){
    mapPoints = loadMapPoints();
  }
  
  void show(){
    ListIterator<MapPoint> iter = mapPoints.listIterator();
    while(iter.hasNext()){
      MapPoint m = iter.next();
      m.show();
    }
    line.show();
  }
  
  void createMapPath(){
    path = new MapPath();
  }
  
  void addToPath(int id){
    path.appendPoint(mapPoints.get(id)); 
  }
  
  void endMapPath(){
    path.end();
    this.createLine();
  }
  
  void createLine(){
    this.line = new MapLine(this.path); 
  }
  

  ArrayList<MapPoint> loadMapPoints(){
    
    ArrayList<MapPoint> map = new ArrayList<MapPoint>();
    float x,y;
    int id;
    
    JSONObject mapJson;
    JSONArray features = new JSONArray();
    
    mapJson = loadJSONObject("graphMilan.json");
    features = mapJson.getJSONArray("features");
    
    for(int i = 0; i<features.size(); i++) {
      JSONObject obj = features.getJSONObject(i);
      JSONObject el = obj.getJSONObject("geometry");
      
      if(el.getString("type").equals("Point")){
        
        x = el.getJSONArray("coordinates").getFloat(0);
        y = el.getJSONArray("coordinates").getFloat(1);
        id = obj.getInt("id");
        
        x = ((x - 9.15040660361177) * width) / (9.231021608560354 - 9.15040660361177);
        y = ((y - 45.49082190275931)* height)/ (45.44414445567239 - 45.49082190275931);
        
        map.add(new MapPoint(id,x,y));
      }
    }
    
    //The map is already sorted in theory but sort it at startup just to be sure
    Collections.sort(map, new MapPointSorter());
    return map;
  }
}
