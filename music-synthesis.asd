;;;; music-synthesis.asd

(asdf:defsystem #:music-synthesis
  :description "Space for making music using suppercollider"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:trivia #:iterate #:uiop #:cl-collider #:cl-patterns)
  :components ((:module "src"
                :components
                 ((:file "package")
                  (:file "music-synthesis")))))
