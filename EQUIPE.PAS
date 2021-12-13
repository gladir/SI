unit equipe;

interface

Const MDA         =  1;
      HGC         =  2;
      CGA         =  3;
      GS          =  4;
      EGA         =  5;
      PGA         =  6;
      MCGA        =  7;
      VGA         =  8;
      IBM8514     =  9;
      ITVGA2      = 10;
      ATIVGA      = 11;

      PC          = 255; { FFh }
      XT          = 254; { FEh }
      PCJunior    = 253; { FDh }
      AT          = 252; { FCh }
      PS2Model30  = 250; { FAh }
      Convertible = 249; { F9h }
      PS2Model80  = 248; { F8h }
      ContermMax  = 086; { 56h }

Type StrVer    = String[7];
     StrDate   = String[15];
     VideoData = Record
		  Moniteur : Array[0..1] of Byte;
		  Carte    : Array[0..1] of Byte;
		  Memoire  : Array[0..1] of LongInt;
		  ROMBIOS  : Array[0..1] of Boolean;
		  Version  : Array[0..1] of StrVer;
		  Date     : Array[0..1] of StrDate;
		 End;

Var Model : Byte Absolute $FFFF:$E;

Function Microprocesseur:Byte;
Function Coprocesseur:Byte;
Function NomCoprocesseur:String;
Function NomMicroprocesseur:String;
Function RegistreAccumulateur:String;
Function RegistreBase:String;
Function RegistreCompteur:String;
Function RegistreDonne:String;
Function RegistreSourceIndex:String;
Function RegistreDestinationIndex:String;
Function RegistreInstructionPointer:String;
Function RegistreBasePointer:String;
Function RegistreStackPointer:String;
Function RegistreCodeSegment:String;
Function RegistreDataSegment:String;
Function RegistreExtraSegment:String;
Function RegistreStackSegment:String;
Function RegistreFlags:String;
Function Teste6845(PortVideo:Word):Byte;
Function TesteHGC:Byte;
Function TesteITVGA2:Byte;
Function TesteATIVGA:Byte;
Function DateBIOSVideo:StrDate;
Function VersionBIOSVideo:StrVer;
Procedure ConfigurationVideo(Var Data:VideoData);
Function DriverMouse:Byte;
Function TesteXMS:Byte;
Function TesteCDROM:Byte;
Function SoftWareProprietaireInterruption(Numero:Byte):Byte;
Function TesteSB2F:Byte;
Function NomMachine:String;
Function Joystick:Byte;
Function DateBIOS:String;
Function ModeleSB2F:String;
Function VerSB2F:String;
Function DateSB2F:String;

implementation

uses dos;

Function Microprocesseur:Byte;
{ Retourne :

   0 si Intel 8088,
   1 si Intel 8086,
   2 si Nec V20,
   3 si Nec V30,
   4 si Intel 80188,
   5 si Intel 80186,
   6 si Intel 80286,
   7 si Intel 80386. }

Begin
 InLine($9C/$51/$52/$57/$56/$06/$33/$C0/$50/$9D/$9C/$58/$25/$00/
	$F0/$3D/$00/$F0/$74/$13/$B2/$06/$B8/$00/$70/$50/$9D/$9C/
	$58/$25/$00/$70/$74/$36/$FE/$C2/$EB/$32/$90/$B2/$04/$B0/
	$FF/$B1/$21/$D2/$E8/$75/$12/$B2/$02/$FB/$BE/$00/$00/$B9/
	$FF/$FF/$F3/$26/$AC/$0B/$C9/$74/$02/$B2/$00/$0E/$07/$FD/
	$B0/$FB/$B9/$03/$00/$E8/$16/$00/$FA/$F3/$AA/$FC/$90/$90/
	$90/$42/$90/$FB/$88/$56/$FF/$07/$5E/$5F/$5A/$59/$9D/$EB/
	$07/$90/$5F/$83/$C7/$09/$EB/$E4);
End;

