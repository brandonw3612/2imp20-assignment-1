module labour::Server

import IO;
import String;
import ParseTree;

import util::IDEServices;
import util::LanguageServer;

import labour::Syntax;

// A minimal implementation of a DSL in rascal
// users can add support for more advanced features
// More information about language servers can be found here:
// - https://www.rascal-mpl.org/docs/Packages/RascalLsp/API/util/LanguageServer/#util-LanguageServer-Summary
// - https://www.rascal-mpl.org/docs/Packages/RascalLsp/API/demo/lang/pico/LanguageServer/#demo-lang-pico-LanguageServer-picoExecutionService
set[LanguageService] contributions() = {
  parsing(parser(#start[BoulderingRoute]), usesSpecialCaseHighlighting = false),
  documentSymbol(labourOutliner)
};

str unquote(value val)
  = replaceAll("<val>", "\"", "");

// =========================================================================
// Outliner
str setHoldLabel(Hold hold) {
  str shapeStr = "";
  str rotationStr = "";

  for (/HoldComponents c := hold) {
    switch (c) {
      case (HoldComponents)`shape: <String arg>`: shapeStr = unquote(arg);
      case (HoldComponents)`rotation: <Integer arg>`: rotationStr = "<arg>";
    }
  }

  return "Hold"
    + (shapeStr != "" ? " <shapeStr>" : "")
    + (rotationStr != "" ? " - <rotationStr>" : "");
}

str setVolumeLabel(Volume volume) {
  switch (volume) {
    case (Volume)`circle { <{CircleComponents ","}+ components> }`: return "Circle";
    case (Volume)`polygon { <{PolygonComponents ","}+ components> }`:  return "Polygon";
    case (Volume)`rectangle { <{RectangleComponents ","}+ components> }`: return "Rectangle";
    default: return "Volume";
  }
}

list[DocumentSymbol] labourOutliner(start[BoulderingRoute] input) {
  // Go through all the states in the program and create a symbol in the outline menu for them.
  // We use the list compression syntax to make this expression more concise.
  list[DocumentSymbol] children = [symbol("Holds", DocumentSymbolKind::\array(), holds.src, children=[
    *[symbol(setHoldLabel(hold), DocumentSymbolKind::\object(), hold.src) | /Hold hold := holds]
  ]) | /Holds holds := input];


  children += [symbol("Volumes", DocumentSymbolKind::\array(), volumes.src, children=[
    *[symbol(setVolumeLabel(volume), DocumentSymbolKind::\object(), volume.src) | /Volume volume := volumes]
  ]) | /Volumes volumes := input];

  // At the top-level, we have our file that we decided to always name "StateMachine"
  return [symbol("BoulderingRoute", DocumentSymbolKind::\file(), input.src, children=children)];
}

// =========================================================================
// Services
// data SummarizerMode
//      = analyze()
//      | build()
//      ;

// Summary analysisService(loc l, start[BoulderingRoute] input) = summaryService(l, input, analyze());
// Summary buildService(loc l, start[BoulderingRoute] input) = summaryService(l, input, build());

// Summary summaryService(loc l, start[BoulderingRoute] input, SummarizerMode mode) {
//   Summary s = summary(l);

//   // Find the state definitions
//   rel[str, loc] defs = {<"<state.name>", state.src> | /State state := input};

//   // Find the usage of said states in the transitions
//   rel[loc, str] uses = {<trans.to.src, "<trans.to>"> | /Trans trans := input};

//   // Provide error messages
//   s.messages += {<src, error("State \"<id>\" is not defined", src, fixes=prepareNotDefinedFixes(id, src, defs, input))>
//                 | <src, id> <- uses, id notin defs<0>};

//   // "references" are links for loc to loc (from def to use)
//   s.references += (uses o defs)<1,0>;

//   // "definitions" are also links from loc to loc (from use to def)
//   s.definitions += uses o defs;

//   return s;
// }
