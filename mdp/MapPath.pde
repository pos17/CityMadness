class MapPath{
  IntList path;
  boolean finished;
  int index;
  
  MapPath(){
    this.path = new IntList();
    this.finished = false;
    this.index = 0;
  }
  
  void append(int id){
     path.append(id);
  }
  
  void end(){
    this.finished = true; 
  }
  
  boolean hasEnd(){
    return finished; 
  }
  
  int getNextPoint(){
    if(finished){
      this.index++;
      if(index < path.size())
        return this.path.get(this.index);
      
      else
        throw new NullPointerException("No more path");
    }
    else
      throw new NullPointerException("not finished");
  }
}
