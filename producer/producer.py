import time

from confluent_kafka import Producer
import json
import random

# Configuration for Redpanda broker
config = {
    'bootstrap.servers': 'redpanda:9092',
}

# Create a producer instance with provided configuration
producer = Producer(config)


# Function to generate random string
def get_random_todo():
    todos = [
        "Clean the kitchen",
        "Take out the trash",
        "Walk the dog",
        "Finish the report",
        "Buy groceries"
    ]
    return random.choice(todos)


# Callback function to handle delivery reports
def delivery_report(err, msg):
    if err is not None:
        print(f"Message delivery failed: {err}")
    else:
        print(f"Message delivered to {msg.topic()}")


print("start producer")

# Produce JSON messages indefinitely
while True:
    data = {
        "id": random.randint(1, 1000),
        "todo": get_random_todo()
    }
    producer.produce("todo", key=str(data["id"]), value=json.dumps(data), callback=delivery_report)

    # Optional: Add a sleep time to control the rate of message production
    time.sleep(1)

# Wait for any outstanding messages to be delivered and delivery reports to be received
producer.flush()
