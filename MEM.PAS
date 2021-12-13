Program Memoire;

Uses DOS;

Const Hex    : Array[0..15] of Char = '0123456789ABCDEF';
      SegCON : Word = 0;
      OfsCON : Word = 0;

Type TableType = Array[0..255] of Byte;
     BytePtr = ^byte;
     MCB     = record
                 IdCode  : char;
                 PSP     : word;
                 Distance : word;
               end;
     MCBPtr  = ^MCB;
     MCBPtr2 = ^MCBPtr;

Function GetDosVer:Byte;
Begin
  GetDosVer := Lo(DosVersion) * 10 + Hi(DosVersion);
End;

{$F+}

Function MK_FP(Seg,Ofs:Word):BytePtr;
Begin
 Inline($8B/$46/$08/     { mov ax,[bp+8] (Lire adresse de segment)    }
        $89/$46/$FE/     { mov [bp-2],ax (et la placer dans pointeur) }
        $8B/$46/$06/     { mov ax,[bp+6] (Lire adresse d'offset)      }
        $89/$46/$FC);    { mov [bp-4],ax (et la placer dans pointeur) }
End;

{$F-}

Function Hex4(Nombre:Word):String;
Begin
 Hex4 := Hex[Nombre shr 12] +
         Hex[(Nombre shr 8) and 15] +
         Hex[(Nombre shr 4) and 15] +
         Hex[Nombre and 15];
End;

Function Hex2(Nombre:Byte):String;
Begin
 Hex2 := Hex[Nombre shr 4]+
         Hex[Nombre and 15];
End;

Function FirstMCB:MCBPtr;
var Registre : Registers;
Begin
 With Registre do
 Begin
  AH := $52;
  MsDos(Registre);
  FirstMCB := MCBPtr2(MK_FP(ES-1,BX+12))^;
  SegCON := MemW[ES:BX+$0E];
  OfsCON  := MemW[ES:BX+$0C];
 End;
End;

Function Ch(Seg,Ofs:Word):Char;
Begin
 Ch := Chr(Mem[Seg:Ofs]);
End;

Procedure IncCh(Var Chaine:String;Temp:String);
Begin
 Chaine := Chaine + Temp;
End;

Function StrAdr(Seg,Ofs:Word):String;
Begin
 StrAdr := Hex4(Seg) + 'h:' + Hex4(Ofs) + 'h';
End;

Function Maj(Chaine:String):String;
Var Temp     : String;
    Compteur : Byte;
Begin
 Temp := '';
 For Compteur := 1 to Length(Chaine) do
 Begin
  IncCh(Temp,UpCase(Chaine[Compteur]));
 End;
 Maj := Temp;
End;

Function NombreMCB : Word;
Var Fin    : Boolean;
    NrMCB  : Word;
    MCBact : MCBPtr;
    SegMCB : Word;
    OfsMCB : Word;
Begin
 Fin    := False;
 NrMCB  := 1;
 MCBact := FirstMCB;
 Repeat
  SegMCB := Seg(MCBact^);
  OfsMCB := Ofs(MCBact^);
  If(MCBact^.IdCode = 'Z')Then Fin := true
   else
  Begin
   MCBact := MCBPtr(MK_FP(SegMCB + MCBact^.Distance + 1, 0));
   Inc(NrMCB);
  End;
 Until Fin;
 NombreMCB := NrMCB;
End;

Procedure TableIntr(Var Table:TableType;Debut,Fin:Word);
Var Z     : Byte;
    NSeg  : Word;
    NOfs  : Word;
Begin
 For Z := 255 downto 0 do
 Begin
  NSeg := MemW[0:Z*4+2];
  NOfs := MemW[0:Z*4];
  If(NSeg<>0)and(NOfs<>0)and(Debut<=NSeg)and(Fin>NSeg)Then Table[Z] := 1
                                                      Else Table[Z] := 0;
 End;
End;

Procedure TraceMCB;
Const ComSpec  : array[0..7] of Char = 'COMSPEC=';
Var  MCBact       : MCBPtr;
     SegMCB       : Word;
     OfsMCB       : Word;
     SegPSP       : Word;
     NSeg         : Word;
     NOfs         : Word;
     Fin          : Boolean;
     Touche       : Char;
     NrMCB        : Word;
     Z            : Word;
     DosVer       : Byte;
     Chaine       : String;
     Repertoire   : PathStr;
     Nom          : NameStr;
     Ext          : ExtStr;
     AncSeg       : Word;
     NbrMCB       : Word;
     Ptr          : Pointer;
     Proprietaire : String[12];
     Description  : String[34];
     Table        : TableType;
     Taille       : LongInt;
     SegPtr       : Word;
     OfsPtr       : Word;
     OffSet       : Word;
Begin
 NbrMCB := NombreMCB;
 GetMem(Ptr,NbrMCB+2);
 SegPtr := Seg(Ptr^);
 OfsPtr := Ofs(Ptr^);
 InLine($B8/$23/$00/$CD/$10);
 DosVer := GetDosVer;
 Fin    := False;
 NrMCB  := 1;
 Ext    := '.COM';
 AncSeg := 0;
 Proprietaire := 'Inconnu';
 While (Proprietaire[0] < #12) do IncCh(Proprietaire,' ');
 Description  := 'Vecteur int.';
 FillChar(Ptr^,320*3,0);
 MemL[SegPtr:OfsPtr+12] := 1024;
 Move(Proprietaire[0],Mem[SegPtr:OfsPtr+16],13);
 Move(Description[0],Mem[SegPtr:OfsPtr+29],35);
  { Zone du BIOS }
 Description  := 'Zone du BIOS';
 MemW[SegPtr:OfsPtr+320+2]  := $40;
 MemW[SegPtr:OfsPtr+320+6]  := $40;
 MemW[SegPtr:OfsPtr+320+10] := $40;
 MemL[SegPtr:OfsPtr+320+12] := 256;
 Move(Proprietaire[0],Mem[SegPtr:OfsPtr+320+16],13);
 Move(Description[0],Mem[SegPtr:OfsPtr+320+29],35);
  { SystŠme DOS }
 Description  := 'SystŠme DOS';
 MemW[SegPtr:OfsPtr+320*2+2]  := $50;
 MemW[SegPtr:OfsPtr+320*2+6]  := $50;
 MemW[SegPtr:OfsPtr+320*2+10] := $50;
 MCBact := FirstMCB;
 MemL[SegPtr:OfsPtr+320*2+12] := (LongInt(Seg(MCBact^) + 1) shl 4) - 1280;
 Move(Proprietaire[0],Mem[SegPtr:OfsPtr+320*2+16],13);
 Move(Description[0],Mem[SegPtr:OfsPtr+320*2+29],35);
 TableIntr(Table,50,Seg(MCBact^));
 Move(Table[0],Mem[SegPtr:OfsPtr+64],256);
 Repeat
  SegMCB := Seg(MCBact^);
  OfsMCB := Ofs(MCBact^);
  SegPSP := SegMCB + 1;
  TableIntr(Table,AncSeg,SegPSP);
  AncSeg := SegPSP;
  If(MCBact^.IdCode = 'Z')Then Fin := true;
  Taille := LongInt(MCBact^.Distance) shl 4;
  Z := 0;
  While ((Z<8) and (ComSpec[Z] = Ch(SegPSP,Z))) do Inc(Z);
  If Z>7 then
  Begin
   Description := 'Environment';
   If(DosVer>= 30)then
   Begin
    Z := 0;
    While(MemW[SegPSP:Z] <> 0)do Inc(Z);
    Inc(Z,4);
    Chaine := '';
    If(Mem[SegPSP:Z] <> 0)Then
    Begin
     Repeat
      IncCh(Chaine,Ch(SegPSP,Z));
      Inc(Z);
     Until (Mem[SegPSP:Z]=0);
     FSplit(Chaine,Repertoire,Nom,Ext);
     While (Nom[0] < #8) do IncCh(Nom,' ');
     Chaine := Nom + Ext;
    End;
   End;
   {Write('Autopsie (O/N) ?');
   Repeat Touche := ReadKey; Until (Touche in ['O','o','N','n']);
   WriteLn;}
   Touche := 'n';
   If(Touche in ['O','o'])Then
   Begin
    Z := 0;
    While Mem[SegPSP:Z]<>0 do
    Begin
     Proprietaire := '';
     Repeat IncCh(Proprietaire,Ch(SegPSP,Z));Inc(Z); Until (Mem[SegPSP:Z]=0);
     Inc(Z);
    End;
   End;
  End
   else
  Begin
   If(MemW[SegPSP:0]=$20CD)Then
   Begin
    Description := 'Programme';
    Chaine := '';
    Z := 8;
    While (Mem[SegMCB:Z] <> 0) do
    Begin
     IncCh(Chaine,Ch(SegMCB,Z));
     Inc(Z);
    End;
    While (Chaine[0] < #8) do IncCh(Chaine,' ');
    Proprietaire := Chaine + Ext;
    Chaine := '';
    For Z := 1 to Mem[SegPSP:128] do IncCh(Chaine,Ch(SegPSP,128+Z));
   End
    else
   If(NrMCB = 1)Then
   Begin
    Description := 'Configuration';
    {Write('Autopsie (O/N) ?');
    Repeat Touche := ReadKey; Until (Touche in ['O','o','N','n']);
    WriteLn;}
    Touche := 'n';
    If(Touche in ['O','o'])Then
    Begin
     NSeg := SegCON;NOfs := OfsCON;
     Repeat
      Chaine := '';
      For Z := 10 to 17 do IncCh(Chaine,Ch(NSeg,NOfs+Z));
      If(Chaine[2] = #128)Then Chaine := 'A: - '+Chr(Ord(Chaine[1])+64)+':';
      WriteLn('Adresse = ',StrAdr(NSeg,NOfs));
      WriteLn('Attribut = ',MemW[NSeg:NOfs+4]);
      WriteLn('OffSet de routine de Strat‚gie = ',MemW[NSeg:NOfs+6]);
      WriteLn('OffSet de routine d''interruption = ',MemW[NSeg:NOfs+8]);
      WriteLn('Nom : ',Chaine);
      {Touche := ReadKey;}
      Z    := MemW[NSeg:NOfs];
      NSeg := MemW[NSeg:NOfs+2] + (Z shr 4);
      NOfs := Z and 15;
      Touche := #27;
     Until (Touche = #27);
    End;
   End
    else
   Begin
    Description := 'non identifiable';
   End;
  End;
  If(Fin=False)then
  Begin
   OffSet := OfsPtr+((NrMCB+2)*320);
   MemW[SegPtr:OffSet]    := 0;
   MemW[SegPtr:OffSet+2]  := SegMCB;
   MemW[SegPtr:OffSet+4]  := 0;
   MemW[SegPtr:OffSet+6]  := SegPSP;
   MemW[SegPtr:OffSet+8]  := 0;
   MemW[SegPtr:OffSet+10] := MCBact^.PSP;
   MemL[SegPtr:OffSet+12] := Taille;
   While (Proprietaire[0] < #12) do IncCh(Proprietaire,' ');
   Move(Proprietaire[0],Mem[SegPtr:OffSet+16],13);
   Move(Description[0],Mem[SegPtr:OffSet+29],35);
   Move(Table[0],Mem[SegPtr:OffSet+64],256);
   MCBact := MCBPtr(MK_FP(SegMCB + MCBact^.Distance + 1, 0));
   Inc(NrMCB);
  End;
 Until Fin;
 WriteLn(' # MCB  MEM  PSP  Taille  Nom           ParamŠtre Description');
 WriteLn('-- ---- ---- ---- ------- ------------- --------- ----------------');
 For Z := 0 to NrMCB + 1 do
 Begin
  OffSet := OfsPtr+Z*320;
  SegMCB := MemW[SegPtr:OffSet+2];
  SegPSP := MemW[SegPtr:OffSet+6];
  MCBact^.PSP := MemW[SegPtr:OffSet+10];
  Taille := MemL[SegPtr:OffSet+12];
  Move(Mem[SegPtr:OffSet+16],Proprietaire[0],13);
  Move(Mem[SegPtr:OffSet+29],Description[0],35);
  Move(Mem[SegPtr:OffSet+64],Table[0],256);
  If(Mem[SegPSP:$80] > 0)and(SegPSP > $50)and
    (Description[1] = 'P')Then Move(Mem[SegPSP:$80],Chaine,128)
                          Else Chaine := '';
  Chaine := Maj(Copy(Chaine,1,10));
  While (Chaine[0] < #10) do IncCh(Chaine,' ');
  If(Z < 3)Then Write(' í')
           Else Write(Z-2:2);
  Write(' ',Hex4(SegMCB),' ',Hex4(SegPSP),' ',Hex4(MCBact^.PSP),Taille:8);
  Write(' ',Proprietaire,' ',Chaine,' ',Description);
  WriteLn;
 End;
 InLine($B8/$00/$00/$CD/$16);
 FreeMem(Ptr,NbrMCB+2);
End;

BEGIN
 TraceMCB;
END.