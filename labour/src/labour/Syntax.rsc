module labour::Syntax

/*
 * Define a concrete syntax for LaBouR. The language's specification is available in the PDF (Section 2)
 */

/*
 * Note, the Server expects the language base to be called BoulderingWall.
 * You are free to change this name, but if you do so, make sure to change everywhere else to make sure the
 * plugin works accordingly.
 */

layout Layout = Whitespace;
lexical Whitespace = [\t\n\r\ ];

lexical IntLiteral = [0-9]+;
lexical Id = [A-Za-z0-9_]+;
lexical StringLiteral = "\"" ![\"]* "\"";

// Keywords to avoid conflicts with identifiers
keyword Keywords = "bouldering_wall" | "volumes" | "routes"
  | "circle" | "rectangle" | "polygon"
  | "pos" | "depth" | "radius" | "width" | "height"
  | "hold" | "shape" | "colours" | "rotation"
  | "start_hold" | "end_hold"
  | "bouldering_route" | "grade" | "grid_base_point";

// Start symbol
start syntax BoulderingWall =
  "bouldering_wall" StringLiteral "{" WallContent "}"
;

syntax WallContent =
  "volumes" "[" VolumeList "]" "," "routes" "[" RouteList "]"
;

syntax VolumeList =
  Volume ("," Volume)*
;

syntax RouteList =
  BoulderingRoute ("," BoulderingRoute)*
;

// Volume variants
syntax Volume =
    CircleVolume
  | RectangleVolume
  | PolygonVolume
;

syntax CircleVolume =
  "circle" "{" "pos" Pos "," "depth" ":" IntLiteral "," "radius" ":" IntLiteral "}"
;

syntax RectangleVolume =
  "rectangle" "{" "pos" Pos "," "depth" ":" IntLiteral "," "width" ":" IntLiteral "," "height" ":" IntLiteral "," "holds" "[" HoldList "]" "}"
;

syntax PolygonVolume =
  "polygon" "{" "pos" Pos "," "faces" "[" FaceList "]" "}"
;

syntax FaceList =
  Face ("," Face)*
;

syntax Face =
  "face" "{" "vertices" "[" VertexList "]" HoldSection? "}"
;

syntax HoldSection =
  "," "holds" "[" HoldList "]"
;

syntax VertexList =
  Vertex ("," Vertex)*
;

syntax Vertex =
  "{" "x" ":" IntLiteral "," "y" ":" IntLiteral "," "z" ":" IntLiteral "}"
;

// Hold list and structure
syntax HoldList =
  Hold ("," Hold)*
;

syntax Hold =
  "hold" StringLiteral "{" HoldPropList "}"
;

syntax HoldPropList =
  HoldProp ("," HoldProp)*
;

syntax HoldProp =
    "pos" Pos
  | "shape" ":" StringLiteral
  | "colours" "[" ColourList "]"
  | "rotation" ":" IntLiteral
  | "start_hold" ":" IntLiteral
  | "end_hold"
;

syntax ColourList =
  Colour ("," Colour)*
;

syntax Colour =
  "red" | "blue" | "green" | "black" | "white" | "yellow" | "orange" | "purple" | "pink"
;

// Position block reused
syntax Pos =
  "{" "x" ":" IntLiteral "," "y" ":" IntLiteral "}"
;

// Route structure
syntax BoulderingRoute =
  "bouldering_route" StringLiteral "{" RouteContent "}"
;

syntax RouteContent =
  "grade" ":" StringLiteral "," "grid_base_point" Pos "," "holds" "[" HoldIdList "]"
;

syntax HoldIdList =
  StringLiteral ("," StringLiteral)*
;

