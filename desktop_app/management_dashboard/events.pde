// User interaction logic calling data (model) and views

void clientConnected() {
  println("client connected to broker");
  client.subscribe("food_orders");
}

void connectionLost() {
  println("connection lost");
}

void messageReceived(String topic, byte[] payload) {
  JSONObject json = parseJSONObject(new String(payload));
  if (json == null) {
    println("Order could not be parsed");
  } else {
    api.saveOrdertoDB(json);
    refreshData();
  }
  refreshDashboardData();
}

void controlEvent(ControlEvent theEvent) {
  
  
 if(theEvent.getController().getValueLabel().getText().contains("O") == true){
   // call the api and get the JSON packet
  view.build_expanded_order(api.getOrdersByStatus(theEvent.getController().getName())[(int)theEvent.getController().getValue()].getString("order_id"));
  
 }
 
}
