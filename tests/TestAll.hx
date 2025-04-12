package;

import queues.QueueFactory;
import queues.IQueue;
import utest.ui.common.HeaderDisplayMode;
import utest.ui.Report;
import utest.Runner;
import cases.*;

class TestAll {
    static function main() {
        var runner = new Runner();

        var queueType = "rabbitmq-queue";
        var producer:IQueue<String> = null;
        var consumer:IQueue<String> = null;
        if (queueType == "rabbitmq-queue") {
            producer = QueueFactory.instance.createQueue(QueueFactory.RABBITMQ_QUEUE, {
                brokerUrl: "amqp://localhost",
                queueName: "unit-tests-queue",
                producerOnly: true
            });
            consumer = QueueFactory.instance.createQueue(QueueFactory.RABBITMQ_QUEUE, {
                brokerUrl: "amqp://localhost",
                queueName: "unit-tests-queue"
            });
        } else if (queueType == "non-queue") {
            producer = QueueFactory.instance.createQueue(QueueFactory.NON_QUEUE);
            consumer = producer;
        } else if (queueType == "simple-queue") {
            producer = QueueFactory.instance.createQueue(QueueFactory.SIMPLE_QUEUE);
            consumer = producer;
        }

        addCases(runner, producer, consumer);

        Report.create(runner, SuccessResultsDisplayMode.AlwaysShowSuccessResults, HeaderDisplayMode.NeverShowHeader);
        runner.run();
    }

    private static function addCases(runner:Runner, producer:IQueue<String>, consumer:IQueue<String>) {
        runner.addCase(new TestBasic(producer, consumer));
    }
}