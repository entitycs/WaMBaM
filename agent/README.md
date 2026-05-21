# Agent Created or Agent Based

## The following resources were created or based on output from the following AI models/agents: Copilot, GLM

## copilot/

Resources created or based on output from Microsoft Copilot

### copilot/shockwave.lua

I asked Copilot for an example of "particle effects" and for an example of a love2d shader. Bugfixed the returned examples (outdated), to transition from seeing black circles, to black boxes, and finally, to a local test image.  Still subject to change, the file represents the current state after updates to the original agent output from multiple back-and-forths.

### copilot/menushader.lua

After (partial) success generating the shockwave shader, decided to give copilot another assignment - generate a simple desaturation + shrink shader. Took a bit of tweaking, updates, and removal of logical errors to get working; works for its current purposes. See agent/copiloat/desatmini.glsl for current version. 

### copilot/desatmini.glsl

A simple, fast, desaturation + shrink shader, written by copilot. Implemented as generated, without shrink effect, which was implemented in containing lua file as shader is loaded/unloaded.

### copilot/images/

When ready to transition from black boxes to transparent shapes, I asked copilot to produce images for temporary use, acting as placeholders for "WaM!" and "BaM!" collision signifiers/indicators. Used to enable, test, and debug png image usage. Some copilot generated images may still live in root.

## glm/

Resources created or based on output from GLM-4.7-flash (run locally)

### glm/rotvis.lua

A simple script adding a line to rotating circle shapes.  After review, the generated load method + code was unnecessary + adding mass, and was eventually removed manually.

## Build

a `build.sh` script is provided in the root level for building release binaries for Windows & Linux. Build script output can be found in the `release` folder. (copilot)

