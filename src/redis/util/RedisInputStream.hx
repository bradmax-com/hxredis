package redis.util;

import haxe.io.Input;

class RedisInputStream
{
    public static function readFloatCrLf(i:Input):Float
    {
        var value = 0.0;
        var isNeg = false;
        var b = 0;

        while(true){
            var b = i.readByte();

            if(b == 13){
                i.readByte();
                break;
            }else{
                if(b == 45){
                    isNeg = true;
                }else{
                    value = value * 10 + (b - 48);
                }
            }
        }

        return isNeg ? -value : value;
    }

    public static function readIntCrLf(i:Input):Int
    {
        return Std.int(readFloatCrLf(i));
    }
}





/*

  public long readLongCrLf() {
    final byte[] buf = this.buf;

    ensureFill();

    final boolean isNeg = buf[count] == '-';
    if (isNeg) {
      ++count;
    }

    long value = 0;
    while (true) {
      ensureFill();

      final int b = buf[count++];
      if (b == '\r') {
        ensureFill();

        if (buf[count++] != '\n') {
          throw new JedisConnectionException("Unexpected character!");
        }

        break;
      } else {
        value = value * 10 + b - '0';
      }
    }

    return (isNeg ? -value : value);
  }

  */