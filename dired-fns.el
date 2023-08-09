;;; dired-fns.el --- Dired related functions. -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2017 Yevgnen Koh
;;
;; Author: Yevgnen Koh <wherejoystarts@gmail.com>
;; Version: 0.0.1
;; Keywords: dired
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;;
;;
;; See documentation on https://github.com/Yevgnen/dired-fns.el.

;;; Code:

;;;###autoload
(defun dired-smart-bol ()
  (interactive)
  (if (eq 2 (current-column))
      (dired-move-to-filename)
    (backward-char (- (current-column) 2))))

;;;###autoload
(defun dired-compile ()
  "Byte compile file or directory on current line."
  (interactive)
  (let ((file (dired-get-filename)))
    (if (dired-nondirectory-p file)
        (if (string-match "\\.el$" file)
            (byte-compile-file file)
          (message "Not a elisp source file."))
      (byte-recompile-directory file 0 t))))

;;;###autoload
(defun dired-compile-dwim ()
  "Do compile the directory when selecting a directory."
  (interactive)
  (unless (featurep 'dired-aux)
    (require 'dired-aux))
  (dired-map-over-marks
   (dired-compile) nil 'byte-compile-file-or-directory))

;;;###autoload
(defun dired-ediff ()
  (interactive)
  (let ((files (dired-get-marked-files)))
    (if (<= (length files) 2)
        (let ((file1 (car files))
              (file2 (if (cdr files)
                         (cadr files)
                       (read-file-name
                        "file: "
                        (dired-dwim-target-directory)))))
          (window-configuration-to-register :quick-diff)
          (if (file-newer-than-file-p file1 file2)
              (ediff-files file2 file1)
            (ediff-files file1 file2))
          (add-hook 'ediff-after-quit-hook-internal
                    (lambda ()
                      (setq ediff-after-quit-hook-internal nil)
                      (jump-to-register :quick-diff))))
      (error "No more than 2 files should be marked"))))

;;;###autoload
(defun dired-quit ()
  (interactive)
  (let ((buffer-name (buffer-name)))
    (bury-buffer)
    (while (and (eq major-mode 'dired-mode)
                (not (string= (buffer-name) buffer-name)))
      (bury-buffer))
    (if (string= buffer-name (buffer-name))
        (kill-buffer))))

(provide 'dired-fns)

;;; dired-fns.el ends here
