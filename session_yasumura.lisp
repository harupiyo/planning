> ros run  # run SBCL

CL-USER> (ql:quickload "planning")
To load "planning":
  Load 1 ASDF system:
    planning
; Loading "planning"
[package callcc]..................................
[package utils]...................................
[package fol].....................................
[package fol].
debugger invoked on a SB-EXT:DEFCONSTANT-UNEQL in thread
#<THREAD "main thread" RUNNING {1004A682D3}>:
  The constant +NO-BINDINGS+ is being redefined (from ((NIL)) to ((NIL)))
See also:
  The ANSI Standard, Macro DEFCONSTANT
  The SBCL Manual, Node "Idiosyncrasies"

Type HELP for debugger help, or (SB-EXT:EXIT) to exit from SBCL.

restarts (invokable by number or by possibly-abbreviated name):
  0: [CONTINUE                     ] Go ahead and change the value.
  1: [ABORT                        ] Keep the old value.
  2: [TRY-RECOMPILING              ] Recompile unify and try loading it again
  3: [RETRY                        ] Retry
                                     loading FASL for #<CL-SOURCE-FILE "planning/fol" "fol" "unify">.
  4: [ACCEPT                       ] Continue, treating
                                     loading FASL for #<CL-SOURCE-FILE "planning/fol" "fol" "unify">
                                     as having been successful.
  5:                                 Retry ASDF operation.
  6: [CLEAR-CONFIGURATION-AND-RETRY] Retry ASDF operation after resetting the
                                     configuration.
  7:                                 Retry ASDF operation.
  8:                                 Retry ASDF operation after resetting the
                                     configuration.
  9:                                 Give up on "planning"
 10: [REGISTER-LOCAL-PROJECTS      ] Register local projects and try again.
 11:                                 Exit debugger, returning to top level.

(SB-IMPL::%DEFCONSTANT +NO-BINDINGS+ ((NIL)) #S(SB-C:DEFINITION-SOURCE-LOCATION :NAMESTRING "/home/harupiyo/common-lisp/planning/fol/unify.lisp" :INDICES 163841) "Indicates unification success, with no variables.")
0] 0
....................................
[package fol].
debugger invoked on a SB-EXT:DEFCONSTANT-UNEQL in thread
#<THREAD "main thread" RUNNING {1004A682D3}>:
  The constant +LOGICAL-CONNECTIVES+ is being redefined (from
  (AND OR NOT => <=>) to (AND OR NOT => <=>))
See also:
  The ANSI Standard, Macro DEFCONSTANT
  The SBCL Manual, Node "Idiosyncrasies"

Type HELP for debugger help, or (SB-EXT:EXIT) to exit from SBCL.

restarts (invokable by number or by possibly-abbreviated name):
  0: [CONTINUE                     ] Go ahead and change the value.
  1: [ABORT                        ] Keep the old value.
  2: [TRY-RECOMPILING              ] Recompile normal and try loading it again
  3: [RETRY                        ] Retry
                                     loading FASL for #<CL-SOURCE-FILE "planning/fol" "fol" "normal">.
  4: [ACCEPT                       ] Continue, treating
                                     loading FASL for #<CL-SOURCE-FILE "planning/fol" "fol" "normal">
                                     as having been successful.
  5:                                 Retry ASDF operation.
  6: [CLEAR-CONFIGURATION-AND-RETRY] Retry ASDF operation after resetting the
                                     configuration.
  7:                                 Retry ASDF operation.
  8:                                 Retry ASDF operation after resetting the
                                     configuration.
  9:                                 Give up on "planning"
 10: [REGISTER-LOCAL-PROJECTS      ] Register local projects and try again.
 11:                                 Exit debugger, returning to top level.

(SB-IMPL::%DEFCONSTANT +LOGICAL-CONNECTIVES+ (AND OR NOT => <=>) #S(SB-C:DEFINITION-SOURCE-LOCATION :NAMESTRING "/home/harupiyo/common-lisp/planning/fol/normal.lisp" :INDICES 491521) NIL)
0] 0

debugger invoked on a SB-EXT:DEFCONSTANT-UNEQL in thread
#<THREAD "main thread" RUNNING {1004A682D3}>:
  The constant +LOGICAL-QUANTIFIERS+ is being redefined (from (FORALL EXISTS)
  to (FORALL EXISTS))
See also:
  The ANSI Standard, Macro DEFCONSTANT
  The SBCL Manual, Node "Idiosyncrasies"

Type HELP for debugger help, or (SB-EXT:EXIT) to exit from SBCL.

restarts (invokable by number or by possibly-abbreviated name):
  0: [CONTINUE                     ] Go ahead and change the value.
  1: [ABORT                        ] Keep the old value.
  2: [TRY-RECOMPILING              ] Recompile normal and try loading it again
  3: [RETRY                        ] Retry
                                     loading FASL for #<CL-SOURCE-FILE "planning/fol" "fol" "normal">.
  4: [ACCEPT                       ] Continue, treating
                                     loading FASL for #<CL-SOURCE-FILE "planning/fol" "fol" "normal">
                                     as having been successful.
  5:                                 Retry ASDF operation.
  6: [CLEAR-CONFIGURATION-AND-RETRY] Retry ASDF operation after resetting the
                                     configuration.
  7:                                 Retry ASDF operation.
  8:                                 Retry ASDF operation after resetting the
                                     configuration.
  9:                                 Give up on "planning"
 10: [REGISTER-LOCAL-PROJECTS      ] Register local projects and try again.
 11:                                 Exit debugger, returning to top level.

