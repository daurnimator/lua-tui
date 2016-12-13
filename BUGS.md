## rxvt-unicode (urxvt)

  - F23 and F23 (i.e. shift + F11 and shift + F12) come through as "\27[23$" and "\27[24$", which are unterminated CSI sequences.

  - In X10 mouse reporting mode, going past Cx=255 the escape sequence ends early (I expect they just see the wrapped-around Cx value as a NUL byte that ends the string)
