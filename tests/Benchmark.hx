package;
import haxe.Resource;

class Benchmark { 

  static function main() {
    testPerformance();
  }
  
  static function measure(f:Void->Void) {
    function stamp()
      return
        #if java
          Sys.cpuTime();
        #else
          haxe.Timer.stamp();
        #end
        
    var start = stamp();
    f();
    return stamp() - start;
  }

  static function testPerformance() {
    var o = {
      blub: [
        { foo: [ { bar: [true] } ] }, 
        { foo: [ { bar: [false] } ] } 
      ]
    };
    
    var platform = 
      #if java
        'java';
      #elseif neko
        'neko';
      #elseif interp
        'interp';
      #elseif cpp
        'cpp';
      #elseif cs
        'cs';
      #elseif python
        'python';
      #elseif nodejs
        'nodejs';
      #elseif flash
        'flash';
      #elseif php
        'php';
      #else
        #error
      #end
    
    var count = switch platform {
      case 'php' | 'python': 1000;
      case 'java': 50000;
      default: 10000;
    }
        
    for (i in 0...10 * count)
      haxe.Json.stringify(o);
      
    var haxeStringify = measure(function () 
      for (i in 0...count)
        haxe.Json.stringify(o)
    );
    
    var writer = new tink.json.Writer<{ blub:Array<{ foo: Array<{ bar:Array<Bool> }>}> }>();
    for (i in 0...10 * count)
      writer.write(o);
      
    var tinkStringify = measure(function () 
      for (i in 0...count)
        writer.write(o)
    );
        
    var s = tink.Json.stringify(o);
    
    for (i in 0...10 * count)
      o = haxe.Json.parse(s);
      
    var haxeParse = measure(function () 
      for (i in 0...count)
        o = haxe.Json.parse(s)
    );
    
    var parser = new tink.json.Parser<{ blub:Array<{ foo: Array<{ bar:Array<Bool> }>}> }>();
    for (i in 0...10 * count)
      parser.parse(s);
    
    var tinkParse = measure(function () 
      for (i in 0...count)
        parser.parse(s)
    );
    
    function clamp(f:Float)
      return Std.int(f * 100) / 100;
    
    Sys.println('| $platform | ${clamp(haxeStringify / tinkStringify)} | ${clamp(haxeParse / tinkParse)} |');
  }  
}