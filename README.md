# queues-core
pluggable queue abstraction

# basic usage

```haxe
queue.onMessage = (item:Int) -> {
    return new Promise((resolve, reject) -> {
        trace("got item", item);
        item++;
        if (item == 31) {
            queue.requeue(item, 1000); // requeue with 1s delay
        }
        resolve(true); // ack
    });
}
queue.start().then(success -> {
    q.enqueue(10);
    q.enqueue(20);
    q.enqueue(30);
    q.enqueue(40);
    q.enqueue(50);
});
```

# simple queue

This is the most basic queue, it will dispatch items seqentually waiting for an ack or nack before dispatching the second. This is purely an internal implementation for simple things (like making sure http requests are "in order" when dealing with nonces for example)

```haxe
var queue:IQueue<Int> = QueueFactory.instance.createQueue(QueueFactory.SIMPLE_QUEUE);
```

# non queue
This isnt actually a queue but can be used when an interface for a queue is required (for example its the default in the http request queue). This "queue" simply dispatches items as they come in, there is nothing sequential about this at all. It is _not_ a queue

```haxe
var queue:IQueue<Int> = QueueFactory.instance.createQueue(QueueFactory.NON_QUEUE);
```

# rabbitmq

```haxe
var queue:IQueue<Int> = QueueFactory.createDatabase(QueueFactory.RABBITMQ_QUEUE, {
    brokerUrl: "amqp://localhost",
    queueName: "my-http-request-queue"
});
```
_Note: must include [__queues-rabbitmq__](https://github.com/core-haxe/queues-rabbitmq) for plugin to be auto-registered_
