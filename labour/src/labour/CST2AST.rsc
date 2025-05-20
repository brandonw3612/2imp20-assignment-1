module labour::CST2AST

// This provides println which can be handy during debugging.
import IO;

// These provide useful functions such as toInt, keep those in mind.
import Prelude;
import String;

import labour::AST;
import labour::Syntax;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 * Hint: Use switch to do case distinction with concrete patterns
 * Map regular CST arguments (e.g., *, +, ?) to lists
 * Map lexical nodes to Rascal primitive types (bool, int, str)
 */

/**  
 * Convert a parsed BoulderingWall CST into an AST.  
 */
public BoulderingWall cst2ast(tree cst) = visit(cst) {
  case appl(prod("BoulderingWall", _), [_, StringLiteral(id), _, wallContent, _]):
    return bouldering_wall(
      id,
      cst2astWallVolumes(wallContent),
      cst2astWallRoutes(wallContent)
    );
};

/** Extract all Volume ASTs from a WallContent node */
list[Volume] cst2astWallVolumes(tree wc) = visit(wc) {
  // matches: "volumes" "[" VolumeList "]" ... 
  case appl(prod("WallContent", _), [_, _, volList, *rest]):
    return [ cst2astVolume(v) | v <- children(volList), !isComma(v) ];
};

/** Extract all BoulderingRoute ASTs from a WallContent node */
list[BoulderingRoute] cst2astWallRoutes(tree wc) = visit(wc) {
  // matches: ... "routes" "[" RouteList "]"
  case appl(prod("WallContent", _), [*rest, routeList, _]):
    retuen [ cst2astRoute(r) | r <- children(routeList), !isComma(v) ];
};

/** Convert one Volume CST node into AST */
Volume cst2astVolume(tree v) = visit(v) {
  // circle { pos Pos , depth: D , radius: R }
  case appl(prod("CircleVolume", _), [_, _, _, posT, _, _, _, depthT, _, _, _, radiusT, _]):
    return circle(
      cst2astPos(posT),
      toInt(depthT),
      toInt(radiusT)
    );

  // rectangle { pos Pos , depth: D , width: W , height: H , holds [H*] }
  case appl(prod("RectangleVolume", _), [_, _, _, posT, _, _, _, depthT, _, _, _, widthT, _, _, _, heightT, _, _, _, holdsList, *]):
    return rectangle(
      cst2astPos(posT),
      toInt(depthT),
      toInt(widthT),
      toInt(heightT),
      [ cst2astHold(h) | h <- children(holdsList), !isComma(v) ]
    );

  // polygon { pos Pos , faces [F*] }
  case appl(prod("PolygonVolume", _), [_, _, _, posT, _, _, _, faceList, *]):
    return polygon(
      cst2astPos(posT),
      [ cst2astFace(f) | f <- children(faceList), !isComma(v) ]
    );
};

/** Convert one Face CST node into AST */
Face cst2astFace(tree f) = visit(f) {
  // face { vertices [V*] ( , holds [H*] )? }
  case appl(prod("Face", _), [_, _, _, _, verticesList, _, *tail]):
    list[Vertex] vs = [ cst2astVertex(vx) | vx <- children(verticesList), !isComma(v) ];
    list[Hold] hs =
      if (size(tail) == 1) []
      else {
        tree holdListNode = tail[3];
        [ cst2astHold(h) | h <- children(holdListNode), !isComma(h) ];
      }
    return face(vs, hs);
};

/** Convert one Vertex CST node into AST */
Vertex cst2astVertex(tree vx) = visit(vx) {
  // { x: X , y: Y , z: Z }
  case appl(prod("Vertex", _), [_, _, _, xT, _, _, _, yT, _, _, _, zT, _]):
    return vertex(toInt(xT), toInt(yT), toInt(zT));
};

/** Convert one Hold CST node into AST */
Hold cst2astHold(tree h) = visit(h) {
  // hold "ID" { HoldProp* }
  case appl(prod("Hold", _), [_, StringLiteral(id), _, propsList, _]):
    list[tree] raw = [ n | n <- children(propsList), !isComma(n) ];
    Pos p = cst2astPos(children(raw[0])[1]);          // pos { ... }
    str shape = toStr(children(raw[1])[2]);               // shape : "..."
    tree colourTree = getChildByLabel(props, "colours", 2);
    list[Colour] colours =
      [ toStr(c)
      | c <- children(colourTree),
        c := lex(_)            
      ];  // colours [ ... ]
    int rotation =
      exists(pRot <- props | extractLabel(pRot) == "rotation")
      ? toInt(getChildByLabel(props, "rotation", 2))
      : 0;
    int startH =
      exists(pSt <- props | extractLabel(pSt) == "start_hold")
      ? toInt(getChildByLabel(props, "start_hold", 2))
      : 0;
    bool isEnd = exists(pEnd <- props | extractLabel(pEnd) == "end_hold");
    return hold(id, p, shape, colours, rotation, startH, isEnd);
};

/** Convert one Pos CST node into AST */
Pos cst2astPos(tree p) = visit(p) {
  // { x: X , y: Y }
  case appl(prod("Pos", _), [_, _, _, xT, _, _, _, yT, _]):
    return pos(toInt(xT), toInt(yT));
};

/** Convert one BoulderingRoute CST node into AST */
BoulderingRoute cst2astRoute(tree r) = visit(r) {
  // bouldering_route "ID" { grade: G , grid_base_point Pos , holds [IDs] }
  case appl(prod("BoulderingRoute", _), [_, StringLiteral(id), _, content, _]):
    // TODO: Index handling unimplemented
    list[tree] fields = children(content);
    str grade    = toStr(fields[0][1]);
    Pos base     = cst2astPos(fields[1][1]);
    list[str] hs  = [ toStr(lit) | lit <- children(fields[2][2]) ];
    return bouldering_route(id, grade, base, hs);
};

/** Helpers **/

// Convert IntLiteral tree to int
int toInt(tree t) = readInt(lexeme(t));

// Convert StringLiteral tree to str (strip quotes)
str toStr(tree t) = lexeme(t)[1..size(lexeme(t))-2];

// Extract the production label of an 'appl' node
str extractLabel(tree t) = switch (t) {
  case appl(prod(lbl,_),_): lbl;
};

// Find the i-th child of the first subtree whose production label matches
tree getChildByLabel(list[tree] ps, str lbl, int idx) =
  head([ children(sub)[idx] | sub <- ps, extractLabel(sub)==lbl ]);

// Determine if a node is a comma
bool isComma(tree t) = switch (t) { case lit(","): true; default: false; };