Function Coprocesseur:Byte;
{ Retourne :

   0 si pas de coprocesseur,
   1 si Intel 8087,
   2 si Intel 80187,
   3 si Intel 80287,
   4 si Intel 80387. }
Begin
 If(Test8087 > 0)Then
 Begin
  If(Microprocesseur in [4,5])Then Coprocesseur := 2
   else
  Begin
   If(Test8087 = 1)Then Coprocesseur := Test8087
		   Else Coprocesseur := Test8087 + 1;
  End;
 End
  else
 Coprocesseur := 0;
End;

Function NomCoprocesseur:String;
Var Tempory : String;
Begin
 If(Test8087 = 0)Then NomCoprocesseur := 'Absent'
  else
 Begin
  If(Test8087 > 1)Then Str(Coprocesseur-1,Tempory)
		  Else Tempory := '';
  NomCoprocesseur := 'Intel 80'+Tempory+'87';
 End;
End;

Function NomMicroprocesseur:String;
Var Tempory : String;
Begin
 Str(Microprocesseur-4,Tempory);
 Case Microprocesseur of
  0 : NomMicroprocesseur := 'Intel 8088';
  1 : NomMicroprocesseur := 'Intel 8086';
  2 : NomMicroprocesseur := 'Nec V20';
  3 : NomMicroprocesseur := 'Nec V30';
  4 : NomMicroprocesseur := 'Intel 80188';
   else
  NomMicroprocesseur := 'Intel 80'+Tempory+'86';
 End;
End;

 { Registre de travail }

Function RegistreAccumulateur:String;
Begin
 RegistreAccumulateur := 'AX (AH,AL)';
End;

Function RegistreBase:String;
Begin
 RegistreBase := 'BX (BH,BL)';
End;

Function RegistreCompteur:String;
Begin
 RegistreCompteur := 'CX (CH,CL)';
End;

Function RegistreDonne:String;
Begin
 RegistreDonne := 'DX (DH,DL)';
End;

 { Registre OffSet }

Function RegistreSourceIndex:String;
Begin
 RegistreSourceIndex := 'SI';
End;

Function RegistreDestinationIndex:String;
Begin
 RegistreDestinationIndex := 'DI';
End;

Function RegistreInstructionPointer:String;
Begin
 RegistreInstructionPointer := 'IP';
End;

Function RegistreBasePointer:String;
Begin
 RegistreBasePointer := 'BP';
End;

Function RegistreStackPointer:String;
Begin
 RegistreStackPointer := 'SP';
End;

 { Registre Segment }

Function RegistreCodeSegment:String;
Begin
 RegistreCodeSegment := 'CS';
End;

Function RegistreDataSegment:String;
Begin
 RegistreDataSegment := 'DS';
End;

Function RegistreExtraSegment:String;
Begin
 RegistreExtraSegment := 'ES';
End;

Function RegistreStackSegment:String;
Begin
 RegistreStackSegment := 'SS';
End;

 { Registre Option }

Function RegistreFlags:String;
Begin
 RegistreFlags := 'CF,PF,AF,ZF,SF,OF,TF,IF,DF';
End;

Function Teste6845(PortVideo:Word):Byte;
Var Temp1 : Byte;
    Temp2 : Byte;
{ Mono    = 3B4h
  Couleur = 3D4h }
Begin
 Port[PortVideo] := 12;
 Inc(PortVideo);
 Temp1 := Port[PortVideo];
 Port[PortVideo] := $10;
 InLine($B9/$00/$01/ {        Mov CX,0100h }
	$E2/$FE);    { Wait : Loop Wait    }
 Temp2 := Port[PortVideo];
 Port[PortVideo] := Temp1;
 If(Temp2 = $10)Then Teste6845 := 1
		Else Teste6845 := 0;
End;

Function TesteHGC:Byte;
Var AH : Byte;
    AL : Byte;
    CX : Word;
Begin
 AH := Port[$3BA];
 AH := AH and $80;
 For CX := $8000 DownTo 0 do
 Begin
  AL := Port[$3BA];
  AL := AL and $80;
  If(AL <> AH)Then
  Begin
   TesteHGC := 1;
   Exit;
  End;
 End;
 TesteHGC := 0;
