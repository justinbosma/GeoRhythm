//Take in array that represents 16th notes - 4 measures
//Each hit is written as 1 off written as 0
//initialize one parent -> spawn 8 children randomly flipping bits
//Get the interval vector for parent and each child
//Comparing weights: add 1 to simliarity weight if index has same number -> max weight=15

//Get interval vector
//1. Find first 'hit' and store index
//2. count intervals to next 'hit'
//3. continue til end of array
//4. move to next 'hit' and repeat from 2

~son = [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0];
TempoClock.default.tempo = 105/60;
(
~getIntervalVector = {arg rhythmArray;
	var intervalVector = Array.fill(rhythmArray.size/2, {0});
	for(0, rhythmArray.size - 2, {arg i;
		if(rhythmArray.at(i) == 1, {
			for(i + 1, (rhythmArray.size - 1), {arg j;
				var interval = 0, intervalAt = 0;
				if(rhythmArray.at(j) == 1, {
					interval = min((j - i), (rhythmArray.size - (j - i)));
					intervalAt = intervalVector.at(interval - 1);
					intervalAt = intervalAt + 1;
					intervalVector.put(interval - 1, intervalAt);
				}
				)
			}
			)
		}
		)
	}
	);
	intervalVector;
};



~spawnChild = {arg rhythmArray;
	//sets child to same rhythm as parent
	var child = rhythmArray.addAll();
	var probRS = 1/25;
	var probLS = 1/25;
	var probRot = 1/25;
	var probBF = 1/20;
	var probEnd;
	var end = false;
	var random = 1.0.rand;
	var bit, rotClone, pivot, end1, end2, end3;
	var count = 1;
	while({end == false}, {
		//probEnd = 1 - (probRS + probLS + probRot + probBF);
		end1 = probLS + probRS;
		end2 = probRS + probLS + probRot;
		end3 = probRS + probLS + probRot + probBF;
		if(random < probRS, {//right shift
			//"right shift".postln;
			count = count + 1;
			child = child.rotate(1);
			//child.postln;
			probRS = probRS/count;
			//probLS = probLS/count;
			//probRot = probRot/count;
			//probBF = probBF/count;
		});
		if((probRS <= random) && (random < end1), {//left shift
			//"left shift".postln;
			count = count + 1;
			child = child.rotate(-1);
			//child.postln;
			//probRS = probRS/count;
			probLS = probLS/count;
			//probRot = probRot/count;
			//probBF = probBF/count;
		});
		if((end1 <= random) && (random < end2), {
			count = count + 1;
			//"reverse".postln;
			child = child.reverse;
			//probRS = probRS/count;
			//probLS = probLS/count;
			probRot = probRot/count;
			//probBF = probBF/count;
		});
		if((end2 <= random) && (random < end3), {//bit flip
			//"bit flip".postln;
			count = count + 1;
			bit = rrand(0, child.size.rand);
			//bit.postln;
			if(child.at(bit) == 0, {child = child.put(bit, 1)}, {child = child.put(bit, 0)});
			//probRS = probRS/count;
			//probLS = probLS/count;
			//probRot = probRot/count;
			probBF = probBF/count;
		});
		if((end3 <= random), {
			end = true;
		});
	});
	child;
};


~getRhythmIVWeight = {arg parentIV, childIV;
	var weight = 0;
	for(0, parentIV.size - 1, {arg i;
		weight = weight + abs(parentIV.at(i) - childIV.at(i));
	});
	1/(weight + 1);//plus 1 to avoid div by zero
};



~evolveRhythmGeodesic = {arg parent;
	var children = Array.new(8);
	var probabilities = Array.new(8);
	var parentIV = ~getIntervalVector.(parent);
	var childIV;
	var child;
	var chosenOne;
	var randInt;
	var s0, s1, s2, s3, s4, s5, s6, s7;
	for(0, 7, {arg i;
		child = ~spawnChild.(parent);
		children = children.add(child);
		childIV = ~getIntervalVector.(child);
		probabilities = probabilities.add(~getRhythmIVWeight.(parentIV, childIV));

	});
	probabilities = probabilities.normalizeSum;
	probabilities.postln;
	children.postln;
	s0 = probabilities.at(0);
	s1 = s0 + probabilities.at(1);
	s2 = s1 + probabilities.at(2);
	s3 = s2 + probabilities.at(3);
	s4 = s3 + probabilities.at(4);
	s5 = s4 + probabilities.at(5);
	s6 = s5 + probabilities.at(6);

	randInt = 1.0.rand;
	if(randInt < s0, {
		chosenOne = children.at(0);
	});
	if((s0<= randInt) && (randInt < s1), {
		chosenOne = children.at(1);
	});
	if((s1<= randInt) && (randInt < s2), {
		chosenOne = children.at(2);
	});
	if((s2<= randInt) && (randInt < s3), {
		chosenOne = children.at(3);
	});
	if((s3<= randInt) && (randInt < s4), {
		chosenOne = children.at(4);
	});
	if((s4<= randInt) && (randInt < s5), {
		chosenOne = children.at(5);
	});
	if((s5<= randInt) && (randInt < s6), {
		chosenOne = children.at(6);
	});
	if((s6<= randInt) && (randInt <= 1), {
		chosenOne = children.at(7);
	});
	chosenOne;
};
)
(
~evo1 = {arg rhythm;
	~rhythm1 = ~evolveRhythmGeodesic.(~rhythm1);
	"r1".postln;
	~rhythm1.postln;
};
~evo2 = {arg rhythm;
	~rhythm2 = ~evolveRhythmGeodesic.(~rhythm2);
	"r2".postln;
	~rhythm2.postln;
};

~evo3 = {arg rhythm;
	~rhythm3 = ~evolveRhythmGeodesic.(~rhythm3);
	"r3".postln;
	~rhythm3.postln;
};

~evo4 = {arg rhythm;
	~rhythm4 = ~evolveRhythmGeodesic.(~rhythm4);
	"r4".postln;
	~rhythm4.postln;
};

~evo5 = {arg rhythm;
	~rhythm5 = ~evolveRhythmGeodesic.(~rhythm5);
	"r5".postln;
	~rhythm5.postln;
};

~rhythm1 = [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0];
~rhythm2 = [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0];
~rhythm3 = [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0];
~rhythm4 = [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0];
~rhythm5 = [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0];
)
(
~malletEvo1 = Pbind(
    \instrument, \mallet,
	\freq, Pseq([220], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo1.())});
).play;


