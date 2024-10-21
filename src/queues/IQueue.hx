package queues;

import promises.Promise;

interface IQueue<T> {
    public var name(get, set):String;
    public var onMessage(get, set):T->Promise<Bool>;
    public var onMessageWithProperties(get, set):T->Map<String, Any>->Promise<Bool>;
    public function config(config:Dynamic):Void;
    public function start():Promise<Bool>;
    public function stop():Promise<Bool>;
    public function enqueue(item:T, properties:Map<String, Any> = null):Void;
    public function requeue(item:T, delay:Null<Int> = null):Void;
}