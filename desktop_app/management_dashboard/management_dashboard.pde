import mqtt.*;

MQTTClient client;

void setup() {
  client = new MQTTClient(this);
  client.connect("mqtt://try:try@broker.hivemq.com", "processing");
}

void draw() {}

void keyPressed() {
  client.publish("/hello", "world");
}

void clientConnected() {
  println("client connected");

  client.subscribe("food_orders");
}

void messageReceived(String topic, byte[] payload) {
  println("new message: " + topic + " - " + new String(payload));
}

void connectionLost() {
  println("connection lost");
}