~malletEvo2 = Pbind(
    \instrument, \mallet,
	\freq, Pseq([440], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo2.())});
).play;

~malletEvo3 = Pbind(
    \instrument, \mallet,
	\freq, Pseq([880], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo3.())});
).play;

~malletEvo4 = Pbind(
    \instrument, \mallet,
	\freq, Pseq([110], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo4.())});
).play;
)

~kick.stop;
(
~kick = Pbind(
    \instrument, \playbufKick,
	\bufnum, ~kickBuf.bufnum,
	\time, Pseq([0.4], inf),
	\rate, Pseq([1/4], inf),
	\dur, Pseq([1], inf),
	\amp, Pseq([0.4], inf);
).play;

~malletEvo1.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([[220, 220]], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 300,
	\amp, Pn(Plazy{Pseq(~evo1.())});
).asStream;

~malletEvo2.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([440], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo2.())});
).asStream;

~malletEvo3.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([880], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo3.())});
).asStream;

~malletEvo4.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([440], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo4.())});
).asStream;
)

(
~pad = Pbind(
    \instrument, \pad1,
	\scale, Scale.dorian,
	\degree, Pwhite(-9, 9),
	//\freq, Pseq([220, 440], inf),
	\dur, Pseq([8], inf),
	\release, 10,
	\lowDiv, 1,
    \amp, 0.04;
).play(quant: 0);

~kick.stream = Pbind(
    \instrument, \playbufKick,
	\bufnum, ~kickBuf.bufnum,
	\time, Pseq([0.4], inf),
	\rate, Pseq([1/4], inf),
	\dur, Pseq([1], inf),
	\amp, Pseq([0.4], inf);
).asStream;

~malletEvo1.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([[220, 220]], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 300,
	\amp, Pn(Plazy{Pseq(~evo1.())});
).asStream;

~malletEvo2.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([440], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo2.())});
).asStream;

~malletEvo3.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([880], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo3.())});
).asStream;

~malletEvo4.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([440], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo4.())});
).asStream;
)

(
~pad.stream = Pbind(
    \instrument, \pad1,
	\scale, Scale.dorian,
	\degree, Pwhite(0, 9),
	//\freq, Pseq([220, 440], inf),
	\dur, Pseq([8], inf),
	\release, 12,
	\lowDiv, 4,
    \amp, 0.04;
).asStream;

~kick.stream = Pbind(
    \instrument, \playbufKick,
	\bufnum, ~kickBuf.bufnum,
	\time, Pseq([0.4], inf),
	\rate, Pseq([1/4], inf),
	\dur, Pseq([1], inf),
	\amp, Pseq([0.4], inf);
).asStream;

~malletEvo1.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([[220, 220]], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo1.())});
).asStream;

~malletEvo2.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([440], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo2.())});
).asStream;

~malletEvo3.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([880], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo3.())});
).asStream;

