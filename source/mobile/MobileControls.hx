package mobile;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.FlxInput;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/** Touch overlay polled after Flixel updates input and before the active state. */
class MobileControls extends FlxBasic
{
	static var instance:MobileControls;
	var overlay:FlxGroup;
	var touchCamera:FlxCamera;
	var context:FlxState;
	var gameplay:Bool = false;
	var buttons:Array<TouchButton> = [];
	var blockedTouches:Array<Int> = [];

	public function new()
	{
		super();
		instance = this;
	}

	public static function check(action:String):Bool
	{
		if (instance == null) return false;
		var current:FlxState = FlxG.state;
		while (current.subState != null) current = current.subState;
		if (current != instance.context) return false;
		var parts = action.split('-');
		for (button in instance.buttons)
		{
			if (!button.actions.contains(parts[0])) continue;
			if (parts.length > 1)
			{
				if (parts[1] == 'press' && button.input.justPressed) return true;
				if (parts[1] == 'release' && button.input.justReleased) return true;
			}
			else if (parts[0] == 'accept' || parts[0] == 'back' || parts[0] == 'pause' || parts[0] == 'reset')
			{
				if (button.input.justPressed) return true;
			}
			else if (button.input.pressed) return true;
		}
		return false;
	}

	override public function update(elapsed:Float):Void
	{
		var next:FlxState = FlxG.state;
		while (next.subState != null) next = next.subState;
		var play:PlayState = Std.isOfType(next, PlayState) ? cast next : null;
		var playing = play != null && !play.inCutscene && !play.endingSong;
		if (next != context || playing != gameplay || touchCamera == null || !FlxG.cameras.list.contains(touchCamera))
		{
			context = next;
			gameplay = playing;
			rebuild();
			// A finger that opened a menu must be lifted before it can select an item.
			blockedTouches = [for (touch in FlxG.touches.list) if (touch.pressed) touch.touchPointID];
		}
		blockedTouches = blockedTouches.filter(function(id) {
			for (touch in FlxG.touches.list)
				if (touch.touchPointID == id && touch.pressed) return true;
			return false;
		});
		visible = !Std.isOfType(context, CustomFadeTransition)
			&& (Std.isOfType(context, MusicBeatState) || Std.isOfType(context, MusicBeatSubstate));
		for (button in buttons)
		{
			var held = false;
			if (visible)
				for (touch in FlxG.touches.list)
				{
					if (!touch.pressed || blockedTouches.contains(touch.touchPointID)) continue;
					var point = touch.getScreenPosition(touchCamera);
					if (point.x >= button.box.x && point.x < button.box.x + button.box.width
						&& point.y >= button.box.y && point.y < button.box.y + button.box.height) held = true;
					point.put();
				}
			if (held) button.input.press();
			else button.input.release();
			button.box.alpha = held ? 0.6 : (gameplay && button.actions[0].indexOf('note_') == 0 ? 0.12 : 0.35);
		}
		overlay.update(elapsed);
	}

	function rebuild():Void
	{
		if (overlay != null) overlay.destroy();
		if (touchCamera != null && FlxG.cameras.list.contains(touchCamera)) FlxG.cameras.remove(touchCamera);
		touchCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		touchCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(touchCamera, false);
		overlay = new FlxGroup();
		overlay.cameras = [touchCamera];
		buttons = [];
		if (gameplay)
		{
			var lanes = ['left', 'down', 'up', 'right'];
			var labels = ['<', 'v', '^', '>'];
			var colors:Array<Int> = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];
			var width = FlxG.width / 4;
			for (i in 0...4)
				addButton(i * width, 100, width - 2, FlxG.height - 100, labels[i], ['note_' + lanes[i]], colors[i]);
			addButton(FlxG.width - 160, 12, 148, 76, 'PAUSE', ['pause']);
		}
		else
		{
			var size:Float = Math.min(96, FlxG.height / 7);
			var y = FlxG.height - size - 12;
			addButton(12, y, size, size, '<', ['ui_left']);
			addButton(24 + size, y, size, size, 'v', ['ui_down']);
			addButton(36 + 2 * size, y, size, size, '^', ['ui_up']);
			addButton(48 + 3 * size, y, size, size, '>', ['ui_right']);
			addButton(FlxG.width - 2 * size - 24, y, size, size, 'BACK', ['back']);
			addButton(FlxG.width - size - 12, y, size, size, 'OK', ['accept']);
		}
	}

	function addButton(x:Float, y:Float, width:Float, height:Float, label:String, actions:Array<String>, color:Int = FlxColor.GRAY):Void
	{
		var box = new FlxSprite(x, y).makeGraphic(Std.int(width), Std.int(height), color, true);
		box.scrollFactor.set();
		box.cameras = [touchCamera];
		overlay.add(box);
		var text = new FlxText(x, gameplay && height > 100 ? FlxG.height - 64 : y + (height - 32) / 2, width, label, 24);
		text.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		text.scrollFactor.set();
		text.cameras = [touchCamera];
		overlay.add(text);
		buttons.push({box: box, input: new FlxInput<String>(actions[0]), actions: actions});
	}

	override public function draw():Void
	{
		if (visible && overlay != null) overlay.draw();
	}

	override public function destroy():Void
	{
		if (instance == this) instance = null;
		if (overlay != null) overlay.destroy();
		if (touchCamera != null && FlxG.cameras.list.contains(touchCamera)) FlxG.cameras.remove(touchCamera);
		super.destroy();
	}
}

private typedef TouchButton =
{
	var box:FlxSprite;
	var input:FlxInput<String>;
	var actions:Array<String>;
}
