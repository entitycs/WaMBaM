# WaMBaM

(ty ma'am)

## Made with Love2D

## Build

a `build.sh` script is provided for building release binaries for Windows & Linux. Build script output can be found in the `release` folder.

## Basic Controls

### Current Controls (WIP)

#### Input Diagram

```mermaid
---
config:
    theme: Neutral
---
flowchart LR

    R((RearWheel))
    F((Front Wheel))
    R ---|non-colliding joint| F

    subgraph LS["Left Stick / Keyboard Arrows"]
        AxisX
        AxisY
    end

    subgraph RS["Right Stick"]
        AxisY2[AxisY]
    end

    LS ---> Force
    Force --> R

    AxisY2[AxisY] --- RS --> Torque --> F
```

#### Input Table

| Input | Action |
| ----- | ------: |
| Controller | |
| left stick | apply `force` through `rear 'wheel'` |
| right stick | apply `torque` through `front 'wheel'` |
| right trigger | apply `brake` through `front 'wheel'` |
| left trigger | increase `force` through `rear 'wheel'` |
| Keyboard | |
| directional keys | apply `force` through `rear 'wheel'` |

More is planned, but feel free to attempt mastering these basic controls while the remaining mechanics and mappings are completed. Have fun and good luck!

## Goals

Also still in production are the `goals`. The goal of the game is to win by scoring more goals than the opponent. The `goals` are to be offset from the floor, and to be unscorable from below; otherwise, the design(s) is/are in progress. Candidate designs include:

- `Buckets` - eg. the game plays a bit like "hoops".
- `Narrow Openings` - eg. the game plays like "aerial hockey".
- `Buttons` - eg. the goals are large, thin, reactionary, with points scored based on hit force (and no ball reset).
  
Most players will need to either get lucky enough to score, or will need to learn enough mechanics to get the `ball` off of the floor and into their opponent's goal consistently. Your approach to get the ball off of the floor and into the goal will be up to you. How your opponents approach the same task will likely differ. Perhaps you can learn from one another.

## Basic Mechanics

Noting that this is a minimal set of bits of knowledge, take note of the following:

1. You'll not be able to get airborne using input from a single stick. Well, perhaps you can, but not easily, from a standstill.  
2. Applying Forces to one wheel will affect your ability to apply forces through the other wheel. Of course, you can and are meant to use both inputs to maneuver, but to have full control, you'll want to study and experiment some.
3. Full control is not meant to really be achievable. At least at some points, your movement through the arena can only be described as "Que sera, sera" until you hit a wall, or the floor, or get lucky in getting reorientated.

### Current Named Mechanics List

(subject to change)

| Img | Name | Description |
| --- | ---- | --------- |
| ![Carry example gif](docs/images/carry.gif) | Carry | Place the ball above the WaM'er and lift it off of the ground, balancing as the ball keeps steady contact with the WaM'er (rear 'wheel') |
| ![WaM example gif](docs/images/WaM.gif) | WaM | Hit the ball with sufficient force using the rear 'wheel' |
| ![BaM example gif](docs/images/BaM.gif) | BaM | Hit the ball with sufficient force using the front 'wheel' |
| ![Carry WaMBaM example gif](docs/images/WaMBaM.gif) | WaMBaM | Transition from Carrying or from a WaM into a BaM |

## TODOs

### Kanban

```mermaid
---
config:
  theme: 'forest'
---
kanban
  core[Core Todo]
    ct[Goal Design / Placement]
    ct[Points System / Scoring]
    ct[Level Customization / Progression]
  graphics[Graphics Todo]
    sc[Collision Signifiers ~basic~]
    sc[Collision Signifiers ~image/advanced~]
  physics[PhysicsTodo]
  q[In progress]
    tg[Torque Increaser]@{ticket: TI00,  priority: 'High'}
    tg[Torque Limiter]@{ticket: TL00,  priority: 'High'}
    id6[Explain Concepts in README]
  id9[VideoDoc - In Progress]
  id10[Ready for test]
    vl[Velocity Limiter]@{ticket: VL00, priority: 'High'}

    tg[Torque Break]@{ticket: TB00,  priority: 'Very High'}
    id4[Challenge Others to Perform Mechanics]@{ ticket: 2038, assigned: 'entitycs', priority: 'High' }
  id11[Done]
    id8[Record Basic Mechanics] 
    id5[Define base character abilities]
    id2[POC World + Demo]
```

### Controls (basic)

| Kanban Code | Description | Priority |
| ------ | ------------- | ---------- |
| FTB00 | Force/Torque Brake: An input which brings  velocity to a stop over time | `Highest` |
| TI00 | Torque Increaser: An input which increases the torque applied on the front wheel | `Medium` |
| TL00 | Torque Limiter: Internal default torque limit when no Increaser input is given | `High` |
| FTB00 | Torque/Force Breaking (per handle) | `High` |

### Interaction Signifiers

todo: some/any kind of pixel filter applied based on visuals/interactions

| Kanban Code | Description | Priority |
| ------ | ------------- | ---------- |
| ISB00 | Backdrop: Planned `'arena'` backdrops are local street art (credited placeholders until then) | `Highest` |
| ISI00 | WaMBaM Interactions: Graffiti-like WaM / BaM for respective colliders (rear/front) | `Medium` |
| ISS00 | Signifier for when player breaks the 'proposed speed / torque limits' | `Low` |

## Files

```mermaid
---
config:
    treeView:
        rowIndent: 30
        lineThickness: 1
        paddingX: 1
        paddingY: 1
    themeVariables:
        treeView:
            labelFontSize: '20px'
            labelColor: '#e05a5a'
            lineColor: '#2c8b2c'
---
treeView-beta
    "agent/"
      "copilot/"
        "docs/images/"
          "shockwave.png"
          "shockwave2.png"
        "shockwave.lua"
      "glm"
        "rotvis.lua"
    "backdrops/"
      "maxresdefault.jpg"
    "core/"
      "arena.lua"
      "ball.lua"
      "goal.lua"
      "joystick.lua"
      "ratios.lua"
    "current/"
      "arena.lua"
      "goals.lua"
    "release/"
    "build.sh"
    "main.lua"
    "README.md"
```

### README.md

- `you are`***`here`***

### main.lua

- Main script
  - All game logic leads from here.
  - Gets required tables / types.
  - Defines main callbacks.
  - Calls load, update, and/or draw methods of instantiated or referenced objects.
  
### build.sh

- Build from linux / wsl
  - Produces .exe and .love executables.
  - Attempts to copy windows dlls from `c:/Program Files/LOVE/`
    - Alternatively, copy them manually from your local install location to the `release/` folder.

### release/

- ==Build script target location==.
  
### core/

- ==Holds files handling core, static settings / setup==.

#### core/arena.lua

- Sets up the core arena items, which might include goals, floor, walls, etc.
  
> &nbsp;
> **Arena** (the same as many other returned objects) is returned with callable **`load`**, **`update`**, and **`draw`** methods, meant to coincide with the global lifecycle.
>
> ```mermaid
> flowchart LR
>   subgraph M[main.lua]
>     load
>     update
>     draw
>   end
>   subgraph J["core/arena.lua"]
>     subgraph J1["Arena"]
>     load1["load"]
>     update1["update"]
>     draw1["draw"]
>     end
>   end
>   J1 -->|= require| M
>   load --> load1
>   update --> update1
>   draw --> draw1
> ```
>
> *Expected arguments may differ*
> &nbsp;

==Note==: The same require | mirror-lifecycle pattern is used for `JoystickInput`, `Ball`, `Arena`, `CurrentArena` (current/arena.lua) and `any new 'objects' added going forward` where applicable.  I will refrain from posting the same diagram with different names, and slim down class diagrams in the same spirit.

```mermaid
classDiagram
  class Arena {
    top
    floor
    left
    right
    ...
    +load(window, world)
    +draw()
    ...(tbd)
  }
```

#### core/ball.lua

- Handles creation, updates, display, and other core behavior for the ball.
  
```mermaid
classDiagram
  class Ball {
    -RotVis BallRotVis
    +drop(xPos, yPos)
    +load(window, world, radius)
    +update(dt)
    +draw()
    ...(tbd)
  }
```

#### core/contact.lua

- Handles world collisions 
- Pub/Sub pattern allowing for adding/removing callbacks
  - implemented for `begin` callback only initially.
  - other callbacks will be implemented here if necessary, alongside the `begin` table.

```mermaid
classDiagram
  class ContactHandler {
    +new(world)
    -beginContact(fixtureA, fixtureB, contact)
    +addBegin(nameFixtureA, nameFixtureB, handler)
    +removeBegin(handler)
    ...(tbd)
  }
```

#### core/goal.lua

- Defines a default Goal type

```mermaid
classDiagram
  class Goal {
    +new(world, ballSize, posX, posY, flip)
    +load(scoreGroup)
    +update(dt)
    +draw()
    ...(tbd)
  }
```

#### core/joystick.lua

- Handles setup, updates, and drawing related to joystick input.

```mermaid
classDiagram
  class JoystickInput {
    lambda: love.gamepadpressed
    lambda: love.joystickadded
    +load()
    +update(dt, rear, front)
    +draw()
    ...(tbd)
  }
```

#### core/ratios.lua

- Used to provide relative values for influenced physics/geometry constraints.
- Provides functions taking taking values from the base control; `rear 'wheel'` as input, and yielding relative values for related components.
  - eg., changing `'wheel' size` should change `ball size` such that `carrying` and other mechanics resume working as expected / required.
  
> &nbsp;
> **Ratio** Class
>
>```mermaid
>classDiagram
>  class Ratios{
>    +BallSize(rearWheelSize)
>    +FrontWheelMass(rearWheelMass)
>    +FrontWheelGravityScale(rearWheelGravityScale)
>    +FrontWheelTorque(rearWheelForce)
>    ...(tbd)
>  }
>```
>
> &nbsp;
> **Ratio** input/output flow
>
> ```mermaid
> flowchart LR
>   subgraph M["main.lua"]
>     R["`**rear**`"]
>     F["`**front**`"]
>     B["`**ball**`"]
>   end
>   C@{ shape: docs, label: "core/ratios.lua"}
>   R -->|physics, geometry| C -->|physics, geometry| F & B
> ```

### current/

- Holds logic concerned with the current game / round ==**(volatile)**==.

#### current/arena.lua

- Loads the arena background / other temporary arena settings
  
#### current/goals.lua

- Loads and places initial goal examples (eg. the high difficulty default)
  
> &nbsp;
> ***Image**: ball sitting in red goal with white edges*
>
> ![high difficulty goal example](docs/images/goal-high-difficulty.png)
>

- Alternatively, custom / other goal types are planned.

#### lib/

- ==Third Party Libraries==

#### agent/

- ==Resources (code, images, etc.) created with the help of AI, per model/service.  See `README` files per folder for more details==.
  
## Credits

- `todo`
  
### Further Acknowledgements

`Dedicated to the LOML`
