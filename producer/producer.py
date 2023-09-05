import time

from confluent_kafka import Producer
import json
import random

config = {
    'bootstrap.servers': 'redpanda:9092',
}

producer = Producer(config)


def get_random_todo():
    todos = [
        "Clean the kitchen",
        "Take out the trash",
        "Walk the dog",
        "Finish the report",
        "Buy groceries"
    ]
    return random.choice(todos)


def delivery_report(err, msg):
    if err is not None:
        print(f"Message delivery failed: {err}")
    else:
        print(f"Message delivered to {msg.topic()}")


print("start producer")

while True:
    data = {
        "id": random.randint(1, 1000),
        "todo": get_random_todo()
    }
    producer.produce("todo", key=str(data["id"]), value=json.dumps(data), callback=delivery_report)

    time.sleep(1)
