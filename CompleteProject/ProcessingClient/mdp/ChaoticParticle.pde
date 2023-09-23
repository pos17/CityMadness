
class ChaoticParticle{
  PVector p, v, a, p1;
  
  ChaoticParticle(){
    this.p = new PVector(random(-width/2,width/2),random(-height/2,height/2));
    this.p1 = p;
    this.v = new PVector(0,0);
    this.a = new PVector(0,0);
    
  }
  ChaoticParticle(PVector p){
    this.p = p;
    this.v = new PVector(0,0);
    this.a = new PVector(0,0);
  }
  
  ChaoticParticle(float x, float y){
    this.p = new PVector(x,y);
    this.v = new PVector(0,0);
    this.a = new PVector(0,0);
  }
  
  PVector getPos(){
    return this.p; 
  }
  
  
  void move(){
    (this.v.add(this.a)).setMag(1);
    this.p.add(this.v);
    
  }
  
  void moveNoise(){
    this.p.add((this.p.cross(PVector.fromAngle((noise(this.p.x/100, this.p.y/100, float(frameCount+1)/100)-0.5)*TWO_PI))).setMag(2));
  }
  
  void setA(PVector acc){
    this.a = acc; 
  }
  
  void setV(PVector v){
    this.v = v; 
  }
  
}
