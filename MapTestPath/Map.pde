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
             //<>//
            
            srcNodeNoMusic.connectBoth(tgtNodeNoMusic);
            //println("z");
            //println(tgtNodeMusic.z);
            //println(srcNodeMusic.z);
            int tgtNodeMusicId = parseInt(tgtNodeMusic.z);
            int srcNodeMusicId = parseInt(srcNodeMusic.z);
            //println(tgtNodeMusicId);
            //println(srcNodeMusicId);
            float linkWeight = sounds.getWeights(tgtNodeMusicId,srcNodeMusicId);
            linkWeight = 13-linkWeight;
            srcNodeMusic.connectBoth(tgtNodeMusic,linkWeight*10000);
      }
    }
    pf = new Pathfinder(nodesNoMusic);
    pfMusic = new Pathfinder(nodesMusic);
    pfNoMusic = new Pathfinder(nodesNoMusic);
    ArrayList<Node> nodesMus = pfMusic.nodes;
    for(int i = 0; i< nodesMus.size();i++ ) {
      print(nodesMus.get(i).links.get(0)); //<>//
    }
    
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
  
  void createUserPath(int clickedX,int clickedY, int srcX, int srcY,int hasMusic) {
  
    println("click");
    Node srcNode = this.getNodeNearToPoint(srcX,srcY);
    clickedDot = this.getNodeNearToPoint(clickedX,clickedY);
    //println(mapDotsClicked.size());
    sourceClickPath = this.getPath(clickedDot,srcNode,hasMusic);
    
    //println(sourceClickPath);
    
     
    //FloatList distList = new FloatList(); 
    
    for(int i = 0; i < sourceClickPath.size();i++) {
      Node n = sourceClickPath.get(i);
      int nId = parseInt(n.z);
      pathIdList.append(nId);
    }
    //println(pathIdList);
    
    midiList = sounds.generateMidiList(pathIdList);
    tp.add(new TriggerParticle(sourceClickPath));
    thread("initializeParticles");
    //initializeParticles();
    
    
  
  }
  
  ArrayList<Node> getPath(Node src,Node tgt,int pfId) {
    if(pfId == 0) {
      return pf.bfs(src,tgt);
    } else if(pfId == 1) {
      return pfNoMusic.dijkstra(src,tgt);
    } else if(pfId == 2) {
      return this.randomGetPath(src,tgt);
    }
    else return pf.bfs(src,tgt);
  }
  
  ArrayList<Node> getMapDots() {
    return pf.nodes;
  }
  
  
  ArrayList<Node> randomGetPath(Node src, Node tgt) {
    ArrayList<Node> toRet = new ArrayList<Node>();
    
    
    ArrayList<Node> nodes = this.getMapDots();
    Node randomNode1 =  nodes.get(int(random(0,nodes.size())));
    Node randomNode2 =  nodes.get(int(random(0,nodes.size())));
    
    ArrayList<Node> srcR1 = pfNoMusic.bfs(src,randomNode1);
    Collections.reverse(srcR1);
    toRet.addAll(srcR1);
     ArrayList<Node> srcR2 = pfNoMusic.bfs(toRet.get(toRet.size()-1),randomNode2);
    Collections.reverse(srcR2);
    toRet.remove(toRet.size()-1);
    toRet.addAll(srcR2);
    ArrayList<Node> srcR3 = pfNoMusic.bfs(toRet.get(toRet.size()-1),tgt);
    Collections.reverse(srcR3);
    toRet.remove(toRet.size()-1);
    toRet.addAll(srcR3);
    Collections.reverse(toRet);
    return toRet;
  }
  
}
