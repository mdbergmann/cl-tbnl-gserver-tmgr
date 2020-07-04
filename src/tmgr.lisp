;;(in-package :cl-user)
(defpackage :cl-tbnl-gserver-tmgr.tmgr
  (:use :cl :log4cl :hunchentoot :gstmgr-wkr)
  (:nicknames :gstmgr)
  (:export #:gserver-tmgr
           #:gserver-pool))

(in-package :cl-tbnl-gserver-tmgr.tmgr)

(defparameter *gserver-tmgr-poolsize* 8)

(defclass gserver-tmgr (multi-threaded-taskmaster)
  ((gserver-pool :initform nil
                 :type simple-array
                 :reader gserver-pool
                 :documentation "the gserver pool. it contains as many gservers as is specified in `:max-thread-count'.")
   (max-thread-count :initarg :max-thread-count
                     :type integer
                     :initform *gserver-tmgr-poolsize*
                     :accessor taskmaster-max-thread-count
                     :documentation
                     "The number of gservers that should be spawned to handle requests. A number of <cores> * 2 could be a good value.")
   (thread-count :initform 0
                 :type integer
                 :accessor taskmaster-thread-count
                 :documentation "The currently running number of gservers.")
   (test-acceptor :initarg :test-acceptor
                  :initform nil
                  :documentation "Internal, only for testing to inject a fake acceptor.")))

(defmethod initialize-instance :after ((self gserver-tmgr) &key)
  (with-slots (gserver-pool test-acceptor max-thread-count) self
    (when test-acceptor
      (log:warn "Injecting test acceptor: " test-acceptor)
      (setf (tbnl::taskmaster-acceptor self) test-acceptor))

    (log:info "Spawning " max-thread-count " gservers.")
    (unless gserver-pool
      (setf gserver-pool (make-array max-thread-count
                                     :element-type 'gserver-worker)))
    (dotimes (i max-thread-count)
      (setf (aref gserver-pool i) (make-instance 'gserver-worker)))))

(defmethod taskmaster-thread-count ((self gserver-tmgr))
  (length (slot-value self 'gserver-pool)))

(defmethod execute-acceptor ((self gserver-tmgr))
  (format t "execute acceptor...~%")
  (call-next-method))

(defmethod handle-incoming-connection ((self gserver-tmgr) socket)
  ;;(format t "handle-incoming-connection...~%")
  (do-process-connection
      (aref (gserver-pool self) (random (slot-value self 'max-thread-count)))
    (taskmaster-acceptor self)
    socket))

(defmethod shutdown ((self gserver-tmgr))
  (with-slots (gserver-pool max-thread-count) self
    (dotimes (i max-thread-count)
      (stop-worker (aref gserver-pool i)))))