End;

Function TesteITVGA2:Byte;
Var Chaine   : Array[0..8] of Byte Absolute $C000:$0181;
    Temp     : String[15];
    Compteur : Byte;
Begin
 Temp := '';
 For Compteur := 0 to 8 do
 Begin
  Temp := Temp + Chr(Chaine[Compteur]);
 End;
 If(Temp = 'IT - VGA2')Then TesteITVGA2 := 1
		       Else TesteITVGA2 := 0;
End;

Function TesteATIVGA:Byte;
Var Chaine   : Array[0..2] of Byte Absolute $C000:$00F9;
    Temp     : String[15];
    Compteur : Byte;
Begin
 Temp := '';
 For Compteur := 0 to 2 do
 Begin
  Temp := Temp + Chr(Chaine[Compteur]);
 End;
 If(Temp = 'ATI')Then TesteATIVGA := 1
	         Else TesteATIVGA := 0;
End;

Function DateBIOSVideo:StrDate;
Var Chaine    : Array[0..7] of Byte Absolute $C000:$8F;
    Temp      : String[15];
    Compteur  : Byte;
Begin
 Temp := '';
 If(TesteITVGA2 = 1)Then
 Begin
  For Compteur := 0 to 7 do
  Begin
   Temp := Temp + Chr(Chaine[Compteur]);
  End;
 End
  else
 Temp := 'Inconnue';
 DateBIOSVideo := Temp;
End;

Function VersionBIOSVideo:StrVer;
Var Chaine    : Array[0..3] of Byte Absolute $C000:$0099;
    ChaineATI : Array[0..5] of Byte Absolute $C000:$011F;
    Temp      : String[7];
    Compteur  : Byte;
Begin
 Temp := '';
 If(TesteATIVGA = 1)Then
 Begin
  For Compteur := 0 to 5 do
  Begin
   Temp := Temp + Chr(ChaineATI[Compteur]);
  End;
 End
  else
 If(TesteITVGA2 = 1)Then
 Begin
  For Compteur := 0 to 3 do
  Begin
   Temp := Temp + Chr(Chaine[Compteur]);
  End;
 End
  else
 Temp := 'Inconnu';
 VersionBIOSVideo := Temp;
End;

Procedure ConfigurationVideo(Var Data:VideoData);
Var Registre        : Registers;
    Temp            : Array[0..63] of Byte;
    Pos             : Byte;
    TempPtr         : Pointer;
{ 00 = Aucun     00 = Aucun
  01 = MDA       01 = Monochrome
  02 = HGC       02 = Couleur
  03 = CGA       03 = Couleur Haute-Resolution
  04 = GS        04 = 5175
  05 = EGA       05 = Monochrome digital
  06 = PGA       06 = Couleur digital
  07 = MCGA      07 = Monochrome analogique
  08 = VGA       08 = Couleur analogique
  09 = IBM8514/A 09 = Analogique
  10 = IT-VGA2   10 = Nulle
  11 = ATI VGA   11 = Nulle
  FF = Inconnu   FF = Inconnu }

 Procedure NumeroCaseVGAPS2(Numero:Byte);
 Begin
  Case Temp[Numero] of
 $00 : Begin
	Data.Carte[Numero]    := 0; { Aucun }
	Data.Moniteur[Numero] := 0; { Aucun }
       End;
 $01 : Begin
	Data.Carte[Numero]    := MDA; { MDA }
	Data.Moniteur[Numero] := 1; { Monochrome }
       End;
 $02 : Begin
	Data.Carte[Numero]    := CGA; { CGA }
	Data.Moniteur[Numero] := 2; { Couleur }
       End;
 $04 : Begin
	Data.Carte[Numero]    := EGA; { EGA }
	Data.Moniteur[Numero] := 3; { Couleur Haute-Resolution }
       End;
 $05 : Begin
	Data.Carte[Numero]    := EGA; { EGA }
	Data.Moniteur[Numero] := 1; { Monochrome }
       End;
 $06 : Begin
	Data.Carte[Numero]    := PGA; { PGA }
	Data.Moniteur[Numero] := 4; { Moniteur 5175 }
       End;
 $07 : Begin
	Data.Carte[Numero]    := VGA; { VGA }
	Data.Moniteur[Numero] := 7; { Monochrome Analogique }
       End;
 $08 : Begin
	Data.Carte[Numero]    := VGA; { VGA }
	Data.Moniteur[Numero] := 8; { Couleur Analogique }
       End;
 $0A : Begin
	Data.Carte[Numero]    := MCGA; { MCGA }
	Data.Moniteur[Numero] := 6; { Couleur digital }
       End;
 $0B : Begin
	Data.Carte[Numero]    := MCGA; { MCGA }
	Data.Moniteur[Numero] := 5; { Monochrome digital }
       End;
 $0C : Begin
	Data.Carte[Numero]    := MCGA; { MCGA }
	Data.Moniteur[Numero] := 8; { Couleur Analogique }
       End;
 $FF : Begin
	Data.Carte[Numero]    := $FF; { Inconnue }
	Data.Moniteur[Numero] := $FF; { Inconnue }
       End;
  End;
 End;

