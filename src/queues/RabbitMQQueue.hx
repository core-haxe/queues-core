package queues;

import haxe.Unserializer;
import haxe.Serializer;
import rabbitmq.Message;
import rabbitmq.RetryableQueue;
import rabbitmq.ConnectionManager;
import rabbitmq.RabbitMQError;
import promises.Promise;

class RabbitMQQueue<T> implements IQueue<T> {
    private var _queue:RetryableQueue;

    public function new() {
    }

    private var _onMessage:T->Promise<Bool>;
    public var onMessage(get, set):T->Promise<Bool>;
    private function get_onMessage():T->Promise<Bool> {
        return _onMessage;
    }
    private function set_onMessage(value:T->Promise<Bool>):T->Promise<Bool> {
        _onMessage = value;
        return value;
    }
    
    private var _config:Dynamic = null;
    public function config(config:Dynamic) {
        // TODO: validate or dont use Dynamic (somehow)
        _config = config;
    }

    public function start():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            ConnectionManager.instance.getConnection(_config.brokerUrl).then(connection -> {
                _queue = new RetryableQueue({
                    connection: connection,
                    queueName: _config.queueName
                });
                return _queue.start();
            }).then(retryableQueue -> {
                retryableQueue.onMessage = onRabbitMQMessage;
                resolve(true);
            }, (error:RabbitMQError) -> {
                //connection.close();
                reject(error);
            });
    
        });
    }

    private function onRabbitMQMessage(message:Message) {
        var item:Dynamic = Unserializer.run(message.content.toString()); // TODO: probably want to make this pluggable
        _onMessage(item).then(success -> {
            if (success) {
                message.ack();
            } else{
                message.nack();
            }
        }, error -> {
            message.nack();
        });
    }

    public function enqueue(item:T) {
        var data = Serializer.run(item); // TODO: probably want to make this pluggable
        var message = new Message(data);
        _queue.publish(message);
    }

    public function requeue(item:T, delay:Null<Int> = null) {
        var data = Serializer.run(item); // TODO: probably want to make this pluggable
        var message = new Message(data);
        _queue.retry(message, delay);
    }

}