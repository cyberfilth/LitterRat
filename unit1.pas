unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
  ExtCtrls, StdCtrls, jsonConf, fpjson, StrUtils, LCLType, unit2;

type
  textType = (tNone, tCharacter, tScene, tDialogue, tTransition, tAction);

type

  { TForm1 }

  TForm1 = class(TForm)
    btnCharacter: TButton;
    btnDialogue: TButton;
    btnScene: TButton;
    btnTransition: TButton;
    btnAction: TButton;
    FindDialog1: TFindDialog;
    lblCharacters: TLabel;
    characterList: TListBox;
    MainMenu1: TMainMenu;
    divider1: TMenuItem;
    divider2: TMenuItem;
    divider3: TMenuItem;
    divider6: TMenuItem;
    rcFind: TMenuItem;
    rcDivider1: TMenuItem;
    mnuFind: TMenuItem;
    rcAction: TMenuItem;
    rcTransition: TMenuItem;
    rcScene: TMenuItem;
    rcDialogue: TMenuItem;
    rcCharacter: TMenuItem;
    mnuSaveAs: TMenuItem;
    mnuDocDeets: TMenuItem;
    mnuNew: TMenuItem;
    divider5: TMenuItem;
    mnuExit: TMenuItem;
    mnuHideSide: TMenuItem;
    mnuWhite: TMenuItem;
    mnuDark: TMenuItem;
    mnuLight: TMenuItem;
    mnuThemes: TMenuItem;
    mnuExpHTML: TMenuItem;
    mnuExpFountain: TMenuItem;
    mnuImpFountain: TMenuItem;
    mnuImportExport: TMenuItem;
    mnuSave: TMenuItem;
    mnuOpen: TMenuItem;
    ImportFountain: TOpenDialog;
    loadScript: TOpenDialog;
    ExportFountain: TSaveDialog;
    rightClickMenu: TPopupMenu;
    saveScript: TSaveDialog;
    exportHTML: TSaveDialog;
    screenplay: TMemo;
    mnuFile: TMenuItem;
    mnuDocument: TMenuItem;
    panelScript: TPanel;
    panelButtons: TPanel;
    divider4: TMenuItem;
    StatusBar1: TStatusBar;
    procedure btnActionClick(Sender: TObject);
    procedure btnCharacterClick(Sender: TObject);
    procedure btnDialogueClick(Sender: TObject);
    procedure btnSceneClick(Sender: TObject);
    procedure btnTransitionClick(Sender: TObject);
    procedure characterListClick(Sender: TObject);
    procedure characterListMouseEnter(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnuDarkClick(Sender: TObject);
    procedure mnuDocDeetsClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuExpFountainClick(Sender: TObject);
    procedure mnuExpHTMLClick(Sender: TObject);
    procedure mnuFindClick(Sender: TObject);
    procedure mnuHideSideClick(Sender: TObject);
    procedure mnuImpFountainClick(Sender: TObject);
    procedure mnuLightClick(Sender: TObject);
    procedure mnuOpenClick(Sender: TObject);
    procedure mnuNewClick(Sender: TObject);
    procedure mnuSaveAsClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure mnuWhiteClick(Sender: TObject);
    procedure screenplayChange(Sender: TObject);
    procedure screenplayKeyPress(Sender: TObject; var Key: char);
    procedure updateStatusBar;
    (* Checks if character name is already on the list *)
    function alreadyInList(characterName: string): boolean;
    (* Stops program closing if document not saved *)
    procedure closeWithoutSaving;
  private
    FFoundPos: integer;

  public

  end;

const
  VERSION = '0.9.5';

var
  Form1: TForm1;
  currentStatus: textType;
  Filepath, documentName, documentAuthor, savedFileLocation: string;
  FileSaved: boolean;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnCharacterClick(Sender: TObject);
var
  characterName, lineContents: string;
begin
  lineContents := screenplay.Lines[screenplay.CaretPos.y + 1];

  (* If character name selected *)
  if (Length(screenplay.SelText) > 0) then
  begin
    (* Format the text and add to list of characters *)
    characterName := screenplay.SelText;
    // Check if the following line has text
    if (lineContents <> '') and (lineContents <> characterName) then
      // if it does, don't add a newline
      screenplay.SelText := UpperCase(screenplay.SelText)
    else
      // else, add a newline
      screenplay.SelText := UpperCase(screenplay.SelText) + sLineBreak;
    if (alreadyInList(characterName) = False) then
    begin
      characterList.Items.Add(UpperCase(characterName));
      (* Display character list *)
      if characterList.Visible = False then
      begin
        lblCharacters.Visible := True;
        characterList.Visible := True;
      end;
    end;
    screenplay.SetFocus;
    currentStatus := tDialogue;
  end
  (* If no character name selected *)
  else
  begin
    currentStatus := tCharacter;
  end;
  updateStatusBar;
  screenplay.SetFocus;
end;

procedure TForm1.btnActionClick(Sender: TObject);
begin
  currentStatus := tAction;
  updateStatusBar;
  screenplay.SetFocus;
end;

procedure TForm1.btnDialogueClick(Sender: TObject);
begin
  currentStatus := tDialogue;
  updateStatusBar;
  screenplay.SetFocus;
end;

procedure TForm1.btnSceneClick(Sender: TObject);
begin
  (* If scene description selected *)
  if (Length(screenplay.SelText) > 0) then
  begin
    (* Format the text *)
    screenplay.SelText := UpperCase(screenplay.SelText) + sLineBreak + sLineBreak;
    screenplay.SetFocus;
    currentStatus := tCharacter;
  end
  (* If no scene description selected *)
  else
  begin
    currentStatus := tScene;
  end;
  updateStatusBar;
  screenplay.SetFocus;
end;

procedure TForm1.btnTransitionClick(Sender: TObject);
begin
  (* If transition selected *)
  if (Length(screenplay.SelText) > 0) then
  begin
    (* Format the text *)
    if (screenplay.SelText[1] <> '>') then
      screenplay.SelText :=
        '>' + UpperCase(screenplay.SelText) + sLineBreak + sLineBreak
    else
      screenplay.SelText := UpperCase(screenplay.SelText) + sLineBreak + sLineBreak;
    screenplay.SetFocus;
    currentStatus := tScene;
  end
  (* If no transition selected *)
  else
  begin
    currentStatus := tTransition;
  end;
  updateStatusBar;
  screenplay.SetFocus;
end;

procedure TForm1.characterListClick(Sender: TObject);
begin
  screenplay.SelText := characterList.GetSelectedText + sLineBreak;
  screenplay.SetFocus;
  currentStatus := tDialogue;
end;

procedure TForm1.characterListMouseEnter(Sender: TObject);
begin
  characterList.Hint := 'Click on a character name to add them to the screenplay';
end;

procedure TForm1.FindDialog1Find(Sender: TObject);
begin
  with Sender as TFindDialog do
  begin
    FFoundPos := PosEx(FindText, screenplay.Lines.Text, FFoundPos + 1);
    if FFoundPos > 0 then
    begin
      screenplay.SelStart := FFoundPos - 1;
      screenplay.SelLength := Length(FindText);
      screenplay.SetFocus; // Memo must be activate, or selection will not be displayed
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Filepath := '';
  FileSaved := True;
  Form1.Caption := 'LitterRat';
  documentName := '';
  StatusBar1.Panels.Items[2].Text := '';
  documentAuthor := '';
  savedFileLocation := '';
  mnuSave.Enabled := False;
  (* Hide Character list *)
  if (characterList.items.Count = 0) then
  begin
    lblCharacters.Visible := False;
    characterList.Visible := False;
  end;
  (* Set colour theme *)
  mnuLightClick(nil);
  (* Clear text *)
  screenplay.Clear;
  currentStatus := tNone;
  StatusBar1.Panels.Items[1].Text := 'LitterRat v' + VERSION;
  updateStatusBar;
end;

procedure TForm1.mnuDarkClick(Sender: TObject);
begin
  screenplay.Color := clBlack;
  screenplay.Font.Color := clCream;
  mnuWhite.Checked := False;
  mnuDark.Checked := True;
  mnuLight.Checked := False;
end;

procedure TForm1.mnuDocDeetsClick(Sender: TObject);
begin
  frmDocDeets.edTitle.Text := documentName;
  frmDocDeets.edAuthor.Text := documentAuthor;
  frmDocDeets.ShowModal;
  StatusBar1.Panels.Items[2].Text := documentName;
end;

procedure TForm1.mnuExitClick(Sender: TObject);
begin
  if (FileSaved = False) then
    closeWithoutSaving
  else
    Form1.Close;
end;

procedure TForm1.mnuExpFountainClick(Sender: TObject);
var
  fountainFile: TStringList;
  i: integer;
begin
  if ExportFountain.Execute then
  begin
    fountainFile := TStringList.Create;
    try
      fountainFile.Add('Title: _**' + documentName + '**_');
      fountainFile.Add('Author: ' + documentAuthor);
      fountainFile.Add(' ');
      fountainFile.Add(' ');
      fountainFile.Add(' ');
      fountainFile.Add(' ');
      fountainFile.Add(' ');
      fountainFile.Add(' ');

      // Add the lines from TMemo individually
      for i := 0 to screenplay.Lines.Count - 1 do
      begin
        fountainFile.Add(screenplay.Lines[i]);
      end;
      fountainFile.SaveToFile(ExportFountain.FileName);
    finally
      fountainFile.Free;
    end;
  end;
end;

procedure TForm1.mnuExpHTMLClick(Sender: TObject);
var
  F: TextFile;
  HTMLstring, transitionString, ExportFilename: string;
  i: integer;
begin
  if exportHTML.Execute then
    ExportFilename := ExtractFilePath(exportHTML.FileName) +
      ExtractFileName(exportHTML.FileName);

  HTMLstring := '';

  (* Add HTML skeleton *)
  HTMLstring := HTMLstring + '<!DOCTYPE html>' + sLineBreak + '<html>' +
    sLineBreak + '<head>' + sLineBreak + '<title>' + documentName +
    '</title>' + sLineBreak + '<style>' + sLineBreak + 'div {text-align: center;}' +
    sLineBreak + '.transition {text-align: right;}' + sLineBreak +
    'body {font-family: "Courier New", Courier; font-size: 12px}' +
    sLineBreak + '</style>' + sLineBreak + '</head>' + sLineBreak +
    '<body>' + sLineBreak;
  (* Add title page *)
  HTMLstring := HTMLstring + '<br /><br /><br /><br /><br /><br /><br />' + sLineBreak;
  HTMLstring := HTMLstring + '<div><strong>' + documentName +
    '</strong><br />Author: ' + documentAuthor + '</div>';
  HTMLstring := HTMLstring +
    '<br /><br /><br /><br /><br /><p style="page-break-before: always">' + sLineBreak;

  (* Add script *)
  for i := 0 to screenplay.Lines.Count - 1 do
  begin
    (* Blank lines *)
    if (screenplay.Lines[i] = '') or (screenplay.Lines[i] = ' ') then
      HTMLstring := HTMLstring + '<br /><br />' + sLineBreak

    (* Scene description *)
    else if (LeftStr(screenplay.Lines[i], 3) = 'EXT') or
      (LeftStr(screenplay.Lines[i], 3) = 'INT') or
      (LeftStr(screenplay.Lines[i], 3) = 'EST') then
      HTMLstring := HTMLstring + '<strong>' + screenplay.Lines[i] +
        '</strong>' + sLineBreak

    (* Transition *)
    else if (LeftStr(screenplay.Lines[i], 1) = '>') then
    begin
      transitionString := screenplay.Lines[i];
      HTMLstring := HTMLstring + '<div class="transition">' +
        RightStr(transitionString, Length(transitionString) - 1) + sLineBreak + '</div>';
    end

    else
      HTMLstring := HTMLstring + '<div>' + sLineBreak + screenplay.Lines[i] +
        sLineBreak + '</div>';
  end;
  HTMLstring := HTMLstring + '</body>' + sLineBreak + '</html>' + sLineBreak;

  AssignFile(F, ExportFilename);
  try
    ReWrite(F);
    Write(F, HTMLstring);
  finally
    CloseFile(F);
  end;
end;

procedure TForm1.mnuFindClick(Sender: TObject);
begin
  with FindDialog1 do
  begin
    if frEntireScope in Options then
      FFoundPos := 0
    else
      FFoundPos := screenplay.SelStart;
    Execute;
  end;
end;

procedure TForm1.mnuHideSideClick(Sender: TObject);
begin
  if (panelButtons.Visible = True) then
  begin
    panelButtons.Visible := False;
    mnuHideSide.Checked := True;
  end
  else
  begin
    panelButtons.Visible := True;
    mnuHideSide.Checked := False;
  end;
end;

procedure TForm1.mnuImpFountainClick(Sender: TObject);
begin
  if ImportFountain.Execute then
    screenplay.Lines.LoadFromFile(ImportFountain.Filename);
end;

procedure TForm1.mnuLightClick(Sender: TObject);
begin
  screenplay.Color := clCream;
  screenplay.Font.Color := clBlack;
  mnuWhite.Checked := False;
  mnuDark.Checked := False;
  mnuLight.Checked := True;
end;

procedure TForm1.mnuOpenClick(Sender: TObject);
var
  JSONText, importFileName: string;
  JSONData: TJSONData;
  ScriptArray, CharactersArray: TJSONArray;
  i: integer;
  FileContent, screenplayContent: TStringList;
begin
  if loadScript.Execute then
  begin
    if FileExists(loadScript.Filename) then
      importFileName := loadScript.Filename;

    savedFileLocation := loadScript.Filename;
    FileContent := TStringList.Create;
    screenplayContent := TStringList.Create;
    try
      try
        (* Clear current document *)
        screenplay.Lines.Clear;
        characterList.Clear;
        characterList.Visible := False;
        lblCharacters.Visible := False;
        documentName := '';
        StatusBar1.Panels.Items[2].Text := '';
        documentAuthor := '';
        currentStatus := tNone;

        (* Load the entire file content into FileContent *)
        FileContent.LoadFromFile(importFileName);
        (* Join the lines of FileContent to form JSONText *)
        JSONText := FileContent.Text;
        (* Parse the JSONText as a JSON object *)
        JSONData := GetJSON(JSONText);
        try
          if JSONData <> nil then
          begin
            documentName := JSONData.FindPath('Title').AsString;
            StatusBar1.Panels.Items[2].Text := JSONData.FindPath('Title').AsString;
            documentAuthor := JSONData.FindPath('Author').AsString;
            CharactersArray := JSONData.FindPath('Characters') as TJSONArray;
            if Assigned(CharactersArray) then
            begin
              for i := 0 to CharactersArray.Count - 1 do
              begin
                characterList.Items.Add(CharactersArray.Items[i].AsString);
              end;
            end;
            ScriptArray := JSONData.FindPath('Script') as TJSONArray;

            if Assigned(ScriptArray) then
            begin
              for i := 0 to ScriptArray.Count - 1 do
                screenplayContent.Add(ScriptArray.Items[i].AsString);
              (* Speeds up loading tmemo contents *)
              screenplay.Lines.Text := screenplayContent.Text;
            end;

          end
          else
          begin
            ShowMessage('Error parsing JSON.');
          end;
        finally
          JSONData.Free;
        end;
      except
        on E: EInOutError do
          ShowMessage('File handling error: ' + E.Message);
      end;
    finally
      FileContent.Free;
      screenplayContent.Free;
      if (characterList.items.Count > 0) then
      begin
        lblCharacters.Visible := True;
        characterList.Visible := True;
      end;
      Form1.Caption := 'LitterRat: ' + documentName;
      FileSaved := True;
      mnuSave.Enabled := True;
    end;
  end;
end;

procedure TForm1.mnuNewClick(Sender: TObject);
var
  Reply, BoxStyle: integer;
begin
  if (FileSaved = False) then
  begin
    BoxStyle := MB_ICONQUESTION + MB_YESNO;
    Reply := Application.MessageBox(
      'Do you want to start a new document without saving?',
      'File not saved', BoxStyle);
    if Reply = idYes then
      (* Delete current content *)
    begin
      screenplay.Lines.Clear;
      characterList.Clear;
      characterList.Visible := False;
      lblCharacters.Visible := False;
      Filepath := '';
      FileSaved := True;
      mnuSave.Enabled := False;
      Form1.Caption := 'LitterRat';
      documentName := '';
      StatusBar1.Panels.Items[2].Text := '';
      documentAuthor := '';
      savedFileLocation := '';
      currentStatus := tNone;
    end
    else
      Exit;
  end
  else
  begin
    screenplay.Lines.Clear;
    characterList.Clear;
    characterList.Visible := False;
    lblCharacters.Visible := False;
    Filepath := '';
    FileSaved := True;
    mnuSave.Enabled := False;
    Form1.Caption := 'LitterRat';
    documentName := '';
    StatusBar1.Panels.Items[2].Text := '';
    documentAuthor := '';
    currentStatus := tNone;
  end;
end;

procedure TForm1.mnuSaveAsClick(Sender: TObject);
var
  c: TJSONConfig;
begin
  c := TJSONConfig.Create(nil);
  try
    try
      c.Formatted := True;
      if saveScript.Execute then
        c.Filename := ExtractFilePath(saveScript.FileName) +
          ExtractFileName(saveScript.FileName);
    except
      exit;
    end;
    savedFileLocation := c.Filename;
    c.SetValue('LitterRat Version', VERSION);
    c.SetValue('Title', documentName);
    c.SetValue('Author', documentAuthor);
    if (characterList.items.Count > 0) then
      c.SetValue('Characters', characterList.items);
    c.SetValue('Script', screenplay.Lines);
  finally
    c.Free;
  end;
  FileSaved := True;
  Form1.Caption := 'LitterRat - ' + documentName;
  mnuSaveAs.Enabled := True;
end;

procedure TForm1.mnuSaveClick(Sender: TObject);
var
  c: TJSONConfig;
begin
  c := TJSONConfig.Create(nil);
  try
    try
      c.Formatted := True;
      c.Filename := savedFileLocation;
    except
      exit;
    end;
    c.SetValue('LitterRat Version', VERSION);
    c.SetValue('Title', documentName);
    c.SetValue('Author', documentAuthor);
    if (characterList.items.Count > 0) then
      c.SetValue('Characters', characterList.items);
    c.SetValue('Script', screenplay.Lines);
  finally
    c.Free;
  end;
  FileSaved := True;
  Form1.Caption := 'LitterRat - ' + documentName;
  mnuSaveAs.Enabled := True;
end;

procedure TForm1.mnuWhiteClick(Sender: TObject);
begin
  screenplay.Color := clWhite;
  screenplay.Font.Color := clBlack;
  mnuWhite.Checked := True;
  mnuDark.Checked := False;
  mnuLight.Checked := False;
end;

procedure TForm1.screenplayChange(Sender: TObject);
begin
  if (FileSaved = True) then
  begin
    FileSaved := False;
    Form1.Caption := Form1.Caption + ' *';
  end;
end;

procedure TForm1.screenplayKeyPress(Sender: TObject; var Key: char);
var
  Row, Col: integer;
  characterName: string;
begin
  (* Triggered when the ENTER key is pressed *)
  if (Key = #13) then
  begin
    // select last line
    Col := screenplay.CaretPos.x;
    Row := screenplay.CaretPos.y;

    (* Character *)
    if currentStatus = tCharacter then
    begin
      screenplay.SelStart := screenplay.SelStart + screenplay.SelLength - Col;
      screenplay.SelLength := Length(screenplay.Lines[Row]);
      // capitalise last line
      if (Length(screenplay.SelText) > 0) then
      begin
        (* Format the text and add to list of characters *)
        characterName := screenplay.SelText;
        {$IFDEF Linux}
        screenplay.SelText := UpperCase(screenplay.SelText) + sLineBreak;
        {$ENDIF}
        {$IFDEF Windows}
        screenplay.SelText := UpperCase(screenplay.SelText);
        {$ENDIF}
        if (alreadyInList(characterName) = False) then
        begin
          characterList.Items.Add(UpperCase(characterName));
          (* Display character list *)
          if characterList.Visible = False then
          begin
            lblCharacters.Visible := True;
            characterList.Visible := True;
          end;
        end;
        screenplay.SetFocus;
        currentStatus := tDialogue;
      end;
    end

    (* Scene *)
    else if currentStatus = tScene then
    begin
      screenplay.SelStart := screenplay.SelStart + screenplay.SelLength - Col;
      screenplay.SelLength := Length(screenplay.Lines[Row]);
      // capitalise last line
      if (Length(screenplay.SelText) > 0) then
      begin
        (* Format the text *)
        {$IFDEF Linux}
        screenplay.SelText := UpperCase(screenplay.SelText) + sLineBreak + sLineBreak;
        {$ENDIF}
        {$IFDEF Windows}
        screenplay.SelText := UpperCase(screenplay.SelText) + sLineBreak;
         {$ENDIF}
        screenplay.SetFocus;
        currentStatus := tCharacter;
      end;
    end

    (* Transition *)
    else if currentStatus = tTransition then
    begin
      screenplay.SelStart := screenplay.SelStart + screenplay.SelLength - Col;
      screenplay.SelLength := Length(screenplay.Lines[Row]);
      // capitalise last line
      if (Length(screenplay.SelText) > 0) then
      begin
        (* Format the text *)
        if (screenplay.SelText[1] <> '>') then
          screenplay.SelText :=
            '>' + UpperCase(screenplay.SelText) + sLineBreak + sLineBreak
        else
          screenplay.SelText := UpperCase(screenplay.SelText) + sLineBreak + sLineBreak;
        screenplay.SetFocus;
        currentStatus := tScene;
      end;
    end

    (* Action *)
    else if currentStatus = tAction then
    begin
      screenplay.SetFocus;
      currentStatus := tCharacter;
    end;

  end;
  updateStatusBar;
end;

procedure TForm1.updateStatusBar;
begin
  if (currentStatus <> tNone) then
  begin
    case currentStatus of
      tCharacter: StatusBar1.Panels.Items[0].Text := 'Mode: Character name';
      tDialogue: StatusBar1.Panels.Items[0].Text := 'Mode: Dialogue';
      tScene: StatusBar1.Panels.Items[0].Text := 'Mode: Scene description';
      tTransition: StatusBar1.Panels.Items[0].Text := 'Mode: Transition';
      tAction: StatusBar1.Panels.Items[0].Text := 'Mode: Action';
    end;
  end;
end;

function TForm1.alreadyInList(characterName: string): boolean;
var
  i: integer;
begin
  Result := False;
  characterList.ClearSelection;
  for i := 0 to characterList.Items.Count - 1 do
    if (characterList.Items[i] = UpperCase(characterName)) then
    begin
      Result := True;
      exit;
    end;
end;

procedure TForm1.closeWithoutSaving;
var
  Reply, BoxStyle: integer;
begin
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  Reply := Application.MessageBox('Do you want to Exit without saving document?',
    'File not saved', BoxStyle);
  if Reply = idYes then Form1.Close
  else
    Exit;
end;

end.
