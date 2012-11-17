with RASCAL.ToolboxWritableField; use RASCAL.ToolboxWritableField;
with RASCAL.OS;                   use RASCAL.OS;

package Controller_Filter is
   
   type TEL_WritableField_Changed is new ATEL_Toolbox_WritableField_ValueChanged with null record;

   procedure Handle (The : in TEL_WritableField_Changed);

end Controller_Filter;
