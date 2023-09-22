
class Map{
  ArrayList<MapPoint> mapPoints = new ArrayList<MapPoint>();
  MapPath path;
  MapLine line;
  
  PVector startPath;
  PVector endPath;
  int endPathID;
  
  ArrayList<ChaoticParticle> chaoticParticles = new ArrayList<ChaoticParticle>();
  ArrayList<MapPathParticle> pathParticles = new ArrayList<MapPathParticle>();
  ArrayList<RandomPathParticle> wanderingParticles = new ArrayList<RandomPathParticle>();
  
  ArrayList<PVector> pathParticlePosBuffer = new ArrayList<PVector>();
  
  ArrayList<MapPoint> nextPoints = new ArrayList<MapPoint>();
  MapPoint toInterestPoint;
  MapPoint interestPoint;
  MapPoint currentPoint;
  
  boolean pathDone, systemCreated;
  
  PGraphics shadow;
  
  PGraphics city, render;
  
  PImage cityGraphics;
  ArrayList<MapFragment> mapFragments = new ArrayList<MapFragment>();
  
  Map(){
    this.mapPoints = loadMapPoints();
    this.pathDone = false;
    this.systemCreated = false;
    this.renderMap();
    this.render = createGraphics(width, height, P2D);
    this.shadow = createGraphics(width, height, P2D);
    this.path = new MapPath();
    this.line = new MapLine(this.path);
    for(int i = 0; i < NMAPPARTICLES; i++){
      chaoticParticles.add(new ChaoticParticle()); 
    }
    //this.cityGraphics = new PImage(width, height, 2);
    this.cityGraphics = loadImage("map.png");
    this.cityGraphics.resize(width,height);
    this.startPath = new PVector();
    this.endPath = new PVector();
  }
  
  void show(){
    this.render.beginDraw();
    //this.render.clear();
    
    this.render.noStroke();
    this.render.fill(0,50);
    this.render.rect(0,0,width,height);
    
    this.render.push();
    this.render.translate(HALF_WIDTH,HALF_HEIGHT);
    
    println(this.mapFragments.size());
    for(int i = 0; i<this.mapFragments.size(); i++){
      MapFragment f = mapFragments.get(i);
      
      float alpha = f.getAlpha();
      this.render.tint(255,alpha);
      this.render.image(f.show(),-HALF_WIDTH,-HALF_HEIGHT); 
    }
    
    //SHOW CHAOTIC PARTICLES
    this.render.stroke(255,MAPPARTICLEALPHA);
    this.render.strokeWeight(3);
    
    if(click){
       this.renderShadow();
    }
    
    if(this.pathDone){ // BEHAVIOUR IF WE HAVE A PATH
      
      ListIterator<ChaoticParticle> chaoticParticlesIter = this.chaoticParticles.listIterator();
      while(chaoticParticlesIter.hasNext()){
        ChaoticParticle m = chaoticParticlesIter.next();
        m.moveNoise();
        PVector p = m.getPos();
        
        if(particleIsNearStartPath(p)){
          pathParticles.add(new MapPathParticle(this.pathParticlePosBuffer, endPathID));
          chaoticParticlesIter.remove();
        }
        else{
          render.point(p.x,p.y);
        }
      }
    }
    else{ // BEHAVIOUR IF WE DON'T HAVE A PATH
      ListIterator<ChaoticParticle> chaoticParticlesIter = this.chaoticParticles.listIterator();
      while(chaoticParticlesIter.hasNext()){
        ChaoticParticle m = chaoticParticlesIter.next();
        m.moveNoise();
        PVector p = m.getPos();
        render.point(p.x,p.y);
      }
    }
    
    /*
   for(int i = 0; i<alphaLine.getChildCount(); i++){
     PShape s = alphaLine.getChild(i);
     this.render.shape(s,0,0);
   }
   */
   
   //this.render.image(this.shadow,-HALF_WIDTH,-HALF_HEIGHT);
   

    this.render.strokeWeight(3);
    //RENDER RANDOM PATH PARTICLES
    if(this.wanderingParticles.size()>0){
      ListIterator<RandomPathParticle> wanderingParticlesIter = this.wanderingParticles.listIterator();
      this.render.stroke(255,200,0);
      while(wanderingParticlesIter.hasNext()){
        RandomPathParticle m = wanderingParticlesIter.next();
        m.move();
        PVector p = m.getP();
        this.render.point(p.x,p.y);
      }
    }
    
    // RENDER PATH PARTICLES
    if(this.pathDone){
      this.render.stroke(50,50,255);
      
      for(int i = 0; i<pathParticles.size(); i++){
        MapPathParticle m = pathParticles.get(i);
        PVector p = m.getP();
        render.point(p.x,p.y);
        m.move();
      }
    }
    
    
    if(!startup){
      //println("RENDERING NEXT POINTS");
      this.render.stroke(0,0,255, 255*sin(5*radians(frameCount)));
      this.render.strokeWeight(8);
      ListIterator<MapPoint> nextPointIter = nextPoints.listIterator();
      while(nextPointIter.hasNext()){
        PVector p = nextPointIter.next().getCoords();
        this.render.point(p.x, p.y);
      }
      
      // CURRENT POINT
      this.render.stroke(255,0,0);
      PVector p = currentPoint.getCoords();
      this.render.point(p.x,p.y);
      
      // PATH TO INTEREST POINT
      this.render.stroke(0,255,255, 255*sin(5*radians(frameCount)));
      p = toInterestPoint.getCoords();
      this.render.point(p.x,p.y);
      
      // TEMP, CURRENT INTEREST POINT
      /*
      this.render.strokeWeight(12);
      p = interestPoint.getCoords();
      this.render.point(p.x,p.y);
      */
    }
    
    if(this.line.exists()){
      ArrayList<PVector> lineList = line.show();
      ListIterator<PVector> linetIter = lineList.listIterator();
      
      while(linetIter.hasNext()){
        PVector p = linetIter.next();
        this.render.stroke(255, map(linetIter.nextIndex(),0,lineList.size(),0,70));
        this.render.point(p.x, p.y);
      }
    }
    
    this.render.pop();
    this.render.endDraw();
    image(this.render,0,0);
    //image(this.city,0,0);
    
    //shape(alphaLine,0,0);
        
  }
  
