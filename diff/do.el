;; -*- mode: lisp-interaction; lexical-binding: t; -*-

(require 'set)

(progn
  (d:generate-diff "dict_revised"
    :old-commit "a327b48"
    :new-commit "1d7c5b5"
    :old-version "2015_20230106"
    :new-version "2015_20230626")
  (k/send-notification "Done"))

(cl-defun d:generate-diff (dict &key old-commit new-commit old-version new-version)
  "Generate diff for DICT."
  (declare (indent 1))
  (let ((removed (set-new))
        (added (set-new))
        (size 0))
    (with-current-buffer (get-buffer-create "test")
      (erase-buffer)
      (call-process
       "git" nil '(t nil) nil
       "diff" "-U0"
       old-commit new-commit
       "--"
       (format "../%s.json" dict))
      (setq size (buffer-size))
      (goto-char (point-min))
      (search-forward "+++")
      (catch 'done
        (while (not (eobp))
          (catch 'continue
            (beginning-of-line)
            (forward-line)
            (message "%s%%" (* 100 (/ (point) size 1.0)))
            (unless (memql (char-after) '(?- ?+))
              (throw 'continue nil))
            (let ((flag (char-after))
                  title)
              (search-forward "{")
              (forward-char -1)
              ;; (message "%s" (line-number-at-pos))
              (setq title (gethash "title" (json-parse-buffer)))
              (if (eql flag ?-)
                  (set-add removed title)
                (set-add added title)))))))
    ;; (with-temp-file (format "%s - %s-%s - modified.json" dict old-version new-version)
    ;;   (insert
    ;;    (json-serialize (seq-into (seq-intersection added removed) 'vector))))
    (with-temp-file (format "%s - %s-%s - added.json" dict old-version new-version)
      (insert
       (json-serialize (seq-into (seq-difference added removed) 'vector))))
    (with-temp-file (format "%s - %s-%s - removed.json" dict old-version new-version)
      (insert
       (json-serialize (seq-into (seq-difference removed added) 'vector))))))
