pragma SPARK_Mode (Off);

with Ada.Text_IO;            use Ada.Text_IO;
with Ada.Command_Line;       use Ada.Command_Line;
with Ada.Streams.Stream_IO;  use Ada.Streams.Stream_IO;
with Stack_SPARK;            use Stack_SPARK;

procedure Main is

   procedure Run (Label : String; Input : String) is
      Buffer   : Safe_Buffer;
      Accepted : Boolean;
   begin
      Bof (Input, Buffer, Accepted);
      Put (Label & " | len=" & Integer'Image (Input'Length) & " | ");
      if Accepted then
         Put ("ACCEPTE  -> [");
         for K in 1 .. Buffer.Length loop
            Put (Buffer.Data (K));
         end loop;
         Put_Line ("]");
      else
         Put_Line ("REJETE (trop long ou octet non imprimable)");
      end if;
   end Run;

   procedure Run_File (Name : String) is
      File : Ada.Streams.Stream_IO.File_Type;
      Strm : Stream_Access;
      Data : String (1 .. 100_000);
      Len  : Natural := 0;
      Byte : Character;
   begin
      Open (File, In_File, Name);
      Strm := Stream (File);
      while not End_Of_File (File) and then Len < Data'Last loop
         Character'Read (Strm, Byte);
         Len := Len + 1;
         Data (Len) := Byte;
      end loop;
      Close (File);
      Run ("file:" & Name, Data (1 .. Len));
   end Run_File;

   procedure Run_Builtin_Suite is
      Nop_Sled : constant String (1 .. 16) := (others => Character'Val (16#90#));
   begin
      Put_Line ("=== Jeu d'essai interne (version SPARK) ===");
      Run ("valide     ", "hello world");                 --  imprimable, court
      Run ("borne-100  ", (1 .. Buffer_Size => 'A'));      --  pile Buffer_Size
      Run ("borne-vide ", "");                             --  longueur 0
      Run ("trop-long  ", (1 .. 517 => 'A'));              --  > Buffer_Size
      Run ("shellcode  ", Nop_Sled);                       --  octets 0x90
      Run ("nul-bytes  ", (1 .. 8 => Character'Val (0)));  --  octets NUL
   end Run_Builtin_Suite;

begin
   if Argument_Count >= 1 then
      Run_File (Argument (1));
   else
      Run_Builtin_Suite;
   end if;
end Main;
