(************************************************************************)
(*  Unit‚        : Ecran Malte                                          *)
(*  Version      : pour IBM, 1.01                                       *)
(*  Description  : Gestion de l'‚cran texte                             *)
(************************************************************************)
(*  Groupe       : Les Chevaliers de Malte                              *)
(*  Auteur       : Sylvain Maltais                                      *)
(*  Date cr‚e    : 1991/11/01                                           *)
(*  Date modifi‚ : 1992/03/07                                           *)
(************************************************************************)
(*  RequŠre      : þ Turbo Pascal 6                                     *)
(*                 þ Carte vid‚o                                        *)
(************************************************************************)

Unit EcranM;

(*******************************************)
		 Interface
(*******************************************)

Type Binaire = 0..1;

Const OmbreEcranM       : Binaire = 1;
      EspaceCadreEcranM : Binaire = 0;
      ExclureEcranM     : Binaire = 0;
      CouleurSelecte    : Byte    = 94;
      CadreFormat       : Array[0..8] of Byte = (218,196,191,179,
						 179,192,196,217,196);
      OffSetEcranM      : Word = 0;
      SegExcEcranM      : Word = 0;
      OfsExcEcranM      : Word = 0;

 { Gestion Mode Video }

Procedure ModeVideo(Mode:Byte;Claire:Binaire);

Function ModeActuel:Byte;
Function ModeInitiale:Byte;
Function Minimum0(Nombre:Byte):Byte;
Function MaximumColonne(Nombre:Byte):Byte;

 { Gestion Police CaractŠre }

Procedure ChargePolice(AscII:Word;Table,Matrice,Nombre:Byte;Buffer:Pointer);
Procedure DensiteLigne(Nombre:Byte);

 { Gestion du Curseur }

Procedure DetermineFormatCurseur(Var Debut,Fin:Byte);
Procedure FermeCurseur;
Procedure FixeFormatCurseur(Debut,Fin:Byte);
Procedure Localise(X,Y:Byte);
Procedure LocaliseDebut;
Procedure OuvreCurseur;

Function XPosition:Byte;
Function YPosition:Byte;

 { Gestion des Page }

Procedure CopiePage(Source,Target:Byte);
Procedure FixePageTravail(Page:Byte);
Procedure FixePageVisuel(Page:Byte);

 { Ecrit du texte }

Procedure CentreEcriture(Y:Byte;Phrase:String;Couleur:Byte);
Procedure Ecrit(X,Y:Byte;Phrase:String;Couleur:Byte);
Procedure EcritBIOS(Phrase:String);
Procedure EcritBIOSCouleur(Phrase:String;Couleur:Byte);
Procedure EcritBIOSTraite(Chaine:String);
Procedure EcritChoix(X,Y:Byte;Phrase:String;Couleur1,Couleur2:Byte);
Procedure EcritSpecial(X,Y:Byte;Phrase:String);
Procedure EcritUnCarac(X,Y,Caractere:Byte);
Procedure EcritUnCaractere(X,Y,Caractere,Couleur:Byte);
Procedure EcritUnAttribut(X,Y,Couleur:Byte);
Procedure TurboEcrit(Phrase:String);

 { Gestion des palettes }

Procedure Clignotement(Nombre:Byte);
Procedure FixePaletteEGA(Palette,Couleur:Byte);
Procedure FixePaletteRGB(Palette:Word;Bleu,Vert,Rouge:Byte);

 { Exclure zone ‚cran }

Procedure ClaireBoiteMemoire(X1,Y1,X2,Y2:Byte);
Procedure ClaireMemoire(Valeur:Byte);

 { Divers }

Function Adresse:Word;
Function Colonne:Word;
Function Ligne:Byte;

Procedure BarSelecte(X1,Y,X2,Couleur:Byte);
Procedure BarSelecteVert(X,Y1,Y2,Couleur:Byte);
Procedure BarTexteHori(X1,Y,X2,Caractere,Couleur:Byte);
Procedure BarTexteVert(X,Y1,Y2,Caractere,Couleur:Byte);
Procedure BoiteCaractere(X1,Y1,X2,Y2,Couleur:Byte);
Procedure CadreChoix(X1,Y1,X2,Y2:Byte;Chaine:String);
Procedure CadrePlain(X1,Y1,X2,Y2,Couleur:Byte);
Procedure CadreVide(X1,Y1,X2,Y2,Couleur:Byte);
Procedure ClaireColonne(Colonne,Caractere,Couleur:Byte);
Procedure ClaireLigne(Ligne,Caractere,Couleur:Byte);
Procedure ClaireLigneTrans(Ligne,Caractere:Byte);
Procedure ClaireSuite(Ligne,Colonne:Byte;Longeur:Word;Caractere,Couleur:Byte);
Procedure Construction(Nombre:Byte);
Procedure FenetreTapiserie(X1,Y1,X2,Y2,MotifA,MotifB,AttributA,AttributB:Byte);
Procedure MouveFenetre(X1,Y1,X2,Y2,Couleur:Byte;Direction:Integer);
Procedure Selecte(X1,Y,X2,Couleur:Byte);
Procedure Tapiserie(Y1,Y2,MotifA,MotifB,AttributA,AttributB:Byte);
Procedure FixeCadre(Const Buffer);
Procedure BoiteMemoire(X1,Y1,X2,Y2,Couleur:Byte);

(*******************************************)
	       Implementation
(*******************************************)

Uses DOS;

Const ColorNormal : Byte = 15;

Var Compteur : Word;
    ColonneP : Word Absolute $0040 : $4A;
    Page     : Byte Absolute $0040 : $62;
    VidAdr   : Word;
	
Procedure FixeCadre(Const Buffer);Begin
End;	

Procedure BoiteMemoire(X1,Y1,X2,Y2,Couleur:Byte);Begin
End;

Function Minimum0(Nombre:Byte):Byte;
Begin
 If(Nombre < 0)Then Nombre := 0;
 Minimum0 := Nombre;
End;

Function MaximumColonne(Nombre:Byte):Byte;
Var Col : Byte;
Begin
 Col := ColonneP - 1;
 If(Nombre > Col)Then Nombre := Col;
 MaximumColonne := Nombre;
End;

Procedure DetermineFormatCurseur(Var Debut,Fin:Byte);
Begin
 Debut := Mem[$0040:$60];
 Fin   := Mem[$0040:$61];
End;

Procedure FixeFormatCurseur(Debut,Fin:Byte);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AH := $01;
  CH := Debut;
  CL := Fin;
  Intr($10,Registre);
 End;
End;

Procedure FixePaletteEGA(Palette,Couleur:Byte);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AX := $1000;
  BH := Couleur;
  BL := Palette;
  Intr($10,Registre);
 End;
End;

Procedure FixePaletteRGB(Palette:Word;Bleu,Vert,Rouge:Byte);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AX := $1010;
  BX := Palette;
  CH := Vert;
  CL := Bleu;
  DH := Rouge;
  Intr($10,Registre);
 End;
End;

Function ModeActuel:Byte;
Begin
 ModeActuel := Mem[$0040:$49];
End;

Function Paire(Nombre:Word):Byte;
Begin
 Paire := Nombre and 1;
End;

Function Impaire(Nombre:Word):Byte;
Begin
 Impaire := 1 - (Nombre and 1);
End;

Function Adresse:Word;
Var ModeVideo : Byte Absolute $0040:$49;
Begin
 Case ModeVideo of
       $07 : Adresse := $B000;
  $0D..$13 : Adresse := $A000;
  $25,$29,$2D..$30,$37,$38 : Adresse := $A000;
   else
  Adresse := $B800;
 End;
End;

Function Colonne:Word;
Begin
 Colonne := ColonneP;
End;

Function Ligne:Byte; { Ligne - 1 }
Var Temp : Byte;
Begin
 Temp := Mem[$0040:$84];
 If(Temp = 0)Then Ligne := 24
             Else Ligne := Temp;
End;

Function XPosition:Byte;
Begin
 XPosition := Mem[$0040:$50+Page*2];
End;

Function YPosition:Byte;
Begin
 YPosition := Mem[$0040:$50+Page*2+1];
End;

Procedure Localise(X,Y:Byte);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AH := $02;
  BH := Page;
  DL := X;
  DH := Y;
  Intr($10,Registre);
 End;
End;

Procedure FermeCurseur;
Assembler;
ASM PUSH AX;
    PUSH CX;
    MOV  AH,$01;
    MOV  CX,$2020;
    INT  $10;
    POP  CX;
    POP  AX;
END;

Procedure OuvreCurseur;
Assembler;
ASM PUSH AX;
    PUSH BX;
    PUSH CX;
    MOV  AX,$1200;
    MOV  BL,$34;
    INT  $10;
    MOV  AH,$01;
    MOV  CX,$0607;
    INT  $10;
    POP  CX;
    POP  BX;
    POP  AX;
END;

Procedure BarSelecte(X1,Y,X2,Couleur:Byte);
Var X : Byte;
Begin
 For X := X1 to X2 do EcritUnAttribut(X,Y,Couleur);
End;

Procedure BarSelecteVert(X,Y1,Y2,Couleur:Byte);
Var Y : Byte;
Begin
 For Y := Y1 to Y2 do EcritUnAttribut(X,Y,Couleur);
End;

Procedure BoiteCaractere(X1,Y1,X2,Y2,Couleur:Byte);
Var X,Y : Byte;
    Seg : Word;
    Tmp : Word;
    Bse : Word;
Begin
 Seg := Adresse;
 Tmp := Couleur * 256;
 For Y := Y1 to Y2 do
 Begin
  Bse := Y * ColonneP;
  For X := X1 to X2 do
  Begin
   If(ExclureEcranM=0)or((ExclureEcranM=1)and
    (Mem[SegExcEcranM:OfsExcEcranM+X+Bse] = 0))Then
   Begin
    MemW[Seg:(X+Bse)*2+OffSetEcranM] := Tmp;
   End;
  End;
 End;
End;

Procedure EcritUnCarac(X,Y,Caractere:Byte);
Begin
 If(ExclureEcranM=0)or((ExclureEcranM=1)and
   (Mem[SegExcEcranM:OfsExcEcranM+X+Y*ColonneP] = 0))Then
 Begin
  Mem[Adresse:(X+Y*ColonneP)*2+OffSetEcranM] := Caractere;
 End;
End;

Procedure EcritUnCaractere(X,Y,Caractere,Couleur:Byte);
Begin
 If(ExclureEcranM=0)or((ExclureEcranM=1)and
   (Mem[SegExcEcranM:OfsExcEcranM+X+Y*ColonneP] = 0))Then
 Begin
  MemW[Adresse:(X+Y*ColonneP)*2+OffSetEcranM] := Caractere + Couleur * 256;
 End;
End;

Procedure EcritSpecial(X,Y:Byte;Phrase:String);
Var Compteur  : Byte;
    Boucle    : Byte;
    XPos      : Word;
    YPos      : Byte;
    Longeur   : Byte;
    Carac     : Byte;
    DerColor  : Byte;

 Procedure EcritUnCaractere(X,Y,Caractere,Couleur:Byte);
 Begin
  If(ExclureEcranM=0)or((ExclureEcranM=1)and
    (Mem[SegExcEcranM:OfsExcEcranM+X+Y*ColonneP] = 0))Then
  Begin
   MemW[VidAdr:(X+Y*ColonneP)*2+OffSetEcranM] := Caractere + Couleur * 256;
  End;
 End;

Begin
 VidAdr := Adresse;
 XPos   := X;
 YPos   := Y;
 For Compteur := 0 to Length(Phrase)-1 do
 Begin
  If(Phrase[Compteur+1] > #31)Then
  Begin
   EcritUnCaractere(XPos,YPos,Ord(Phrase[Compteur+1]),ColorNormal);
   Inc(XPos);
  End
   else
  Case Phrase[Compteur+1] of
   #1 : Begin
         XPos := X;
         Inc(YPos);
        End;
   #3 : Begin
         Inc(Compteur);
         DerColor := ColorNormal;
         ColorNormal := Ord(Phrase[Compteur+1]);
        End;
   #4 : Begin
         Inc(Compteur,2);
         Longeur := Ord(Phrase[Compteur]);
         Carac   := Ord(Phrase[Compteur+1]);
         If(Longeur > 0)Then
         Begin
          For Boucle := 1 to Longeur do
          Begin
           EcritUnCaractere(XPos+Boucle,YPos,Carac,ColorNormal);
          End;
         End;
         Inc(XPos,Longeur);
        End;
   #9 : Begin
         For Boucle := 1 to 8 do EcritUnCaractere(XPos+Boucle,YPos,32,ColorNormal);
         Inc(XPos,7);
        End;
  #16 : Begin
         Inc(Compteur,2);
         XPos := Ord(Phrase[Compteur]);
         YPos := Ord(Phrase[Compteur+1]);
        End;
  #18 : Begin
         Boucle := ColorNormal;
         ColorNormal := DerColor;
         DerColor := Boucle;
        End;
  #29 : Begin
         ClaireLigne(YPos,32,ColorNormal);
        End;
  #30 : Begin
         Inc(Compteur);
         Carac := Ord(Phrase[Compteur+1]);
         EcritUnCarac(XPos,YPos,Carac);
         Inc(XPos);
        End;
  #31 : Begin
         EcritUnAttribut(XPos,YPos,ColorNormal);
        End;
  End;
 End;
End;

Procedure BarTexteHori(X1,Y,X2,Caractere,Couleur:Byte);
Var X     : Byte;
    Seg   : Word;
    Attr  : Word;
    Base  : Word;
    XBase : Word;
Begin
 Seg  := Adresse;
 Attr := Caractere + Couleur * 256;
 Base := Y * ColonneP;
 For X := X1 to X2 do
 Begin
  XBase := Base + X;
  If(ExclureEcranM=0)or((ExclureEcranM=1)and
    (Mem[SegExcEcranM:OfsExcEcranM+XBase] = 0))Then
  Begin
   MemW[Seg:XBase*2+OffSetEcranM] := Attr;
  End;
 End;
End;

Procedure BarTexteVert(X,Y1,Y2,Caractere,Couleur:Byte);
Var Y    : Byte;
    Seg  : Word;
    Attr : Word;
Begin
 Seg := Adresse;
 Attr := Caractere + Couleur * 256;
 For Y := Y1 to Y2 do
 Begin
  If(ExclureEcranM=0)or((ExclureEcranM=1)and
    (Mem[SegExcEcranM:OfsExcEcranM+X+Y*ColonneP] = 0))Then
  Begin
   MemW[Seg:(X+Y*ColonneP)*2+OffSetEcranM] := Attr;
  End;
 End;
End;

Procedure EcritUnAttribut(X,Y,Couleur:Byte);
Begin
 If(ExclureEcranM=0)or((ExclureEcranM=1)and
   (Mem[SegExcEcranM:OfsExcEcranM+X+Y*ColonneP] = 0))Then
 Begin
  Mem[Adresse:(X+Y*ColonneP)*2+1+OffSetEcranM] := Couleur;
 End;
End;

Procedure Ecrit(X,Y:Byte;Phrase:String;Couleur:Byte);
Var Compteur : Byte;
    Segment  : Word;
    Color    : Word;
    Base     : Word;
    XBase    : Word;
Begin
 Segment := Adresse;
 Base    := X + Y * ColonneP;
 Color   := Couleur * 256;
 For Compteur := 0 to Length(Phrase)-1 do
 Begin
  XBase := Base + Compteur;
  If(ExclureEcranM=0)or((ExclureEcranM=1)and
    (Mem[SegExcEcranM:OfsExcEcranM+XBase] = 0))Then
  Begin
   MemW[Segment:XBase*2+OffSetEcranM] := Ord(Phrase[Compteur+1]) + Color;
  End;
 End;
End;

Procedure EcritChoix(X,Y:Byte;Phrase:String;Couleur1,Couleur2:Byte);
Var Compteur : Byte;
Begin
 EcritUnCaractere(X,Y,Ord(Phrase[1]),Couleur1);
 Ecrit(X+1,Y,Copy(Phrase,2,255),Couleur2);
End;

Procedure TurboEcrit(Phrase:String);
Var Compteur,Position : Byte;
    Registre          : Registers;
Begin
 With Registre do
 Begin
  Position := XPosition;
  For Compteur := 0 to Length(Phrase)-1 do
  Begin
   Localise(Position+Compteur,YPosition);
   AL := Ord(Phrase[Compteur+1]);
   AH := 10;
   BH := Page;
   BL := 15;
   CX := 1;
   Intr($10,Registre);
  End;
  Localise(Position+Compteur+1,YPosition);
 End;
End;

Procedure EcritBIOS(Phrase:String);
Var Compteur,Position : Byte;
    LignePos          : Byte;
    XTemp,YTemp       : Byte;
    Registre          : Registers;
Begin
 With Registre do
 Begin
  Position := XPosition;
  LignePos := YPosition;
  For Compteur := 0 to Length(Phrase)-1 do
  Begin
   XTemp := Position + Compteur;
   YTemp := LignePos;
   If(XTemp > (ColonneP-1))Then
   Begin
    Dec(XTemp,ColonneP);
    Inc(YTemp);
   End;
   Localise(XTemp,YTemp);
   AL := Ord(Phrase[Compteur+1]);
   AH := 9;
   BH := Page;
   BL := 15;
   CX := 1;
   Intr($10,Registre);
  End;
  Localise(Position+Compteur+1,YPosition);
 End;
End;

Procedure EcritBIOSCouleur(Phrase:String;Couleur:Byte);
Var Compteur,Position : Byte;
    Registre          : Registers;
Begin
 With Registre do
 Begin
  Position := XPosition;
  For Compteur := 0 to Length(Phrase)-1 do
  Begin
   Localise(Position+Compteur,YPosition);
   AL := Ord(Phrase[Compteur+1]);
   AH := 9;
   BH := Page;
   BL := Couleur;
   CX := 1;
   Intr($10,Registre);
  End;
  Localise(Position+Compteur+1,YPosition);
 End;
End;

Procedure CentreEcriture(Y:Byte;Phrase:String;Couleur:Byte);
Begin
 Ecrit((ColonneP - Length(Phrase)) div 2,Y,Phrase,Couleur);
End;

Procedure CadreVide(X1,Y1,X2,Y2,Couleur:Byte);
Begin
 BarTexteVert(X1,Y1+1,Y2-1,CadreFormat[3],Couleur);
 BarTexteVert(X2,Y1+1,Y2-1,CadreFormat[4],Couleur);
 BarTexteHori(X1+1,Y1,X2-1,CadreFormat[1],Couleur);
 BarTexteHori(X1+1,Y2,X2-1,CadreFormat[6],Couleur);
 EcritUnCaractere(X1,Y1,CadreFormat[0],Couleur);
 EcritUnCaractere(X1+1,Y1,CadreFormat[8],Couleur);
 EcritUnCaractere(X1,Y2,CadreFormat[5],Couleur);
 EcritUnCaractere(X2,Y1,CadreFormat[2],Couleur);
 EcritUnCaractere(X2,Y2,CadreFormat[7],Couleur);
End;

Procedure CadrePlain(X1,Y1,X2,Y2,Couleur:Byte);
Var Compteur : Byte;
    X,Y      : Byte;
Begin
 BoiteCaractere(X1,Y1,X2,Y2,Couleur);
 If(OmbreEcranM = 1)Then
 Begin
  BarSelecte(X1+2,Y2+1,X2+2,7);
  BarSelecteVert(X2+1,Y1+1,Y2+1,7);
  BarSelecteVert(X2+2,Y1+1,Y2+1,7);
 End;
 If(EspaceCadreEcranM = 1)Then CadreVide(X1+2,Y1+1,X2-2,Y2-1,Couleur)
			  Else CadreVide(X1,Y1,X2,Y2,Couleur);
End;

Procedure ClaireColonne(Colonne,Caractere,Couleur:Byte);
Var Compteur : Byte;
Begin
 For Compteur := 0 to Ligne do EcritUnCaractere(Colonne,Compteur,Caractere,Couleur);
End;

Procedure ClaireLigne(Ligne,Caractere,Couleur:Byte);
Begin
 BarTexteHori(0,Ligne,ColonneP-1,Caractere,Couleur);
End;

Procedure ClaireLigneTrans(Ligne,Caractere:Byte);
Var Compteur : Byte;
    Seg      : Word;
    Base     : Word;
    XBase    : Word;
Begin
 Seg  := Adresse;
 Base := Ligne * ColonneP;
 For Compteur := 0 to ColonneP - 1 do
 Begin
  XBase := Compteur + Base;
  If(ExclureEcranM=0)or((ExclureEcranM=1)and
    (Mem[SegExcEcranM:OfsExcEcranM+XBase] = 0))Then
  Begin
   Mem[Seg:XBase*2+OffSetEcranM] := Caractere;
  End;
 End;
End;

Procedure ClaireSuite(Ligne,Colonne:Byte;Longeur:Word;Caractere,Couleur:Byte);
Var Registre : Registers;
Begin
 Localise(Colonne,Ligne);
 With Registre do
 Begin
  AL := Caractere;
  AH := $09;
  BL := Couleur;
  BH := Page;
  CX := Longeur;
  Intr($10,Registre);
 End;
 Localise(Colonne,Ligne);
End;

Procedure MouveFenetre(X1,Y1,X2,Y2,Couleur:Byte;Direction:Integer);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  If(Direction < 0)Then AH := $06 else
  If(Direction > 0)Then AH := $07;
  AL := Abs(Direction);
  CL := X1;
  CH := Y1;
  DL := X2;
  DH := Y2;
  BL := Couleur;
  Intr($10,Registre);
 End;
End;

Procedure CadreChoix(X1,Y1,X2,Y2:Byte;Chaine:String);
Begin
 BoiteCaractere(X1,Y1,X2,Y2,31);
 EcritUnCarac(X1,Y1,218);
 EcritUnCarac(X1,Y2,192);
 EcritUnCarac(X2,Y1,191);
 EcritUnCarac(X2,Y2,217);
 EcritUnCarac(X1,Y1+1,$B3);
 EcritUnCarac(X2,Y1+1,$B3);
 EcritUnCarac(X1,Y1+2,195);
 EcritUnCarac(X2,Y1+2,180);
 For Compteur := X1+1 to X2-1 do
 Begin
  EcritUnCarac(Compteur,Y1,$C4);
  EcritUnCarac(Compteur,Y1+2,$C4);
  EcritUnCarac(Compteur,Y2,$C4);
 End;
 For Compteur := Y1+3 to Y2-1 do
 Begin
  EcritUnCarac(X1,Compteur,$B3);
  EcritUnCarac(X2,Compteur,$B3);
 End;
 BarSelecte(X1+2,Y2,X2+2,7);
 BarSelecteVert(X2+1,Y1+1,Y2+1,7);
 BarSelecteVert(X2+2,Y1+1,Y2+1,7);
 Ecrit(X1+2,Y1+1,Chaine,CouleurSelecte);
End;

Procedure ChargePolice(AscII:Word;Table,Matrice,Nombre:Byte;Buffer:Pointer);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AX := $1100;
  BH := Matrice;
  BL := Table;
  CX := Nombre;
  DX := AscII;
  BP := Ofs(Buffer^);
  ES := Seg(Buffer^);
  Intr($10,Registre);
 End;
End;

Procedure Clignotement(Nombre:Byte);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AH := $10;
  AL := $03;
  BL := Nombre;
  Intr($10,Registre);
 End;
End;

Procedure ModeVideo(Mode:Byte;Claire:Binaire);
Var Registre : Registers;
Begin
 Registre.AX := Mode + (1-Claire) * $80;
 Intr($10,Registre);
End;

Procedure DensiteLigne(Nombre:Byte);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AH := $12;
  AL := Nombre;
  BL := $30;
  Intr($10,Registre);
 End;
End;

Procedure EcritBIOSTraite(Chaine:String);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  Chaine := Chaine + '$';
  AH := $09;
  DS := Seg(Chaine[1]);
  DX := Ofs(Chaine[1]);
  MsDos(Registre);
 End;
End;

Procedure Tapiserie(Y1,Y2,MotifA,MotifB,AttributA,AttributB:Byte);
Var Ligne : Byte;
    Base  : Word;
    TempA : Word;
    TempB : Word;
    Seg   : Word;
Begin
 TempA := MotifA + 256 * AttributA;
 TempB := MotifB + 256 * AttributB;
 Seg   := Adresse;
 For Ligne := Y1 to Y2 do
 Begin
  For Compteur := 0 to (ColonneP div 2) - 1 do
  Begin
   Base  := Ligne * ColonneP + Compteur * 2;
   If(ExclureEcranM=0)or((ExclureEcranM=1)and
     (Mem[SegExcEcranM:OfsExcEcranM+Base+Paire(Ligne)] = 0))Then
   Begin
    MemW[Seg:OffSetEcranM + (Base + Paire(Ligne))*2]   := TempA;
   End;
   If(ExclureEcranM=0)or((ExclureEcranM=1)and
     (Mem[SegExcEcranM:OfsExcEcranM+Base+Impaire(Ligne)] = 0))Then
   Begin
    MemW[Seg:OffSetEcranM + (Base + Impaire(Ligne))*2] := TempB;
   End;
  End;
 End;
End;

Procedure FenetreTapiserie(X1,Y1,X2,Y2,MotifA,MotifB,AttributA,AttributB:Byte);
Var Ligne  : Byte;
    Base   : Word;
    TempA  : Word;
    TempB  : Word;
    Seg    : Word;
    Deb    : Byte;
    Fin    : Byte;
    Pai    : Byte;
    Imp    : Byte;
    TLigne : Word;
    TBase  : Word;
    XBase  : Word;
Begin
 Seg   := Adresse;
 Deb   := X1 div 2;
 Fin   := X2 div 2;
 TempA := MotifA + 256 * AttributA;
 TempB := MotifB + 256 * AttributB;
 For Ligne := Y1 to Y2 do
 Begin
  Pai    := Paire(Ligne);
  Imp    := Impaire(Ligne);
  TLigne := Ligne * ColonneP;
  For Compteur := Deb to Fin do
  Begin
   Base  := TLigne + Compteur * 2;
   TBase := OffSetEcranM + Base;
   XBase := OfsExcEcranM + Base;
   If(ExclureEcranM=0)or((ExclureEcranM=1)and
     (Mem[SegExcEcranM:XBase+Pai] = 0))Then
   Begin
    MemW[Seg:(TBase+Pai)*2] := TempA;
   End;
   If(ExclureEcranM=0)or((ExclureEcranM=1)and
     (Mem[SegExcEcranM:XBase+Imp] = 0))Then
   Begin
    MemW[Seg:(TBase+Imp)*2] := TempB;
   End;
  End;
 End;
End;

Function ModeInitiale:Byte;
Begin
 If(MemW[$0040:$10] and 48 in [16,32])Then ModeInitiale := 3 else
 If(MemW[$0040:$10] and 48 = 48)Then ModeInitiale := 7
  else
 Begin
  If(MemW[$0040:$63] = $3D4)Then ModeInitiale := 3
			    Else ModeInitiale := 7;
 End;
End;

Procedure LocaliseDebut;
Begin
 Localise(0,0);
End;

Procedure Selecte(X1,Y,X2,Couleur:Byte);
Var Compteur : Byte;
Begin
 For Compteur := X1 to X2 do EcritUnAttribut(Compteur,Y,Couleur);
End;

Procedure Construction(Nombre:Byte);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AH := $12;
  BL := $36;
  AL := 1 - (Nombre and 1);
  Intr($10,Registre);
 End;
End;

Procedure FixePageVisuel(Page:Byte);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AH := $05;
  AL := Page;
  Intr($10,Registre);
 End;
End;

Procedure FixePageTravail(Page:Byte);
Begin
 OffSetEcranM := Page * MemW[$0040:$4C];
End;

Procedure CopiePage(Source,Target:Byte);
Var Taille : Word Absolute $0040:$4C;
    Seg    : Word;
Begin
 Seg := Adresse;
 Move(Mem[Seg:Taille*Source],Mem[Seg:Taille*Target],Taille);
End;

Procedure ClaireBoiteMemoire(X1,Y1,X2,Y2:Byte);
Var CompteurX : Byte;
    CompteurY : Byte;
    Base      : Word;
Begin
 For CompteurY := Y1 to Y2 do
 Begin
  Base := CompteurY * ColonneP + OfsExcEcranM;
  For CompteurX := X1 to X2 do
  Begin
   Mem[SegExcEcranM:CompteurX+Base] := 1;
  End;
 End;
End;

Procedure ClaireMemoire(Valeur:Byte);
Begin
 FillChar(Mem[SegExcEcranM:OfsExcEcranM],MemW[$0040:$4C] div 2,Valeur);
End;

End.