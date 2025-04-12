package cases;

import promises.Promise;
import rabbitmq.ConnectionManager;
import promises.PromiseUtils;
import haxe.Timer;
import utest.ITest;
import utest.Async;
import utest.Assert;
import queues.IQueue;

@:timeout(20000)
class TestBasic implements ITest {
    var producer:IQueue<String>;
    var consumer:IQueue<String>;

    public function new(producer:IQueue<String>, consumer:IQueue<String>) {
        this.producer = producer;
        this.consumer = consumer;
    }

    function setup(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        this.consumer.start().then(_ -> {
            return this.producer.start();
        }).then(_ -> {
            async.done();
        }, error -> {
            trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ", error);
            async.done();
        });
    }

    function teardown(async:Async) {
        logging.LogManager.instance.clearAdaptors();
        consumer.stop().then(_ -> {
            return producer.stop();
        }).then(_ -> {
            // rmq only - doesnt apply to simple queue types
            return ConnectionManager.instance.closeAll();
        }).then(_ -> {
            async.done();
        }, error -> {
            trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ", error);
            async.done();
        });
    }

    function testBasic(async:Async) {
        consumer.onMessage = (message) -> {
            return new Promise((resolve, reject) -> {
                Assert.equals("foo-message", message);
                resolve(true); // ack
                async.done();
            });
        }
        producer.enqueue("foo-message");
    }
}