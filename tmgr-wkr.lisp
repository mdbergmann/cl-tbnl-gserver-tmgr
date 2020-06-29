(defpackage :cl-tbnl-gserver-tmgr.tmgr-wkr
  (:use :cl :hunchentoot :cl-gserver)
  (:nicknames :gstmgr-wkr)
  (:export #:gserver-worker
           #:get-processed-requests
           #:do-process-connection
           #:stop-worker))

(in-package :cl-tbnl-gserver-tmgr.tmgr-wkr)

(defstruct worker-state
  (processed-requests 0 :type integer))

(defclass gserver-worker (gserver) ())

(defmethod handle-cast ((self gserver-worker) message current-state)
  (with-slots (processed-requests) current-state
    (case (first message)
      (:process (progn
                  ;;(format t "Calling on 'tbnl:process-connection'...~%")
                  (handler-case
                      (tbnl:process-connection
                       (second message)
                       (third message))
                    (t (c)
                      (format t "Error: ~a~%" c)))
                  (cons
                   current-state
                   (make-worker-state
                    :processed-requests
                    (1+ processed-requests)))))
      (t (cons current-state current-state)))))

(defmethod handle-call ((self gserver-worker) message current-state)
  (cons current-state current-state))

(defmethod initialize-instance :after ((self gserver-worker) &key)
  (with-slots (cl-gserver::state) self
    (setf cl-gserver::state (make-worker-state))))

;; ---------------------------
;; worker facade -------------
;; ---------------------------
(defun get-processed-requests (worker)
  (with-slots (cl-gserver::state) worker
    (slot-value cl-gserver::state 'processed-requests)))

(defun do-process-connection (worker acceptor socket)
  (cast worker `(:process ,acceptor ,socket)))

(defun stop-worker (worker)
  (cast worker :stop))
