;; -*- mode: lisp-interaction; lexical-binding: t; -*-

(require 'set)

(defun d:read-dicts-versions ()
  "Read dictionary versions from ../versions.ts.
Return ((DICT PREVIOUS-VERSION CURRENT-VERSION) ...)."
  (with-temp-buffer
    (insert-file-contents "../versions.ts")
    (unless (re-search-forward "const dicts" nil t)
      (error "Cannot find the dicts line"))
    (let ((ret nil))
      (forward-line)
      (while (re-search-forward
              (rx (+ " ")
                  (group (+ (any "a-z" "_"))) ":"
                  (* nonl)
                  "current: \"" (group (+ (any "0-9" "_"))) "\", "
                  "previous: \"" (group (+ (any "0-9" "_"))) "\"")
              nil t)
        (push (list (match-string 1) (match-string 3) (match-string 2))
              ret))
      (nreverse ret))))

(cl-defun d:generate-diff (dict &key (old-commit "HEAD") old-version new-version)
  "Generate diff for DICT.
This asks Git to generate a diff between OLD-COMMIT and the working copy.
OLD-COMMIT is \"HEAD\" by default, meaning we are comparing the latest
commit with the working copy.

The output file is named
  \"DICT - <OLD-VERSION>-<NEW-VERSION> - {added|removed}.json\"."
  (declare (indent 1))
  (let ((removed (set-create))
        (added (set-create))
        (size 0))
    (with-current-buffer (get-buffer-create "test")
      (erase-buffer)
      (call-process
       "git" nil '(t nil) nil
       "diff" "-U0"
       old-commit
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
            (message "%s - %s%%" dict (* 100 (/ (point) size 1.0)))
            (unless (memql (char-after) '(?- ?+))
              (throw 'continue nil))
            (let ((flag (char-after))
                  title)
              (when (search-forward "{" nil t)
                (forward-char -1)
                ;; (message "%s" (line-number-at-pos))
                (setq title (gethash "title" (json-parse-buffer)))
                (if (eql flag ?-)
                    (set-add removed title)
                  (set-add added title))))))))
    ;; (with-temp-file (format "%s - %s-%s - modified.json" dict old-version new-version)
    ;;   (insert
    ;;    (json-serialize (seq-into (seq-intersection added removed) 'vector))))
    (with-temp-file (format "%s - %s-%s - added.json" dict old-version new-version)
      (insert
       (json-serialize (seq-into (seq-difference added removed) 'vector))))
    (with-temp-file (format "%s - %s-%s - removed.json" dict old-version new-version)
      (insert
       (json-serialize (seq-into (seq-difference removed added) 'vector))))))
