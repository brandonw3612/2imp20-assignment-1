module labour::Plugin

import util::Reflective;
import util::IDEServices;
import util::LanguageServer;

import labour::Server;

/*
 * This function is defined to test the functionality of the whole assignment. It receives a file path as a parameter and returns true if 
 * the program satisfies the specification or false otherwise.
 * First, it calls the parser (Parser.rsc). Then, it transforms the resulting parse tree of the previous program and calls the function 
 * cst2ast (CST2AST.rsc), responsible for transforming a parse tree into an abstract syntax tree.
 * Finally, the resulting AST is used to evaluate the well-formedness of the labour program using the check function (Check.rsc).
 */
// bool checkWellformedness(loc fil) {
// 	// Parsing
// 	&T resource = parserLaBouR(fil);
// 	// Transform the parse tree into an abstract syntax tree
// 	&T ast = cst2ast(resource);
// 	// Check the well-formedness of the program
// 	return checkBoulderRouteConfiguration(ast);
// }

/*
 * This is the main function of the project. This function enables the editor's syntax highlighting.
 * After calling this function from the terminal, all files with extension .labour will be parsed using the 
 * parser defined in module labour::Parser.
 * If there are syntactic errors in the program, no highlighting will be shown in the editor.
 */
int main() {
  registerLanguage(
    language(
      pathConfig(srcs=[|project://labour/src|]),
      "BoulderingRoute",     // name of the language
      {"labour"},            // extension, e.g., example.lbr
      "labour::Server",      // module to import, this one
      "contributions"
    )
  );
  return 0;
}

// Use this function to clear all traces of your language from VS code.
void clearLaBouR() {
  unregisterLanguage("BoulderingRoute", {"labour"});
}
