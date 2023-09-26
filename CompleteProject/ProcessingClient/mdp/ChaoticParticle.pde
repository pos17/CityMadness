
class ChaoticParticle{ // Particelle caotiche
  PVector p;
  
  ChaoticParticle(){
    this.p = new PVector(random(-width/2,width/2),random(-height/2,height/2)); 
  }
  ChaoticParticle(PVector p){
    this.p = p;
  }
  
  ChaoticParticle(float x, float y){
    this.p = new PVector(x,y);
  }
  
  PVector getPos(){
    return this.p; 
  }
  
  
  void moveNoise(){
    this.p.add((this.p.cross(PVector.fromAngle((noise(this.p.x/100, this.p.y/100, float(frameCount)/100)-0.5)*TWO_PI))).setMag(2));
  }

}
