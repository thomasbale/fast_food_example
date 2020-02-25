// Data focused on reading, writing and preparing data

// Example use of abstract class for typedef
static abstract class Status {
  static final String[] LIST = {
    Status.OPEN, 
    Status.CLOSED, 
    Status.PROCESSING, 
    Status.INTRANSIT, 
    Status.DELIVERED
  };
  static final String OPEN = "open";
  static final String CLOSED = "closed";
  static final String PROCESSING = "processing";
  static final String INTRANSIT = "intransit";
  static final String DELIVERED = "delivered";
}
// Example use of public class for metric as we use multiple (modular design)
public class Metric {
  public String name;
  public float value;
  // The Constructor
  Metric(String _name, float _value) {
    name = _name;
    value = _value;
  }
}
// Simulate SoC b/w API and Database
private class Database {
  int max_orders = 100;
  JSONObject[] orders = new JSONObject[max_orders];
  Database() {
  }
  int max_orders() {
    return max_orders;
  }
}

// copy any JSON objects on disk into working memory
void refreshData() {
  File dir;
  File[] files;
  dir = new File(dataPath(""));
  files = dir.listFiles();
  JSONObject json;
  if (files != null) {
    for (int i = 0; i <= files.length - 1; i++) {
      String path = files[i].getAbsolutePath();
      if (path.toLowerCase().endsWith(".json")) {
        json = loadJSONObject(path);
        if (json != null) {
          db.orders[i] = json;
        }
      }
    }
  }
}
// this is our API class to ensure separation of concerns. User -> API -> DB
public class OrderData {
  JSONObject[] getOrdersByStatus(String status) {
    JSONObject[] ret = new JSONObject[0];
    for (JSONObject order : db.orders) {
      if (order != null) {

        if (status.contains(order.getString("order_status"))) {
          ret = (JSONObject[]) append(ret, order);
        }
      }
    }
    return ret;
  }
  // API CALL 1
  JSONObject getOrderByID(String id) {
    JSONObject ret = new JSONObject();
    for (JSONObject order : db.orders) {
      if (order != null) {
        if (id.contains(order.getString("order_id"))) {
          ret = order;
        }
      }
    }
    return ret;
  }
  // API CALL 2
  void saveOrdertoDB(JSONObject order) {
    if (order == null) {
      return;
    } else {
      saveJSONObject(order, "data/" + order.getString("order_id") + ".json");
    }
  }
  // API CALL 3
  void updateOrderStatus(String id, String newstatus) {
    JSONObject[] ret = new JSONObject[db.max_orders()];

    JSONObject order = getOrderByID(id);
    // key, value
    order.setString("order_status", newstatus);
    client.publish("food_orders", order.toString());
  }
}
