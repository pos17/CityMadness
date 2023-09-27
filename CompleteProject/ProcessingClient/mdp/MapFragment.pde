
class MapFragment{ // SFONDO MAPPA
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
     
     this.fragment = this.img;
     this.mask.beginDraw(); 
     this.mask.push();
     this.mask.translate(HALF_WIDTH, HALF_HEIGHT);
     this.mask.stroke(255,10);
     this.mask.noFill();
     this.mask.strokeJoin(ROUND);
     
     for(int i = 0; i<to.size();i++){
       PVector t = to.get(i);
       for(int j = 0; j<20; j++){
         float fade = sq(sq(float(j)/20));
         this.mask.strokeWeight(map(fade,0,1,5,15));
         this.mask.line(t.x,t.y,from.x,from.y);
       }
     }
     this.mask.pop();
     this.mask.endDraw();
      
     this.fragment.mask(mask);
     //this.fragment.save("AAA.png");
  }
  
  PImage show(){
    return this.fragment;
  }
  
  
  float update(){
    this.t++;
    if(this.t<30)
      return this.t*255/30;
    
    return 255;
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
