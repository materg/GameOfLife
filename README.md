GameOfLife
==========
![Screenshot](http://i.imgur.com/p39DHak.png)
A simple implementation of Conway's Game of Life in Delphi.  
**Feel free to suggest changes**, this is just a small thing I wanted to do in my free time :)

Some technical info
-------------------
Code was written in and first compiled under Delhpi XE5, although I don't think I used any of the "new" features, so hopefully it should compile fine on any of the newer versions too. 

What is the "finite-grid problem"?
----------------------------------
Conway assumed that the "playing"-board was infinite. We can't really do that, and basically there are two common ways of dealing with that issue.  
One is to assume that all the cells outside of the board are empty - this is the "*Empty-cell solution*".  
The other is to connnect the left edge of the board to the right and then connect the two bases of our newly formed cylinder (well, it's actually not a cylinder, because there is no face on where the base should be, but you get the point). This creates a torus  - hence the name "*Toroidal-grid solution*".  

*Fun-fact*: it's actually impossible to create a torus from a plane that has the same surface area, unless we want to get the horrible mess which is a degenerated torus - a [horn torus](http://en.wikipedia.org/wiki/Torus#mediaviewer/File:Standard_torus-horn.png). The point in the middle has quite interesting properties then, but that's a topic that I don't want to discuss here. For our purposes, the stretch doesn't matter, since we rely only on the neighbours count and not the area ;)

To-Do List
----------
- Add support for different rulesets (e.g. HighLife)
- Solve the "board is bigger than the image" problem - zooming or something similar
- Hence, different cell sizes than 1px
- Visual stuff (color picker, etc.)
- Support for drawing own patterns or loading/saving presets
- Perhaps add HashLife?

Credits
-------
Icons used in the project are from the [Farm-Fresh Web Icons](http://www.fatcow.com/free-icons) set from fatcow.com.  
(Hopefully) upcoming contributors will be credited here as well...
