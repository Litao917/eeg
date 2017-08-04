%% Controlling Random Number Generation
% This example shows how to use the |rng| function, which provides control
% over random number generation.
%
% (Pseudo)Random numbers in MATLAB come from the |rand|, |randi|, and |randn|
% functions.  Many other functions call those three, but those are the
% fundamental building blocks.  All three depend on a single shared random
% number generator that you can control using |rng|.  
%
% It's important to realize that "random" numbers in MATLAB are not
% unpredictable at all, but are generated by a deterministic algorithm.  The
% algorithm is designed to be sufficiently complicated so that its output
% _appears_ to be an independent random sequence to someone who does not know
% the algorithm, and can pass various statistical tests of randomness.  The
% function that is introduced here provides ways to take advantage of the
% determinism to
%
% * repeat calculations that involve random numbers, and get the same results, or
% * guarantee that different random numbers are used in repeated calculations
%
% and to take advantage of the apparent randomness to justify combining
% results from separate calculations.

% Copyright 2010-2013 The MathWorks, Inc.


%% "Starting Over"
% If you look at the output from |rand|, |randi|, or |randn| in a new MATLAB
% session, you'll notice that they return the same sequences of numbers each
% time you restart MATLAB.  It's often useful to be able to reset the random
% number generator to that startup state, without actually restarting MATLAB.
% For example, you might want to repeat a calculation that involves random
% numbers, and get the same result.
%
% |rng| provides a very simple way to put the random number generator back to
% its default settings.
rng default
rand % returns the same value as at startup

%%
% What are the "default" random number settings that MATLAB starts up with, or
% that |rng default| gives you?  If you call |rng| with no inputs, you can see
% that it is the Mersenne Twister generator algorithm, seeded with 0.
rng
%%
% You'll see in more detail below how to use the above output, including the
% |State| field, to control and change how MATLAB generates random numbers.
% For now, it serves as a way to see what generator |rand|, |randi|, and
% |randn| are currently using.


%% Non-Repeatability
% Each time you call |rand|, |randi|, or |randn|, they draw a new value from
% their shared random number generator, and successive values can be treated
% as statistically independent.  But as mentioned above, each time you restart
% MATLAB those functions are reset and return the same sequences of numbers.
% Obviously, calculations that use the _same_ "random" numbers cannot be
% thought of as statistically independent.  So when it's necessary to combine
% calculations done in two or more MATLAB sessions as if they _were_
% statistically independent, you cannot use the default generator settings.
%
% One simple way to avoid repeating the same random numbers in a new MATLAB
% session is to choose a different seed for the random number generator.
% |rng| gives you an easy way to do that, by creating a seed based on the
% current time.
% 
rng shuffle
rand
%%
% Each time you use |'shuffle'|, it reseeds the generator with a different
% seed.  You can call |rng| with no inputs to see what seed it actually used.
rng
%%
rng shuffle % creates a different seed each time
rng 
%%
rand

%%
% |'shuffle'| is a very easy way to reseed the random number generator.  You
% might think that it's a good idea, or even necessary, to use it to get
% "true" randomness in MATLAB.  For most purposes, though, _it is not
% necessary to use |'shuffle'| at all_.  Choosing a seed based on the current
% time does not improve the statistical properties of the values you'll get
% from |rand|, |randi|, and |randn|, and does not make them "more random" in
% any real sense.  While it is perfectly fine to reseed the generator each
% time you start up MATLAB, or before you run some kind of large calculation
% involving random numbers, it is actually not a good idea to reseed the
% generator too frequently within a session, because this can affect the
% statistical properties of your random numbers.
%
% What |'shuffle'| does provide is a way to avoid repeating the same sequences
% of values.  Sometimes that is critical, sometimes it's just "nice", but
% often it is not important at all.  Bear in mind that if you use |'shuffle'|,
% you may want to save the seed that |rng| created so that you can repeat your
% calculations later on.  You'll see how to do that below.


%% More Control over Repeatability and Non-Repeatability
% So far, you've seen how to reset the random number generator to its default
% settings, and reseed it using a seed that is created using the current time.
% |rng| also provides a way to reseed it using a specific seed.
%
% You can use the same seed several times, to repeat the same calculations.
% For example, if you run this code twice ...
rng(1) % the seed is any non-negative integer < 2^32
x = randn(1,5)
%%
rng(1)
x = randn(1,5)
%%
% ... you get exactly the same results.  You might do this to recreate |x|
% after having cleared it, so that you can repeat what happens in subsequent
% calculations that depend on |x|, using those specific values.

%%
% On the other hand, you might want to choose _different_ seeds to ensure
% that you don't repeat the same calculations.  For example, if you run this code
% in one MATLAB session ...
rng(2)
x2 = sum(randn(50,1000),1); % 1000 trials of a random walk

%%
% and this code in another ...
rng(3)
x3 = sum(randn(50,1000),1);

%%
% ... you could combine the two results and be confident that they are not
% simply the same results repeated twice.
x = [x2 x3];

%%
% As with |'shuffle'| there is a caveat when reseeding MATLAB's random number
% generator, because it affects all subsequent output from |rand|, |randi|,
% and |randn|.  Unless you need repeatability or uniqueness, it is usually
% advisable to simply generate random values without reseeding the generator.
% If you do need to reseed the generator, that is usually best done at the
% command line, or in a spot in your code that is not easily overlooked.


