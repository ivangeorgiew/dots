;;(setq my-global-map (make-keymap))
;;(substitute-key-definition 'self-insert-command 'self-insert-command my-global-map global-map)
;;(use-global-map my-global-map)
(global-set-key (kbd "<C-.>") 'forward-char)