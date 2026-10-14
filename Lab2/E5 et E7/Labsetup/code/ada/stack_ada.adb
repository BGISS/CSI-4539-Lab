with Ada.Text_IO; use Ada.Text_IO;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Ada.Command_Line; use Ada.Command_Line;

procedure Stack_Ada is
   Buffer_Size : constant := 100;
   subtype Buffer_String is String (1 .. Buffer_Size);

   procedure Bof (Input : String) is
      Buffer : Buffer_String;
   begin
      Buffer (1 .. Input'Length) := Input;
   end Bof;

   File    : Ada.Streams.Stream_IO.File_Type;
   In_Strm : Stream_Access;
   Byte    : Character;
   Input   : String (1 .. 10_000);
   Len     : Natural := 0;

begin
   Open (File, In_File, Argument (1));
   In_Strm := Stream (File);

   while not End_Of_File (File) loop
      Character'Read (In_Strm, Byte);
      Len := Len + 1;
      Input (Len) := Byte;
   end loop;

   Close (File);
   Put_Line ("Read" & Len'Image & " bytes from badfile.");

   Bof (Input (1 .. Len));
   Put_Line ("Copy succeeded.");
exception
   when Constraint_Error =>
      Put_Line ("Constraint_Error caught: input rejected safely.");
end Stack_Ada;
