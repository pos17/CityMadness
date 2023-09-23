
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
      mask.stroke(255,20);
      mask.strokeJoin(ROUND);
      for(int i = 0; i<to.size(); i++){
        PVector l = PVector.lerp(this.from, to.get(i), float(this.t)/30);
        
        for(int j = 0; j<20; j++){
          float fade = sq(float(j)/20);
          mask.strokeWeight(map(fade,0,1,5,50));
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
