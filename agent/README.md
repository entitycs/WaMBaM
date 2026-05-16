# Agent Created or Agent Based

## The following resources were created or based on output from the following AI models/agents: Copilot, GLM

## copilot/

Resources created or based on output from Microsoft Copilot

### copilot/shockwave.lua

I asked Copilot for an example of "particle effects" and for an example of a love shader. Bugfixed the returned examples (outdated), to transition from seeing black circles, to black boxes, and finally, to a local test image.  Still subject to change, the file represents the current state after updates to the original agent output from multiple back-and-forths.

### copilot/images/

When ready to transition from black boxes to transparent shapes, I asked copilot to produce images for temporary use, acting as placeholders for "WaM!" and "BaM!" collision signifiers/indicators. Used to enable, test, and debug png image usage.

## glm/

Resources created or based on output from GLM-4.7-flash (run locally)

### glm/rotvis.lua

A simple script adding a line to rotating circle shapes.  After review, the generated load method + code was unnecessary + adding mass, and was eventually removed manually.

## Build

a `build.sh` script is provided in the root level for building release binaries for Windows & Linux. Build script output can be found in the `release` folder. (copilot)
