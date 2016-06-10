Why D?
------
Because Rayman 2 does very much math using pointers. Doing SNA parsing in C# or any other VM-based language would be pain.

I don't know D
--------------
Then you should learn. If you know C/C++ it shouldn't be hard for you. I will be trying to make code as readable as possible, so even, if you know very little about programming, you should understand what my code does.
Also, you don't have to send any pull requests. If you have any information that could help me with reverse engineering Rayman, you can create an issue.

How to build?
-------------
This project uses [DUB](http://code.dlang.org/getting_started) build system. If you installed [DUB](http://code.dlang.org/getting_started) and [DMD](https://dlang.org/download.html), go to the sub-folder with project and just simply open command prompt and enter:
```
dub run
```