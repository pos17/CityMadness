void mouseReleased(){
  if(mouseX<width && mouseX > width-buttonw && mouseY > height-buttonw){
    goodMusic = false;
    println("BAD MUSIC");
    OscMessage msg = new OscMessage("/mode");
    msg.add(0);
    osc.send(msg, pureData);

  }
  else if(mouseX<width-buttonw && mouseX > width-2*buttonw && mouseY > height-buttonw){
    goodMusic = true;
    println("GOOD MUSIC");
    OscMessage msg = new OscMessage("/mode");
    msg.add(1);
    osc.send(msg, pureData);
  }
  else{
    int hasMusic;
    if(isMusicOn) hasMusic = 2;
    else hasMusic = 1;
    //println(hasMusic);
    myMap.createUserPath(mouseX,mouseY, width/5,height/2,hasMusic);
  }
}
