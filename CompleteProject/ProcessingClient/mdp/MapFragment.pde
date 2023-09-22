
class MapFragment{
  PImage img;
  int t, id;
  
  MapFragment(PImage img, int id){
    this.img = img;
    this.t = 0;
    this.id = id;
  }
  
  void addTime(){
    this.t++; 
  }
  
  PImage show(){
    this.t++;
    return this.img;
  }
  
  float getAlpha(){
    if(this.t<20)
      return map(this.t,0,20,0,255);
    
    return 255;
  }
}
