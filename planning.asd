;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Package: cl-user; Base: 10; Lowercase: Yes -*-
;;; vim: set filetype=lisp :

(defsystem "planning/utils"
  :description "Utilities for Planning System"
  :version "0.90"
  :author "Peter Norvig & Paul Graham"
  :maintainer "Seiji Koide <SeijiKoide@aol.com>"
  :licence "Norvig's Licence Agreement, cf http://www.norvig.com/license.html."
  :components ((:module "utils"
                        :components ((:file "callcc")
                                     (:file "utilities")))))

(defsystem "planning/fol"
  :description "FOL subsystem for Planning System"
  :version "0.90"
  :author "Peter Norvig"
  :maintainer "Seiji Koide <SeijiKoide@aol.com>"
  :licence "Norvig's Licence Agreement, cf http://www.norvig.com/license.html."
  :depends-on ("planning/utils")
  :components ((:module "fol"
                        :components((:file "infix")
                                    (:file "unify")
                                    (:file "normal" :depends-on ("infix" "unify"))
                                    (:file "fol"    :depends-on ("unify" "normal"))))))

(defsystem "planning/plan"
  :description "plan subsystem for Planning System"
  :version "0.90"
  :author "Seiji Koide"
  :maintainer "Seiji Koide <SeijiKoide@aol.com>"
  :licence "Norvig's Licence Agreement, cf http://www.norvig.com/license.html."
  :depends-on ("planning/fol")
  :components ((:module "plan"
                        :components ((:file "statespace")
                                     (:file "operator")
                                     (:file "FrwdBkwd")
                                     (:file "STRIPS")
                                     (:file "planspace")
                                     (:file "PSP")
                                     (:file "STN")))))

(defsystem "planning"
  :description "Planning System"
  :version "0.90"
  :author "Seiji Koide"
  :maintainer "Seiji Koide <SeijiKoide@aol.com>"
  :licence "Norvig's Licence Agreement, cf http://www.norvig.com/license.html."
  :depends-on ("planning/plan"))

