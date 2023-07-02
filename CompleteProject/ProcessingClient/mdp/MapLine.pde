
class MapLine{
  ArrayList<PVector> line;
  ArrayList<PVector> buffer;
  MapPath path;
  PVector current, next;
  int lineLength;
  //int numSegments;
  
  MapLine(MapPath path){
    line = new ArrayList<PVector>();
    buffer = new ArrayList<PVector>();
    this.path = path;
    lineLength = 200;
    //numSegments = 100;
    
    this.next = path.getNextPoint().getCoords();
    this.setNextPoint();
  }
  
  void appendCoordinate(PVector p){
    line.add(p);
    if(line.size() > lineLength){
      line.remove(0);
    }
  }
  
  void setNextPoint(){
    this.current = this.next;
    this.next = path.getNextPoint().getCoords();
    this.lerpCoordinates();
  }
  
  void lerpCoordinates(){
    int numSegments = floor(PVector.dist(this.current,this.next)/2);
    for(int i = 0; i<numSegments; i++){
       buffer.add((PVector.lerp(this.current, this.next, map(i,0,numSegments,0,1))));
    }
  }
  
  void show(){
    PVector p1, p2;
    
    float alpha = 0;
    strokeWeight(5);
    
    if(buffer.size() > 0){
      this.appendCoordinate(buffer.get(0));
      buffer.remove(0);
    }
    else{
       this.setNextPoint();
    }
    
    ListIterator<PVector> iter = line.listIterator();
    p1 = iter.next();
    while(iter.hasNext()){
       p2 = iter.next();
       
       alpha = map(iter.nextIndex(), 0, line.size(), 10, 255);
       stroke(255,alpha);
       line(p1.x, p1.y, p2.x, p2.y);
       //point(p2.x, p2.y);
       p1 = p2;
    }
  }
}
