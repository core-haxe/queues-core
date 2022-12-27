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

    public function enqueue(item:T) {
        items.push(item);
        processQueue();
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