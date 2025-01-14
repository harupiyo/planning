;;;-*- Mode: common-lisp; syntax: common-lisp; base: 10 -*-
;;
;; The Automated Planning - Theory and Practice is a textbook for planning by Malik Ghallab, 
;; Dana Nau, and Paolo Traverso, from Morgan Kaufmann. 
;; This program is a realization of algorithms that are published on the book, coded by Seiji 
;; Koide. 

;;;; Operator Module (2.3.2 Operators and Actions, 2.5.2 Operators and Actions, Chapter 4 State-Space Planning)
;;; All rights on programs are reserved by Seiji Koide. 
;;; 
;;; Copyrights (c), 2008, Seiji Koide

(cl:defpackage :plan
  #+:rdfs (:shadowing-import-from :gx typep type-of subtypep)
  (:shadowing-import-from :fol compound-unify compound-unify?)
  (:shadow method make-method defmethod)
  (:use common-lisp :callcc :utils :fol)
  (:export positive-precond negative-precond
   )
  )

(in-package :plan)

;;;
;;;; Operators
;;;
;;; A <planning operator> <o> is defind as a triple &lt;name(<o>), precond(<o>), effects(<o>)&gt;.
;;; An <operator name> is a syntactic expression of the form "<symbol>(<parms>)".
;;; An <operator precond> and <effects> are a conjunctive set of literals.
;;;
;;; An <operator name> is implemented as structure <ope-name> in lisp, which has 
;;; <symbol> slot and <parms> slot.

(defstruct (ope-name (:print-function print-ope-name)) symbol parms)

(defun print-ope-name (x stream depth)
  "prints <ope-name> like ''move($r $l $m)''."
  (declare (ignore depth))
  (format stream "~S~@[~S~]" (ope-name-symbol x) (ope-name-parms x)))

(defun ope-name-equal-p (op-name1 op-name2)
  "returns true if <op-name1> and <op-name2> are equal as ope-name definition."
  (and (ope-name-p op-name1) (ope-name-p op-name2)
       (eq (ope-name-symbol op-name1) (ope-name-symbol op-name2))
       (equalp (ope-name-parms op-name1) (ope-name-parms op-name2))))
        
(defun ope-name (exp)
  "makes an instance of <ope-name> from <exp> and returns it.
   If <exp> is a string, it should be in infix notation like ''move(r,l,m)'', otherwise it should be 
   a list in prefix operator name notation like ''(move $r $l $m)''.
   Note that a single character in string turns out an object variable with its name in logics."
  (if (ope-name-p exp) exp
    (if (stringp exp) (ope-name (logic exp))
      (make-ope-name :symbol (op exp) :parms (args exp)))))

;;;
;;; An <operator> in lisp is a structure composed of <name>, <comment>, <precond>, and <effects>.
;;;  * An <operator-name> is an instance of structure <ope-name>. 
;;;  * An <operator-comment> should be a string or nil.
;;;  * An <operator-precond> is a set of literals in first-order logics with implicit conjunction.
;;;  * An <operator-effects> is a set of literals in first-order logics with implicit conjunction.

