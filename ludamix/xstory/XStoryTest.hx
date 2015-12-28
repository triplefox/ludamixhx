package ludamix.xstory;

class XStoryTest {
	
	public static function run() {
		var xs = new XStory();
		
		xs.globals = Vector.fromArrayCopy([0, 0, 0]);
		xs.runcode = [
			function(xs, si, instruction) {
				trace('hello world: $si $instruction');
			},
			function(xs, si, instruction) {
				trace('${xs.globals}');
			},
			function(xs, si, instruction) {
				trace('waiting 4 times ${xs.stack}');
			},
		];
		xs.ifcode = [
			function(xs, si, instruction) {
				return true;
			},
			function(xs, si, instruction) {
				return false;
			},
		];
		xs.programs = [
			{name:"Test0", locals:0, local_default:-1, code: [
				[XStoryOp.GSET.asInt(), 0, 123],
				[XStoryOp.RUNSTEP.asInt(), 0, 1, 2, 3],
				[XStoryOp.RJUMP.asInt(), 2],
				[XStoryOp.RUNSTEP.asInt(), 1], // skip over
				[XStoryOp.CJUMP.asInt(), 6],
				[XStoryOp.POP.asInt(), 1],
				[XStoryOp.RUNSTEP.asInt(), 1],
				[XStoryOp.PUSH.asInt(), 1, 0],
				[XStoryOp.RUNWAIT.asInt(), 2],
				[XStoryOp.POP.asInt(), 1]
			]
			},
			{name:"Test1", locals:1, local_default:0, code: [
				[XStoryOp.LSET.asInt(), 2, 2],
				[XStoryOp.GSET.asInt(), 1, 200],
				[XStoryOp.WAIT.asInt(), 2],
				[XStoryOp.WAITSTEP.asInt()],
				[XStoryOp.POP.asInt(), 1]
			]
			},
			{name:"Test2", locals:0, local_default:0, code: [
				[XStoryOp.CIF.asInt(), 0, 3],
				[XStoryOp.GSET.asInt(), 0, 100], // skip over
				[XStoryOp.RJUMP.asInt(), 2],
				[XStoryOp.GSET.asInt(), 0, 200],
				[XStoryOp.RIF.asInt(), 1, 2],
				[XStoryOp.RUNSTEP.asInt(), 0], // skip over
				[XStoryOp.PUSH.asInt(), 1, 0], 
				[XStoryOp.WAITIF.asInt(), 0], 
				[XStoryOp.RUNSTEP.asInt(), 1], // display 100, 200, 0
				[XStoryOp.POP.asInt(), 1],
			]}
		];
		xs.validate();
		for (test in [0, 2]) {
			trace('running ${xs.programs[test].name}');
			xs.start(test, 0);
			var timeout = 0;
			while (xs.stack.length > 0) {
				xs.run();
				if (xs.last_error != null)
					trace(xs.last_error);
				xs.last_error = null;
				timeout += 1;
				if (timeout > 100)
					{ trace("timeout: too many runs");  break; }
			}
		}		
	}
	
}

