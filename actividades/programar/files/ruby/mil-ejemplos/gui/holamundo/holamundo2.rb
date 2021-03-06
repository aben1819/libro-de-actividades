#!/usr/bin/env ruby
## Inicializa Ruby/GTK2, como siempre.
require 'gtk2'

Gtk.init

# Crea la ventana.
window = Gtk::Window.new

# Especifica el título y el borde de la ventana.
s = "Hola Mundo2!"
window.title = s
window.border_width = 5

# El programa terminará directamente con el evento 'delete_event'.
window.signal_connect('delete_event') do
  Gtk.main_quit
  false
end

# Crea un nuevo botón 
label = Gtk::Label.new(s)
window.add(label)

window.show_all
Gtk.main
