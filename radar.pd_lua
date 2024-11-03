local radar = pd.Class:new():register("radar")

-- creation arguments: sym (receiver sym basename, default "left")
-- input range (default: 32768)
function radar:initialize(sel, atoms)
   self.inlets = 0
   self.outlets = 0
   -- normalized coordinates (center = (0,0), nw = (-1,-1))
   self.x = 0
   self.y = 0
   -- button press (1 = on, 0 = off)
   self.z= 0
   -- foreground and background colors
   self.bg = Colors.background
   self.fg = Colors.foreground
   -- object size
   self:set_size(64, 64)
   -- receivers
   local sym = type(atoms[1]) == "string" and atoms[1] or "left"
   self.x_recv = pd.receive(self, sym .. "x", "recvx")
   self.y_recv = pd.receive(self, sym .. "y", "recvy")
   self.stick_recv = pd.receive(self, sym .. "stick", "recvz")
   -- input range
   self.max = type(atoms[2]) == "number" and atoms[2] or 32768
   return true
end

-- set the coordinates
function radar:translate(x)
   if x == self.max-1 then
      -- like MIDI data bytes, controller ranges are often asymmetric, ranging
      -- from -max to max-1; nudge the max value to make it symmetric
      x = self.max
   end
   return x/self.max
end

function radar:recvx(sel, atoms)
   if type(atoms[1]) == "number" then
      self.x = self:translate(atoms[1])
      self:repaint()
   end
end

function radar:recvy(sel, atoms)
   if type(atoms[1]) == "number" then
      self.y = self:translate(atoms[1])
      self:repaint()
   end
end

function radar:recvz(sel, atoms)
   if type(atoms[1]) == "number" then
      self.z = atoms[1]
      self:repaint()
   end
end

-- draw the radar
function radar:paint(g)
   local width, height = self:get_size()
   local x, y = (self.x+1)*width/2, (self.y+1)*width/2

   -- standard object border, fill with bg color
   g:set_color(0)
   g:fill_all()

   -- helper function to set a color value
   function set_color(x)
      if type(x) == "table" then
	 g:set_color(table.unpack(x))
      elseif type(x) == "number" then
	 g:set_color(x)
      end
   end

   -- draw circle and hand of the radar in the set colors
   set_color(self.bg)
   g:fill_ellipse(1, 1, width - 2, height - 2)
   set_color(self.fg)
   g:stroke_ellipse(0, 0, width, height, 1)
   g:fill_ellipse(width/2 - 2, height/2 - 2, 4, 4)
   g:fill_ellipse(x - 3.5, y - 3.5, 7, 7)
   g:draw_line(x, y, width/2, height/2, 2)
   -- draw crosshairs if z is nonzero
   if self.z ~= 0 then
      g:draw_line(width/2, 0, width/2, height, 1)
      g:draw_line(0, height/2, width, height/2, 1)
   end
end
