package queues;

import haxe.Exception;

@:build(queues.macros.QueueTypes.build())
class QueueFactory {
    private static var _instance:QueueFactory = null;
    public static var instance(get, null):QueueFactory;
    private static function get_instance():QueueFactory {
        if (_instance == null) {
            _instance = new QueueFactory();
        }
        return _instance;
    }

    ///////////////////////////////////////////////////////////////////////////////
    private function new() {
        init();
    }

    private function init() {
    }

    // macro will build this
    public function createQueue<T>(typeId:String, config:Dynamic = null):IQueue<T>;
}