Begin
 With Registre do With Data do
 Begin
  ROMBIOS[0] := False;
  ROMBIOS[1] := False;
  AH := $1A;
  AL := $00;
  Intr($10,Registre);
  If(AL = $1A)Then { Fonction support‚ ? }
  Begin
   Temp[0] := BL;
   Temp[1] := BH;
    { Combien de M‚moire ? }
   For Pos := 1 DownTo 0 do
   Begin
    NumeroCaseVGAPS2(Pos);
    Memoire[Pos] := 0;
    Case Carte[Pos] of
     VGA : Begin { VGA ? }
	    ROMBIOS[Pos] := True;
	    Memoire[Pos] := 262144;
            If(TesteATIVGA = 1)Then Carte[Pos] := 11
             else
	    If(TesteITVGA2 = 1)Then Carte[Pos] := ITVGA2
	     else
	    Begin
	     GetIntVec($7F,TempPtr);
	     If(Mem[Seg(TempPtr):Ofs(TempPtr)] <> $CF)Then
	     Begin
	      GetIntVec($F7,TempPtr);
	      If(Mem[Seg(TempPtr):Ofs(TempPtr)] <> $CF)Then
	       { Si Int F7h <> CFh alors IBM8514/A }
	      Begin
	       Carte[Pos]   := 9;
	       Memoire[Pos] := 524288;
	      End;
	     End;
	    End;
	   End;
     EGA : Begin { EGA ? }
	    ROMBIOS[Pos] := True;
	    AH := $12;
	    BL := $10;
	    Intr($10,Registre);
	    Memoire[Pos] := (BL+1)*65536;
	   End;
     CGA : Memoire[Pos]  := 16384; { CGA ? }
     MDA : Begin { MDA ? }
	    If(TesteHGC = 1)Then { HGC ? }
	    Begin
	     Carte[Pos] := HGC;
	     If(Port[$3BF] and 2=2)Then Memoire[Pos] := 65536
				   Else Memoire[Pos] := 32768;
	    End
	     else
	    Memoire[Pos]  := 4096; { 4Ko }
	   End;
    End;
   End;
  End
   else
  Begin
    { Teste EGA }
   ROMBIOS[Pos] := True;
   AH := $12;
   BL := $10;
   Intr($10,Registre);
   If(BL <> $10)Then { EGA ? }
   Begin
    If(MemW[$0040:$63] = $3D4)Then Pos := 0
			      Else Pos := 1;
    Carte[Pos] := EGA; { EGA }
    If(CL = $0B)Then Moniteur[Pos] := $01 else { Monochrome }
    If(CL = $08)Then Moniteur[Pos] := $02      { Couleur }
		Else Moniteur[Pos] := $03; { Multi Sync }
    Memoire[Pos] := (BL+1)*65536;
   End;
   If(Teste6845($3D4) = 1)Then { CGA ? }
   Begin
    If(MemW[$0040:$63] = $3D4)Then Pos := 0
			      Else Pos := 1;
    Carte[Pos]    := CGA;   { CGA }
    Moniteur[Pos] := $02;   { Couleur }
    Memoire[Pos]  := 16384; { 16Ko }
   End;
   If(Teste6845($3B4) = 1)Then { MDA ? }
   Begin
    If(MemW[$0040:$63] = $3B4)Then Pos := 0
			      Else Pos := 1;
    Moniteur[Pos] := $01; { Monochrome }
    If(TesteHGC = 1)Then { HGC ? }
    Begin
     Carte[Pos] := HGC;
     If(Port[$3BF] and 2=2)Then Memoire[Pos] := 65536
			   Else Memoire[Pos] := 32768;
    End
     else
    Begin
     Carte[Pos]    := MDA;  { MDA }
     Moniteur[Pos] := $01;  { Monochrome }
     Memoire[Pos]  := 4096; { 4Ko }
    End;
   End;
  End;
  For Pos := 0 to 1 do
  Begin
   If(Carte[Pos] > 5)Then
   Begin
    Date[Pos] := DateBIOSVideo;
    Version[Pos] := VersionBIOSVideo;
   End
    else
   Begin
    Date[Pos]    := 'Absent';
    Version[Pos] := 'Absent';
   End;
  End;
 End;
