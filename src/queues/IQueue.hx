package queues;

import promises.Promise;

interface IQueue<T> {
    public var onMessage(get, set):T->Promise<Bool>;
    public function enqueue(item:T):Void;
}