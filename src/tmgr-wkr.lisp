(defpackage :cl-tbnl-gserver-tmgr.tmgr-wkr
  (:use :cl :cl-gserver.actor)
  (:nicknames :gstmgr-wkr)
  (:export #:tmgr-worker
           #:make-tmgr-worker
           #:get-processed-requests))

(in-package :cl-tbnl-gserver-tmgr.tmgr-wkr)

(defstruct worker-state
  (processed-requests 0 :type integer))

(defclass tmgr-worker (actor) ())

(defun make-tmgr-worker ()
  (make-instance 'tmgr-worker
                 :receive #'receive
                 :state (make-worker-state)))

(defun receive (worker message current-state)
  (declare (ignore worker))
  (case (first message)
    (:process (process-request
               (second message)
               (third message)
               current-state))
    (t (cons current-state current-state))))

(defun process-request (acceptor socket current-state)
  (handler-case
      (progn
        (with-slots (processed-requests) current-state
          (tbnl:process-connection acceptor socket)
          (cons
           current-state
           (make-worker-state
            :processed-requests
            (1+ processed-requests)))))
    (t (c)
      (progn 
        (log:error "Error: " c)
        (cons
         current-state
         current-state)))))

;; ---------------------------
;; worker facade -------------
;; ---------------------------

(defun get-processed-requests (worker)
  (with-slots (act-cell:state) worker
    (slot-value act-cell:state 'processed-requests)))
