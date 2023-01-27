(defpackage :cl-tbnl-gserver-tmgr.tmgr-test
  (:use :cl :fiveam :gstmgr :gstmgr-wkr :drakma)
  (:export #:run!
           #:all-tests
           #:nil))
(in-package :cl-tbnl-gserver-tmgr.tmgr-test)

(def-suite tmgr-tests
  :description "Sento Taskmanager tests.")

(in-suite tmgr-tests)

(defparameter *process-connection-called* 0)

(defclass fake-acceptor (tbnl:acceptor) ())
(defmethod tbnl:process-connection (fake-acceptor socket)
  (declare (ignore fake-acceptor socket))
  (incf *process-connection-called*))

(def-fixture start-stop-tmgr (pool-size)
  (let ((cut (make-instance 'gserver-tmgr
                            :test-acceptor (make-instance 'fake-acceptor)
                            :max-thread-count pool-size)))
    (unwind-protect
         (&body)
      (tbnl:shutdown cut))))

(test create-tmgr
  "Creates the taskmanager"
  (with-fixture start-stop-tmgr (1)
    (is (not (null cut)))))

(test tmgr-has-number-of-gservers-we-need
  "When creating the taskmanager we start the desired number of gservers"
  (with-fixture start-stop-tmgr (8)
    ;;(is (= 8 (tbnl:taskmaster-thread-count cut)))
    (is (= 8 (length (router:routees (router cut)))))))

(test tmgr-can-respond-to-ask-for-state
  "Test that tmgr can respond with it's state."
  (with-fixture start-stop-tmgr (1)
    (is (every (lambda (o) (= 0 (get-processed-requests o)))
               (router:routees (router cut))))))

(test tmgr-calls-process-connection-on-acceptor
  "Tests that 'process-connection' is called on the acceptor instance."
  (with-fixture start-stop-tmgr (1)
    (let ((worker (first (router:routees (router cut)))))
      (tbnl:handle-incoming-connection cut (make-instance 'usocket:usocket))
      (sleep 0.5)

      (is (= 1 (get-processed-requests worker))))))

(tbnl:define-easy-handler (say-yo :uri "/yo") (name)
  (setf (hunchentoot:content-type*) "text/plain")
  (format nil "Hey~@[ ~A~]!" name))

(test server-can-make-real-client-requests
  "Tests that server can really handle the requests."
  (let ((acceptor (make-instance 'tbnl:easy-acceptor
                                 :port 4242
                                 :access-log-destination nil
                                 :taskmaster (make-instance 'gserver-tmgr
                                                            :max-thread-count 8))))
    (unwind-protect
         (progn 
           (tbnl:start acceptor)
           (is (every (lambda (x) (string= "Hey!" x))
                      (loop repeat 100
                            collect (drakma:http-request "http://127.0.0.1:4242/yo")))))
      (tbnl:stop acceptor))))


;;(run! 'create-tmgr)
;;(run! 'tmgr-has-number-of-gservers-we-need)
;;(run! 'tmgr-can-respond-to-ask-for-state)
;;(run! 'tmgr-calls-process-connection-on-acceptor)
;;(run! 'server-can-make-real-client-requests)

(defparameter *my-acceptor* nil)

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

;; (defun start-quux-threaded ()
;;   (setf lparallel:*kernel* (lparallel:make-kernel 8))  
;;   (setf *my-acceptor* (make-instance 'hunchentoot:easy-acceptor
;;                                      :port 4242
;;                                      :taskmaster
;;                                      (make-instance 'quux-hunchentoot:thread-pooling-taskmaster
;;                                                     :max-thread-count 8
;;                                                     :max-accept-count 100000)
;;                                      :access-log-destination nil))

;;   (bt:make-thread (lambda ()
;;                     (tbnl:start *my-acceptor*))
;;                   :name "Foo"))
