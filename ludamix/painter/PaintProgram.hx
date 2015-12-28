package ludamix.painter;

/* A PaintProgram describes an instance of a tool. 
 The program spawns alongside a new instance of tool state, contained in (Painter.paint).
 The tool manages updates in the second state instance passed in, which represents changes in user input.
 PaintProgram writes output either to (Painter.result) or (Painter.preview).
 When the program has finished rendering, it returns true. When it needs to continue into the next frame, it returns false.
 A typical pattern is to write to preview as long as button_down is true, and then write to result at the end.
 */
typedef PaintProgram = Painter->PaintState->Bool;