End;

Function DriverMouse:Byte;
Var TempPtr : Pointer;
Begin
 GetIntVec($F7,TempPtr);
 If(Mem[Seg(TempPtr):Ofs(TempPtr)] <> $CF)Then DriverMouse := 1
					  Else DriverMouse := 0;
End;

Function TesteXMS:Byte;
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AX := $4300;
  Intr($2F,Registre);
  If(AL = $80)Then TesteXMS := 1
	      Else TesteXMS := 0;
 End;
End;

Function TesteCDROM:Byte;
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AX := $1500;
  BX := $0000;
  Intr($2F,Registre);
  TesteCDROM := BX;
 End;
End;

Function SoftWareProprietaireInterruption(Numero:Byte):Byte;
Var TempPtr : Pointer;
{ Retourne :

   0 = Nulle,
   1 = BIOS,
   2 = DOS,
   3 = IRQ,
   4 = Fichier }
Begin
 GetIntVec(Numero,TempPtr);
 If(Numero in [$08..$0F])or
   ((Mem[$FFFF:$0E]=252)and(Numero in [$70..$77]))Then { IRQ ? }
 Begin
  SoftWareProprietaireInterruption := 3;
 End
  else
 If(Seg(TempPtr) = 0)and(Ofs(TempPtr) = 0)Then { Nulle ? }
 Begin
  SoftWareProprietaireInterruption := 0;
 End
  else
 If(Seg(TempPtr) > $BFFF)Then { BIOS ? }
 Begin
  SoftWareProprietaireInterruption := 1;
 End
  else
 Begin
  If(Mem[Seg(TempPtr):Ofs(TempPtr)] <> $CF)and
    (Numero in [$33,$60..$66,$7F,$F7])Then
  Begin
   SoftWareProprietaireInterruption := 4;
  End
   else
  Begin
   SoftWareProprietaireInterruption := 2;
  End;
 End;
End;

Function TesteSB2F:Byte;
Var Chaine   : Array[0..22] of Byte Absolute $C800:$14F9;
    Temp     : String[31];
    Compteur : Byte;
Begin
 Temp := '';
 For Compteur := 0 to 22 do
 Begin
  Temp := Temp + Chr(Chaine[Compteur]);
 End;
 If(Temp = 'Super Bios II Formatter')Then TesteSB2F := 1
				     Else TesteSB2F := 0;
End;

Function NomMachine:String;
Var Chaine : String[15];

 Function RtnChn(Seg,Ofs:Word;Nombre:Byte):String;
 Var Temp     : String[15];
     Compteur : Byte;
 Begin
  Temp := '';
  For Compteur := 0 to Nombre do
  Begin
   Temp := Temp + Chr(Mem[Seg:Ofs+Compteur]);
  End;
  RtnChn := Temp;
 End;

