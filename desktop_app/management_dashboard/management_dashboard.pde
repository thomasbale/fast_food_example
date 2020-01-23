import mqtt.*;
import controlP5.*;

ControlP5 cp5;
MQTTClient client;
Dashboard_view view = new Dashboard_view();
OrderData api = new OrderData();
Database db = new Database();

void setup() {
  cp5 = new ControlP5(this);
  
  size(900, 700);
  // connect to the broker
  client = new MQTTClient(this);
  client.connect("mqtt://try:try@broker.hivemq.com", "processing_desktop" + str(random(3)));
  delay(100);
  // refresh the dashboard with the information
  

}

void draw() {
  background(0);
  updateDashboardData();
}
