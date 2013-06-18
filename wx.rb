#coding:UTF-8
require 'tk'

root = TkRoot.new{title "Exl"}
TkLabel.new(root) do
  text 'Hello world' 
  pack('padx' => 15, 'pady'=>15, 'side' => 'left')
end

Tk.mainloop