
class ChaoticParticle{ // Particelle caotiche
  PVector p;
  PVector velocity;
  PVector acc; 
  
  ChaoticParticle(PVector velocity, PVector acc){
    this.p = new PVector(random(-width/2,width/2),random(-height/2,height/2)); 
    this.velocity = velocity;
    this.acc = acc;
  }
  ChaoticParticle(PVector p,PVector velocity, PVector acc){
    this.p = p;
    this.velocity = velocity;
    this.acc = acc;
  }
  
  ChaoticParticle(float x, float y,PVector velocity, PVector acc){
    this.p = new PVector(x,y);
    this.velocity = velocity;
    this.acc = acc;
  }
  
  PVector getPos(){
    return this.p; 
  }
  
  PVector getVel() {
    return this.velocity;
  }
  PVector getAcc() {
    return this.acc;
  }
  
  void moveNoise(int state){
    if(state == 0)
      this.p.add((this.p.cross(PVector.fromAngle((noise(this.p.x/100, this.p.y/100, float(frameCount)/100)-0.5)*TWO_PI))).setMag(2));
    else if(state == 1) {
       this.p.add((this.p.cross(PVector.fromAngle((noise(this.p.x/100, this.p.y/100, float(frameCount)/100)-0.5)*TWO_PI))).setMag(1));
       this.velocity.add(acc); 
       this.p.add(velocity)
    }
  }

}
