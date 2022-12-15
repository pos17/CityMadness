void mouseReleased(){
  int hasMusic;
  if(isMusicOn) hasMusic = 2;
  else hasMusic = 1;
  myMap.createUserPath(isMusicOn, mouseX,mouseY, width/5,height/2,hasMusic);
}
