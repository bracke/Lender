with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with StuffList;                  use StuffList;
with Main;                       use Main;

with RASCAL.OS;                  use RASCAL.OS;

package StuffIO is

   --
   -- Reads a stuff file and inserts information into stuff list.
   --
   procedure Read;

   --
   -- Save stuff list as file.
   --
   procedure Save;
                                           
private
end StuffIO;