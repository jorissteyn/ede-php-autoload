;;; ede-php-autoload-test.el --- ERT tests for ede-php-autoload-project -*- lexical-binding: t -*-

;; Copyright (C) 2015, Steven Rémot

;; Author: Steven Rémot <steven.remot@gmail.com>
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
;;

;;; Code:
(ert-deftest ede-php-autoload-project-is-defined ()
  "The EDE php autoload project should be defined."
  (with-current-project-file "main.php" "without-composer"
    (should (ede-php-autoload-project-p (ede-current-project)))))

(define-class-definition-test ede-php-autoload-find-psr0 ()
  "The definition for a PSR-4 class should be found."
  :class "Psr0Ns_TheClass"
  :file-name "src/Psr0Ns/TheClass.php"
  :project "without-composer")

(define-class-definition-test ede-php-autoload-find-psr4 ()
  "The definition for a PSR-4 class should be found."
  :class "Psr4Ns\\TheClass"
  :file-name "src/Psr4Ns/TheClass.php"
  :project "without-composer")

(define-class-definition-test ede-php-autoload-find-multidir-1 ()
  "The definition of the first item of a multi-directory namespace should be found."
  :class "MultiDirNs\\TheClass1"
  :file-name "src/MultiDirNs1/TheClass1.php"
  :project "without-composer")

(define-class-definition-test ede-php-autoload-find-multidir-2 ()
  "The definition of the non-first item of a multi-directory namespace should be found."
  :class "MultiDirNs\\TheClass2"
  :file-name "src/MultiDirNs2/TheClass2.php"
  :project "without-composer")

(define-class-definition-test ede-php-autoload-find-psr0-split-without-clash ()
  "The definition of a class in a split namespace (iwht multiple sub-namespaces) should be found on PSR-0."
  :class "Psr0Split\\Ns2\\TheClass"
  :file-name "src/Psr0Split/Ns2/TheClass.php"
  :project "without-composer")

(define-class-definition-test ede-php-autoload-find-psr4-split-without-clash ()
  "The definition of a class in a split namespace (iwht multiple sub-namespaces) should be found on PSR-4."
  :class "Psr4Split\\Ns2\\TheClass"
  :file-name "src/Psr4Split/Ns2/TheClass.php"
  :project "without-composer")

(define-class-definition-test ede-php-autoload-find-nothing ()
  "nil should be returned when no definition have been found."
  :class "Psr4Ns\\DoesNotExist"
  :file-name nil
  :project "without-composer")

(provide 'ede-php-autoload-test)

;;; ede-php-autoload-test.el ends here
