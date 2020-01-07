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

JSONObject json;
JSONObject[] orders = new JSONObject[max_orders];
Chart overview;
DropdownList open_orders, processing_orders, in_transit_orders, delivered_orders ;

void setup() {
  cp5 = new ControlP5(this);
  size(900, 700);
  client = new MQTTClient(this);
  client.connect("mqtt://try:try@broker.hivemq.com", "processing");
  delay(500);
  loadData();
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
 print("control event from : "+theEvent.getController().getName());
 println(", value : "+theEvent.getController().getValue());

}

// update metrics from the saved orders
void updateMetricsfromOrders() {
  int total_files = 0;
  // loop through all the in-memory orders
  for (JSONObject order: orders){
  // main update function
  if (order != null){
    total_files = total_files + 1;
    total_income.value = total_income.value + order.getFloat("order_total");
    average_income.value = total_income.value / total_files;
    total_open.value = 1.0;
    total_cancelled.value = 1.0;
    total_inprogress.value = 1.0;
    total_intransit.value = 1.0;
    total_delivered.value = 1.0;
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
  overview.updateData("Status Overview", 12, 0, 0, 0);
  // this updates the grid
  open_orders.addItem("test",1);
  processing_orders.addItem("test",1);
  in_transit_orders.addItem("test",1);
  delivered_orders.addItem("test",1);
}

void loadData() {
  dir= new File(dataPath(""));
  files= dir.listFiles();
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
  
  // Orders view create a DropdownList
  open_orders = cp5.addDropdownList("open_orders")
          .setPosition(300, 100)
          .setSize(100,100)
          ;
          
  processing_orders = cp5.addDropdownList("processing_orders")
          .setPosition(450, 100)
          .setSize(100,100)
          ;
  
  in_transit_orders = cp5.addDropdownList("intransit_orders")
          .setPosition(600, 100)
          .setSize(100,100)
          ;
  
  delivered_orders = cp5.addDropdownList("delivered_orders")
          .setPosition(750, 100)
          .setSize(100,100)
          ;
  
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
  
  for (int i=0;i<40;i++) {
    ddl.addItem("item "+i, i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}