Begin
 If(RtnChn($F000,$4,12)='AAAAMMMMIIII')Then Chaine := 'American Megatrend' else
 If(RtnChn($FFFE,$A,5)='COMPAQ')Then Chaine := 'COMPAG' else
 If(RtnChn($FC05,0,7)='OLIVETTI')Then Chaine := 'OLIVETTI' else
 If(RtnChn($FE00,4,5)='Tandon')Then Chaine := 'Tandon' else
 If(RtnChn($FC02,$B,4)='Tandy')Then Chaine := 'Tandy' else
 If(RtnChn($FFFC,2,3)='WANG')Then Chaine := 'WANG' else
 If(RtnChn($FE00,3,3)='WYSE')Then Chaine := 'WYSE' else
 If(RtnChn($FB00,0,5)='Zenith')Then Chaine := 'Zenith' else
 If(RtnChn($FC2F,$F,5)='Zenith')Then Chaine := 'Zenith' else
 If(RtnChn($FE00,$E,2)='IBM')Then Chaine := 'IBM'
  else
 Chaine := 'Machine "clone"';
 NomMachine := Chaine;
End;

Function Joystick:Byte;
Var Registre : Registers;
Begin
 Joystick := 0;
 If(Mem[$FFFF:$E] in [$FF,$FE,$FD])Then { PC,XT,PC Junior ? }
 Begin
  If(MemW[$0040:$10] and $4000 = $4000)Then Joystick := 1;
 End
  else
 If(Mem[$FFFF:$E] = $FC)Then { AT ? }
 Begin
  With Registre do
  Begin
   AH := $84;
   DX := $00;
   Intr($15,Registre);
   If(AL <> 0)Then Joystick := 1;
  End;
 End
  else
 Begin { La derniŠre possiblit‚ est d'interroger
	 le port joystick lui mˆme }
  If(Port[$201] <> 0)Then Joystick := 1;
 End;
End;

Function DateBIOS:String;
Var Chaine   : Array[0..7] of Byte Absolute $FFFF:$5;
    Temp     : String[15];
    Compteur : Byte;
Begin
 Temp := '';
 For Compteur := 0 to 7 do
 Begin
  Temp := Temp + Chr(Chaine[Compteur]);
 End;
 DateBIOS := Temp;
End;

(*******************************************************************)
(*  Fonction    : Teste Super Bios II Formatter                    *)
(*******************************************************************)
(*  Entr‚e      : Aucun                                            *)
(*  Sortie      : TesteSB2F retourne 1 pour pr‚sent et 0 absent.   *)
(*******************************************************************)

Function ModeleSB2F:String;
Var Chaine   : Array[0..22] of Byte Absolute $C800:$1528;
    Temp     : String[31];
    Compteur : Byte;
Begin
 If(TesteSB2F = 1)Then
 Begin
  Temp := '';
  For Compteur := 0 to 15 do Temp := Temp + Chr(Chaine[Compteur]);
 End
  else
 Temp := '';
 ModeleSB2F := Temp;
End;

Function VerSB2F:String;
Var Chaine   : Array[0..22] of Byte Absolute $C800:$1516;
    Temp     : String[31];
    Compteur : Byte;
Begin
 If(TesteSB2F = 1)Then
 Begin
  Temp := '';
  For Compteur := 0 to 2 do Temp := Temp + Chr(Chaine[Compteur]);
 End
  else
 Temp := '';
 VerSB2F := Temp;
End;

Function DateSB2F:String;
Var Chaine   : Array[0..22] of Byte Absolute $C800:$153E;
    Temp     : String[31];
    Compteur : Byte;
Begin
 If(TesteSB2F = 1)Then
 Begin
  Temp := '';
  For Compteur := 0 to 3 do Temp := Temp + Chr(Chaine[Compteur]);
 End
  else
 Temp := '';
 DateSB2F := Temp;
End;

end.