(defstruct (operator (:print-function print-operator)) name comment precond effects)
(defun print-operator (x stream depth)
  "prints <operator> such as ''(operator <name> <comment> (:precond <precond>) (:effects <effects>)''."
  (declare (ignore depth))
  (cond ((eq (operator-symbol x) 'start)
         (format stream "~<(start~;~1:I~{ ~W~:_~}~;)~:>" (list (operator-effects x))))
        ((eq (operator-symbol x) 'finish)
         (format stream "~<(finish~;~1:I~{ ~W~:_~}~;)~:>" (list (operator-precond x))))
        ((operator-comment x)
         (format stream "~<(operator ~;~W ~_~:I~W ~_~W ~_~W~;)~:>"
           (list (operator-name x) (operator-comment x)
                 (cons :precond (operator-precond x)) (cons :effects (operator-effects x)))))
        (t (format stream "~<(operator ~;~W ~_~:I~W ~_~W~;)~:>"
             (list (operator-name x) (cons :precond (operator-precond x)) (cons :effects (operator-effects x)))))))

(defun operator-symbol (operator)
  "returns <ope-name-symbol> of <operator>'s name."
  (ope-name-symbol (operator-name operator)))
(defun operator-variables (operator)
  "returns <ope-name-parms> of <operator>'s name."
  (ope-name-parms (operator-name operator)))

;;;
;;; Function <operator> creates an operator instance.
;;; ----------------------------------------------------------------------------------
;;;   Ex. (operator "move(r,l,m)"
;;;                 :comment "robot r moves from location l to an adjacent location m."
;;;                 :precond "adjacent(l,m),at(r,l),~occupied(m)"
;;;                 :effects "at(r,m),occupied(m),~occupied(l),~at(r,l)")
;;;     -> (operator move($r $l $m)
;;;                  "robot r moves from location l to an adjacent location m."
;;;                  (:precond (adjacent $l $m) (at $r $l) (not (occupied $m)))
;;;                  (:effects (at $r $m) (occupied $m) (not (occupied $l)) (not (at $r $l))))
;;; ----------------------------------------------------------------------------------

(defun operator (ope-name &key precond effects comment)
  "makes an instance of <operator> with <ope-name>, <precond>, <effects>, and <comment>, 
   and returns it. Each parameter in <precond> and <effects> may be in prefix notation 
   in lisp and in infix notation in string. <precond> and <effects> do not require to 
   envelop it with braces. This function does not add the result into *operators*."
  (make-operator :name (ope-name ope-name)
                 :precond (mapcar #'normalize-statevar
                            (mapcar #'statevar
                              (if (stringp precond) (logic (with-brace precond)) precond)))
                 :effects (mapcar #'normalize-statevar
                            (mapcar #'statevar
                              (if (stringp effects) (logic (with-brace effects)) effects)))
                 :comment comment))

(defun operator-equal-p (operator1 operator2)
  "returns true if <operator1> and <operator2> are equal in the operator definition."
  (or (equalp operator1 operator2)
      (and (operator-p operator1) (operator-p operator2)
           (ope-name-equal-p (operator-name operator1) (operator-name operator2))
           (subsetp (operator-precond operator1) (operator-precond operator2) :test #'statevar-equalp)
           (subsetp (operator-precond operator2) (operator-precond operator1) :test #'statevar-equalp)
           (subsetp (operator-effects operator1) (operator-effects operator2) :test #'statevar-equalp)
           (subsetp (operator-effects operator2) (operator-effects operator1) :test #'statevar-equalp))))

(defun with-brace (str)
  "trims white spaces at the both ends of <str> 
   and envelops it with braces if braces do not exist, then returns the result."
  (setq str (string-trim '(#\Space #\Tab #\Newline) str))
  (if (and (char= (char str 0) #\{) (char= (char str (1- (length str))) #\})) str
    (format nil "{~A}" str)))

;;;
;;; All operators in system should be stored in a global var *operators*. Macro <defoperator> 
;;; do it. The <defoperator> can accept infix notations. See the following example.
;;; ----------------------------------------------------------------------------------
;;; (defoperator "move(r,l,m)"
;;;     "robot <r> moves from location <l> to an adjacent location <m>"
;;;   :precond "adjacent(l,m),at(r,l),~occupied(m)"
;;;   :effects "at(r,m),occupied(m),~occupied(l),~at(r,l)")
;;; ----------------------------------------------------------------------------------

(defvar *operators* () "A global var that stores operators defined.")

(defmacro defoperator (ope-name &rest initargs)
  "defines an operator and pushes the result into *operators*."
  `(car
    (setq *operators*
          (cons (operator ,ope-name
                          :comment ,(if (stringp (car initargs)) (car initargs))
                          :precond ,(if (stringp (car initargs))
                                        (getf (cdr initargs) :precond)
                                      (getf initargs :precond))
                          :effects ,(if (stringp (car initargs))
                                        (getf (cdr initargs) :effects)
                                      (getf initargs :effects)))
                *operators*))))

(defun find-operator (symbol)
  "finds the operator of which operator symbol is <symbol> and returns it."
  (find symbol *operators* :test #'eq :key #'operator-symbol))

(defun positive-precond (precond)
  "retrieves positive literals from <precond> and returns it."
  (remove-if-not #'statevar-val precond))
(defun negative-precond (precond)
  "retrieves negative literals from <precond> and returns it."
  (remove-if #'statevar-val precond))

(defun positive-effects (effects precond)
  "retrieves positive literals from <effects> and returns it.
   <precond> is ignored."
  (declare (ignore precond))
  (remove-if-not #'statevar-val effects))

(defun negative-effects (effects precond)
  "retrieves negative literals from <effects> and returns it."
  (declare (ignore precond))
  (remove-if #'statevar-val effects))

;;;
;;;; Unification for Operators
;;;

(cl:defmethod compound-unify? ((x ope-name) (y ope-name)) t)
(cl:defmethod compound-unify ((x ope-name) (y ope-name) bindings)
  (cond ((eql (ope-name-symbol x) (ope-name-symbol y))
         (unify (ope-name-parms x) (ope-name-parms y) bindings))
        (t +fail+)))

(cl:defmethod compound-unify? ((x operator) (y operator)) t)
(cl:defmethod compound-unify ((x operator) (y operator) bindings)
  (cond ((eql (operator-symbol x) (operator-symbol y))
         (unify (operator-variables x) (operator-variables y) bindings))
        (t +fail+)))

(cl:defmethod subst-bindings (bindings (x ope-name))
  (cond ((eq bindings +fail+) +fail+)
        ((eq bindings +no-bindings+) x)
        (t (make-ope-name :symbol (ope-name-symbol x)
                          :parms (subst-bindings bindings (ope-name-parms x))))))

(cl:defmethod subst-bindings (bindings (x operator))
  (cond ((eq bindings +fail+) +fail+)
        ((eq bindings +no-bindings+) x)
        (t (make-operator :name (subst-bindings bindings (operator-name x))
                          :comment (operator-comment x)
                          :precond (subst-bindings bindings (operator-precond x))
                          :effects (subst-bindings bindings (operator-effects x))))))

(cl:defmethod variables-in ((x operator))
  (variables-in (operator-variables x)))

;;;; Reverse Operator
;;; If effects of operator <A> is completely opposite of effects of operator <B>, 
;;; then <A> is called reverse operator of <B>.
;;; Note that exact matching without unification is needed.

(defun reverse-operator-p (op1 op2)
  (let ((effects1 (operator-effects op1))
        (effects2 (operator-effects op2)))
    (and (subsetp effects1 effects2 :test #'statevar-opposite-p)
         (subsetp effects2 effects1 :test #'statevar-opposite-p))))

#|
(reverse-operator-p (find-operator 'LOAD) (find-operator 'UNLOAD))
|#
#|
(negative-effects `(,(statevar (logic "load(r1)=c3"))
                      ,(statevar (logic "~holding(crane1)")))
                  `(,(statevar (logic "loc(r1)=loc1"))
                      ,(statevar (logic "belong(crane1)=loc1"))
                      ,(statevar (logic "holding(crane1)=c3"))
                      ,(statevar (logic "~load(r1)"))))
|#
;;;; Actions
;;;
;;; An action is a ground instance (via substitution for operator variables) of an operator. 
;;; We capture an operator which does not have any variables in precond. 

(cl:defmethod ground-p ((x operator))
  "returns true if precond in <x> does not include any variable."
  (every #'ground-p (operator-precond x)))

;;;
;;; In lisp, <action> is an extended structure of <operator>, and <action-name> is also an extention of <ope-name>.
;;; However, there is no difference between the slot-access function of <operator> and <action>, for example, 
;;; <action-precond> and <operator-precond> are effectively same, because there is no additional slots for <action> 
;;; to <operator>. 
;;; 
;;; So, the accessor for <action> is same as <operator> in practice. Strictly, <action> means completely ground 
;;; <operator>, but we often call partially instantiated <operator> <action> and use slot-accessors for <action> 
;;; instead of slot-accessors for <operator>.

(defstruct (action-name (:include ope-name)))
(defstruct (action (:include operator)))

(defun action (ope-name &key precond effects comment)
  "same as operator but makes an instance of action."
  (make-action :name (ope-name ope-name)
               :precond (mapcar #'normalize-statevar
                          (mapcar #'statevar
                            (if (stringp precond) (logic (with-brace precond)) precond)))
               :effects (mapcar #'normalize-statevar
                          (mapcar #'statevar
                            (if (stringp effects) (logic (with-brace effects)) effects)))
               :comment comment))

(defun action-equal-p (action1 action2)
  "same as <operator-equal-p>."
  (operator-equal-p action1 action2))
  
(defun same-action-p (action1 action2)
  "returns true if <action1> and <action2> has same <action-name> or <ope-name>, 
   even if two are not equal as <action> or <operator>."
  (equalp (action-name action1) (action-name action2)))

(defun same-operator-p-with-unify (relevant1 relevant2)
  "Is these operator name same with unification?"
  (let ((relname1 (operator-name relevant1))
        (relname2 (operator-name relevant2)))
    (and (eql (ope-name-symbol relname1) (ope-name-symbol relname2))
         (let ((bindings (unify relname1 relname2)))
           (equalp (subst-bindings bindings relname1)
                   (subst-bindings bindings relname2))))))

(defun make-action-from (operator &optional (bindings +no-bindings+))
  "makes an action from <operator> with substitution of <bindings>.
   If the substitution does not make operator ground, nil is returned."
  (let ((precond (subst-bindings bindings (operator-precond operator))))
    (when (notany #'variable? precond)
      (make-action :name (make-action-name :symbol (operator-symbol operator)
                                           :parms (subst-bindings bindings
                                                                  (operator-variables operator)))
                   :comment (operator-comment operator)
                   :precond precond
                   :effects (subst-bindings bindings (operator-effects operator))))))

(defun instantiate-relevant-from (operator bindings)
  "makes partially instantiated action from <operator> with substitution by <bindings>.
   Note that this function creates an action if ground, otherwise creates an operator."
  (cond ((eq bindings +fail+) (error "cant happen."))
        ((eq bindings +no-bindings+) operator)
        (t (let ((precond (subst-bindings bindings (operator-precond operator))))
             (cond ((notany #'variable? precond)
                    (make-action :name (make-action-name :symbol (operator-symbol operator)
                                                         :parms (subst-bindings bindings
                                                                                (operator-variables operator)))
                                 :comment (operator-comment operator)
                                 :precond (subst-bindings bindings (operator-precond operator))
                                 :effects (subst-bindings bindings (operator-effects operator))))
                   (t (make-operator :name (make-ope-name :symbol (operator-symbol operator)
                                                          :parms (subst-bindings bindings
                                                                                 (operator-variables operator)))
                                     :comment (operator-comment operator)
                                     :precond (subst-bindings bindings (operator-precond operator))
                                     :effects (subst-bindings bindings (operator-effects operator)))))))))

;;;; Applicability of Action
;;;
;;; If positive literals in <precond> in <action> is a subset of <state>, and any 
;;; negative literal in <precond> does not meet any positive literal in <state>,
;;; the <action> is applicable to <state>.

(defun applicable-action-p (action state)
  "returns true if positive precond in <action> makes a subset of <state>, and 
   null intersection between negative precond in <action> and positive literals in <state>."
  (and (subsetp (positive-precond (action-precond action)) state :test #'statevar-equalp)
       (let ((negatives (negative-precond (action-precond action))))
         (or (null negatives)
             (null (intersection negatives (remove-if-not #'statevar-val state)
                                 :test #'pseudo-statevar-equalp))))))
#|
(defun subst-statevars-bindings (binds vars)
  (mapcar #'(lambda (var) 
              (make-statevar :symbol (statevar-symbol var)
                             :parms (subst-bindings binds (statevar-args var))
                             :val (subst-bindings binds (statevar-val var))))
    vars))
|#

;;;
;;;
