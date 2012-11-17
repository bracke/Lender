with RASCAL.OS;           use RASCAL.OS;

package View_Main is

   --
   -- The user has created a new item.
   --Read the values from the Add_Window, create a new item, add it to the model and refresh the list window.
   --
   procedure Add;

   --
   -- The user wants to edit an item. Find the selected item in the model and fill the values into a new edit window.
   --
   procedure Edit (Index : in Integer := -1);

   --
   -- The user has changed an item. Read the new values from the edit window, update the model and refresh the list window.
   --
   procedure Change;

   --
   -- Fill the window with data from the model.
   --
   procedure Fill;


   --
   -- Clear the window.
   --
   procedure Clear_Movie (Window : Object_id);

end View_Main;
