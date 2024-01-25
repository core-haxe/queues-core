package queues.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class QueueTypes {
    private static var typeClasses:Map<String, String> = [];

    macro static function register(id:String, c:String) {
        Sys.println('registering queue type ${c} (${id})');
        var parts = c.split(".");
        var name = parts.pop();
        // lets just make sure it exists
        Context.onAfterInitMacros(() -> {
            Context.resolveType(TPath({pack: parts, name: name, params: [TPType(TPath({pack: [], name: "Dynamic"}))]}), Context.currentPos());
        });
        if (!typeClasses.exists(id)) {
            typeClasses.set(id, c);
        }

        return null;
    }

    macro static function build():Array<Field> {
        var fields = Context.getBuildFields();

        var typeIds:Array<String> = [];
        var typeExprs:Array<Expr> = [];
        for (typeId in typeClasses.keys()) {
            typeIds.push(typeId);
            var c = typeClasses.get(typeId);
            var parts = c.split(".");
            var name = parts.pop();
            var t:TypePath = {
                pack: parts,
                name: name,
                params: [TPType(TPath({pack: [], name: "T"}))]
            }
            typeExprs.push(macro @:mergeBlock if (typeId == $v{typeId}) {
                queue = new $t<T>();
                if (config != null) {
                    queue.config(config);
                }
            });
        }

        for (f in fields) {
            if (f.name == "createQueue") {
                switch (f.kind) {
                    case FFun(f):
                        f.expr = macro @:mergeBlock {
                            var queue:IQueue<T> = null;

                            $b{typeExprs}

                            return queue;
                        }
                    case _:    
                }
                break;
            }
        }

        for (typeId in typeIds) {
            fields.push({
                name: typeId.toUpperCase().replace("-", "_"),
                kind: FVar(
                    macro: String,
                    macro $v{typeId}
                ),
                access: [AStatic, APublic, AInline],
                pos: Context.currentPos()
            });
        }


        return fields;
    }
}
