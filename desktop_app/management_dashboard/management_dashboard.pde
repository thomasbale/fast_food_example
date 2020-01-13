import mqtt.*;
import controlP5.*;

ControlP5 cp5;
MQTTClient client;

Dashboard_view view;
OrderData data = new OrderData();
Database db = new Database();

void setup() {
  cp5 = new ControlP5(this);
  
  size(900, 700);
  client = new MQTTClient(this);
  client.connect("mqtt://try:try@broker.hivemq.com", "processing_desktop");
  
  refreshData();
  updateDashboard();
  delay(500);
 
}

void draw() {
  background(0);
}
