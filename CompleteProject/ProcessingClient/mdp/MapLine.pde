
class MapLine{
  ArrayList<PVector> line;
  
  MapPath buffer;
  int lineLength;
  int index;
  
  boolean exists;
  boolean pathHasChanged;
  
  MapLine(MapPath path){
    line = new ArrayList<PVector>();
    lineLength = 20;
    
    this.pathHasChanged = false;
    
    if(path.getPath().size()>1){
      this.buffer = path;
      this.createLine();
      this.exists = true; 
      this.pathHasChanged = true;
    }
  }
  
  void createLine(){
    ArrayList<MapPoint> p = this.buffer.getPath();
   
    this.line.clear();
    this.index = 0;
    
    for(int i = 0; i<p.size()-1; i++){
      PVector a = p.get(i).getCoords();
      PVector b = p.get(i+1).getCoords();
      
      int numSegments = floor(PVector.dist(a,b)/2);
      for(int j = 0; j<numSegments; j++){
       line.add((PVector.lerp(a, b, map(j,0,numSegments,0,1))));
      }
    }
  }
  
  void appendToLine(){
    ArrayList<MapPoint> p = this.buffer.getPath();
    
    PVector a = p.get(p.size()-2).getCoords();
    PVector b = p.get(p.size()-1).getCoords();
      
    int numSegments = floor(PVector.dist(a,b)/2);
    for(int j = 0; j<numSegments; j++){
     line.add((PVector.lerp(a, b, map(j,0,numSegments,0,1))));
    }
  }
 
  ArrayList<PVector> show(){
    ArrayList<PVector> showLine = new ArrayList<PVector>();
    
    if(this.index>line.size()){
       this.index = 0;
       if(this.pathHasChanged){
         this.createLine();
         this.pathHasChanged = false;
       }
    }
    
    for(int i = this.index>this.lineLength? this.index-this.lineLength : 0 ; i<this.index; i++){
      showLine.add(this.line.get(i));
    }
    this.index+=3;
    return showLine;
  }
  
  PVector getPos(){
   return(this.line.get(this.index<this.line.size()? this.index : 0)); 
  }
  
  boolean exists(){
     return this.exists;
  }
  
  void updatePath(MapPath m){
    if(m.getPath().size()>1){
      
      this.buffer = m; 
      if(this.exists){
        this.appendToLine();
      }
      this.exists = true;
      this.pathHasChanged = true;
      
      if(this.line.size() == 0){
        this.appendToLine();
        this.pathHasChanged = false;
      }
    }
    else
      return;
    
  }
}
