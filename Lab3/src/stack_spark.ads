package Stack_SPARK with SPARK_Mode => On is

   --  Capacite du tampon : IDENTIQUE a BUF_SIZE de stack.c (labo 2).
   Buffer_Size : constant := 100;

   --  Sous-types CONTRAINTS (E3).
   subtype Length_T is Natural  range 0 .. Buffer_Size;   --  longueur admissible
   subtype Index_T  is Positive range 1 .. Buffer_Size;   --  indice du tampon

   --  Jeu de caracteres admissible, en PREDICAT de sous-type (E3).
   --  ASCII imprimable : espace (32) a tilde (126). Exclut les octets de
   --  controle, NUL et les octets a bit de poids fort -> rejette le shellcode.
   subtype Printable is Character with
     Static_Predicate => Printable in ' ' .. '~';

   --  Tampon de taille fixe + longueur utile. L'invariant « l'entree acceptee
   --  tient dans le tampon » est garanti par le type : Length <= Buffer_Size.
   type Buffer_Array is array (Index_T) of Character;

   type Safe_Buffer is record
      Length : Length_T    := 0;
      Data   : Buffer_Array := (others => ' ');
   end record;

   --  Fonctions d'aide, utilisables dans les contrats.
   function Is_Printable (C : Character) return Boolean is
     (C in Printable);

   function All_Printable (S : String) return Boolean is
     (for all K in S'Range => Is_Printable (S (K)));

   --  Politique de validation : tient dans le tampon ET imprimable.
   --  (Une entree vide est admissible, comme dans bof : elle copie 0 octet.)
   function Is_Acceptable (S : String) return Boolean is
     (S'Length <= Buffer_Size and then All_Printable (S));

   --    Input    : entree brute (bornes quelconques, lue par le harnais).
   --    Buffer   : tampon sur ; significatif seulement si Accepted = True.
   --    Accepted : True ssi l'entree respecte la politique.
   procedure Bof
     (Input    : in     String;
      Buffer   :    out Safe_Buffer;
      Accepted :    out Boolean)
   with
     Global  => null,
     Depends => (Buffer => Input, Accepted => Input),
     Post    =>
       Accepted = Is_Acceptable (Input)
         and then
       (if Accepted then
          Buffer.Length = Input'Length
            and then
          (for all K in 1 .. Input'Length =>
             Buffer.Data (K) = Input (Input'First + (K - 1))));

end Stack_SPARK;
