# fast_food_example
 Example implementation of MQTT integration of IoT, Web & Desktop application layers for Software Engineering Unit 2019/20.
 The communication protocol is MQTT using a public broker: http://www.hivemq.com/demos/websocket-client/
 The example uses 'food_orders' as a channel for publishing all data. The 'status' field determines the order stage in the customer journey.

## Customer: Web application / Customer portal

### Instructions
Open the HTML file in a web browser. Make sure the JS is in the same folder.

### Exercises
Can you improve the HTML to make the page look more interesting?
Can you display the orders in progress on the customer portal?
How would you impliment a login werby order are submitted by a specific client_id?

## Restaurant: Java Desktop application

### Instructions
Make sure you have necessary libraries imported as per comments in the Management Dashboard file.
Run the sketch and create an order using the web application.
Watch it appear!

### Exercises
Which tests would you perform to check the API calls?
Have a go at adding the tests to the run_tests file
How might you refactor the 'view' controller?

## Rider: IoT device

### Instructions
Open the sketches and get Wifi working on your stick/stack.
Connect to the 'foo_orders' to watch for publications.

### Exercises
Can you display all ready order to the rider?
