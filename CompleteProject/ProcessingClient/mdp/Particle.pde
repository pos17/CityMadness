
class Particle{
  PVector p, v, a;
  boolean near;
  
  Particle(){
    this.p = new PVector(random(-width/2,width/2),random(-height/2,height/2));
    this.v = new PVector(0,0);
    this.a = new PVector(0,0);
    this.near = false;
  }
  Particle(PVector p){
    this.p = p;
    this.v = new PVector(0,0);
    this.a = new PVector(0,0);
  }
  
  Particle(float x, float y){
    this.p = new PVector(x,y);
    this.v = new PVector(0,0);
    this.a = new PVector(0,0);
  }
  
  PVector getPos(){
    return this.p; 
  }
  
  float getX(){
    return this.p.x;
  }
  
  float getY(){
    return this.p.y; 
  }
  
  void move(){
    (this.v.add(this.a)).setMag(1);
    this.p.add(this.v);
    
  }
  
  float moveNoiseReturnAlpha(ArrayList<MapPoint> m){
    this.p.add((this.p.cross(PVector.fromAngle((noise(this.p.x/100, this.p.y/100, float(frameCount)/100)-0.5)*TWO_PI))).setMag(2));
    
    float alpha = 200;
    float alpha_temp;
    for(int i = 0; i<m.size(); i++){
      PVector mc = m.get(i).getCoords();
      alpha_temp = 0.7*sqrt(sq(this.p.x - mc.x)+sq(this.p.y - mc.y));
      
      if(alpha_temp<alpha){
        alpha = alpha_temp; 
      }
      
    }
    
    if(alpha<MAPPARTICLEALPHA){
        alpha/=MAPPARTICLEALPHA;
        return alpha < 0.7 ? 800 * alpha * alpha * alpha * alpha : MAPPARTICLEALPHA*(1 - pow(-2 * alpha + 2, 4) / 2);
      }
    
    return MAPPARTICLEALPHA;
  }
  
  void moveNoise(){
    this.p.add((this.p.cross(PVector.fromAngle((noise(this.p.x/100, this.p.y/100, float(frameCount)/100)-0.5)*TWO_PI))).setMag(2));
  }
  
  void setA(PVector acc){
    this.a = acc; 
  }
  
  void setV(PVector v){
    this.v = v; 
  }
  
  boolean isNear(){
    return this.near;
  }
}
