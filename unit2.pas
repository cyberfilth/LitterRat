unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmDocDeets }

  TfrmDocDeets = class(TForm)
    btnSave: TButton;
    btnQuit: TButton;
    edAuthor: TEdit;
    edTitle: TEdit;
    lblAuthor: TLabel;
    lblTitle: TLabel;
    procedure btnQuitClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmDocDeets: TfrmDocDeets;

implementation

uses
  unit1;

{$R *.lfm}

{ TfrmDocDeets }

procedure TfrmDocDeets.btnSaveClick(Sender: TObject);
begin
  if (edTitle.Text <> '') then
  begin
    Unit1.documentName := edTitle.Text;
    Form1.Caption := 'LitterRat - ' + Unit1.documentName + ' *';
    unit1.FileSaved := False;
  end;
  if (edAuthor.Text <> '') then
  begin
    Unit1.documentAuthor := edAuthor.Text;
    unit1.FileSaved := False;
  end;
  frmDocDeets.Close;
end;

procedure TfrmDocDeets.FormCreate(Sender: TObject);
begin
  edTitle.Text := Unit1.documentName;
  edAuthor.Text := Unit1.documentAuthor;
end;

procedure TfrmDocDeets.btnQuitClick(Sender: TObject);
begin
  frmDocDeets.Close;
end;

end.
