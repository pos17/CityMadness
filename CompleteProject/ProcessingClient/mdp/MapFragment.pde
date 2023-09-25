
class MapFragment{
  PImage img;
  int id;
  int t;
  PImage fragment;
  PGraphics mask;
  
  PVector from;
  ArrayList<PVector> to;
  
  
  /*
  MapFragment(PImage img, int id){
    this.img = img;
    this.t = 0;
    this.id = id;
  }
  */
  
  MapFragment(PVector from, ArrayList<PVector> to, int id, PImage img){
     this.from = from;
     this.to = to;
     this.id = id;
     this.img = img;
     this.t = 0;
     this.mask = createGraphics(width, height, P2D);
  }
  
  PImage show(){
    return this.fragment;
  }
  
  
  void update(){
    if(this.t<30){
      this.fragment = this.img;
      mask.beginDraw();
      mask.clear();
      mask.push();
      mask.translate(HALF_WIDTH, HALF_HEIGHT);
      mask.stroke(255,5);
      mask.strokeJoin(ROUND);
      for(int i = 0; i<to.size(); i++){
        PVector l = PVector.lerp(this.from, to.get(i), float(this.t)/30);
        
        for(int j = 0; j<30; j++){
          float fade = sq(sq(float(j)/30));
          mask.strokeWeight(map(fade,0,1,2,20));
          mask.line(l.x,l.y,from.x,from.y);
        }  
      }
      mask.pop();
      mask.endDraw();
      
      
      this.fragment.mask(mask);
      
    }

    this.t++;

  }
  
  int getT(){
    return this.t; 
  }
  
  float getAlpha(){
    //if(this.t<20)
      //return map(this.t,0,20,0,255);
    
    return 255;
  }
  
  int getId(){
    return this.id; 
  }
}


class Fragment{
  ArrayList<PVector> to;
  PVector from;
  int id;
  int t;
  boolean young;
  
  Fragment(PVector f, ArrayList<PVector> t, int id){
    this.to = t;
    this.from = f;
    this.id = id;
    this.t = 0;
    this.young = true;
  }
  
  
}
