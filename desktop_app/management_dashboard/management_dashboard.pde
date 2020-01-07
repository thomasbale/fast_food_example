import mqtt.*;
import controlP5.*;

ControlP5 cp5;
MQTTClient client;

public class Metric {
  public String name;
  public float value;
  // The Constructor
  Metric(String _name, float _value) { 
    name = _name;
    value = _value;
  }  
}

Metric total_income = new Metric("Total Income", 0.0);
Metric average_income = new Metric("Average Income", 0.0);
Metric total_open = new Metric("Open Orders", 0.0);
Metric total_cancelled = new Metric("Cancelled Orders", 0.0);
Metric total_inprogress = new Metric("Accepted Orders", 0.0);
Metric total_intransit = new Metric("Orders in Transit", 0.0);
Metric total_delivered = new Metric("Orders Delivered", 0.0);
Metric average_wait = new Metric("Average Wait", 0.0);

Metric[] metrics_drawn = { total_income, average_income, total_open, total_cancelled, total_inprogress, total_intransit, total_delivered, average_wait };
File dir; 
File [] files;
int max_orders = 100;
int is_expanded = 0;
ListBox l;

JSONObject json;
JSONObject[] orders = new JSONObject[max_orders];
JSONObject[] all_open_orders = new JSONObject[max_orders];
JSONObject[] all_processing_orders = new JSONObject[max_orders];
JSONObject[] all_intransit_orders = new JSONObject[max_orders];
JSONObject[] all_delivered_orders = new JSONObject[max_orders];
JSONObject[] all_cancelled_orders = new JSONObject[max_orders];

Chart overview;
DropdownList open_orders, processing_orders, in_transit_orders, delivered_orders ;

void setup() {
  cp5 = new ControlP5(this);
  size(900, 700);
  client = new MQTTClient(this);
  client.connect("mqtt://try:try@broker.hivemq.com", "processing");
  delay(500);
  buildView();
  updateMetricsfromOrders();
}

void draw() {
  background(0);
 if(cp5.isMouseOver( overview )) {
    String set = "Status Overview";
    int s = overview.getDataSet( set ).size();
    int n = int( constrain( map( overview.getPointer().x() , 0 , overview.getWidth() , 0 , s ) , 0 , s ) ) ;
    float value =  overview.getData( set , n ).getValue();
    println(String.format( "value for dataset %s : item %d = %.2f", set , n , value ) );
  }}
  
void controlEvent(ControlEvent theEvent) {
  
  println(theEvent.getController().getName());
 
 if(theEvent.getController().getName() == "delivered_orders"){
  ExpandOrder(theEvent.getController().getValueLabel().getText());
 }
 
 if(theEvent.getController().getName() == "open_orders"){
  ExpandOrder(theEvent.getController().getValueLabel().getText());
 }
 
 if(theEvent.getController().getName() == "processing_orders"){
  ExpandOrder(theEvent.getController().getValueLabel().getText());

 }
 
 if(theEvent.getController().getName() == "intransit_orders"){
  ExpandOrder(theEvent.getController().getValueLabel().getText());
 }
}

// update metrics from the saved orders
void updateMetricsfromOrders() {
  // load data from filestore
  loadData();
  int total_orders = 0;
  // loop through all the in-memory orders
  for (JSONObject order: orders){
  // main update function
  if (order != null){
    total_orders = total_orders + 1;
    // allocate the orders based on status
    switch(order.getString("order_status")) {
    case "open": 
    all_open_orders = (JSONObject[])append(all_open_orders,order);
    break;
    case "in_progress": 
    all_processing_orders = (JSONObject[])append(all_processing_orders,order);
    break;
    case "in_transit": 
    all_intransit_orders = (JSONObject[])append(all_intransit_orders,order);
    break;
    case "delivered": 
    all_delivered_orders = (JSONObject[])append(all_delivered_orders,order);
    break;
    case "closed": 
    all_cancelled_orders = (JSONObject[])append(all_cancelled_orders,order);
    break;
    case "cancelled": 
    all_cancelled_orders = (JSONObject[])append(all_cancelled_orders,order);
    break;
    default:
    println("No order status found!");   // Does not execute
    break;
}
    total_income.value = total_income.value + order.getFloat("order_total");
    average_income.value = total_income.value / total_orders;
    total_open.value = totalOrderValue(all_open_orders);
    total_cancelled.value = totalOrderValue(all_cancelled_orders);
    total_inprogress.value = totalOrderValue(all_processing_orders);
    total_intransit.value = totalOrderValue(all_intransit_orders);
    total_delivered.value = totalOrderValue(all_delivered_orders);
    average_wait.value = 1.0;
    }  
  }
  updateDashboard();
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
 }*/
 return;
}