~malletEvo4.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([440], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo4.())});
).asStream;
)
(
~tink.stream = Pbind(
    \instrument, \tink,
	\scale, Scale.dorian,
	\degree, Pwhite(-9, 9),
	//\freq, Pseq([220, 440], inf),
	\dur, 1/4,
    \amp, Pn(Plazy{Pseq(~evo5.()*0.4)});
).asStream;

~kick.stream = Pbind(
    \instrument, \playbufKick,
	\bufnum, ~kickBuf.bufnum,
	\time, Pseq([0.4], inf),
	\rate, Pseq([1/4], inf),
	\dur, Pseq([1], inf),
	\amp, Pseq([0.4], inf);
).asStream;


~pad.stream = Pbind(
    \instrument, \pad1,
	\scale, Scale.dorian,
	\degree, Pwhite(0, 9),
	//\freq, Pseq([220, 440], inf),
	\dur, Pseq([8], inf),
	\release, 10,
	\lowDiv, 4,
    \amp, 0.04;
).asStream;



~malletEvo5.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([220, 225], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pseq(~rhythm1, inf);
).asStream;
)
~malletEvo1.play;
~malletEvo2.play;
~malletEvo3.play;
~malletEvo4.play;
~pad.play();
(
~tink.stream = Pbind(
    \instrument, \tink,
	\scale, Scale.dorian,
	\degree, Pwhite(-9, 9),
	//\freq, Pseq([220, 440], inf),
	\dur, 1/4,
    \amp, Pn(Plazy{Pseq(~evo5.()*0.7)});
).asStream;

~bass = Pbind(
	\instrument, \bass,
	\freq, 55,
	//\freq, Pseq([220, 440], inf),
	\dur, 4,
    \amp, 0.8;
).asStream;

~kick.stream = Pbind(
    \instrument, \playbufKick,
	\bufnum, ~kickBuf.bufnum,
	\time, Pseq([0.4], inf),
	\rate, Pseq([1/4], inf),
	\dur, Pseq([1], inf),
	\amp, Pseq([0.4], inf);
).asStream;

~malletEvo1.play;
~malletEvo2.play;
~malletEvo3.play;
~malletEvo4.play;
~pad.play();

~malletEvo2.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([220, 225], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pseq(~rhythm1, inf);
).asStream;

)
~pad.stop();

(
~malletEvo1.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([[220, 220]], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pn(Plazy{Pseq(~evo1.())});
).asStream;

~malletEvo2 = Pbind(
    \instrument, \mallet,
	\freq, Pseq([220, 225], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 100,
	\amp, Pseq(~rhythm1, inf);
).play;
)
Scale.directory;


-----------------------------------
(
~bass = Pbind(
    \instrument, \bass,
	\freq, Pseq([60], inf),
	\dur, Pseq([1, 1/2, 1/2, 2], inf),
	\amp, 0.5;
).play();

~malletEvo1.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([[220, 220]], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\cutoff, 200,
	\amp, Pn(Plazy{Pseq(~evo1.()/2)});

).asStream;
)
(
~bass.stream = Pbind(
    \instrument, \bass,
	\freq, Pseq([60], inf),
	\dur, Pseq([1/2, 1/2,  1]*4, inf),
	\amp, 0.3;
).asStream;



~kick = Pbind(
    \instrument, \playbufKick,
	\bufnum, ~kickBuf.bufnum,
	\time, Pseq([0.4], inf),
	\rate, Pseq([1]/2, inf),
	\dur, Pseq([2], inf),
	\amp, Pseq([0.2, 0.2, 0.1, 0.1, 0.1], inf);
).play;
)

(
~malletEvo1.stream = Pbind(
    \instrument, \mallet,
	\freq, Pseq([[220, 220]], inf),
	\dur, Pseq([1/4], inf),
	\release, 0.2,
	\amp, Pn(Plazy{Pseq(~evo1.())});
).asStream;

~bass.stream = Pbind(
    \instrument, \bass,
	\freq, Pseq([60], inf),
	\dur, Pseq([1/2, 1]*4, inf),
	\amp, 0.5;
).asStream;

~kick.stream = Pbind(
    \instrument, \playbufKick,
	\bufnum, ~kickBuf.bufnum,
	\time, Pseq([0.4], inf),
	\rate, Pseq([1]/2, inf),
	\dur, Pseq([1, 1/2, 1/2], inf),
	\amp, Pwhite(0, 0.4, inf);
).asStream;
)


(
~pad = Pbind(
    \instrument, \pad1,
	\freq, Pseq([220, 440]/4, inf),
	\dur, Pseq([16], inf),
    \amp, 0.1;
).play;
)











(
~snare = Pbind(
    \instrument, \playbufSnare,
	\bufnum, ~snareBuf.bufnum,
	\time, Pseq([0.2], inf),
	\rate, Pseq([1]/4, inf),
	\dur, Pseq([1], inf),
	\amp, Pn(Plazy{Pseq(~evo2.())});
).play();
)


(
~mallet2Seq = Pbind(
    \instrument, \mallet2,
    \freq, Pseq( ~mallet2_1.at(0)*4, inf),
    \dur, Pseq( ~mallet2_1.at(1), inf),
    \amp, Pseq( ~mallet2_1.at(2)*0.1, inf);
).play(quant: 16);
)
