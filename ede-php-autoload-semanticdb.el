;;; ede-php-autoload-semanticdb.el --- Semanticdb support for ede-php-autoload

;; Copyright (C) 2015, Steven Rémot

;; Author: Steven Rémot <steven.remot@gmail.com>
;;         Inspired by Joris Stein's edep <https://github.com/jorissteyn/edep>
;; Keywords: PHP project ede
;; Homepage: https://github.com/stevenremot/ede-php-autoload

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This provides a simple semanticdb backend that uses ede-php-autoload to
;; get tags by emulating PHP autoload system.

;;; Code:

(require 'semantic/db)
(require 'semantic/db-typecache)
(require 'ede-php-autoload)

(eval-and-compile
  (unless (fboundp 'cl-defmethod)
    (defalias 'cl-defmethod 'defmethod))
  (unless (fboundp 'cl-call-next-method)
    (defalias 'cl-call-next-method 'call-next-method)))

(defclass ede-php-autoload-semanticdb-table (semanticdb-search-results-table eieio-singleton)
  ((major-mode :initform php-mode))
  "Database table for PHP using `ede-php-autoload'.")

(defclass ede-php-autoload-semanticdb-database (semanticdb-project-database eieio-singleton)
  ((new-table-class :initform ede-php-autoload-semanticdb-table
                    :type class
                    :documentation "Class of the new tables created for this database."))
  "Semanticdb database that uses `ede-php-autoload'.")

(cl-defmethod semanticdb-get-database-tables ((obj ede-php-autoload-semanticdb-database))
  "For an `ede-php-autoload-project', there is only one singleton table."
  (when (or (not (slot-boundp obj 'tables))
            (not (ede-php-autoload-semanticdb-table-p (car (oref obj tables)))))
    (let ((newtable (ede-php-autoload-semanticdb-table "EDE-PHP-AUTOLOAD")))
      (oset obj tables (list newtable))
      (oset newtable parent-db obj)))
  (cl-call-next-method))

(cl-defmethod semanticdb-file-table ((obj ede-php-autoload-semanticdb-database) filename)
  "For an `ede-php-autoload-project', use the only table."
  (car (semanticdb-get-database-tables obj)))

(defun ede-php-autoload-semanticdb-import-file-content-for-class (project class-name)
  "Import the tags in the file that defines a certain class.

PROJECT is the ede php project in which class is defined.
CLASS-NAME is the name of the class.

Return nil if it could not find the file or if the file was the current file."
  (let ((file (ede-php-autoload-find-class-def-file project class-name)))
    (when (and file (not (string= file (buffer-file-name))))
      (find-file-noselect file)
      (semanticdb-file-stream file))))

(defun ede-php-autoload-current-project ()
  "Return the current `ede-php-autoload' project."
  (when (ede-php-autoload-project-p (ede-current-project))
    (ede-current-project)))

(define-mode-local-override semanticdb-typecache-find
  php-mode (type &optional path find-file-match)
  "Search the typecache for TYPE in PATH.
If type is a string, split the string, and search for the parts.
If type is a list, treat the type as a pre-split string.
PATH can be nil for the current buffer, or a semanticdb table.
FIND-FILE-MATCH is non-nil to force all found tags to be loaded into a buffer."
  ;; If type is a string, strip the leading separator.
  (unless (listp type)
    (setq type (list (replace-regexp-in-string "\\(^[\\]\\)" "" type))))

  (let ((result
         ;; First try finding the type using the default routine.
         (or (semanticdb-typecache-find-default type path find-file-match)

             ;; Or try ede-php-autoload
             (car (semanticdb-find-tags-by-name-method
                   (ede-php-autoload-semanticdb-table "EDE PHP ROOT")
                   (mapconcat 'identity type "\\"))))))

    (when (and result find-file-match)
      (find-file-noselect (semantic-tag-file-name result)))

    result))

(cl-defmethod semanticdb-find-tags-by-name-method
  ((table ede-php-autoload-semanticdb-table) name &optional tags)
  "Find all tags named NAME in TABLE"
  (if (ede-php-autoload-current-project)
      (or (ede-php-autoload-semanticdb-import-file-content-for-class
           (ede-php-autoload-current-project)
           name)
          (cl-call-next-method))
    (cl-call-next-method)))

(cl-defmethod semanticdb-deep-find-tags-by-name-method
  ((table ede-php-autoload-semanticdb-table) name &optional tags)
  "Find all tags name NAME in TABLE.
Optional argument TAGS is a list of tags to search.
Like `semanticdb-find-tags-by-name-method' for global."
  (semanticdb-find-tags-by-name-method table name tags))

(provide 'ede-php-autoload-semanticdb)

;;; ede-php-autoload-semanticdb.el ends here
