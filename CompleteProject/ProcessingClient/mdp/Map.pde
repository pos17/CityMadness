
class Map{
  ArrayList<MapPoint> mapPoints = new ArrayList<MapPoint>();
  MapPath path;
  MapLine line;
  
  PVector startPath;
  PVector endPath;
  int endPathID;
  
  ArrayList<PVector> explosionsPaths = new ArrayList<PVector>();
  
  ArrayList<ChaoticParticle> chaoticParticles = new ArrayList<ChaoticParticle>();
  ArrayList<MapPathParticle> pathParticles = new ArrayList<MapPathParticle>();
  ArrayList<RandomPathParticle> wanderingParticles = new ArrayList<RandomPathParticle>();
  
  ArrayList<PVector> pathParticlePosBuffer = new ArrayList<PVector>();
  
  ArrayList<MapPoint> nextPoints = new ArrayList<MapPoint>();
  ArrayList<PVector> toInterestPoint = new ArrayList<PVector>();
  MapPoint interestPoint;
  MapPoint currentPoint;  
  
  boolean pathDone, systemCreated, moving;
  
  PGraphics shadow;
  PGraphics trash;
  
  PGraphics city, render;
  
  PImage cityGraphics;
  ArrayList<MapFragment> mapFragments = new ArrayList<MapFragment>();
  
  
  ArrayList<IntList> explosions = new ArrayList<IntList>();
  
  Map(){
    this.mapPoints = loadMapPoints();
    this.pathDone = false;
    this.systemCreated = false;
    this.renderMap();
    this.render = createGraphics(width, height, P2D);
    this.shadow = createGraphics(width, height, P2D);
    this.trash = createGraphics(width, height, P2D);
    this.path = new MapPath();
    this.line = new MapLine(this.path);
    for(int i = 0; i < NMAPPARTICLES; i++){
      chaoticParticles.add(new ChaoticParticle()); 
    }
    this.cityGraphics = loadImage("map.png");
    this.cityGraphics.resize(width,height);
    this.startPath = new PVector();
    this.endPath = new PVector();
        
    this.trash.beginDraw();
    this.trash.circle(200,200,200);
    this.trash.endDraw();
    
  }
  
