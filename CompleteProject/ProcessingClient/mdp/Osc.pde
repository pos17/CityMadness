
void oscEvent(OscMessage msg) {

  click = true;
  //println("new OSC MESSAGE: ");
  //println(msg);

  if (msg.checkAddrPattern("/nextNodes")) {
    println("type: " + 0 );
    IntList addresses = oscPathParser(msg);
    map.setNextPoints(addresses);
    map.updateCurrentPointConnections(addresses);
    //println("Next Points Set");

    //println("Next addresses: " + addresses);
  } else if (msg.checkAddrPattern("/firstConections")) {
    
    music_phase = 3;
    println("type: " + 1 );
    IntList addresses = new IntList();
    int nodeID = msg.get(0).intValue();
    for (int i = 1; i<msg.arguments().length; i++) {
      addresses.append(msg.get(i).intValue());
    }
    println("STARTID: " + nodeID + ", conn: " + addresses);
    map.updatePointConnections(nodeID, addresses);
    map.setFirstConnectionsArrived(true);
  } else if (msg.checkAddrPattern("/interestPath")) {
    println("type: " + 2 );
    //[0] interest node, [1] path len, [...] path

    int interestPointId = msg.get(0).intValue();
    map.setNextInterestPoint(interestPointId);

    int len = msg.get(1).intValue();
    IntList addresses = new IntList();
    for (int i = 0; i<len; i++) {
      addresses.append(msg.get(i+2).intValue());
    }

    map.updatePathToInterestPoint(addresses);
  } else if (msg.checkAddrPattern("/mapDiscoveredPath")) {
    if(!explosionRunning) {
      println("explosionRunning");
      explosionRunning = true; 
      for (int i = 0; i < 10000; i++) {
        map.randomParticlesExp.add(new RandomPathParticle(map.currentPoint.getId()));
      }  
    }
    println("type: " + 3 );
    IntList addresses = new IntList();
    println("new message");
    println("MESSAGE ARGS: " + msg.arguments().length);
    for (int i = 0; i<msg.arguments().length; i++) {
      //println("msg: " +  msg.get(i));
      
      addresses.append(msg.get(i).intValue());

      map.explosionsPaths.add(map.getMapPoint(msg.get(i).intValue()).getCoords());
    }

    //map.explosionParser(addresses);
    map.explosions.add(addresses);
    //println("explosions");
    //println("addresses: " + addresses);
    //print("STARTID: "+ id + " addresses: " + addresses);
    // VERSIONE DI PARSING ALTERNATIVA NON USATA
    // PARSE EXPLOSIONS
    /*
    if (map.explosions.size()>0) {
      //println("explosions");
      IntList add = map.explosions.get(0);
      int id = add.get(0);
      add.remove(0);
      //print("STARTID: "+ id + " addresses: " + addresses);
      MapPoint m = map.getMapPoint(id);
      PVector f = m.getCoords();
      ArrayList<PVector> t = new ArrayList<PVector>();
      //m.addToConnections(add);
      map.updatePointConnections(m.id, addresses);
      for (int i = 1; i<add.size(); i++) {
        t.add(map.getMapPoint(add.get(i)).getCoords());
      }
      

      //map.mapFragments.add(new MapFragment(f, t, id, cityGraphics));
    }
    */
    explosions = true; // IL PARSER EFFETTIVO STA IN MAP RIGA 395 CIRCA
  } else if (msg.checkAddrPattern("/chaoticParticleAlpha")) {
    println("type: " + 4 );
    MAPPARTICLEALPHA = msg.get(0).intValue();

    if (MAPPARTICLEALPHA <=0) {
      showChaoticParticles = false;
      map.chaoticParticles.clear();
    }
  } else if (msg.checkAddrPattern("/pathToInterestPath")) {
    showPathToInterestPoint = msg.get(0).booleanValue();
  } else {
    println("something else");
    println(msg);
  }
}

void mousePressed() {
  if(loaded) {
    
    // UPDATE THE NUMBER OF TIMES THE USER HAS CLICKED
    if (!map.isMoving()) {
      time++;
      if (time == 0 ) {
        music_phase = 1; 
        map.chaoticParticlesMove = true;
      } else {
    
        timeFromClick = 0;
        map.setChaoticParticlesState(1);
        int id = map.getClosestPointId(mouseX-HALF_WIDTH, mouseY-HALF_HEIGHT);
        if (!startup) {
          OscMessage myMessage = new OscMessage("/currentNode");
          myMessage.add(id);
          oscP5.send(myMessage, myRemoteLocation);
        } else {
          // primo click
          music_phase = 2;
          OscMessage myMessage = new OscMessage("/currentNodeFirst");
          myMessage.add(id);
          oscP5.send(myMessage, myRemoteLocation);
          OscMessage myMessage2 = new OscMessage("/currentNode");
          myMessage2.add(id);
          oscP5.send(myMessage2, myRemoteLocation);
        }
        //after this call !startup
        map.updatePath(id);
        map.setCurrentPoint(id);
      }
    }
  }
}

void keyPressed() {

  if (key == LEFT) {
    if (explosionPaths)
      explosionPaths = false;
    else
      showInterestPoint = true;
  } else if (keyCode == UP) {
    if (showPathToInterestPoint)
      showPathToInterestPoint = false;
    else
      showPathToInterestPoint = true;
  } else if (keyCode == RIGHT) {
    if (showUser)
      showUser = false;
    else
      showUser = true;
  } else if (keyCode == DOWN) {
    if (showInterestPoint)
      showInterestPoint = false;
    else
      showInterestPoint = true;
  } else if (keyCode == 65) {
    OscMessage myMessage = new OscMessage("/currentNode");
    myMessage.add(55);
    oscP5.send(myMessage, myRemoteLocation);
  } else if(key == 'r' || key == 'R') {
    reset();
  }
}

IntList oscPathParser(OscMessage msg) {
  // First element is the length, all other elements are the IDs
  int len = msg.get(0).intValue();
  IntList addresses = new IntList();
  for (int i = 0; i<len; i++) {
    addresses.append(msg.get(i+1).intValue());
  }

  return addresses;
}
// 60 - 16000
void controlFilter(int freq) {
  OscMessage myMessage = new OscMessage("/fcVal");
  myMessage.add(freq);
  oscP5.send(myMessage, myRemoteLocation);
}

// 0.0 - 1.0
void controlMusicVol(float val) {
  OscMessage myMessage = new OscMessage("/musicVol");
  myMessage.add(val);
  oscP5.send(myMessage, myRemoteLocation);
}

// 0.0 - 0.8
void controlGrainAgit(float valAgit) {
  OscMessage myMessage = new OscMessage("/synthAgit");
  myMessage.add(valAgit);
  oscP5.send(myMessage, myRemoteLocation);
}
// 0.0 - 1.0
void controlscVol(float val) {
  OscMessage myMessage = new OscMessage("/scVol");
  myMessage.add(val);
  oscP5.send(myMessage, myRemoteLocation);
}
// 0.0 - 1.0
void controlGrainVol(float val) {
  OscMessage myMessage = new OscMessage("/grainVol");
  myMessage.add(val);
  oscP5.send(myMessage, myRemoteLocation);
}

void sendReset() {
  OscMessage myMessage = new OscMessage("/reset");
  oscP5.send(myMessage, myRemoteLocation);
}