%% Choosing a Generator Type
% Not only can you reseed the random number generator as shown above, you can
% also choose the type of random number generator that you want to use.
% Different generator types produce different sequences of random numbers, and
% you might, for example, choose a specific type because of its statistical
% properties.  Or you might need to recreate results from an older version of
% MATLAB that used a different default generator type.
%
% One other common reason for choosing the generator type is that you are
% writing a validation test that generates "random" input data, and you need
% to guarantee that your test can always expect exactly the same predictable
% result.  If you call |rng| with a seed before creating the input data, it
% reseeds the random number generator.  But if the generator type has been
% changed for some reason, then the output from |rand|, |randi|, and |randn|
% will not be what you expect from that seed.  Therefore, to be 100% certain
% of repeatability, you can  also specify a generator type.
%
% For example,
rng(0,'twister')
%%
% causes |rand|, |randi|, and |randn| to use the Mersenne Twister generator
% algorithm, after seeding it with 0.
%
% Using |'combRecursive'|
rng(0,'combRecursive')
%%
% selects the Combined Multiplicative Recursive generator algorithm, which
% supports some parallel features that the Mersenne Twister does not.
%
% This command
rng(0,'v4')
%%
% selects the generator algorithm that was the default in MATLAB 4.0.
%
% And of course, this command returns the random number generator to its
% default settings.
rng default
%%
% However, because the default random number generator settings may change
% between MATLAB releases, using |'default'| does not guarantee predictable
% results over the long-term.  |'default'| is a convenient way to reset the
% random number generator, but for even more predictability, specify a
% generator type and a seed.
%
% On the other hand, when you are working interactively and need
% repeatability, it is simpler, and usually sufficient, to call |rng| with
% just a seed.


%% Saving and Restoring Random Number Generator Settings
% Calling |rng| with no inputs returns a scalar structure with fields that
% contain two pieces of information described already: the generator type, and
% the integer with which the generator was last reseeded.
s = rng
%%
% The third field, |State|, contains a copy of the generator's current state
% vector.  This state vector is the information that the generator maintains
% internally in order to generate the next value in its sequence of random
% numbers.  Each time you call |rand|, |randi|, or |randn|, the generator that
% they share updates its internal state.  Thus, the state vector in the
% settings structure returned by |rng| contains the information necessary to
% repeat the sequence, beginning from the point at which the state was captured.
%
% While just being able to see this output is informative, |rng| also accepts
% a settings structure as an _input_, so that you can save the settings,
% including the state vector, and restore them later to repeat calculations.
% Because the settings contain the generator type, you'll know exactly what
% you're getting, and so "later" might mean anything from moments later in the
% same MATLAB session, to years (and multiple MATLAB releases) later.  You can
% repeat results from any point in the random number sequence at which you
% saved the generator settings.  For example
x1 = randn(10,10); % move ahead in the random number sequence
s = rng;           % save the settings at this point
x2 = randn(1,5)
%%
x3 = randn(5,5);   % move ahead in the random number sequence
rng(s);            % return the generator back to the saved state
x2 = randn(1,5)    % repeat the same numbers

%%
% Notice that while reseeding provides only a coarse reinitialization, saving
% and restoring the generator state using the settings structure allows you to
% repeat _any_ part of the random number sequence.

%%
% The most common way to use a settings structure is to restore the generator
% state.  However, because the structure contains not only the state, but also
% the generator type and seed, it's also a convenient way to temporarily
% switch generator types.  For example, if you need to create values using one
% of the legacy generators from MATLAB 5.0, you can save the current settings
% at the same time that you switch to use the old generator ...
previousSettings = rng(0,'v5uniform')
%%
% ... and then restore the original settings later.
rng(previousSettings)

%%
% You should not modify the contents of any of the fields in a settings
% structure.  In particular, you should not construct your own state vector,
% or even depend on the format of the generator state.


%% Writing Simpler, More Flexible, Code
% |rng| allows you to either
%
% * reseed the random number generator, or
% * save and restore random number generator settings
%
% without having to know what type it is.  You can also return the random
% number generator to its default settings without having to know what those
% settings are.  While there are situations when you might _want_ to specify a
% generator type, |rng| affords you the simplicity of not _having_ to specify
% it.
%
% If you are able to avoid specifying a generator type, your code will
% automatically adapt to cases where a different generator needs to be used,
% and will automatically benefit from improved properties in a new default
% random number generator type.


%% Legacy Mode and |rng|
% In versions of MATLAB prior to 7.7, you controlled the internal state of the
% random number generator by calling |rand| or |randn| directly with the
% 'seed', 'state', or 'twister' inputs.  For example, 
rand('state',1234)
%%
% That syntax is not recommended, and switches MATLAB into "legacy random
% number mode", where |rand| and |randn| use separate and out of date
% generators, behaving as they did prior to MATLAB 7.7.  If possible, you
% should update any existing code that uses the old syntax to use |rng|
% instead.  To do that, it may take some thought to determine the true intent
% of the old code; see
% <matlab:helpview([docroot,'/matlab/math/updating-your-random-number-generator-syntax.html']) 
% Updating Your Random Number Generator Syntax> in the User Guide for
% suggestions and examples.
%
% If you, or some code you've run, have executed a command such as
% |rand('state',1234)| that puts MATLAB into legacy mode, you can use
rng default
%%
% to escape from legacy mode and get back to the default startup generator.
% If there is code that you are not able or not permitted to modify, you can
% guard around that old code using:
s = rng; % save current settings of the generator

% call code using legacy random number generator syntaxes

rng(s) % restore previous settings of the generator
%%
% to make sure that no other code uses the legacy random number generators.


%% |rng| and |RandStream|
% |rng| provides a convenient way to control random number generation in
% MATLAB for the most common needs.  However, more complicated situations
% involving multiple random number streams and parallel random number
% generation require a more complicated tool.  The |RandStream| class is that
% tool, and it provides the most powerful way to control random number
% generation. The two tools are complementary, with |rng| providing a much
% simpler and concise syntax that is built on top of the flexibility of
% |RandStream|.


displayEndOfDemoMessage(mfilename)