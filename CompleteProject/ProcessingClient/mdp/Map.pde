
class Map{
  ArrayList<MapPoint> mapPoints = new ArrayList<MapPoint>();
  MapPath path;
  ArrayList<MapPath> randPath;
  MapLine line;
  MapParticleSystem system;
  MapAttractor attractor;
  
  PVector startPath;
  PVector endPath;
  
  ArrayList<Particle> mapParticles = new ArrayList<Particle>();
  
  ArrayList<MapPoint> nextPoints = new ArrayList<MapPoint>();
  MapPoint toInterestPoint;
  MapPoint interestPoint;
  MapPoint currentPoint;
  
  boolean pathDone, systemCreated;
  
  PGraphics city, render;
  
  Map(){
    this.mapPoints = loadMapPoints();
    this.pathDone = false;
    this.systemCreated = false;
    this.renderMap();
    this.attractor = new MapAttractor(5);
    this.render = createGraphics(width, height, P2D);
    this.randPath = new ArrayList<MapPath>();
    this.path = new MapPath();
    this.line = new MapLine(this.path);
    for(int i = 0; i < NMAPPARTICLES; i++){
      mapParticles.add(new Particle()); 
    }
    
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
    
    //SHOW CHAOTIC PARTICLES
    this.render.stroke(255,MAPPARTICLEALPHA);
    this.render.strokeWeight(3);
    
    if(this.pathDone){ // BEHAVIOUR IF WE HAVE A PATH
      
      //Set first and last path point
      this.startPath = this.path.getStartPath();
      this.endPath = this.path.getEndPath();
      
      ListIterator<Particle> mapParticlesIter = this.mapParticles.listIterator();
      while(mapParticlesIter.hasNext()){
        Particle m = mapParticlesIter.next();
        //alpha = m.moveNoiseReturnAlpha(pathPos);
        m.moveNoise();
        PVector p = m.getPos();
        
        if(particleIsNearStartPath(p)){
          float[]f = p.array();
          system.addParticle(new Particle(f[0],f[1]));
          mapParticlesIter.remove();
        }
        else{
          render.point(p.x,p.y);
        }
      }
    }
    else{ // BEHAVIOUR IF WE DON'T HAVE A PATH
      ListIterator<Particle> mapParticlesIter = this.mapParticles.listIterator();
      while(mapParticlesIter.hasNext()){
        Particle m = mapParticlesIter.next();
        m.moveNoise();
        PVector p = m.getPos();
        render.point(p.x,p.y);
      }
    }
    
    
    path.show(); // TEMPORARY, WILL BE DELETED LATER
    if(systemCreated){      
      
      ArrayList<Particle> systemParticles = system.getSystem();
      this.render.stroke(13, 152, 186);
      this.render.strokeWeight(3);
      ListIterator<Particle> systemParticlesIter = systemParticles.listIterator();
      while(systemParticlesIter.hasNext()){
        PVector p = systemParticlesIter.next().getPos();
        
        if(particleIsNearEndPath(p)){
          float[]f = p.array();
          mapParticles.add(new Particle(f[0],f[1]));
          systemParticlesIter.remove();
        }
        else
          this.render.point(p.x, p.y);
      }
      system.moveParticles();
      
    }
    
    
    if(pathDone){
      /*
      for(int i = 0; i<randPath.size(); i++){
        randPath.get(i).show(); 
      }
      */
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
      this.render.strokeWeight(12);
      p = interestPoint.getCoords();
      this.render.point(p.x,p.y);
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
    
    //SHOW ATTRACTORS
    
    ArrayList<PVector> attractorPos = this.attractor.getPos();
    this.render.stroke(0,0,255);
    this.render.strokeWeight(2);
    ListIterator<PVector> attractorIter = attractorPos.listIterator();
    while(attractorIter.hasNext()){
      PVector p = attractorIter.next();
      this.render.point(p.x,p.y);
    }
    
    this.render.pop();
    this.render.endDraw();
    image(this.render,0,0);
    //image(this.city,0,0);
    
  }
  
  /*
  void addMusicPath(IntList addr){
    ArrayList<MapPoint> musicPoints = new ArrayList<MapPoint>();
    for(int i = 0; i<addr.size(); i++){
      musicPoints.add(this.getMapPoint(addr.get(i))); 
    }
    this.musicPath = new MapPath(musicPoints);
    this.pathDone = true;
    
    this.createParticleSystem();
  }
  
  void addShortPath(IntList addr){
    ArrayList<MapPoint> shortPoints = new ArrayList<MapPoint>();
    for(int i = 0; i<addr.size(); i++){
      shortPoints.add(this.getMapPoint(addr.get(i))); 
    }
    this.shortPath = new MapPath(shortPoints);
  }
  */
  
  void createLine(){
    this.line = new MapLine(this.path); 
  }
  
  void createParticleSystem(){
    //println("SYSTEM CREATED");
    this.system = new MapParticleSystem(this.path); 
  }
  
  MapPoint getMapPoint(int id){
    return this.mapPoints.get(id);
  }
  
  PVector getPointCoords(int id){
     return this.mapPoints.get(id).getCoords();
  }
  
  void addRandPath(IntList addr){
    ArrayList<MapPoint> randPoints = new ArrayList<MapPoint>();
    for(int i = 0; i<addr.size(); i++){
      randPoints.add(this.getMapPoint(addr.get(i))); 
    }
    this.randPath.add(new MapPath(randPoints));
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
    
    this.pathDone = true;
  }
  
  void updatePath(int id){
    this.path.updatePath(this.getMapPoint(id));
    
    if(systemCreated){
      this.system.generateAttractors(this.path);
      //println("UPDATE PATH");
      
      this.line.updatePath(this.path);
    }
    
    if(startup){
     // println("CREATING PARTICLE SYSTEM");
      this.createParticleSystem();
      this.systemCreated = true;
    }
    startup = false; //After second click we exit map startup
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
  
  void addChaoticParticle(Particle p){
    
  }
  
}
