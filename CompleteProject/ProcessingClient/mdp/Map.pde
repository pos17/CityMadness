class Map{
  ArrayList<MapPoint> mapPoints = new ArrayList<MapPoint>();
  MapPath path;
  MapLine line;
  
  boolean pathDone;
  
  Map(){
    this.mapPoints = loadMapPoints();
    this.pathDone = false;
  }
  
  void show(){
    ListIterator<MapPoint> iter = mapPoints.listIterator();
    while(iter.hasNext()){
      MapPoint m = iter.next();
      m.show();
    }
    if(pathDone){
      path.show();
      line.show();
    }   
  }
  
  void createMapPath(){
    this.path = new MapPath();
  }
  
  void addToPath(int id){
    this.path.appendPoint(mapPoints.get(id)); 
  }
  
  void endMapPath(){
    this.path.end();
    this.pathDone = true;
    this.createLine();
  }
  
  void createLine(){
    this.line = new MapLine(this.path); 
  }
  
  MapPoint getMapPoint(int id){
    return this.mapPoints.get(id);
  }
  

  ArrayList<MapPoint> loadMapPoints(){
    
    ArrayList<MapPoint> map = new ArrayList<MapPoint>();
    float x,y;
    int id;
    
    JSONObject mapJson;
    JSONArray features = new JSONArray();
    
    mapJson = loadJSONObject("graphCremona.json");
    features = mapJson.getJSONArray("features");
    
    // map.add(new MapPoint(0,0,0)); // Offset to get that Id of the MapPoint = index in the ArrayList
    for(int i = 0; i<features.size(); i++) {
      JSONObject obj = features.getJSONObject(i);
      JSONObject el = obj.getJSONObject("geometry");
      
      if(el.getString("type").equals("Point")){
        
        x = el.getJSONArray("coordinates").getFloat(0);
        y = el.getJSONArray("coordinates").getFloat(1);
        id = obj.getInt("id")-1;
        
        // MILAN
        /*
        x = ((x - 9.15040660361177) * width) / (9.231021608560354 - 9.15040660361177);
        y = ((y - 45.49082190275931)* height)/ (45.44414445567239 - 45.49082190275931);
        */
        
        // CREMONA
        x = ((x - 10.012826061753287) * width) / (10.031731839461685 - 10.012826061753287);
        y = ((y - 45.138503171087336)* height)/ (45.13185662179308 - 45.138503171087336);
        
        map.add(new MapPoint(id,x,y));
      }
    }
    
    //The map is already sorted in theory but sort it at startup just to be sure
    Collections.sort(map, new MapPointSorter());
    
    return map;
  }
}
