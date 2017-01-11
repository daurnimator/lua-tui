## rxvt-unicode (urxvt)

  - Shift + various keys send invalid CSI sequences, e.g.

	  - Shift+Delete sends "\27[3$"
	  - Shift+F11 and Shift+F12 (i.e. F23 and F24) come through as "\27[23$" and "\27[24$", which are unterminated CSI sequences.

  - In X10 mouse reporting mode, going past Cx=255 the escape sequence ends early (I expect they just see the wrapped-around Cx value as a NUL byte that ends the string)
