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
    //data.saveOrdertoDB(json);
  }
}

void controlEvent(ControlEvent theEvent) {
  
  println(theEvent.getController().getValueLabel().getText());
   println(theEvent.getController().getName());
 
 if(theEvent.getController().getName() == Status.OPEN || theEvent.getController().getName() == Status.CLOSED || theEvent.getController().getName() == Status.INTRANSIT){
  
   
  view.build_expanded_order(theEvent.getController().getValueLabel().getText());
 }
 
 if(theEvent.getController().getName() == "open_orders"){
  //ExpandOrder(theEvent.getController().getValueLabel().getText());
 }
 
 if(theEvent.getController().getName() == "processing_orders"){
  //ExpandOrder(theEvent.getController().getValueLabel().getText());

 }
 
 if(theEvent.getController().getName() == "intransit_orders"){
  //ExpandOrder(theEvent.getController().getValueLabel().getText());
 }
}
/*
// Save everything to file that is recieved on the MQTT channel
void messageReceived(String topic, byte[] payload) {
  JSONObject json = parseJSONObject(new String(payload));
  if (json == null) {
    println("Order could not be parsed");
  } else {
    saveOrder(json);
  }
  // when a new message is recieved call the main update loop

}


// update screen
void updateDashboard()  {
  for (Metric _metric: metrics_drawn){
    cp5.getController(_metric.name).setValue(_metric.value);
  }
  // this updates the chart
  overview.updateData("Status Overview", countOrders(all_open_orders), countOrders(all_intransit_orders), countOrders(all_delivered_orders), countOrders(all_cancelled_orders));

  // Build the drop down lists
  addToarray(all_open_orders,open_orders);
  addToarray(all_processing_orders,processing_orders);
  addToarray(all_intransit_orders,in_transit_orders);
  addToarray(all_delivered_orders,delivered_orders);
}

// function to add item to dynamic list from order array
void addToarray(JSONObject[] orders, DropdownList list){
  int i = 0;
  list.clear();
/*
  for  (JSONObject order : orders){
    if (order != null){
       i = i+1;
       list.removeItem(order.getString("order_id"));
       list.addItem(order.getString("order_id"),i);

    }
 }
 return;
}*/
