(defsystem "cl-tbnl-gserver-tmgr"
  :version "0.1.0"
  :author "Manfred Bergmann"
  :license "MIT"
  :description "Hunchentoot pooled multi-threaded taskmanager based on cl-gserver."
  :depends-on ("hunchentoot"
               "cl-gserver")
  :components ((:module "src"
                :serial t
                :components
                ((:file "tmgr-wkr")
                 (:file "tmgr"))))
  :in-order-to ((test-op (test-op "cl-tbnl-gserver-tmgr/tests"))))

(defsystem "cl-tbnl-gserver-tmgr/tests"
  :author "Manfred Bergmann"
  :license "MIT"
  :depends-on ("cl-tbnl-gserver-tmgr"
               "fiveam"
               "cl-mock")
  :components ((:module "tests"
                :components
                ((:file "tmgr-test"))))
  :description "Test system for cl-tbnl-gserver-tmgr"
  :perform (test-op (op c) (symbol-call :fiveam :run!
                                        (uiop:find-symbol* '#:tmgr-tests
                                                           '#:cl-tbnl-gserver-tmgr.tmgr-test))))

