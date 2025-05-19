module labour::AST

/*
 * Define the Abstract Syntax for LaBouR
 * - Hint: make sure there is an almost one-to-one correspondence with the grammar in Syntax.rsc
 */

// Basic type: 2D position (used in holds and volumes)
data Pos = pos(int x, int y);

// 3D vertex (used in polygonal faces)
data Vertex = vertex(int x, int y, int z);

// Triangle face defined by three vertices and optional holds
data Face = face(list[Vertex] vertices, list[Hold] holds);

// Colour alias; could be refined as a data type if needed
alias Colour = str;

// Bouldering hold definition
data Hold = hold(
  str id,                      // Four-digit hold identifier
  Pos pos,                     // Position relative to the base grid
  str shape,                   // Shape ID (e.g., "52")
  list[Colour] colours,        // One or more colours
  int rotation,               // Optional rotation angle (0–359)
  int startHold,              // Optional start hold (1 or 2)
  bool isEnd                   // Whether this is an end hold
);

// Wall volumes: can be circular, rectangular, or polygonal
data Volume =
    circle(Pos pos, int depth, int radius)
  | rectangle(Pos pos, int depth, int width, int height, list[Hold] holds)
  | polygon(Pos pos, list[Face] faces);

// Route definition with metadata and hold references
data BoulderingRoute = bouldering_route(
  str id,                      // Unique route identifier
  str grade,                   // Route grade (e.g., "5A")
  Pos gridBasePoint,          // Starting reference point
  list[str] holdRefs          // IDs of holds used in the route
);

// Top-level wall structure
data BoulderingWall = bouldering_wall(
  str id,                       // Wall identifier
  list[Volume] volumes,         // All defined volumes
  list[BoulderingRoute] routes  // All defined routes
);