  void createLine(){
    this.line = new MapLine(this.path); 
  }
  
  MapPoint getMapPoint(int id){
    return this.mapPoints.get(id);
  }
  
  PVector getPointCoords(int id){
     return this.mapPoints.get(id).getCoords();
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
        x = ((x - 10.012826061753287) * width) / (10.031731839461685 - 10.012826061753287) - HALF_WIDTH;
        y = ((y - 45.138503171087336)* height)/ (45.13185662179308 - 45.138503171087336) - HALF_HEIGHT;
        
        map.add(new MapPoint(id,x,y));
      }
    }
    
    //The map is already sorted in theory but sort it at startup just to be sure
    Collections.sort(map, new MapPointSorter());
    
    return map;
  }
  
  void renderMap(){
    this.city = createGraphics(width, height, P2D);
    this.city.beginDraw();
    this.city.translate(HALF_WIDTH, HALF_HEIGHT);
    //this.city.background(0);
    this.city.stroke(255,0,0);
    this.city.noFill();
    this.city.strokeWeight(5);
    for(int i = 0; i<mapPoints.size(); i++){
      PVector pos = mapPoints.get(i).getCoords();
      this.city.point(pos.x, pos.y);
    }
    this.city.endDraw();
  }
  
  int getClosestPointId(float x, float y){
    PVector p = new PVector(x,y);
    ArrayList<MapPoint> distSorted;
    // If an element has alredy been clicked only check in the next points
    if(!pathDone){
      distSorted = new ArrayList<MapPoint>(this.mapPoints);
    }
    else{
      distSorted = new ArrayList<MapPoint>(this.nextPoints);
    }
    distSorted.sort(new MapPointDistanceSorter(p));
    strokeWeight(9);
    stroke(25,200,100);
    point(distSorted.get(0).getCoords().x,distSorted.get(0).getCoords().y);
    return distSorted.get(0).getId();
  }
  
  void setNextPoints(IntList addr){
    this.nextPoints.clear();
    for(int i = 0; i<addr.size(); i++){
      this.nextPoints.add(this.getMapPoint(addr.get(i))); 
    }
    
  }
  
  void updatePath(int id){
    this.path.updatePath(this.getMapPoint(id));
    this.pathParticlePosBuffer = this.path.computeParticleBuffer();
    
    if(time>1){
      //this.system.generateAttractors(this.path);
      //println("UPDATE PATH");
      
      this.line.updatePath(this.path);
      this.pathDone = true;
    }
    
    //Set first and last path point
    this.startPath = this.path.getStartPath();
    this.endPath = this.path.getEndPath();
    this.endPathID = this.path.getEndID();
    
    /*
    this.alphaLine = createShape(GROUP);
    ArrayList<MapPoint> pathList = path.getPath();
    for(int n = 0; n<30; n++){
      PShape s = createShape();
      s.setStrokeJoin(ROUND);
      s.setFill(false);
      s.strokeJoin(ROUND);
      s.setStrokeWeight(map(n,0,30,0,120));
      s.setStroke(color(0,25));
      s.beginShape();
      
      for(int i = 0; i<pathList.size(); i++){
        PVector p = pathList.get(i).getCoords();
        s.vertex(p.x,p.y);
      }
      s.endShape();
      alphaLine.addChild(s);
    }
    */
    
    startup = false; //After second click we exit map startup
  }
  
  void renderShadow(){
    this.shadow.beginDraw();
    this.shadow.push();
    this.shadow.translate(HALF_WIDTH, HALF_HEIGHT);
    this.shadow.stroke(0,10);
    this.shadow.noFill();
    this.shadow.strokeJoin(ROUND);
    
    PGraphics mask = createGraphics(width,height, P2D);
    mask.beginDraw();
    mask.push();
    mask.translate(HALF_WIDTH, HALF_HEIGHT);
    mask.background(0);
    mask.stroke(255,25);
    mask.noFill();
    mask.strokeJoin(ROUND);
    mask.strokeWeight(50);
    
    IntList addresses = this.currentPoint.getConnections();
    ArrayList<PVector> to = new ArrayList<PVector>();
    println(addresses.size());
    for(int i = 0; i<addresses.size(); i++){
      to.add(this.getMapPoint(addresses.get(i)).getCoords());
    }
    PVector from = this.currentPoint.getCoords();
    
    for(int i = 0; i<to.size();i++){
      PVector t = to.get(i);
      for(int j = 0; j<20; j++){
        this.shadow.strokeWeight(map(j,0,20,5,50));
        this.shadow.line(t.x,t.y,from.x,from.y);
        mask.strokeWeight(map(j,0,20,5,50));
        mask.line(t.x,t.y,from.x,from.y);
      }
      
    }
    mask.pop();
    mask.endDraw();
    
    mask.loadPixels(); // TEST
    
    PImage fragment = loadImage("map.png");
    fragment.resize(width,height);
    println("Resized: " + fragment.pixelDensity);
    println("Gen: " + mask.pixelDensity);
    
    
    fragment.mask(mask);
    
    this.mapFragments.add(new MapFragment(fragment, this.currentPoint.getId()));
    this.shadow.pop();
    this.shadow.endDraw();
    
    
    click = false;
  }
  
  void setNextInterestPoint(int p){
    this.interestPoint = this.getMapPoint(p);
    //println(p);
  }
  
  void updatePathToInterestPoint(int p){
    this.toInterestPoint = this.getMapPoint(p);
  }
  
  void setCurrentPoint(int p){
    this.currentPoint = this.getMapPoint(p); 
  }
  
  void updateCurrentPointConnections(IntList addresses){
    this.currentPoint.addToConnections(addresses);
  }
  
  // PARTICLE SYSTEM METHODS
  
  boolean particleIsNearStartPath(PVector p){
    if(sqrt(sq(p.x-this.startPath.x) + sq(p.y-this.startPath.y)) < TRANSITION_RANGE)
      return true;
     
    return false;
  }
  
  boolean particleIsNearEndPath(PVector p){
    if(sqrt(sq(p.x-this.endPath.x) + sq(p.y-this.endPath.y)) < RETURN_RANGE)
      return true;
     
    return false;
  } 
  
  void removePathParticle(MapPathParticle p){
    
    this.wanderingParticles.add(new RandomPathParticle(p.getID()));
    
    this.pathParticles.remove(p);
  }
  
  
}
