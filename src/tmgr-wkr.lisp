(defpackage :cl-tbnl-gserver-tmgr.tmgr-wkr
  (:use :cl :sento.actor)
  (:nicknames :gstmgr-wkr)
  (:export #:tmgr-worker
           #:make-tmgr-worker
           #:get-processed-requests))

(in-package :cl-tbnl-gserver-tmgr.tmgr-wkr)

(defstruct worker-state
  (processed-requests 0 :type integer))

(defclass tmgr-worker (actor) ())

(defun make-tmgr-worker (asystem)
  (ac:actor-of asystem
               :state (make-worker-state)
               :receive #'receive
               :dispatcher :pinned
               :state (make-worker-state)))

(defun receive (message)
  (case (first message)
    (:process (process-request
               (second message)
               (third message)))))

(defun process-request (acceptor socket)
  (handler-case
      (progn
        (with-slots (processed-requests) *state*
          (tbnl:process-connection acceptor socket)
          (setf *state* (make-worker-state
            :processed-requests
            (1+ processed-requests)))))
    (t (c)
       (log:error "Error: " c))))

;; ---------------------------
;; worker facade -------------
;; ---------------------------

(defun get-processed-requests (worker)
  (with-slots (act-cell:state) worker
    (slot-value act-cell:state 'processed-requests)))
