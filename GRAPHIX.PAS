(*********************************************************************)
(*  Unit‚        : GRAPHIX                                           *)
(*  Description  : Manipulation de l'‚cran graphique.                *)
(*********************************************************************)
(*  Auteur       : Sylvain Maltais                                   *)
(*  Date Cr‚‚    : 1992/02/26                                        *)
(*  Date modifi‚ : 1992/02/26                                        *)
(*********************************************************************)
(*  RequŠre      : þ Turbo Pascal 6                                  *)
(*                 þ Carte graphique                                 *)
(*********************************************************************)

UNIT GRAPHIX;

(*********************************************************************)
                             INTERFACE
(*********************************************************************)

Const CouleurCourant : Byte = 15;
      PageCourant    : Byte = 0;

Procedure BoitePlaine(X1,Y1,X2,Y2:Word);
Procedure BoiteVide(X1,Y1,X2,Y2:Word);
Procedure CerclePlain(X,Y,Rayon:Word);
Procedure CercleVide(X,Y,Rayon:Word);
Procedure EllipsePlain(X,Y,Rayon:Word;Fraction:Real);
Procedure EllipseVide(X,Y,Rayon:Word;Fraction:Real);
Procedure TraceLigne(X1,Y1,X2,Y2:Word);
Procedure TraceLigneHorizontal(X1,Y,X2:Word);
Procedure TraceLigneVertical(X,Y1,Y2:Word);
Procedure Point(X,Y:Word);
Function ColonnePixel:Word;
Function LignePixel:Word;
Function ModeGraphique:Boolean;
Function NombreCouleur:Word;

(*********************************************************************)
                            IMPLEMENTATION
(*********************************************************************)

Uses DOS;

 {  Y2-Y1     B
   ÄÄÄÄÄÄÄ = ÄÄÄ = M = Pente
    X2-X1     A }

Procedure CerclePlain(X,Y,Rayon:Word);
Const Fin  : Real = 11/7;
Var Saut   : Real;
    Boucle : Real;
    TempA  : Word;
    TempB  : Word;
Begin
 Saut   := Fin / (Rayon * 2);
 Boucle := 0;
 Repeat
  TempA := Trunc(Cos(Boucle) * Rayon);
  TempB := Trunc(Sin(Boucle) * Rayon);
  TraceLigneHorizontal(X+TempA,Y+TempB,X-TempA);
  TraceLigneHorizontal(X+TempA,Y-TempB,X-TempA);
  Boucle := Boucle + Saut;
 Until (Boucle > Fin);
End;

Procedure CercleVide(X,Y,Rayon:Word);
Const Fin  : Real = 11/7;
Var Saut   : Real;
    Boucle : Real;
    TempA  : Word;
    TempB  : Word;
Begin
 Saut   := Fin / (Rayon * 2);
 Boucle := 0;
 Repeat
  TempA := Trunc(Cos(Boucle) * Rayon);
  TempB := Trunc(Sin(Boucle) * Rayon);
  Point(X+TempA,Y+TempB);
  Point(X+TempA,Y-TempB);
  Point(X-TempA,Y+TempB);
  Point(X-TempA,Y-TempB);
  Boucle := Boucle + Saut;
 Until (Boucle > Fin);
End;

Procedure EllipsePlain(X,Y,Rayon:Word;Fraction:Real);
Const Fin  : Real = 11/7;
Var Saut   : Real;
    Boucle : Real;
    TempA  : Word;
    TempB  : Word;
Begin
 Saut   := Fin / (Rayon * 2 * Fraction);
 Boucle := 0;
 Repeat
  TempA := Trunc(Cos(Boucle) * Rayon * Int(Fraction));
  TempB := Trunc(Sin(Boucle) * Rayon * Frac(Fraction));
  TraceLigneHorizontal(X+TempA,Y+TempB,X-TempA);
  TraceLigneHorizontal(X+TempA,Y-TempB,X-TempA);
  Boucle := Boucle + Saut;
 Until (Boucle > Fin);
End;

Procedure EllipseVide(X,Y,Rayon:Word;Fraction:Real);
Const Fin  : Real = 11/7;
Var Saut   : Real;
    Boucle : Real;
    TempA  : Word;
    TempB  : Word;
Begin
 Saut   := Fin / (Rayon * 2 * Fraction);
 Boucle := 0;
 Repeat
  TempA := Trunc(Cos(Boucle) * Rayon * Int(Fraction));
  TempB := Trunc(Sin(Boucle) * Rayon * Frac(Fraction));
  Point(X+TempA,Y+TempB);
  Point(X+TempA,Y-TempB);
  Point(X-TempA,Y+TempB);
  Point(X-TempA,Y-TempB);
  Boucle := Boucle + Saut;
 Until (Boucle > Fin);
End;

Procedure BoitePlaine(X1,Y1,X2,Y2:Word);
Var Compteur : Word;
Begin
 For Compteur := Y1 to Y2 do TraceLigneHorizontal(X1,Compteur,X2);
End;

Procedure BoiteVide(X1,Y1,X2,Y2:Word);
Begin
 TraceLigneHorizontal(X1,Y1,X2);
 TraceLigneHorizontal(X1,Y2,X2);
 TraceLigneVertical(X1,Y1,Y2);
 TraceLigneVertical(X2,Y1,Y2);
End;

Procedure TraceLigne(X1,Y1,X2,Y2:Word);
Var M        : Real;
    Compteur : Word;
Begin
 If(X1 = X2)Then TraceLigneVertical(X1,Y1,Y2) else
 If(Y1 = Y2)Then TraceLigneHorizontal(X1,Y1,X2)
  else
 Begin
  M := (Y2-Y1) / (X2-X1);
  For Compteur := X1 to X2 do Point(Compteur,Trunc(M * Compteur));
 End;
End;

Procedure TraceLigneHorizontal(X1,Y,X2:Word);
Var Compteur : Word;
Begin
 For Compteur := X1 to X2 do Point(Compteur,Y);
End;

Procedure TraceLigneVertical(X,Y1,Y2:Word);
Var Compteur : Word;
Begin
 For Compteur := Y1 to Y2 do Point(X,Compteur);
End;

Procedure Point(X,Y:Word);
Var Registre : Registers;
Begin
 With Registre do
 Begin
  AH := $0C;
  AL := CouleurCourant;
  BH := PageCourant;
  CX := X;
  DX := Y;
  Intr($10,Registre);
 End;
End;

Function ColonnePixel:Word;
Begin
 ColonnePixel := MemW[$0040:$4A] * 8;
End;

Function LignePixel:Word;
Var Ligne : Word;
Begin
 Ligne := (Mem[$0040:$84]+1) * Mem[$0040:$85];
 If(Ligne = 0)Then Ligne := 200;
 If(Ligne = 592)Then Ligne := 600;
 LignePixel := Ligne;
End;

Function ModeGraphique:Boolean;
Var Registre : Registers;
    Couleur  : Word;
Begin
 With Registre do
 Begin
  AH := $0D;
  BH := 0;
  CX := 0;
  DX := 0;
  Intr($10,Registre);
  Couleur := AL;
  CouleurCourant := 1;
  Point(0,0);
  AH := $0D;
  BH := 0;
  CX := 0;
  DX := 0;
  Intr($10,Registre);
  If(AL = 1)Then ModeGraphique := True
            Else ModeGraphique := False;
  CouleurCourant := Couleur;
  Point(0,0);
 End;
End;

Function NombreCouleur:Word;
Var Registre : Registers;
    Tableau  : Array[0..63] of Byte;
    Temp     : Word;
    Couleur  : Word;
Begin
 With Registre do
 Begin
  AH := $1B;
  BX := $0000;
  ES := Seg(Tableau);
  DI := Ofs(Tableau);
  Intr($10,Registre);
  Temp := Tableau[39] + (Tableau[40] * 256);
  If(AL = $1B)and(Temp <> 0)Then
  Begin
   NombreCouleur := Temp;
  End
   else
  Begin
   AH := $0D;
   BH := 0;
   CX := 0;
   DX := 0;
   Intr($10,Registre);
   Couleur := AL;
   CouleurCourant := 255;
   Point(0,0);
   AH := $0D;
   BH := 0;
   CX := 0;
   DX := 0;
   Intr($10,Registre);
   CouleurCourant := Couleur;
   Point(0,0);
   NombreCouleur := AL+1;
   If(ModeGraphique = False)and(AL = 0)Then NombreCouleur := 4;
  End;
 End;
End;

Begin
End.