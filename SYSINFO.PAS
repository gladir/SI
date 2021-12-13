(********************************************************************)
(*  Programme    : SystŠme Information                              *)
(*  Version      : pour IBM, 1.01                                   *)
(*  Description  : Retourne des informations sur l'‚quipement de    *)
(*                 l'ordinateur.                                    *)
(********************************************************************)
(*  Groupe       : Les Chevaliers de Malte                          *)
(*  Auteur       : Sylvain Maltais                                  *)
(*  Date cr‚‚    : 1991/12/31                                       *)
(*  Date modifi‚ : 1992/02/27                                       *)
(********************************************************************)
(*  RequŠre      : þ Turbo Pascal 6                                 *)
(*                 þ Moniteur EGA et plus                           *)
(********************************************************************)

Program Systeme_Info;

{ Remarque : Ce programme s'adapte … la carte vid‚o graphique
             IT-VGA2 (Cardinal Tseng Labs 4000) et au divers
             mode vid‚o disponible. }

(********************************************************************)
(*                             Unit‚                                *)
(********************************************************************)

Uses DOS,       { Gestion des fonctions du DOS }
     Crt,       { Gestion du Contr“leur        }
     Fichier,   { Gestion des Fichiers         }
     EcranM,    { Gestion de l'Ecran de Texte  }
     Graphix,   { Gestion de l'Ecran Graphique }
     Equipe;

(********************************************************************)
(*                           Constante                              *)
(********************************************************************)

Type TypeCadre = Array[0..8]of Byte;

Const PaletteCadre_E1 : TypeCadre = (128,219,219,158,159,156,163,157,129);
      PaletteCadre_E2 : TypeCadre = (218,196,191,179,179,192,196,217,196);
      PaletteCadre_E3 : TypeCadre = (160,162,161,158,159,156,163,157,162);
      PaletteHex      : Array[0..15] of Char = '0123456789ABCDEF';
      Masque          : Array[0..13] of Byte = (128,192,224,240,248,
                                                252,254,248,248,184,
                                                28,28,0,0);
      Compteur1C      : Byte = 0;
      Couleur1C       : Byte = 1;
      PoBut           : Byte = 1; { Position des boutons }

      MaxMenu         = 7; { Maximum de Menu }
      MenuNormal      : Byte = $F9;
      ColorClock      : Byte = $F0;

       { ParamŠtre }

      FixeIntro       : Byte = 0;
      Fixe25          : Byte = 0;
      FixeMem         : Byte = 0;

  { Palette de caractŠre }

{$I PAL_E1.PAS  } (* Palette 8x14 pixels *)
{$I PAL_E2.PAS  } (* Palette 8x16 pixels *)

(*   { Equipement }

{$I EQUIPE.SI    } Information sur l'‚quipement *)

(********************************************************************)
(*                           Variable                               *)
(********************************************************************)

Var Touche     : Word;
    Original1C : Pointer;
    Video      : VideoData;

(********************************************************************)
(*                      D‚claration des proc‚dures                  *)
(********************************************************************)

Procedure AfficheBar; Forward;
Procedure AfficheCadreMemoire; Forward;
Procedure AfficheTouche(X1,Y1,X2,Y2,X3,Y3,X4,Y4:Byte); Forward;
Procedure AjustePaletteTouche; Forward;
Procedure Clock(X,Y:Byte); Forward;
Procedure DerniereLigne; Forward;
Procedure DesinstalleClignotement; Forward;
Procedure Horloge(X,Y:Byte); Forward;
Procedure Intro; Forward;
Procedure InitialiseEcran; Forward;
Procedure InstalleClignotement; Forward;
Procedure PerformanceProcesseur(X,Y:Byte); Forward;
Procedure Principal; Forward;
Procedure Quitter; Forward;
Procedure SelecteCommunication; Forward;
Procedure SelecteDisque; Forward;
Procedure SelecteMemoire; Forward;
Procedure SelecteProcesseur; Forward;
Procedure SelecteQuitte; Forward;
Procedure SelecteVideo; Forward;
Procedure SpeedInitialiseEcran; Forward;
Procedure SystemInfo; Forward;

(********************************************************************)
(*                      D‚claration des fonctions                   *)
(********************************************************************)

Function MenuCommunication:ShortInt; Forward;
Function MenuDisque:ShortInt; Forward;
Function MenuMemoire:ShortInt; Forward;
Function MenuProcesseur:ShortInt; Forward;
Function MenuQuitte:ShortInt; Forward;
Function MenuVideo:ShortInt; Forward;

(********************************************************************)
(*                       Fichier de donn‚e                          *)
(********************************************************************)

{$I CHAINE.SI    }  (* Gestion des variables *)

 { Gestion Clavier }

{$I CLAVIER.SI   }  (* Gestion du clavier *)
{$I QUESTION.PAS }  (* Gestion de Question *)

 { Gestion du SystŠme MS-DOS }

{$I SOURIS.SI    } (* Gestion de la souris *)
{$I DOSSHELL.SI  } (* Module "DOS Shell" *)
{$I QUITTE.SI    } (* Proc‚dure qui permette de quitter le SI *)

 { Gestion Ecran }

{$I INITECR.SI   } (* Proc‚dure d'initialisation de l'‚cran *)
{$I AFFKEY.SI    } (* Proc‚dure qui Affiche les Touches *)
{$I AFFMEM.SI    } (* Proc‚dure qui affiche l'‚tat de la m‚moire *)
{$I BAR.SI       } (* Divers proc‚dure de Bar du Menu *)
{$I FENETRE.SI   } (* Gestion des fenˆtres *)
{$I INTRO.SI     } (* Introduction *)
{$I MENU.SI      } (* Gestion des menus d‚roulants *)

 { Gestion Animation }

{$I RESIDENT.SI  }  (* Routine de programme r‚sident *)
{$I FLASH.SI     }  (* Routine de clignotment *)
{$I CLOCK.SI     }  (* Module d'Horloge *)

 { Tƒche information vid‚o }

{$I INFOVID.SI   } (* Tƒche Information Vid‚o *)
{$I SPEEDVID.SI  } (* Tƒche Information de la vitesse vid‚o *)
{$I TESTMODE.SI  } (* Tƒche de d‚monstraction des modes vid‚o *)
{$I BIOSINFO.SI  } (* Tƒche Information du BIOS Vid‚o *)
{$I INFOVGA.SI   } (* Tƒche Information VGA/PS2 *)
{$I TABPARM.SI   } (* Tƒche Information de la table de paramŠtre vid‚o *)

 { Tƒche information du processeur }

{$I PROCESS.SI   } (* Tƒche Information Processeur *)
{$I PERFPROC.SI  } (* Tƒche Information Performance du processeur *)

 { Tƒche information de la m‚moire }

{$I MAPBIOS.SI   } (* Tƒche Information de la m‚moire BIOS *)
{$I UMC.SI       } (* Tƒche Information sur l'usage de la m‚moire... *)

 { Tƒche information systŠme MS-DOS }

{$I SYSTEM.SI    } (* Tƒche Information du SystŠme MS-DOS *)

 { Tƒche information disque }

{$I EXTROM.SI    } (* Tƒche Information sur les extensions du Hard Disk *)

(********************************************************************)
(*  Proc‚dure   : Principal                                         *)
(*  Description : Gestion des diff‚rents possiblit‚ du programme.   *)
(********************************************************************)
(*  Entr‚e      : Aucun                                             *)
(*  Sortie      : Aucun                                             *)
(********************************************************************)

Procedure Principal;
Label Normal,Debut,16,25,26,33,46,47,48,50,Fin;
Var Position : ShortInt;
Begin
 FixeCadre(PaletteCadre_E1);
 HypocrytheInitialiseEcran;
 Repeat
  Intro;
 Until ((Lo(Touche) = 27)or(FixeIntro = 0)or
       ((Lo(Touche) = 0)and(Hi(Touche) = 45)));
 SegExcEcranM := Adresse;
 OfsExcEcranM := MemW[$0040:$4C];
 ClaireMemoire(0);
 FixePageTravail(0);
 AfficheCadreMemoire;
 If(Lo(Touche) in [27,67,99])Then Goto Normal;
 If(Lo(Touche) = 0)Then
 Begin
  Case Hi(Touche) of
   16 : Goto 16;
   25 : Goto 25;
   32 : Goto 33;
   45 : Begin
         CertainQuitter;
         If(Lo(Touche) in [79,111])Then Goto Fin;
        End;
   46 : Goto 46;
   47 : Goto 47;
   50 : Goto 50;
  End;
 End;
 Position := 0;
 Repeat
  Case Position of
   0 : InfoVideo((Colonne-57) div 2,(Ligne - 20) div 2);
   1 : BIOSVideo((Colonne-63) div 2,(Ligne - 20) div 2);
   2 : InfoVGAPS2((Colonne-39) div 2,(Ligne - 20) div 2);
   3 : SpeedVideo((Colonne-58) div 2,(Ligne - 20) div 2);
   4 : TableParam((Colonne-66) div 2,(Ligne-14) div 2);
   5 : TesteModeVideo;
   6 : Processeur((Colonne-62) div 2,(Ligne - 20) div 2);
   7 : PerformanceProcesseur((Colonne-63) div 2,(Ligne - 17) div 2);
   8 : UsageMemoireConventionnel((Colonne-55) div 2,(Ligne-16) div 2);
   9 : CarteBIOS((Colonne-53) div 2,(Ligne-16) div 2);
  10 : ExtensionROM((Colonne-34) div 2,(Ligne-12) div 2);
  End;
  If(Lo(Touche) = 0)Then
  Begin
   If(Hi(Touche) = 112)Then Intro;
  End
   else
  If(Lo(Touche) in [67,97])Then
  Begin
   If(Position > 0)Then Dec(Position)
                   Else Position := 10;
  End
   else
  If(Position < 10)Then Inc(Position)
                   Else Position := 0;
  If(Lo(Touche) = 0)and(Hi(Touche) = 45)Then
  Begin
   CertainQuitter;
   If(Lo(Touche) in [79,111])Then Goto Fin;
  End;
 Until (Lo(Touche) in [27,78,110]);
 Normal   : CopiePage(3,0);
 Debut    : Touche := LitClavier;
	    If(Lo(Touche) = 0)Then
	    Begin
	     Case Hi(Touche) of
              16 : Begin
               16 : Position := MenuQuitte;
                    Case Position of
                      1 : Goto Fin; { Quitter     }
                      0 : DOSShell; { DOS Shell   }
                     -2 : Goto 46;  { Menu Communication }
                     -1 : Goto 47;  { Menu Vid‚o  }
                      else
                     Write(^G);
                    End;
                    Touche   := 0;
                   End;
	      25 : Begin
	       25 : Position := MenuProcesseur;
	       26 : Case Position of
		     0 : Processeur((Colonne-62) div 2,(Ligne - 20) div 2);
                     1 : PerformanceProcesseur((Colonne-63) div 2,(Ligne - 17) div 2);
		    -2 : Goto 47; { Menu Video }
		    -1 : Goto 50; { Menu Memoire }
                      else
                     Write(^G);
		    End;
                    CopiePage(3,0);
		    Touche := 0;
		   End;
              32 : Begin
               33 : Position := MenuDisque;
                    Case Position of
                      4 : ExtensionROM((Colonne-34) div 2,(Ligne-12) div 2);
                     -2 : Goto 50; { Menu Memoire }
                     -1 : Goto 46; { Menu Communication }
                      else
                     Write(^G);
                    End;
                    CopiePage(3,0);
                    Touche := 0;
                   End;
              46 : Begin
               46 : Position := MenuCommunication;
                    Case Position of
                     -1 : Goto 16; { Menu Quitte }
		     -2 : Goto 33; { Menu Disque }
                      else
                     Write(^G);
                    End;
                   End;
	      47 : Begin
	       47 : Position := MenuVideo;
	       48 : Case Position of
		    -1 : Goto 25; { Menu Processeur }
		    -2 : Goto 16; { Menu Quitte }
		     0 : InfoVideo((Colonne-57) div 2,(Ligne - 20) div 2);
		     1 : BIOSVideo((Colonne-63) div 2,(Ligne - 20) div 2);
                     2 : InfoVGAPS2((Colonne-39) div 2,(Ligne - 20) div 2);
		     3 : SpeedVideo((Colonne-58) div 2,(Ligne - 20) div 2);
                     4 : TableParam((Colonne-66) div 2,(Ligne-14) div 2);
		     5 : TesteModeVideo;
                      else
                     Write(^G);
		    End;
                    If(Lo(Touche) in [65,97])Then
                    Begin
                     Touche := 0;
                     If(Position > 0)Then Dec(Position)
                                     Else Position := 5;
                     Goto 48;
                    End;
                    If(Lo(Touche) in [13,83,115])Then
                    Begin
                     Touche := 0;
                     If(Position < 5)Then Inc(Position)
                                     Else Position := 0;
                     Goto 48;
                    End;
                    CopiePage(3,0);
		    Touche := 0;
		   End;
              50 : Begin
               50 : Position := MenuMemoire;
                    Case Position of
                     0 : UsageMemoireConventionnel((Colonne-55) div 2,(Ligne-16) div 2);
                     6 : CarteBIOS((Colonne-53) div 2,(Ligne-16) div 2);
		    -2 : Goto 25;
		    -1 : Goto 33;
                      else
                     Write(^G);
		    End;
                    If(Lo(Touche) in [65,97])Then
                    Begin
                     Touche := 0;
                     If(Position > 0)Then Dec(Position)
                                     Else Position := 5;
                     Goto 50;
                    End;
                    If(Lo(Touche) in [13,83,115])Then
                    Begin
                     Touche := 0;
                     If(Position < 5)Then Inc(Position)
                                     Else Position := 0;
                     Goto 50;
                    End;
                    CopiePage(3,0);
		    Touche := 0;
                   End;
	     End;
	    End;
	    If Not((Lo(Touche) = 0)and(Hi(Touche) = 45))Then Goto Debut
             else
            Begin
             CertainQuitter;
             If(Lo(Touche) in [27,78,110])Then Goto Debut;
            End;
 Fin      : Quitter;
End;

{$I INITDTA.SI }

BEGIN { Main Program }
 InitData;
 InitSouris;
 Principal;
END.
