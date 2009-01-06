;;; project.el --- Keep track of the current project
 
;; Copyright (C) 2008 Nathan Weizenbaum
 
;; Author: Nathan Weizenbaum
;; URL: http://github.com/nex3/in-project-el
;; Version: 1.0
;; Created: 2008-01-06
;; Keywords: project, convenience
;; EmacsWiki: FindFileInProject
 
;; This file is NOT part of GNU Emacs.
 
;;; License:
 
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.
 
;;; Commentary:

;; This library provides a simple, standard, extensible way of keeping
;; track of the project in which a user is working.

(eval-when-compile (require 'cl))

(defvar project-root-functions
  '(project-vc-toplevel-dir-p project-vc-dir-p)
  "A list of functions that take the name of a directory and return t
if that directory is the root of a project and nil otherwise.

Each function is run on a single directory node before a higher node
is tried.")

(defvar project-vc-toplevel-dirs '(".git" ".hg" ".bzr" "_darcs")
  "A list of directories that might appear at the top-level of
version-controlled projects.")

(defvar project-vc-dirs '(".svn" "CVS" "RCS")
  "A list of directories that might appear at every of level of
version-controlled projects.")

(defun* project-root (&optional buffer)
  "Return the root of the project for BUFFER, determined using
`project-root-functions', or nil if BUFFER isn't in a project.

No argument means use the current buffer."
  (do ((dir (file-truename (buffer-file-name buffer))
            (directory-file-name (file-name-directory dir))))
      ((string-equal dir "/"))
    (dolist (fn project-root-functions)
      (when (funcall fn dir) (return-from project-root dir)))))

(defun project-vc-toplevel-dir-p (dir)
  "Return t if dir contains a toplevel vc dir as defined
by `project-vc-toplevel-dirs', and nil otherwise."
  (dolist (vc-dir project-vc-toplevel-dirs)
    (when (file-directory-p (concat dir "/" vc-dir)) (return t))))

(defun project-vc-dir-p (dir)
  "Return t if dir is the toplevel vc dir as defined
by `project-vc-dirs', and nil otherwise."
  (dolist (vc-dir project-vc-dirs)
    (when (and (file-directory-p (concat dir "/" vc-dir))
               (not (file-directory-p
                     (concat
                      (directory-file-name
                       (file-name-directory dir))
                      "/" vc-dir))))
      (return t))))

(provide 'project)
