module labour::Check

import labour::AST;
import labour::Parser;
import labour::CST2AST;

import IO;
import List;
import Set;
import Prelude;
import String;


/*
 * - Implement a well-formedness checker for the LaBouR language. For this you must use the AST.
 * - Hint: Map regular CST arguments (e.g., *, +, ?) to lists
 * - Hint: Map lexical nodes to Rascal primitive types (bool, int, str)
 * - Hint: Use switch to do case distinction with concrete patterns
 */

/*
 * We already provided a function called checkBoulderRouteConfiguration(...), which is responsible for calling all
 * the required functions that check the program's well-formedness as described in the PDF (Section 2.2.).
 * This function takes as a parameter the program's AST and returns true if the program is well-formed or false otherwise.
 */

bool checkBoulderRouteConfiguration(BoulderingRoute route){
  bool numberOfHolds = checkNumberOfHolds(route);
  bool startingLabelLimit = checkStartingHoldsTotalLimit(route);

  return (numberOfHolds && startingLabelLimit);
}

/*
 * Check that there is a single list of volumes
 */
bool checkNumberOfVolumeLists(BoulderingRoute route) {
  volumeLists = [part | part <- route.parts, \volumes(_) := part];
  return size(volumeLists) <= 1;
}

/*
 * Check that routes have between zero and two hand start holds
 */
bool checkStartingHoldsTotalLimit(BoulderingRoute route) {
  // Get hold components
  list[list[HoldComponents]] holds = [c | \holds(holdList) <- route.parts, \hold(c) <- holdList];

  // Find all starting_labels
  starting_labels_items = [];
  for(list[HoldComponents] tmp <- holds) {
    starting_labels_items += [component | component <- tmp, (\single_start() := component || \double_start() := component)];
  }

  int total = size(starting_labels_items);
  return (total >= 0 && total <= 2);
}

/*
 * Define a function per each verification defined in the PDF (Section 2.2.)
 * Once again, we already provided two functions as examples.
 */
