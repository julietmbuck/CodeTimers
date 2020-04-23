/*
  Timer
  by Juliet Buck

  Expects a string of comma-delimted Serial data from Arduino:
  ** field is 0 or 1 as a string (switch) — not used
  ** second fied is 0-4095 (potentiometer)
  ** third field is 0-4095 (LDR) — not used, we only check for 2 data fields  
  
 */
 
// Importing the serial library to communicate with the Arduino 
import processing.serial.*;    

// Initializing a vairable named 'myPort' for serial communication
Serial myPort;      

// Data coming in from the data fields
// data[0] = "1" or "0"                  -- BUTTON
// data[1] = 0-4095, e.g "2049"          -- POT VALUE
// data[2] = 0-4095, e.g. "1023"        -- LDR value
String [] data;

int switchValue = 0;
int potValue = 0;
int ldrValue = 0;

// Change to appropriate index in the serial list — YOURS MIGHT BE DIFFERENT
int serialIndex = 2;

//color array 
color [] colors = {#EC7B7B, #CD5C5C, #FF1493, #DB7093, #FFC0CB, #FFB6C1, #FE7F92, #FFB7C5, #FA6E79, #FFB8C6, #FFB6C1, #EC7B7B};
int currentColor = 0;

//timing for colors
Timer displayTimer;
Timer anotherTimer; 
float timePerColor = 0; 
float minTimePerColor = 100; 
float maxTimePerColor = 1000; 
int defaultTimerPerColor = 1500; 

// mapping pot values
float minPotValue = 0;
float maxPotValue = 4095;

PImage pug; 
PImage bone; 
PImage bowl; 

PImage treats; 
int treatsAmt = 10;
float treatsX; 
float treatsY; 

PFont displayFont; 


//initialize pug x & y 
int pugX = 10; 
int pugY = 700; 

void setup  () {
  size (1000,  600);    
  
  // List all the available serial ports
  printArray(Serial.list());
    
  // Set the com port and the baud rate according to the Arduino IDE
  //-- use your port name
  myPort  =  new Serial (this, "/dev/cu.SLAB_USBtoUART",  115200); 
  
  // Allocate the timer
  displayTimer = new Timer(defaultTimerPerColor);
  anotherTimer = new Timer(1000); 

  
  // start the timer. Every 1/2 second, it will do something
  displayTimer.start();
  anotherTimer.start(); 
  
  pug = loadImage("img/pug.png"); 
  bone = loadImage("img/bone.png"); 
  bowl = loadImage("img/bowl.png"); 
  
  
  textAlign(CENTER); 
  displayFont = createFont("Georgia", 32); 

} 

// We call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();  
    
    print(inBuffer);
    
    // This removes the end-of-line from the string 
    inBuffer = (trim(inBuffer));
    
    // This function will make an array of TWO items, 1st item = switch value, 2nd item = potValue
    data = split(inBuffer, ',');
   
   // we have THREE items — ERROR-CHECK HERE
   if( data.length >= 2 ) {
      switchValue = int(data[0]);           // first index = switch value 
      potValue = int(data[1]);               // second index = pot value
      ldrValue = int(data[2]);               // third index = LDR value
      
      // change the display timer
      timePerColor = map( potValue, minPotValue, maxPotValue, minTimePerColor, maxTimePerColor );
      displayTimer.setTimer( int(timePerColor));
   }
  }
} 

//-- change background to red if we have a button
void draw () {  
  
  checkSerial(); 
  drawBackground();
  checkTimer(); 
  setupTreats(); 
  drawTreats(); 
  drawPug(); 

  

  
}
void drawBackground() {
    background(colors[currentColor]);
    
      fill(255); 
      textSize(20); 
      text("Press 'P' for Treats", width/2, 80); 

}

void drawPug() {
  
image(pug, pugX, pugY);
pugY--; 

if (pugY == 300) {
  pugY++; 
}
}

void setupTreats() {
      treatsX = random(width);
      treatsY = random(height);
}

void drawTreats() {
  
  
  if (keyPressed) {
    if (key == 'p' || key == 'P') {
      
       image(treats, treatsX, treatsY); 
    }
  }
  
      treats = bone;
  
}






void checkTimer() {
  
 // check to see if timer is expired, do something and then restart timer
  if( displayTimer.expired() ) {
    currentColor++;
    
    if (currentColor == colors.length ) 
      currentColor = 0; 
    
    
    displayTimer.start();
  }
  
  if ( anotherTimer.expired() ) {
    

    treats = bowl; 
    
    anotherTimer.start();   
  }
  
}
