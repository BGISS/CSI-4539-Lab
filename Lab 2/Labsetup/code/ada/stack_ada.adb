with Ada.Text_IO; use Ada.Text_IO;
 
procedure Stack_Ada is
   Buffer_Size : constant := 100;
   subtype Buffer_String is String (1 .. Buffer_Size);
 
   procedure Bof (Input : String) is
      Buffer : Buffer_String;
   begin
      Buffer (1 .. Input'Length) := Input;
   end Bof;
 
   Malicious_Input : constant String := (1 .. 517 => 'A');
 
begin
   Bof (Malicious_Input);
   Put_Line ("Copy succeeded.");
exception
   when Constraint_Error =>
      Put_Line ("Constraint_Error caught: input rejected safely.");
end Stack_Ada;
