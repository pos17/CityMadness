
JSONObject json;

class JSONPoints {
  Pathfinder pf;
  
  JSONArray features = new JSONArray();
  JSONArray points = new JSONArray();
  JSONArray connections= new JSONArray();
  //ArrayList<ControlPoint> controlPoints;
  
  
  /* Cremona 
  float tRCoordX = 10.041624438149427;
  float tRCoordY = 45.146485875477254;
  float bLCoordX = 9.99635398643295;
  float bLCoordY = 45.12452785362902;
  */
  
  /* Milano */
  float tRCoordX = 9.231021608560354;
  float tRCoordY = 45.49082190275931;
  float bLCoordX = 9.15040660361177;
  float bLCoordY = 45.44414445567239;
  
  
  JSONPoints() {
    //controlPoints = new ArrayList<ControlPoint>();
    ArrayList<Node> nodes = new ArrayList<Node>();
    
    json = loadJSONObject("graphMilan.json");
    //println(json);
    features = json.getJSONArray("features");
    points = new JSONArray();
    
    
    for(int i = 0; i<features.size(); i++) {
      //println("i:"+i);
      JSONObject obj = features.getJSONObject(i);
      JSONObject el = obj.getJSONObject("geometry");
      //println(el.getString("type"));
      if(el.getString("type").equals("Point")) {
        points.append(obj);
        int objId = obj.getInt("id");
        //println(el.getJSONArray("coordinates").getFloat(0));
        float objx = el.getJSONArray("coordinates").getFloat(0);
        float objy = el.getJSONArray("coordinates").getFloat(1);
        objx = objx - bLCoordX;
        objy = objy - tRCoordY;
        
        int objxInt = parseInt((objx* width)/(tRCoordX-bLCoordX));
        int objyInt = parseInt((objy* height)/(bLCoordY-tRCoordY));
        //println(objxInt);
        //ControlPoint cp = new ControlPoint(objxInt,objyInt,objId);
        //println(cp);
        //controlPoints.add(cp);
        //println("here 1");
        //println("x:"+cp.x+", y"+cp.y+", id:"+cp.id);
        
        Node nd = new Node(objxInt,objyInt,objId);
        nodes.add(nd);  
      }
    }
    
    for(int i = 0; i<features.size(); i++) {
      //println("i:"+i);
      JSONObject obj = features.getJSONObject(i);
      JSONObject el = obj.getJSONObject("geometry");
      //println(el.getString("type"));
      if(el.getString("type").equals("LineString")) {
            int src = obj.getInt("src");
            Node srcNode = new Node();
            int tgt = obj.getInt("tgt");
            Node tgtNode = new Node();
            
            for(int j = 0; j<nodes.size();j++) {
              Node chNode = nodes.get(j);
              if(chNode.z==src){
                srcNode = chNode;
              } else if(chNode.z==tgt) {
                tgtNode = chNode;
              }
            }
            srcNode.connectBoth(tgtNode);
      }
    }
    
    pf = new Pathfinder(nodes);
    println("number of nodes:"+nodes.size());
     //println(pf.nodes);
  }
  /*
  ArrayList<ControlPoint> getControlPoints() {
    return controlPoints;
  }
  */
  Pathfinder getPathfinder() {
    return pf;
  }
  
  int getWidthGivenHeight(int givenheight) {
    int givenwidth = parseInt(abs(givenheight/(tRCoordY-bLCoordY)*(tRCoordX-bLCoordX)));
    println(givenwidth);
    println(givenheight);
    return givenwidth;
  }
  
  ArrayList<Node> getNodesInArea(float xPosRatio, int yPosRatio,int radius) {
    int cPosx = parseInt(xPosRatio);
    int cPosy = parseInt(yPosRatio);
    ArrayList<Node> toRet = new ArrayList<Node>();
    
      for (int i = 0; i < this.pf.nodes.size(); i++) {
        Node node = (Node)this.pf.nodes.get(i);
        int pDist = parseInt(sqrt(sq((node.x)-cPosx)+sq((node.y)-cPosy)));
        if (pDist < radius) {
          toRet.add(node);
        }
      }
    return toRet;
  }
  
  Node getNodeNearToPoint(float xPosRatio, int yPosRatio) {
    int cPosx = parseInt(xPosRatio);
    int cPosy = parseInt(yPosRatio);
    float refDist = -1; 
    Node toRet = new Node();
    //ArrayList<Node> toRet = new ArrayList<Node>();
    
      for (int i = 0; i < this.pf.nodes.size(); i++) {
        Node node = (Node)this.pf.nodes.get(i);
        float pDist = sqrt(sq((node.x)-cPosx)+sq((node.y)-cPosy));
        if(refDist == -1) {
          refDist = pDist;
          toRet = node;
        } else if (pDist < refDist) {
          refDist = pDist;
          toRet = node;
        }
      }
    return toRet;
  }
  
}


/*
class ControlPoint{
  int x,y,id;
  IntList connections; // attento ve che sono gli indici dei controlpoint nella lista mapDots, non gli id dei punti
  
  ControlPoint(int x, int y, int id){
     this.x = x;
     this.y = y;
     this.id = id;
  }
  
  void setupConnections(){
    this.connections = new IntList();
     int nConnections = (int)random(2,5);
     while(connections.size()<nConnections){
       int index = (int)random(mapDots.size());
       int connectionId = mapDots.get(index).getId();
       if(!this.connections.hasValue(index) && connectionId != this.id){
         this.connections.append(index);
       }
     }
  }
  int getX(){
    return this.x;
  }
  
  int getY(){
    return this.y;
  }
  
  int getId(){
    return this.id; 
  }
  
  void show(){
    strokeWeight(5);
    stroke(255,0,0);
    point(this.x, this.y);
  }
  
  IntList getConnections(){
    return this.connections;
  }
}
*/
