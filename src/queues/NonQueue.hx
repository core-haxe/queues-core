package queues;

import promises.Promise;

class NonQueue<T> implements IQueue<T> {
    private var items:Array<T> = [];

    public function new() {
    }

    private var _onMessage:T->Promise<Bool>;
    public var onMessage(get, set):T->Promise<Bool>;
    private function get_onMessage():T->Promise<Bool> {
        return _onMessage;
    }
    private function set_onMessage(value:T->Promise<Bool>):T->Promise<Bool> {
        _onMessage = value;
        processQueue();
        return value;
    }

    public function config(config:Dynamic) {
        // no config
    }

    public function start():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            resolve(true);
        });
    }

    public function enqueue(item:T) {
        items.push(item);
        processQueue();
    }

    public function requeue(item:T, delay:Null<Int> = null) {
        if (delay == null && delay > 0) {
            enqueue(item);
        } else {
            haxe.Timer.delay(() -> {
                enqueue(item);
            }, delay);
        }
    }

    private function processQueue() {
        if (_onMessage == null || items.length == 0) {
            return;
        }

        var item = items.shift();
        _onMessage(item).then(success -> {
            processQueue();
        }, error -> {
            processQueue();
        });
    }
}