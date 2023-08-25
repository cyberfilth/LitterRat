unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, Menus, jsonConf, fpjson, StrUtils;

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
    characterList: TListBox;
    lblCharacters: TLabel;
    MainMenu1: TMainMenu;
    mnuExpHTML: TMenuItem;
    mnuDivider2: TMenuItem;
    mnuDivider: TMenuItem;
    mnuImportExport: TMenuItem;
    mnuExpFountain: TMenuItem;
    mnuImpFountain: TMenuItem;
    mnuSave: TMenuItem;
    mnuLoad: TMenuItem;
    mnuFile: TMenuItem;
    MenuItem2: TMenuItem;
    ImportFountain: TOpenDialog;
    loadScript: TOpenDialog;
    exportHTML: TSaveDialog;
    saveScript: TSaveDialog;
    screenplay: TMemo;
    StatusBar1: TStatusBar;
    ExportFountain: TSaveDialog;
    procedure btnActionClick(Sender: TObject);
    procedure btnCharacterClick(Sender: TObject);
    procedure btnDialogueClick(Sender: TObject);
    procedure btnHTMLClick(Sender: TObject);
    procedure btnSceneClick(Sender: TObject);
    procedure btnTransitionClick(Sender: TObject);
    procedure characterListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnuExpHTMLClick(Sender: TObject);
    procedure mnuImpFountainClick(Sender: TObject);
    procedure mnuExpFountainClick(Sender: TObject);
    procedure mnuLoadClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure screenplayKeyPress(Sender: TObject; var Key: char);
    procedure updateStatusBar;
  private

  public

  end;

const
  VERSION = '0.4';

var
  Form1: TForm1;
  currentStatus: textType;
  Filepath: string;

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
    characterList.Items.Add(UpperCase(characterName));
    (* Display character list *)
    if characterList.Visible = False then
    begin
      lblCharacters.Visible := True;
      characterList.Visible := True;
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
end;

procedure TForm1.btnDialogueClick(Sender: TObject);
begin
  currentStatus := tDialogue;
end;

procedure TForm1.btnHTMLClick(Sender: TObject);
var
  HTMLstring, transitionString: string;
  i: integer;
begin
  HTMLstring := '';

  (* Add HTML skeleton *)
  HTMLstring := HTMLstring + '<!DOCTYPE html>' + sLineBreak + '<html>' +
    sLineBreak + '<head>' + sLineBreak + '<title>LitterRat</title>' +
    sLineBreak + '<style>' + sLineBreak + 'div {text-align: center;}' +
    sLineBreak + '</style>' + sLineBreak + '</head>' + sLineBreak +
    '<body>' + sLineBreak;
  (* Add script *)
  for i := 0 to screenplay.Lines.Count do
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
      HTMLstring := HTMLstring + RightStr(transitionString,
        Length(transitionString) - 1) + sLineBreak + '<br />';
    end

    else
      HTMLstring := HTMLstring + '<div>' + sLineBreak + screenplay.Lines[i] +
        sLineBreak + '</div>';
  end;
  HTMLstring := HTMLstring + '</body>' + sLineBreak + '</html>' + sLineBreak;
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

procedure TForm1.FormCreate(Sender: TObject);
begin
  Filepath := '';
  (* Hide Character list *)
  if (characterList.items.Count = 0) then
  begin
    lblCharacters.Visible := False;
    characterList.Visible := False;
  end;
  (* Clear text *)
  screenplay.Clear;
  currentStatus := tNone;
  updateStatusBar;
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
    sLineBreak + '<head>' + sLineBreak + '<title>LitterRat</title>' +
    sLineBreak + '<style>' + sLineBreak + 'div {text-align: center;}' +
    sLineBreak + '.transition {text-align: right;}' + sLineBreak +
    '</style>' + sLineBreak + '</head>' + sLineBreak + '<body>' + sLineBreak;
  (* Add script *)
  for i := 0 to screenplay.Lines.Count do
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

procedure TForm1.mnuImpFountainClick(Sender: TObject);
begin
  if ImportFountain.Execute then
    screenplay.Lines.LoadFromFile(ImportFountain.Filename);
end;

procedure TForm1.mnuExpFountainClick(Sender: TObject);
begin
  if ExportFountain.Execute then
    screenplay.Lines.SaveToFile(ExportFountain.FileName);
end;

procedure TForm1.mnuLoadClick(Sender: TObject);
var
  JSONText, importFileName: string;
  JSONData: TJSONData;
  ScriptArray, CharactersArray: TJSONArray;
  i: integer;
  FileContent: TStringList;
begin
  if loadScript.Execute then
  begin
    if FileExists(loadScript.Filename) then
      importFileName := loadScript.Filename;

    FileContent := TStringList.Create;
    try
      try
        (* Load the entire file content into FileContent *)
        FileContent.LoadFromFile(importFileName);
        (* Join the lines of FileContent to form JSONText *)
        JSONText := FileContent.Text;
        (* Parse the JSONText as a JSON object *)
        JSONData := GetJSON(JSONText);
        try
          if JSONData <> nil then
          begin
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
                screenplay.Lines.Add(ScriptArray.Items[i].AsString);
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
      if (characterList.items.Count > 0) then
      begin
        lblCharacters.Visible := True;
        characterList.Visible := True;
      end;
    end;
  end;
end;

procedure TForm1.mnuSaveClick(Sender: TObject);
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
    c.SetValue('LitterRat Version', VERSION);
    if (characterList.items.Count > 0) then
      c.SetValue('Characters', characterList.items);
    c.SetValue('Script', screenplay.Lines);
  finally
    c.Free;
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
        screenplay.SelText := UpperCase(screenplay.SelText) + sLineBreak;
        characterList.Items.Add(UpperCase(characterName));
        (* Display character list *)
        if characterList.Visible = False then
        begin
          lblCharacters.Visible := True;
          characterList.Visible := True;
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
        screenplay.SelText := UpperCase(screenplay.SelText) + sLineBreak + sLineBreak;
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
      tCharacter: StatusBar1.SimpleText := 'Mode: Character name';
      tDialogue: StatusBar1.SimpleText := 'Mode: Dialogue';
      tScene: StatusBar1.SimpleText := 'Mode: Scene description';
      tTransition: StatusBar1.SimpleText := 'Mode: Transition';
      tAction: StatusBar1.SimpleText := 'Mode: Action';
    end;
  end;
end;

end.