void clearObjects(JSONObject[] array){
 for (int i = 0; i <= array.length - 1; i++) {
   array[i] = null;
  }
}

int countOrders(JSONObject[] array){
  int no_orders = 0;
   for (int i = 0; i <= array.length - 1; i++) {
   if (array[i] != null){
      no_orders = no_orders + 1;
   }
  }
  return no_orders;
}

void loadData() {
  dir= new File(dataPath(""));
  files= dir.listFiles();
  
  // clear existing orders
  clearObjects(orders);  
  clearObjects(all_open_orders);
  clearObjects(all_processing_orders);
  clearObjects(all_intransit_orders);
  clearObjects(all_delivered_orders);
  clearObjects(all_cancelled_orders);
  
  for (int i = 0; i <= files.length - 1 && i <= max_orders; i++)
   {
    String path = files[i].getAbsolutePath();
    if (path.toLowerCase().endsWith(".json"))
    {
      json = loadJSONObject(path);
      if (json != null){
      orders[i] = json;}  
    }
  }
}

float totalOrderValue(JSONObject[] orders) {
  float total_value = 0.0;
  for (JSONObject order : orders) {
    if (order!= null){
      total_value = order.getFloat("order_total") + total_value;
    }   
  }
  return total_value;
}

void ExpandOrder(String orderid)  {
  JSONObject requestedOrder = null;
  JSONObject delivery = null;
  JSONObject restaurant = null;

  if(is_expanded == 1){
    cp5.get("Expanded order").remove();
    is_expanded = 0;
  }
  // look for the order to expand
  for (JSONObject order : orders) {
    if (order!= null){
      if(order.getString("order_id") == orderid){
        requestedOrder = order;
        delivery = requestedOrder.getJSONObject("delivery");
        restaurant = requestedOrder.getJSONObject("restaurant");
        break;
      }
    }   
  }
  // If the order can't  be found return
  if (requestedOrder != null)  {
    is_expanded = 1;
    l = cp5.addListBox("Expanded order")
         .setPosition(300, 430)
         .setSize(550, 320)
         .setItemHeight(15)
         .setBarHeight(15)
         .setColorBackground(color(255, 128))
         .setColorActive(color(0))
         .setColorForeground(color(255, 100,0)); 
         
    l.addItem(requestedOrder.getString("order_id"),0);
    l.addItem(requestedOrder.getString("order_status"),1);
    l.addItem(requestedOrder.getString("order_items"),2);
    l.addItem(requestedOrder.getString("order_total"),3);
    l.addItem(requestedOrder.getString("order_placed"),4);
    l.addItem(delivery.getString("delivery_name"),5);
    l.addItem(delivery.getString("delivery_address"),6);  
  }
}

void buildView() {
  
  int spacing = 100;
  for (Metric metric : metrics_drawn) {
    cp5.addNumberbox(metric.name)
    .setValue(metric.value)
    .setPosition(70,spacing)
    .setSize(200,19);
    spacing = spacing + 40;
  }
  
  // Build the chart
  overview = cp5.addChart("Status Overview")
               .setPosition(70, spacing + 40)
               .setSize(200, 200)
               .setRange(0, 100)
               .setView(Chart.BAR) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
               ;

  overview.getColor().setBackground(color(255, 100));
  overview.addDataSet("Status Overview");
  overview.setColors("Status Overview", color(255), color(0, 255, 0));
  overview.updateData("Status Overview", 0, 0, 0, 0);
  
  // Orders view create a List
  open_orders = cp5.addDropdownList("open_orders")
          .setPosition(300, 100)
          .setSize(100,100);
  processing_orders = cp5.addDropdownList("processing_orders")
          .setPosition(450, 100)
          .setSize(100,100);
  
  in_transit_orders = cp5.addDropdownList("intransit_orders")
          .setPosition(600, 100)
          .setSize(100,100);
  
  delivered_orders = cp5.addDropdownList("delivered_orders")
          .setPosition(750, 100)
          .setSize(100,100);
  
  customize(open_orders); 
  customize(processing_orders); 
  customize(in_transit_orders); 
  customize(delivered_orders); 
  
}
 
void clientConnected() {
  println("client connected to broker");
  client.subscribe("food_orders");
}

// Save everything to file that is recieved on the MQTT channel
void messageReceived(String topic, byte[] payload) {
  JSONObject json = parseJSONObject(new String(payload));
  if (json == null) {
    println("Order could not be parsed");
  } else {
    saveOrder(json);
  }
  // when a new message is recieved call the main update loop
  updateMetricsfromOrders();
}

// Save order to local file store as individual JSON file
void saveOrder(JSONObject order)  {
  if (order == null){
  return;
  } else {
  saveJSONObject(order, "data/" + order.getString("order_id") + ".json");
  }
}

void connectionLost() {
  println("connection lost");
}

void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(40);
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}
