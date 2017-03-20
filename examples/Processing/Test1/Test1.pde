import oscP5.*;
import netP5.*;
import java.lang.System.*;

OscP5  oscP5;
int    myPort = 11697;

float  x1, y1;

void setup() {
  size(200,200);
  frameRate(30);
  
  x1 = 0;
  y1 = 0;
  
  oscP5 = new OscP5(this, myPort); // this followed by port number to listen for messages on
}

void draw() {
  background(0);
  fill(255.0, 0, 0);
  float xPos = x1 * (width / 2) + (width / 2);
  float yPos = y1 * (height / 2) + (height / 2);  
  ellipse(xPos, yPos, 40, 40);
}

void keyPressed() {
  OscMessage msg;
  if(key == 'h') {
    msg = new OscMessage("/handshake");
    msg.add("Test1");
    msg.add(myPort);
    oscP5.send(msg, "127.0.0.1", 12000);  // 12000 is the device server's ip default port
  }
}

void oscEvent(OscMessage msg) {
  msg.print();

  if(msg.checkAddrPattern("/X")) {
      x1 = msg.get(0).floatValue();
  }else if(msg.checkAddrPattern("/Y")) {
      y1 = msg.get(0).floatValue();
  }
}
