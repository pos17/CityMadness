class Map {
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

  boolean pathDone, systemCreated, moving, firstConnectionsArrived, chaoticParticlesMove;

  PGraphics shadow;
  PGraphics trash;

  PGraphics city, render;

  PImage cityGraphics;
  ArrayList<MapFragment> mapFragments = new ArrayList<MapFragment>();


  ArrayList<IntList> explosions = new ArrayList<IntList>();
 

  Map() {
    this.mapPoints = loadMapPoints();
    this.pathDone = false;
    this.systemCreated = false;
    this.firstConnectionsArrived = false;
    this.chaoticParticlesMove = false;
    this.renderMap();
    this.render = createGraphics(width, height, P2D);
    this.shadow = createGraphics(width, height, P2D);
    this.trash = createGraphics(width, height, P2D);
    this.path = new MapPath();
    this.line = new MapLine(this.path);
    PVector chaosVel = new PVector(0, 0);
    PVector chaosAcc = new PVector(0, 0);
    
    for (int i = 0; i < NMAPPARTICLES; i++) {
      int rand = (int)random(preParticles.size());
      //println("rand: " +rand);
      chaoticParticles.add(new ChaoticParticle(preParticles.get(rand), chaosVel, chaosAcc));
      //preParticles.remove(rand);
    }
    println(chaoticParticles.size());
    this.cityGraphics = loadImage("map.png");
    this.cityGraphics.resize(width, height);
    this.startPath = new PVector();
    this.endPath = new PVector();

    this.trash.beginDraw();
    this.trash.circle(200, 200, 200);
    this.trash.endDraw();
    

    // HANDLING STARTUP VALUES FOR SUPERCOLLIDER

    controlMusicVol(0);
    controlscVol(1);
    controlGrainVol(1);
    controlGrainAgit(1);
    controlFilter(filterFreqValDEF);
  }

  void show() { // Tutti i render stanno qua in ordine
    timeFromClick++;

    this.render.beginDraw();
    //this.render.clear();

    this.render.noStroke();
    if (startup) {
      this.render.fill(0, 50);
    } else if (this.chaoticParticles.size() > 300) {
      this.render.fill(0, 80);
    } else {
      this.render.fill(0, 5);
    }
    this.render.rect(0, 0, width, height);
    //this.render.background(0);

    this.render.push();
    this.render.translate(HALF_WIDTH, HALF_HEIGHT);

    //SHOW CHAOTIC PARTICLES
    this.render.stroke(255, MAPPARTICLEALPHA);
    this.render.strokeWeight(3);
    if (firstConnectionsArrived && this.wanderingParticles.size() < 300 &&  this.chaoticParticles.size() < 300) {
      this.wanderingParticles.add(new RandomPathParticle(this.currentPoint.getId()));
    }

    if (music_phase == 1 ) {
      if (filterFreqVal< filterFreqValRANDOM) {
        filterFreqVal = ceil((float)filterFreqVal + 0.5);
        controlFilter(filterFreqVal);
      }
    } else if (music_phase == 2 ) {
      if (filterFreqVal> filterFreqValATT) {
        filterFreqVal = ceil((float)filterFreqVal - 0.5);
        controlFilter(filterFreqVal);
      }
    } else if (music_phase == 3) {
      if(filterFreqVal<=16000) {
        filterFreqVal += 0.5;
        controlFilter(filterFreqVal);
      }
      
      if (musicVol<0.1) {
        musicVol += 0.001;
        //controlMusicVol(musicVol);
      }
      if (scVol>=0.9) {
        scVol -= 0.001;
        controlscVol(scVol);
      }
      if (grainVol>0.0) {
        grainVol -= 0.001;
        controlGrainVol(grainVol);
      }
      
    }

    //ListIterator<ChaoticParticle> chaoticParticlesIter = this.chaoticParticles.listIterator();
    //while(chaoticParticlesIter.hasNext()){
    //  ChaoticParticle m = chaoticParticlesIter.next();
    //  m.moveNoise();
    //  PVector p = m.getPos();
    /*
          if(particleIsNearStartPath(p)){
     pathParticles.add(new MapPathParticle(this.pathParticlePosBuffer, endPathID));
     chaoticParticlesIter.remove();
     }
     else{
     */
    //render.point(p.x,p.y);
    //}
    //}
    //} else{ // BEHAVIOUR IF WE DON'T HAVE A PATH
    //ListIterator<ChaoticParticle> chaoticParticlesIter = this.chaoticParticles.listIterator();
    //while(chaoticParticlesIter.hasNext()){
    // ChaoticParticle m = chaoticParticlesIter.next();
    // m.moveNoise();
    // PVector p = m.getPos();
    // render.point(p.x,p.y);
    //}
    //}

    // CHAOTIIC PARTICLES GENERATION
    //FIRST CLICK NOT PERFORMED
    if (startup) {
      ListIterator<ChaoticParticle> chaoticParticlesIter = this.chaoticParticles.listIterator();
      while (chaoticParticlesIter.hasNext()) {
        ChaoticParticle m = chaoticParticlesIter.next();
        if (chaoticParticlesMove) {
          m.moveNoise();
        }
        PVector p = m.getPos();

        render.point(p.x, p.y);
      }
    } else {
      //println("not startup");
      PVector userPos = currentPoint.getCoords();
      ListIterator<ChaoticParticle> chaoticParticlesIter = this.chaoticParticles.listIterator();
      while (chaoticParticlesIter.hasNext()) {
        ChaoticParticle m = chaoticParticlesIter.next();
        PVector steeringForce = m.seek(userPos);
        if (m.getDist(userPos) >10) {
          m.applyForce(steeringForce);
          m.moveNoise();
          PVector p = m.getPos();
          render.point(p.x, p.y);
        } else {
          chaoticParticlesIter.remove();
        }
      }
    }

    // RENDER SHADOW
    this.render.image(this.shadow, -HALF_WIDTH, -HALF_HEIGHT);
    if (frameCount%2 == 0) {
      this.updateExplosions();
    }
    // RENDER MAP FRAGMENTS
    if (this.mapFragments.size()>0) {
      this.trash.beginDraw();
      //ListIterator<MapFragment> mapFragmentsIter = this.mapFragments.listIterator();
      for (int i = 0; i< mapFragments.size(); i++) {
        MapFragment f = mapFragments.get(i);
        float alpha = f.update();
        this.render.tint(255, alpha);
        //if(f.t>3){
        //this.render.image(f.show(),-HALF_WIDTH,-HALF_HEIGHT);
        // }
        //else{
        // println("WOW");
        // this.trash.image(f.show(),0,0); // FIX ORRIBILE, NON TOCCARE
        // }
      }
      this.trash.endDraw();
    }
    this.render.tint(255);

    // GENERA LE OMBRE
    /*
    if (click) {
      this.renderShadow();
    }
    */
    this.render.strokeWeight(3);
    //RENDER RANDOM PATH PARTICLES
    if (this.wanderingParticles.size()>0) {
      ListIterator<RandomPathParticle> wanderingParticlesIter = this.wanderingParticles.listIterator();
      this.render.stroke(50, 50, 255);
      while (wanderingParticlesIter.hasNext()) {
        RandomPathParticle m = wanderingParticlesIter.next();
        m.move();
        PVector p = m.getP();
        this.render.point(p.x, p.y);
      }
    }

    // GENERATION OF PATH PARTICLES
    if (this.pathDone ) {
      if (frameCount%2 == 0) {
        pathParticles.add(new MapPathParticle(this.pathParticlePosBuffer, endPathID));
      }
    }


    // RENDER PATH PARTICLES
    if (this.pathDone) {
      this.render.stroke(255, 200, 0);

      for (int i = 0; i<pathParticles.size(); i++) {
        MapPathParticle m = pathParticles.get(i);
        PVector p = m.getP();
        render.point(p.x, p.y);
        m.move();
      }
    }

    // PATH VERSO IL NODO D'INTERESSE
    if (!startup && showPathToInterestPoint) {
      ListIterator<PVector> toInterestPointIter = this.toInterestPoint.listIterator();
      this.render.strokeWeight(2);
      this.render.noFill();
      this.render.stroke(173, 216, 230, 30);
      this.render.beginShape();
      while (toInterestPointIter.hasNext()) {
        PVector p = toInterestPointIter.next();
        this.render.vertex(p.x, p.y);
      }
      this.render.endShape();
    }

    // SEGNAPOSTO UTENTE
    if (!startup && showUser) {
      /*
      if (timeFromClick > 60) {
        PVector p = currentPoint.getCoords();
        for (int j = 0; j<30; j++) {
          float fade = sq(sq(float(j)/30));
          this.render.stroke(lerpColor(color(255, 255, 0), color(255, 0, 0), float(j)/30), 40*sin(10*radians(timeFromClick)));
          this.render.strokeWeight(map(fade, 0, 1, 2, 30));
          this.render.point(p.x, p.y);
        }
      }
      */
        PVector pUser = currentPoint.getCoords();
        this.render.push();
        this.render.translate(pUser.x,pUser.y);
        this.render.tint(255, 30);
        this.render.image(sprite,-sprite.width/2,-sprite.height/2);
        this.render.tint(255, 255);
        //this.render.image(sprite,0,0);
        this.render.pop();
        // SEGNAPOSTO INTEREST POINT
      if (time>0 && showInterestPoint) {
        PVector p = interestPoint.getCoords();
        this.render.stroke(255, 255, 0, 2.0*sin(radians(constrain(timeFromClick, 0, 180))));

        for (int j = 0; j<50; j++) {
          float fade = float(j)/50;
          this.render.strokeWeight(map(fade, 0, 1, 1, 100));
          this.render.point(p.x, p.y);
        }
      }
    }


    this.render.pop();
    this.render.endDraw();
    image(this.render, 0, 0);

    // TEST: PATH GENERATI INTORNO AL'INTEREST POINT
    /*
    if (explosionPaths) {
     stroke(255, 0, 0);
     strokeWeight(5);
     for (int i = 0; i<explosionsPaths.size(); i++) {
     PVector p = explosionsPaths.get(i);
     point(p.x+HALF_WIDTH, p.y+HALF_HEIGHT);
     }
     }
     */
  }

  // INUTILIZZATO MA MEGLIO LASCIARLO
  void createLine() {
    this.line = new MapLine(this.path);
  }

  // OTTIENI MAPPOINT DA ID
  MapPoint getMapPoint(int id) {
    return this.mapPoints.get(id);
  }

  //OTTIENI COORDINATE DA ID
  PVector getPointCoords(int id) {
    return this.mapPoints.get(id).getCoords();
  }

  // IMPORTA GEOJSON
  ArrayList<MapPoint> loadMapPoints() {

    ArrayList<MapPoint> map = new ArrayList<MapPoint>();
    float x, y;
    int id;

    JSONObject mapJson;
    JSONArray features = new JSONArray();

    mapJson = loadJSONObject("graphCremonaLarge.json");
    features = mapJson.getJSONArray("features");

    // map.add(new MapPoint(0,0,0)); // Offset to get that Id of the MapPoint = index in the ArrayList
    for (int i = 0; i<features.size(); i++) {
      JSONObject obj = features.getJSONObject(i);
      JSONObject el = obj.getJSONObject("geometry");

      if (el.getString("type").equals("Point")) {

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

        map.add(new MapPoint(id, x, y));
      }
    }

    //The map is already sorted in theory but sort it at startup just to be sure
    Collections.sort(map, new MapPointSorter());

    return map;
  }

  // VECCHIO TEST, VISUALIZZA I NODI DELLA MAPPA
  void renderMap() {
    this.city = createGraphics(width, height, P2D);
    this.city.beginDraw();
    this.city.translate(HALF_WIDTH, HALF_HEIGHT);
    //this.city.background(0);
    this.city.stroke(255, 0, 0);
    this.city.noFill();
    this.city.strokeWeight(5);
    for (int i = 0; i<mapPoints.size(); i++) {
      PVector pos = mapPoints.get(i).getCoords();
      this.city.point(pos.x, pos.y);
    }
    this.city.endDraw();
  }

  // USATO PER RITORNARE IL NODO PIU' VICINO A DOVE HA CLICCATO L'UTENTE
  int getClosestPointId(float x, float y) {
    PVector p = new PVector(x, y);
    ArrayList<MapPoint> distSorted;
    // If an element has alredy been clicked only check in the next points
    if (startup) {
      distSorted = new ArrayList<MapPoint>(this.mapPoints);
    } else {
      distSorted = new ArrayList<MapPoint>(this.nextPoints);
    }
    distSorted.sort(new MapPointDistanceSorter(p));
    return distSorted.get(0).getId();
  }

  // PROSSIMI PUNTI ESPLORABILI
  void setNextPoints(IntList addr) {
    this.nextPoints.clear();
    for (int i = 0; i<addr.size(); i++) {
      this.nextPoints.add(this.getMapPoint(addr.get(i)));
    }
  }

  // REWARD INTEREST POINT

  // UPDATE DEL PATH (ULTIMI NODI ESPLORATI)
  void updatePath(int id) {
    if (!startup) {
      this.moving = true;
    }

    /*
    if(!startup) {
     ListIterator<ChaoticParticle> chaoticParticlesIter = this.chaoticParticles.listIterator();
     while(chaoticParticlesIter.hasNext()){
     ChaoticParticle m = chaoticParticlesIter.next();
     m.setState(true);
     }
     }
     */
    this.path.updatePath(this.getMapPoint(id));
    this.pathParticlePosBuffer = this.path.computeParticleBuffer();

    if (time>1) {

      this.line.updatePath(this.path);
      this.pathDone = true;
    }

    //Set first and last path point
    this.startPath = this.path.getStartPath();
    this.endPath = this.path.getEndPath();
    this.endPathID = this.path.getEndID();

    startup = false; //After second click we exit map startup
  }

  // GENERA LE OMBRE CHE NASCONDONO LE PARTICELLE

  void renderShadow() {
    for (int i = 0; i<mapFragments.size(); i++) {
      if (mapFragments.get(i).id == currentPoint.id) {
        return;
      }
    }
    PImage img = loadImage("map.png");
    img.resize(width, height);

    IntList addresses = this.currentPoint.getConnections();
    ArrayList<PVector> to = new ArrayList<PVector>();
    for (int i = 0; i<addresses.size(); i++) {
      to.add(this.getMapPoint(addresses.get(i)).getCoords());
    }
    mapFragments.add(new MapFragment(this.currentPoint.getCoords(), to, this.currentPoint.getId(), img));



    this.shadow.beginDraw();
    this.shadow.push();
    this.shadow.translate(HALF_WIDTH, HALF_HEIGHT);
    this.shadow.stroke(0, 5);
    this.shadow.noFill();
    this.shadow.strokeJoin(ROUND);


    PVector from = this.currentPoint.getCoords();

    for (int i = 0; i<to.size(); i++) {
      PVector t = to.get(i);
      for (int j = 0; j<10; j++) {
        this.shadow.strokeWeight(map(j, 0, 20, 5, 25));
        this.shadow.line(t.x, t.y, from.x, from.y);
      }
    }
    this.shadow.pop();
    this.shadow.endDraw();

    println("explosionsInUpdate");
    // PARSE EXPLOSIONS


    click = false;
  }

  void updateExplosions() {
    if (this.explosions.size()>0) {
      println("starting to update");
      IntList add = this.explosions.get(0);
      println("add: " + add);
      int id = add.get(0);
      add.remove(0);
      MapPoint m = this.getMapPoint(id);
      PVector f = m.getCoords();
      ArrayList<PVector> t = new ArrayList<PVector>();
      m.addToConnections(add);
      for (int i = 1; i<add.size(); i++) {
        t.add(this.getMapPoint(add.get(i)).getCoords());
      }

      this.mapFragments.add(new MapFragment(f, t, id, cityGraphics));
      this.explosions.remove(0);
    }
  }

  // VERSIONE DI CODICE ALTERNATIVA NON UTILIZZATA

  /*
  void renderShadow() {
   for (int i = 0; i<mapFragments.size(); i++) {
   if (mapFragments.get(i).id == currentPoint.id) {
   return;
   }
   }
   PImage img = loadImage("map.png");
   img.resize(width, height);
   
   IntList addresses = this.currentPoint.getConnections();
   ArrayList<PVector> to = new ArrayList<PVector>();
   for (int i = 0; i<addresses.size(); i++) {
   to.add(this.getMapPoint(addresses.get(i)).getCoords());
   }
   mapFragments.add(new MapFragment(this.currentPoint.getCoords(), to, this.currentPoint.getId(), img));
   
   
   
   this.shadow.beginDraw();
   this.shadow.push();
   this.shadow.translate(HALF_WIDTH, HALF_HEIGHT);
   this.shadow.stroke(0, 5);
   this.shadow.noFill();
   this.shadow.strokeJoin(ROUND);
   
   
   PVector from = this.currentPoint.getCoords();
   
   for (int i = 0; i<to.size(); i++) {
   PVector t = to.get(i);
   for (int j = 0; j<10; j++) {
   this.shadow.strokeWeight(map(j, 0, 20, 5, 25));
   this.shadow.line(t.x, t.y, from.x, from.y);
   }
   }
   this.shadow.pop();
   this.shadow.endDraw();
   
   click = false;
   }
   */


  void setNextInterestPoint(int p) {
    this.interestPoint = this.getMapPoint(p);
    //println(p);
  }

  // IMPORTA PATH VERSO NODO D'INTERESSE
  void updatePathToInterestPoint(IntList addresses) {
    this.toInterestPoint.clear();
    for (int i = 0; i<addresses.size(); i++) {
      this.toInterestPoint.add(this.getMapPoint(addresses.get(i)).getCoords());
    }
  }

  // SET NODO CORRENTE SCELTO DALL'UTENTE
  void setCurrentPoint(int p) {
    this.currentPoint = this.getMapPoint(p);
  }

  // UPDATE DELLE CONNESSIONI DEL NODO CORRENTE
  void updateCurrentPointConnections(IntList addresses) {
    this.currentPoint.addToConnections(addresses);
  }

  void updatePointConnections(int nodeID, IntList addresses) {
    this.getMapPoint(nodeID).addToConnections(addresses);
  }

  // PARTICLE SYSTEM METHODS

  void removePathParticle(MapPathParticle p) {
    this.wanderingParticles.add(new RandomPathParticle(p.getID()));
    this.pathParticles.remove(p);

    this.moving = false;
  }

  // UPDATE DEL PATH DELLE PATH PARTICLES PER NON FARLE FERMARE PRESTO
  void updatePathParticles(ArrayList<PVector> buffer, int id) {
    ListIterator<MapPathParticle> iter = this.pathParticles.listIterator();
    while (iter.hasNext()) {
      MapPathParticle p = iter.next();
      p.addToPath(buffer, id);
    }
  }

  // C'E' STATO UN CLICK E NON SIAMO ANCORA ARRIVATI AL PROSSIMO NODO
  boolean isMoving() {
    return this.moving;
  }

  void setChaoticParticlesState() {
    ListIterator<ChaoticParticle> chaoticParticlesIter = this.chaoticParticles.listIterator();
    while (chaoticParticlesIter.hasNext()) {
      ChaoticParticle m = chaoticParticlesIter.next();
      m.setState(true);
    }
  }

  void setFirstConnectionsArrived(boolean afcA) {
    this.firstConnectionsArrived = afcA;
  }

  boolean getFirstConnectionsArrived() {
    return this.firstConnectionsArrived;
  }
}
