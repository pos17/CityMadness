class Map {
  
  JSONObject myJSON;
  Pathfinder pf;
  Pathfinder pfNoMusic;
  Pathfinder pfMusic;
  JSONArray features = new JSONArray();
  JSONArray points = new JSONArray();
  JSONArray connections= new JSONArray();
  float tRCoordX = 0;
  float tRCoordY = 0;
  float bLCoordX = 0;
  float bLCoordY = 0;
  SoundWeights sounds;
 
  Map(String jsonChosen, float trXCoord,float trYCoord,float blXCoord,float blYCoord) {        
    this.tRCoordX = trXCoord;
    this.tRCoordY = trYCoord;
    this.bLCoordX = blXCoord;
    this.bLCoordY = blYCoord;
    ArrayList<Node> nodesMusic = new ArrayList<Node>();
    ArrayList<Node> nodesNoMusic = new ArrayList<Node>();
    myJSON = loadJSONObject(jsonChosen);
    features = myJSON.getJSONArray("features");
    points = new JSONArray();
    sounds = new SoundWeights();
    
    
    for(int i = 0; i<features.size(); i++) {
      //println("i:"+i);
      JSONObject obj = features.getJSONObject(i);
      JSONObject el = obj.getJSONObject("geometry");
      //println(el.getString("type"));
      if(el.getString("type").equals("Point")) {
        points.append(obj);
        float objId = obj.getInt("id");
        float objx = el.getJSONArray("coordinates").getFloat(0);
        float objy = el.getJSONArray("coordinates").getFloat(1);
        objx = objx - bLCoordX;
        objy = objy - tRCoordY;
        
        int objxInt = parseInt((objx* width)/(tRCoordX-bLCoordX));
        int objyInt = parseInt((objy* height)/(bLCoordY-tRCoordY));
        
        
        //Node nd = new Node(objxInt,objyInt,objId);
        Node ndNoMusic = new Node(objxInt,objyInt,objId);
        nodesNoMusic.add(ndNoMusic);
        
        Node ndMusic = new Node(objxInt,objyInt,objId);  
        nodesMusic.add(ndMusic);
        if(objId/100.0 == 0.0) {
        println("Porco dio ");
        }
        
        //if(i<100) {
        //  println(objId);
        //}
        sounds.addNote(int(objId));
        
      }
    }
    //println(sounds.notes);
    for(int i = 0; i<features.size(); i++) {
      //println("i:"+i);
      JSONObject obj = features.getJSONObject(i);
      JSONObject el = obj.getJSONObject("geometry");
      //println(el.getString("type"));
      if(el.getString("type").equals("LineString")) {
            float src = obj.getInt("src");
            
            //println("JSON");
            //println(src);
            Node srcNodeMusic = new Node();
            Node srcNodeNoMusic = new Node();
            
            float tgt = obj.getInt("tgt");
            // println(tgt);
            Node tgtNodeNoMusic = new Node();
            Node tgtNodeMusic = new Node();
            
            for(int j = 0; j<nodesMusic.size();j++) {
              Node chNodeNoMusic = nodesNoMusic.get(j);
              Node chNodeMusic = nodesMusic.get(j);
              float chNodeId = chNodeMusic.z;
              
              if(chNodeId==src){
                srcNodeNoMusic = chNodeNoMusic;
                srcNodeMusic = chNodeMusic;
              } else if(chNodeId==tgt) {
                tgtNodeNoMusic = chNodeNoMusic;
                tgtNodeMusic = chNodeMusic;
              } 
            }
            if(srcNodeMusic.z == 0.0) {
                println("Porco dio000 ");
            }
            if(tgtNodeMusic.z == 0.0) {
                println("Porco dio "); //<>//
                println(obj);
                println(src);
                println(tgt);
            }
            
            srcNodeNoMusic.connectBoth(tgtNodeNoMusic);
            //println("z");
            //println(tgtNodeMusic.z);
            //println(srcNodeMusic.z);
            int tgtNodeMusicId = parseInt(tgtNodeMusic.z);
            int srcNodeMusicId = parseInt(srcNodeMusic.z);
            //println(tgtNodeMusicId);
            //println(srcNodeMusicId);
            float linkWeight = sounds.getWeights(tgtNodeMusicId,srcNodeMusicId);
            
            srcNodeMusic.connectBoth(tgtNodeMusic,linkWeight);
      }
    }
    pf = new Pathfinder(nodesNoMusic);
    pfMusic = new Pathfinder(nodesMusic);
    pfNoMusic = new Pathfinder(nodesNoMusic);
    
    println("number of nodes:"+nodesMusic.size());
    println("number of nodes:"+nodesNoMusic.size());
    
    
    
  }
  
  
  Node getNodeNearToPoint(float xPosRatio, int yPosRatio) {
    int cPosx = parseInt(xPosRatio);
    int cPosy = parseInt(yPosRatio);
    float refDist = -1; 
    Node toRet = new Node();
    //ArrayList<Node> toRet = new ArrayList<Node>();
    
      for (int i = 0; i < this.pfNoMusic.nodes.size(); i++) {
        Node node = (Node)this.pfNoMusic.nodes.get(i);
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
  
  Pathfinder getPathfinder(int mypathFinder) {
    if(mypathFinder == 0) {
      return pf;
    } else if(mypathFinder == 1) {
      return pfNoMusic;
    } else if(mypathFinder == 2) {
      return pfMusic;
    } else 
      return pf;
  }
  
  void createUserPath(boolean music, int clickedX,int clickedY, int srcX, int srcY,int hasMusic) {
  
    println("click");
    Node srcNode = this.getNodeNearToPoint(srcX,srcY);
    clickedDot = this.getNodeNearToPoint(clickedX,clickedY);
    //println(mapDotsClicked.size());
    sourceClickPath = getPath(clickedDot,srcNode,hasMusic);
    thread("initializeParticles");
    
  
  }
  
  ArrayList<Node> getPath(Node src,Node tgt,int pfId) {
    if(pfId == 0) {
      return pf.aStar(src,tgt);
    } else if(pfId == 1) {
      return pfNoMusic.dijkstra(src,tgt);
    } else if(pfId == 2) {
      return pfMusic.dijkstra(src,tgt);
    }
    else return pf.bfs(src,tgt);
  }
  
  ArrayList<Node> getMapDots() {
    return pf.nodes;
  }
  
}
