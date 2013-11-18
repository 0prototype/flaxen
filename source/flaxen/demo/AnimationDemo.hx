/**
	TODO
	  - Subdivision shouldn't require tiles across/down data, this should be inferred
	    from the Image
	  - Subdivision, isn't it really just a Division?
*/
package flaxen.demo; 

import ash.core.Entity;
import flaxen.core.Flaxen;
import flaxen.component.Image;
import flaxen.component.Offset;
import flaxen.component.Position;
import flaxen.component.Data;
import flaxen.component.Animation;
import flaxen.component.Subdivision;
import flaxen.service.InputService;

class AnimationDemo extends Flaxen
{
	private static inline var eastRoll:String = "5-9,0-4";
	private static inline var westRoll:String = "15-19,10-14";

	public static function main()
	{
		var demo = new AnimationDemo();
	}

	override public function ready()
	{	
		resolveEntity("ball")
			.add(new Image("art/ball.png"))
			.add(Position.center())
			.add(Offset.center())
			.add(new Data(false))
			.add(Subdivision.create(5, 5, 60, 60))
			.add(new Animation(eastRoll, 30));

		setInputHandler(function(f)
		{
			if(InputService.clicked)
			{
				var ball = resolveEntity("ball");
				var data = ball.get(Data);
				data.value = !data.value;
				ball.get(Animation).setFrames(data.value ? westRoll : eastRoll);
			}
		});
	}
}