# Painter

This library contains a basis for making drawing programs that use bitmap images. In practice it could adapt to tilemap editing, basic pathfinding, and procedural images.

# Painter.hx

This is the central point of the Painter library. It ties together the functionality of the underlying algorithms into a program containing tool state and some defaults. In practical uses, you should call into it from your UI, and swap out its default programs with your own.

The basic workflow of the Painter class is:

1. **Construct a new PaintState**(or reuse a previous one), configuring it with the program, position, etc.
2. As you recieve input, **mutate the PaintState**, and then pass it into **Painter.update()**.
3. **Painter's state mutates** to contain the results.
4. **Copy** the relevant data into your UI, transforming it as necessary to fit your toolkit or framework.

## Fields

**canvas** represents the image being worked on. 

**result** and **preview** are DrawVector objects, containing position and color data. The **result** is the points that were committed to the canvas in this update, and the **preview** is the points used to draw a preview of the tool. For example, if I am dragging out a box shape, the thing being drawn before I release the mouse button is viewed through preview, but the shape that is returned at release time is the result.

**complete** and **sync_canvas** give additional info about the tool program: **complete** indicates whether the program has finished. **sync_canvas** indicates whether the UI should copy the canvas data from Painter to the display.

## Default Programs

To customize Painter, selecting appropriate tool programs is important. The source file contains a defaultPrograms(), which returns an array of PaintProgram. PaintProgram is used when you construct your PaintState for the tool. Study the programs to find out which ones you need.

# PaintState.hx

This is the object constructed and fed into a Painter instance to represent the state of a tool program as the user sends input to that tool(click and drag, pressing buttons, etc). This structure has to represent various kinds of data, and so its fields are mostly defined "by convention", with an escape hatch in the Dynamic **tooldata** field.

**x** and **y** coordinates are used to represent a plotting position.

**button** represents what buttons have been pressed.

**brush** contains a DrawVector object that the program may repeatedly draw to represent, for example, brush thickness. (Note, the naive method of doing this doesn't scale up well to large brushes.)

**program** contains the PaintProgram being worked on. A PaintProgram is simply a function with signature Painter->PaintState->Bool. The Bool value returns true when the program is finished, causing Painter to automatically run a cleanup routine.

# DrawVector.hx

DrawVector is relatively simple: it contains points stored in a single Vector\<Int\>, packed as triplets of x, y, color. The "color" is just a plain old Int value and can contain anything.

# DrawCanvas.hx

DrawCanvas is a simple canvas stored as a 1-dimensional Vector\<Int\>, with a meaty API for various kinds of transformations. The transformations mutate the canvas in place for efficiency purposes; remember to copy() when using DrawCanvas API calls as an intermediate.