(defpackage :cl-tbnl-gserver-tmgr.tmgr-test
  (:use :cl :fiveam :cl-mock :gstmgr :gstmgr-wkr)
  (:export #:run!
           #:all-tests
           #:nil))
(in-package :cl-tbnl-gserver-tmgr.tmgr-test)

(def-suite tmgr-tests
  :description "GServer Taskmanager tests.")

(in-suite tmgr-tests)

(def-fixture start-stop-tmgr ()
  (setf *gserver-tmgr-poolsize* 1)
  (let ((cut (make-instance 'gserver-tmgr
                            :test-acceptor (make-instance 'tbnl:acceptor))))
    (unwind-protect
         (&body)
      (tbnl:shutdown cut))))

(test create-tmgr
  "Creates the taskmanager"
  (with-fixture start-stop-tmgr ()
    (is (not (null cut)))))

(test tmgr-has-number-of-gservers-we-need
  "When creating the taskmanager we start the desired number of gservers"
  (with-fixture start-stop-tmgr ()
    (is (= 1 (length (slot-value cut 'gserver-pool))))
    (is (every (lambda (o) (typep o 'cl-gserver:gserver)) (gserver-pool cut)))))

(test tmgr-can-respond-to-ask-for-state
  "Test that tmgr can respond with it's state."
  (with-fixture start-stop-tmgr ()
    (is (every (lambda (o) (= 0 (get-processed-requests o))) (gserver-pool cut)))))

(test tmgr-calls-process-connection-on-acceptor
  "Tests that 'process-connection' is called on the acceptor instance."
  (with-fixture start-stop-tmgr ()
    (let ((worker (aref (gserver-pool cut) 0)))
      (tbnl:handle-incoming-connection cut (make-instance 'usocket:usocket))
      (sleep 0.5)

      (is (= 1 (get-processed-requests worker)))
    )))


;;(run! 'create-tmgr)
;;(run! 'tmgr-has-number-of-gservers-we-need)
;;(run! 'tmgr-can-respond-to-ask-for-state)
;;(run! 'tmgr-calls-process-connection-on-acceptor)

(defparameter *my-acceptor* nil)

(tbnl:define-easy-handler (say-yo :uri "/yo") (name)
  (setf (hunchentoot:content-type*) "text/plain")
  (format nil "Hey~@[ ~A~]!" name))

(defun start-single-threaded ()
  (setf *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
                                     :port 4242
                                     :taskmaster (make-instance 'tbnl:single-threaded-taskmaster)
                                     :access-log-destination nil))

  (bt:make-thread (lambda ()
                    (tbnl:start *my-acceptor*))
                  :name "Foo"))

(defun start-multi-threaded ()
  (setf *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
                                     :port 4242
                                     :access-log-destination nil))

  (bt:make-thread (lambda ()
                    (tbnl:start *my-acceptor*))
                  :name "Foo"))

(defun start-gserver-threaded ()
  (setf *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
                                     :port 4242
                                     :taskmaster (make-instance 'gserver-tmgr)
                                     :access-log-destination nil))

  (bt:make-thread (lambda ()
                    (tbnl:start *my-acceptor*))
                  :name "Foo"))

(defun start-quux-threaded ()
  (setf lparallel:*kernel* (lparallel:make-kernel 8))  
  (setf *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
                                     :port 4242
                                     :taskmaster
                                     (make-instance 'quux-hunchentoot:thread-pooling-taskmaster
                                                    :max-thread-count 8
                                                    :max-accept-count 100000)
                                     :access-log-destination nil))

  (bt:make-thread (lambda ()
                    (tbnl:start *my-acceptor*))
                  :name "Foo"))