(SB-IMPL::%DEFCONSTANT +LOGICAL-QUANTIFIERS+ (FORALL EXISTS) #S(SB-C:DEFINITION-SOURCE-LOCATION :NAMESTRING "/home/harupiyo/common-lisp/planning/fol/normal.lisp" :INDICES 524289) NIL)
0] 0
....................................
[package fol].....................................
[package plan]....................................
[package plan]....................................
[package plan]....................................
[package plan]....................................
[package plan]....................................
[package plan]....................................
[package plan]..........
("planning")

CL-USER> ;;; 1. parlor-trick
        (in-package :callcc) 
#<PACKAGE "CALLCC">
CALLCC> (=defun two-numbers ()
  (choose-bind n1 '(0 1 2 3 4 5)
    (choose-bind n2 '(0 1 2 3 4 5)
      (=values n1 n2))))
=TWO-NUMBERS
CALLCC> (=defun parlor-trick (sum)
  (=bind (n1 n2) (two-numbers)
    (if (= (+ n1 n2) sum)
        `(The sum of ,n1 ,n2)
        (fail))))
=PARLOR-TRICK
CALLCC> (parlor-trick 7)

Failed.
Failed.
Failed.
Failed.
Failed.
Failed.
Failed.
Failed.
Failed.
Failed.
Failed.
Failed.
Failed.
Failed.
Failed.
Failed.
Failed.
(THE SUM OF 2 5)

CALLCC> ;;; 2. foward-search
        (in-package :plan)
#<PACKAGE "PLAN">
PLAN> (setq *state*
       (state
        "{attach(p1,loc1),in(c1,p1),top(c1,p1),on(c1,pallet),
          attach(p2,loc1),in(c2,p2),top(c2,p2),on(c2,pallet),
          belong(crane1,loc1),holding(crane1,c3),adjacent(loc1,loc2),
          adjacent(loc2,loc1),at(r1,loc2),occupied(loc2),unloaded(r1)}"))
(|attach|(|p1| |loc1|) |in|(|c1| |p1|) |top|(|c1| |p1|) |on|(|c1| |pallet|)
 |attach|(|p2| |loc1|) |in|(|c2| |p2|) |top|(|c2| |p2|) |on|(|c2| |pallet|)
 |belong|(|crane1| |loc1|) |holding|(|crane1| |c3|) |adjacent|(|loc1| |loc2|)
 |adjacent|(|loc2| |loc1|) |at|(|r1| |loc2|) |occupied|(|loc2|)
 |unloaded|(|r1|))
PLAN> (defoperator "move(r,l,m)"
     "robot <r> moves from location <l> to an adjacent location <m>"
   :precond "adjacent(l,m),at(r,l),~occupied(m)"
   :effects "at(r,m),occupied(m),~occupied(l),~at(r,l)")
(operator |move|(|$r| |$l| |$m|)
          "robot <r> moves from location <l> to an adjacent location <m>"
          (:PRECOND |adjacent|(|$l| |$m|) |at|(|$r| |$l|) ~|occupied|(|$m|))
          (:EFFECTS |at|(|$r| |$m|) |occupied|(|$m|) ~|occupied|(|$l|)
           ~|at|(|$r| |$l|)))
PLAN> (defoperator "load(k,l,c,r)"
     "crane <k> at location <l> loads container  onto robot <r>"
   :precond "belong(k,l),holding(k,c),at(r,l),unloaded(r)"
   :effects "empty(k),~holding(k,c),loaded(r,c),~unloaded(r)")
(operator |load|(|$k| |$l| |$c| |$r|)
          "crane <k> at location <l> loads container  onto robot <r>"
          (:PRECOND |belong|(|$k| |$l|) |holding|(|$k| |$c|) |at|(|$r| |$l|)
           |unloaded|(|$r|))
          (:EFFECTS |empty|(|$k|) ~|holding|(|$k| |$c|) |loaded|(|$r| |$c|)
           ~|unloaded|(|$r|)))
PLAN> (setq *goal* (state "{at(r1,loc1),loaded(r1,c3)}"))
(|at|(|r1| |loc1|) |loaded|(|r1| |c3|))
PLAN> (forward-search *operators* *state* *goal* ())
Action taken |move|(|r1| |loc2| |loc1|)
Action taken |load|(|crane1| |loc1| |c3| |r1|)
((operator |move|(|r1| |loc2| |loc1|)
           "robot <r> moves from location <l> to an adjacent location <m>"
           (:PRECOND |adjacent|(|loc2| |loc1|) |at|(|r1| |loc2|)
            ~|occupied|(|loc1|))
           (:EFFECTS |at|(|r1| |loc1|) |occupied|(|loc1|) ~|occupied|(|loc2|)
            ~|at|(|r1| |loc2|)))
 (operator |load|(|crane1| |loc1| |c3| |r1|)
           "crane <k> at location <l> loads container  onto robot <r>"
           (:PRECOND |belong|(|crane1| |loc1|) |holding|(|crane1| |c3|)
            |at|(|r1| |loc1|) |unloaded|(|r1|))
           (:EFFECTS |empty|(|crane1|) ~|holding|(|crane1| |c3|)
            |loaded|(|r1| |c3|) ~|unloaded|(|r1|))))

