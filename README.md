# barchart-race
I decided to try my hand at making one of the increasingly popular bar chart race plots. And since I work in government consulting, I of course decided to give it a government flavor. I give you budget outlays by year and department.

Let the race begin!

![alt text](https://github.com/corydonbaylor/barchart-race/blob/master/final.gif?raw=true)

So how does this work?

This is all done in R using this wonderful package called “gganimate”. Basically what this package lets you make gifs out of ggplots!

First lets start with the type of data that is needed for gganimate:

| Time | Department | Budget |
|------|------------|--------|
| 2018 | DoD        | 105    |
| 2017 | DoD        | 100    |
| 2018 | SSA        | 55     |
| 2017 | SSA        | 50     |

How gganimate works is that the user to designate a variable as the “transition variable”. The packages then splits the plot data up into different states by the transition variable and animates transitions between those states. 

So for this example, if you pick the “Time” variable, each frame in the gif will the source data filtered down to one year. The first frame will be a bar graph for just 2017, the second frame will be a bar graph for just 2018, and so on and on. Basically, you are creating hundreds of plots and showing one at a time to create a movie.

Here is what the above gif would look like if all the frames were shown at once:

![](https://github.com/corydonbaylor/barchart-race/blob/master/all-together.jpg)

On top of cutting the plot data by time and showing them in sequence, gganimate also interpolates what should be between each plot. This allows you to create gifs with limited amount of data and smooths the animation between data points. As such, frames come in two flavors in gganimate: state and transitional. State frames are data points explicitly provided by the user. Transitional frames are interpolated data points between state frames. Using the above example, here is what is happening:

| Time | Department | Budget | Frame Type |
|------|------------|--------|------------|
| 2018 | DoD        | 105    | State |
| 2017.5 | DoD        | 103    | Transitional |
| 2017 | DoD        | 100    | State |
| 2018 | SSA        | 55     | State |
| 2017.5 | SSA        | 53     | Transitional |
| 2017 | SSA        | 50     | State |

There would be three frames for this animation. Two state frames (2017 and 2018) and one transitional frame (2017.5). Realistically, there would be a lot more transitional frames between the two state frames to create a smooth animation. You can even specify the ratio between state frames and transition frames and how many frames the gif should be made up of! Playing around with these setting allows you to control how smooth the animation is and how long it “rests” on a state frame. 

For my gif, I specified there should be 4 times as many transitional frames as state frames, 500 frames overall, and it should run at 15 frames per second. More overall frames means more transition frames and thus better animations between states, but it also greatly increases the time to render. This animation took about 2 minutes to render—which was a real pain to debug. In fact, when I was debugging, I set the total frames to 10, so that I didn’t spend a ton of time looking at a loading screen when changing the plot around.

There is one more important concept to go over: object permanence. Like a new born baby, gganimate does not have object permanence built in. You need to be explicit about what objects in the plot can be animated. Lets say that you picked “Department” instead of “Time”, then gganimate would morph the value of SSA into DoD. 

| Time | Department | Budget | Frame Type |
|------|------------|--------|------------|
| 2018 | DoD        | 105    | State |
| 2018 | DoD        | 100    | State |
| 2018 | SSA + DoD        | 80    | Transitional |
| 2017 | SSA + DoD       | 65     | Transitional |
| 2017 | SSA        | 55     | State |
| 2017 | SSA        | 50     | State |

The values of 80 and 65 don’t really mean anything because the Department of Defense and the Social Security Administration are permanent objects. They cannot morph into each other—at least in the context of a sensible graphic. We need to be explicit about what objects can be animated and which cannot or else we will get some strange behavior in our gifs. Follow the link for gganimate for more info. 

A lot went into making this plot, most of which is particular to this plot rather than something that most people would be interested in for their own animations. Check out the code for how this particular gif was made. Its well commented so it can serve as a bit of template for making things like this in the future—whether for clients or for fun! 
