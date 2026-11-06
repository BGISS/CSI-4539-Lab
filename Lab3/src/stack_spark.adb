package body Stack_SPARK with SPARK_Mode => On is

   procedure Bof
     (Input    : in     String;
      Buffer   :    out Safe_Buffer;
      Accepted :    out Boolean)
   is
      Len : constant Natural := Input'Length;   --  peut depasser Buffer_Size
   begin
      --  Initialisation complete des sorties (analyse de flux propre, E2).
      Buffer   := (Length => 0, Data => (others => ' '));
      Accepted := False;

      --  Decision de politique (court-circuit : All_Printable seulement
      --  une fois la longueur bornee).
      if Len <= Buffer_Size and then All_Printable (Input) then

         Buffer.Length := Len;

         --  Copie sure. K dans 1 .. Len <= Buffer_Size -> Buffer.Data (K)
         --  toujours dans Index_T. (K - 1) est calcule d'abord, donc
         --  Input'First + (K - 1) <= Input'Last : aucun debordement d'entier.
         for K in 1 .. Len loop
            Buffer.Data (K) := Input (Input'First + (K - 1));

            pragma Loop_Invariant (Buffer.Length = Len);
            pragma Loop_Invariant
              (for all J in 1 .. K =>
                 Buffer.Data (J) = Input (Input'First + (J - 1)));
         end loop;

         Accepted := True;
      end if;
   end Bof;

end Stack_SPARK;
