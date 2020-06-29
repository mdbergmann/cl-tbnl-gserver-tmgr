;;(in-package :cl-user)
(defpackage :cl-tbnl-gserver-tmgr.tmgr
  (:use :cl :hunchentoot :gstmgr-wkr)
  (:nicknames :gstmgr)
  (:export #:gserver-tmgr
           #:gserver-pool
           #:*gserver-tmgr-poolsize*))

(in-package :cl-tbnl-gserver-tmgr.tmgr)

(defparameter *gserver-tmgr-poolsize* 4)

(defclass gserver-tmgr (multi-threaded-taskmaster)
  ((gserver-pool :initform (make-array *gserver-tmgr-poolsize*
                                       :element-type 'gserver-worker)
                 :reader gserver-pool)
   (test-acceptor :initarg :test-acceptor
                  :initform nil)))

(defmethod initialize-instance :after ((self gserver-tmgr) &key)
  (with-slots (gserver-pool test-acceptor) self
    (when test-acceptor
      (setf (tbnl::taskmaster-acceptor self) test-acceptor))
    
    (dotimes (i *gserver-tmgr-poolsize*)
      (setf (aref gserver-pool i) (make-instance 'gserver-worker)))))

(defmethod execute-acceptor ((self gserver-tmgr))
  (format t "execute acceptor...~%")
  (call-next-method))

(defmethod handle-incoming-connection ((self gserver-tmgr) socket)
  ;;(format t "handle-incoming-connection...~%")
  (do-process-connection
      (aref (gserver-pool self) (random *gserver-tmgr-poolsize*))
    (taskmaster-acceptor self)
    socket))

(defmethod shutdown ((self gserver-tmgr))
  (with-slots (gserver-pool) self
    (dotimes (i *gserver-tmgr-poolsize*)
      (stop-worker (aref gserver-pool i)))))
