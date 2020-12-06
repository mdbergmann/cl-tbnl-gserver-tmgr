(in-package :cl-user)
(defpackage :cl-tbnl-gserver-tmgr.tmgr
  (:use :cl :log4cl :hunchentoot :gstmgr-wkr)
  (:nicknames :gstmgr)
  (:export #:gserver-tmgr
           #:router))

(in-package :cl-tbnl-gserver-tmgr.tmgr)

(defparameter *gserver-tmgr-poolsize* 8)

(defclass gserver-tmgr (multi-threaded-taskmaster)
  ((asystem :initform (asys:make-actor-system :shared-dispatcher-workers 0))
   (router :initform nil
           :reader router
           :documentation
           "the actor router. it contains as many workers as is specified in `:max-thread-count'.")
   (max-thread-count :initarg :max-thread-count
                     :type integer
                     :initform *gserver-tmgr-poolsize*
                     :accessor taskmaster-max-thread-count
                     :documentation
                     "The number of gservers that should be spawned to handle requests.
A number of <cores> * 2 could be a good value.")
   (thread-count :initform 0
                 :type integer
                 :accessor taskmaster-thread-count
                 :documentation "The currently running number of gservers.")
   (test-acceptor :initarg :test-acceptor
                  :initform nil
                  :documentation "Internal, only for testing to inject a fake acceptor.")))

(defmethod initialize-instance :after ((self gserver-tmgr) &key)
  (with-slots (asystem router test-acceptor max-thread-count) self
    (when test-acceptor
      (log:warn "Injecting test acceptor: " test-acceptor)
      (setf (tbnl::taskmaster-acceptor self) test-acceptor))

    (log:info "Spawning ~a routees." max-thread-count)
    (unless router
      (setf router (router:make-router)))
    (dotimes (i max-thread-count)
      (router:add-routee router (ac:actor-of asystem
                                             (lambda ()
                                               (make-tmgr-worker))
                                             :dispatch-type :pinned)))))

(defmethod taskmaster-thread-count :around ((self gserver-tmgr))
  (length (slot-value self 'max-thread-count)))

(defmethod execute-acceptor ((self gserver-tmgr))
  (format t "execute acceptor...~%")
  (call-next-method))

(defmethod handle-incoming-connection ((self gserver-tmgr) socket)
  ;;(format t "handle-incoming-connection...~%")
  (act:tell (router self) `(:process ,(taskmaster-acceptor self) ,socket)))

(defmethod shutdown ((self gserver-tmgr))
  (with-slots (router) self
    (router:stop router)))
