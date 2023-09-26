class ObjGui {
  
    /** /////////////////
    *** PARAMETERS
    **/ /////////////////
    float posX, posY;
    String objName;
    ControlP5 cp5;
    Knob knob; // https://sojamo.de/libraries/controlP5/examples/controllers/ControlP5knob/ControlP5knob.pde
    Slider slider;
    int sliderWidth, sliderHeight;
    
    float knobRadius = 30;
    
    color colorForeground = color(241, 253, 252); // 6, 27, 68
    color colorBackground = color(6, 27, 68);
    color colorActive = color(249, 252, 198);
    
    float temporaryKnobVolume;
    
    
    /** /////////////////
    *** CONSTRUCTOR
    **/ /////////////////
    ObjGui(ControlP5 cp5, String objName, float posX, float posY){
        this.cp5 = cp5;
        this.objName = objName;
        this.posX = posX;
        this.posY = posY;
    }
    
    ObjGui(ControlP5 cp5, String objName, float posX, float posY, int sliderWidth, int sliderHeight){
        this.cp5 = cp5;
        this.objName = objName;
        this.posX = posX;
        this.posY = posY;
        this.sliderWidth = sliderWidth;
        this.sliderHeight = sliderHeight;
    }
    
    /** /////////////////
    *** BUILDERS
    **/ /////////////////
    
    // Build Knob
    void buildKnob() {
        knob = cp5.addKnob(objName)
               .setRange(0,100) // Range di valori
               .setValue(100)   // Default value
               .setPosition(posX, posY)  // Posizione 
               .setRadius(knobRadius)
               .setNumberOfTickMarks(10)   /// Quante tacche
               .setTickMarkLength(4)       // Lunghezza delle tacche
               .setTickMarkWeight(1.5)    // Quanto ciccione le tacche
               .setLabelVisible(false)
               .setColorForeground(colorForeground) // 184, 180, 45
               .setColorBackground(colorBackground)
               .setColorActive(colorActive) // 216,219,226
               .setDragDirection(Knob.VERTICAL)
               .setDecimalPrecision(0)
               ;
          // To complete
          knob.setVisible(true);
    }
        
    
    // Build Slider
    void buildSlider() {
         slider = cp5.addSlider(objName)
                  .setPosition(posX, posY)
                  .setSize(sliderWidth, sliderHeight)
                  .setValue(70)    // Volume iniziale di default
                  .setRange(0, 100)    // Range di volume
                  .setLabelVisible(false)
                  .setColorForeground(colorForeground) // 184, 180, 45
                  .setColorBackground(colorBackground)
                  .setColorActive(colorActive) // 216,219,226
                  .setDecimalPrecision(0)
                  .setNumberOfTickMarks(0)
                  ;
          // To complete: 
          slider.setVisible(true);
    }
    

    /** /////////////////
    *** GETTERS
    **/ /////////////////
    
    // getName
    String getName() { 
        return this.objName;
    }
    
    // getKnobValue
    float getKnobValue() {
        return knob.getValue();
    }
    
    // getPosX
    float getPosX(){
        return posX;
    }
    
    // getPosY
    float getPosY(){
        return posY;
    }
    
    // getSliderValue
    float getSliderValue() {
        return slider.getValue();
    }
    
    // getKnobRadius
    float getKnobRadius() {
        return knobRadius;
    }
    
    float getTemporaryKnobVolume(){
        return temporaryKnobVolume;
    }
    
    /** /////////////////
    *** SETTERS
    **/ /////////////////
    
    // setValue
    void setKnobValue(float val) {
        knob.setValue(val);
    }
    
    void setTemporaryKnobVolume(float tempVol){
        temporaryKnobVolume = tempVol;
    }
    
}
