package redis.command;

class Connection extends RedisCommand
{
	public function auth(password:String):Bool
		return writeData('AUTH', [password]) == 'OK';

	public function ping():Bool
		return writeData('PING') == 'PONG';
    
	public function quit():Void
		writeData('QUIT');

	public function select(index:Int):Bool
		return writeData('SELECT', [""+index]) == 'OK';
}