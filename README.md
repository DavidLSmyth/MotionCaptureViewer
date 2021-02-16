# Shiny Mocap DB viewer
This mocap db viewer is designed to allow convenient searching and batch downloading of animation files. This is convenient for a range of uses, for example selecting animations to be used to train a pose estimation model. Currently only supports downloading fbx files. The program was hacked together as a shiny app. 

## Usage
You'll first need to populate motionDB.csv with the mocap files in /Database. The mocap files in /Database should be in both fbx and bvh format to be displayed (use blender if one is missing). For example, the below image shows the use of the CMU mocap database and some mixamo animations, with corresponding entries in motionDB.csv. 

![MotionDB screenshot](/MotionDBScreenshot.JPG)

Once your database is populated and motionDB.csv has the relevant metadata, the server can be started as follows:

Check the run_docker file so that the absolute path in the volume argument points to this repo. (use $(pwd) on linux, %cd% in windows). Using a mounted drive causes issues on windows but seems to work on linux.

On windows run 
```
./build_docker.bat
./run_docker.bat
```
On Linux, run
```
./build_docker.sh
./run_docker.sh
```

Then open a browser to point to localhost:3838. You should then be able to use the viewer as shown in the gif:
![Demo GIF](/MocapDBDemoGif.gif)

## Suggested Motion Capture Resources
We suggest looking at the following resources

1. https://animationsinstitut.de/de/forschung/projects/sauce/terms-of-use-phs-motion-library 
2. https://www.mixamo.com
3. https://sites.google.com/a/cgspeed.com/cgspeed/motion-capture/cmu-bvh-conversion

We provide some sample CMU assets in accordance with the notice of permission given on their website: http://mocap.cs.cmu.edu/faqs.php

## Future work
I plan on integrating this with a mocap retargeting pipeline to generate synthetic data for a range of uses.

## Credits 
The player itself is based on the https://github.com/lo-th/olympe repo.