  void show(){
    timeFromClick++;
    this.render.beginDraw();
    //this.render.clear();
    
    this.render.noStroke();
    this.render.fill(0,50);
    this.render.rect(0,0,width,height);
    //this.render.background(0);
    
    this.render.push();
    this.render.translate(HALF_WIDTH,HALF_HEIGHT);
    
    //SHOW CHAOTIC PARTICLES
    this.render.stroke(255,MAPPARTICLEALPHA);
    this.render.strokeWeight(3);
    
    
    if(this.pathDone){ // BEHAVIOUR IF WE HAVE A PATH
      
      if(frameCount%2 == 0){
        pathParticles.add(new MapPathParticle(this.pathParticlePosBuffer, endPathID));
        chaoticParticles.remove(0);
      }
      
      ListIterator<ChaoticParticle> chaoticParticlesIter = this.chaoticParticles.listIterator();
      while(chaoticParticlesIter.hasNext()){
        ChaoticParticle m = chaoticParticlesIter.next();
        m.moveNoise();
        PVector p = m.getPos();
        /*
        if(particleIsNearStartPath(p)){
          pathParticles.add(new MapPathParticle(this.pathParticlePosBuffer, endPathID));
          chaoticParticlesIter.remove();
        }
        else{
          */
          render.point(p.x,p.y);
        //}
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
   
   this.render.image(this.shadow,-HALF_WIDTH,-HALF_HEIGHT);
   
    if(this.mapFragments.size()>0 && !creatingExplosions){
      this.trash.beginDraw();
      //ListIterator<MapFragment> mapFragmentsIter = this.mapFragments.listIterator();
      for(int i = 0; i< mapFragments.size(); i++){
        MapFragment f = mapFragments.get(i);
        f.update();
        if(f.t>1){
          this.render.image(f.show(),-HALF_WIDTH,-HALF_HEIGHT); 
        }
        else
          this.trash.image(f.show(),0,0); // FIX ORRIBILE, NON TOCCARE
      }
      this.trash.endDraw();
    }
    
    
    if(click){
       this.renderShadow();
    }
   
    this.render.strokeWeight(3);
    //RENDER RANDOM PATH PARTICLES
    if(this.wanderingParticles.size()>0){
      ListIterator<RandomPathParticle> wanderingParticlesIter = this.wanderingParticles.listIterator();
      this.render.stroke(50,50,255);
      while(wanderingParticlesIter.hasNext()){
        RandomPathParticle m = wanderingParticlesIter.next();
        m.move();
        PVector p = m.getP();
        this.render.point(p.x,p.y);
      }
    }
    
    // RENDER PATH PARTICLES
    if(this.pathDone){
      this.render.stroke(255,200,0);
      
      for(int i = 0; i<pathParticles.size(); i++){
        MapPathParticle m = pathParticles.get(i);
        PVector p = m.getP();
        render.point(p.x,p.y);
        m.move();
      }
    }
    
    if(!startup){
      ListIterator<PVector> toInterestPointIter = this.toInterestPoint.listIterator();
      this.render.strokeWeight(2);
      this.render.noFill();
      this.render.stroke(173,216,230, 30);
      this.render.beginShape();
      while(toInterestPointIter.hasNext()){
        PVector p = toInterestPointIter.next();
        this.render.vertex(p.x,p.y);
      }
      this.render.endShape();
    }
    
    
    if(!startup){
      if(timeFromClick > 60){
        PVector p = currentPoint.getCoords();
        for(int j = 0; j<30; j++){
            float fade = sq(sq(float(j)/30));
            this.render.stroke(lerpColor(color(255,255,0),color(255,0,0), float(j)/30), 40*sin(10*radians(timeFromClick)));
            this.render.strokeWeight(map(fade,0,1,2,30));
            this.render.point(p.x, p.y);
          }  
      }
      
      
      if(time>0){
        PVector p = interestPoint.getCoords();
        this.render.stroke(255,255,0, 2.0*sin(radians(constrain(timeFromClick,0,180))));

        for(int j = 0; j<50; j++){
            float fade = float(j)/50;
            this.render.strokeWeight(map(fade,0,1,1,100));
            this.render.point(p.x, p.y);
          }  
        
      }
    }
    
    
    this.render.pop();
    this.render.endDraw();
    image(this.render,0,0);
    
    stroke(255,0,0);
    strokeWeight(5);
    for(int i = 0; i<explosionsPaths.size(); i++){
      PVector p = explosionsPaths.get(i);
      point(p.x+HALF_WIDTH,p.y+HALF_HEIGHT);
    }
        
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
    
    mapJson = loadJSONObject("graphCremonaLarge.json");
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
        /*
        x = ((x - 10.012826061753287) * width) / (10.031731839461685 - 10.012826061753287) - HALF_WIDTH;
        y = ((y - 45.138503171087336)* height)/ (45.13185662179308 - 45.138503171087336) - HALF_HEIGHT;
        */
         // CREMONA LARGE
        float boundLBx = 9.989161251126518;
        float boundLBy = 45.12098025283069;
        float boundRTx = 10.066522275498357;
        float boundRTy = 45.15613689432058;
        x = ((x - boundLBx) * width) / (boundRTx - boundLBx) - HALF_WIDTH;
        y = ((y -  boundLBy)* height)/ ( boundRTy -  boundLBy) - HALF_HEIGHT;
        
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
    if(startup){
      distSorted = new ArrayList<MapPoint>(this.mapPoints);
    }
    else{
      distSorted = new ArrayList<MapPoint>(this.nextPoints);
    }
    distSorted.sort(new MapPointDistanceSorter(p));
    return distSorted.get(0).getId();
  }
  
  void setNextPoints(IntList addr){
    this.nextPoints.clear();
    for(int i = 0; i<addr.size(); i++){
      this.nextPoints.add(this.getMapPoint(addr.get(i))); 
    }
    
  }
  
  void setNextPointsExplode(IntList addr){
    for(int i = 0; i<addr.size(); i++){
      IntList t = new IntList();
      if(i == 0){
        t.append(addr.get(1));
      }
      else if(i == addr.size()-1){
        t.append(addr.get(addr.size()-2));
      }
      else{
        t.append(addr.get(i-1));
        t.append(addr.get(i+1));
      }
      MapPoint p = this.getMapPoint(addr.get(i));
      p.addToConnections(t);
    }
    
    this.explosions.add(addr);
    
    if(!creatingExplosions && this.explosions.size()>0){
      thread("updateExplosions"); 
    }
  }
  
  void updateExplosions(){
    
    println("WOW");
    creatingExplosions = true;
    for(int i = 0; i<explosions.size(); i++){
      IntList l = explosions.get(i);
      
      if(l.size() > 2){
        PVector from = this.getMapPoint(l.get(1)).getCoords();
        ArrayList<PVector> to = new ArrayList<PVector>();
        to.add(this.getMapPoint(l.get(0)).getCoords());
        to.add(this.getMapPoint(l.get(2)).getCoords());
        
        this.mapFragments.add(new MapFragment(from, to, l.get(1), this.cityGraphics));
        
        l.remove(0);
      }
      else{
        explosions.remove(i);
      }
    }
    
    delay(300);
    creatingExplosions = false;
  }
  
  void updatePath(int id){
    if(!startup){
      this.moving = true;
    }
    
    this.path.updatePath(this.getMapPoint(id));
    this.pathParticlePosBuffer = this.path.computeParticleBuffer();
    
    if(time>1){
      
      this.line.updatePath(this.path);
      this.pathDone = true;
    }
    
    //Set first and last path point
    this.startPath = this.path.getStartPath();
    this.endPath = this.path.getEndPath();
    this.endPathID = this.path.getEndID();
    
    startup = false; //After second click we exit map startup
  }
  
  void renderShadow(){
    for(int i = 0; i<mapFragments.size(); i++){
      if(mapFragments.get(i).id == currentPoint.id){
        return; 
      }
    }
    PImage img = loadImage("map.png");
    img.resize(width,height);
    
    IntList addresses = this.currentPoint.getConnections();
    ArrayList<PVector> to = new ArrayList<PVector>();
    for(int i = 0; i<addresses.size(); i++){
      to.add(this.getMapPoint(addresses.get(i)).getCoords());
    }
    mapFragments.add(new MapFragment(this.currentPoint.getCoords(), to, this.currentPoint.getId(), img));
    
    
    
    this.shadow.beginDraw();
    this.shadow.push();
    this.shadow.translate(HALF_WIDTH, HALF_HEIGHT);
    this.shadow.stroke(0,5);
    this.shadow.noFill();
    this.shadow.strokeJoin(ROUND);
    
  
    PVector from = this.currentPoint.getCoords();
    
    for(int i = 0; i<to.size();i++){
      PVector t = to.get(i);
      for(int j = 0; j<10; j++){
        this.shadow.strokeWeight(map(j,0,20,5,25));
        this.shadow.line(t.x,t.y,from.x,from.y);
      }
    }
    this.shadow.pop();
    this.shadow.endDraw();
    click = false;
  }
  
  void setNextInterestPoint(int p){
    this.interestPoint = this.getMapPoint(p);
    //println(p);
  }
  
  void updatePathToInterestPoint(IntList addresses){
    this.toInterestPoint.clear();
    for(int i = 0; i<addresses.size(); i++){
      this.toInterestPoint.add(this.getMapPoint(addresses.get(i)).getCoords());
    }
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
    
    this.moving = false;
  }
  
  
  void updatePathParticles(ArrayList<PVector> buffer, int id){
      ListIterator<MapPathParticle> iter = this.pathParticles.listIterator();
      while(iter.hasNext()){
        MapPathParticle p = iter.next();
        p.addToPath(buffer, id);
      }
  }

  boolean isMoving(){
    return this.moving; 
  }
}
