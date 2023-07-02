
class Particle{
  PVector p, v, a;
  
  Particle(){
    this.p = new PVector(random(width),random(height));
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
  
  void setA(PVector acc){
    this.a = acc; 
  }
}
