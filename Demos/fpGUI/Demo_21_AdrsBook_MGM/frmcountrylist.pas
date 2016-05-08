unit frmCountryList;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, fpg_base, fpg_main,
  fpg_widget, fpg_form, fpg_button, fpg_grid,
  fpg_dialogs, fpg_menu,
  fpg_panel,
  model, tiModelMediator;

type

  TCountryListForm = class(TfpgForm)
  private
    {@VFD_HEAD_BEGIN: CountryListForm}
    bvlName1: TfpgBevel;
    btnAdd: TfpgButton;
    btnEdit: TfpgButton;
    btnDelete: TfpgButton;
    grdName1: TfpgStringGrid;
    btnClose: TfpgButton;
    {@VFD_HEAD_END: CountryListForm}
    FData: TCountryList;
    FMediator: TtiModelMediator;
    procedure SetData(const AValue: TCountryList);
    procedure SetupMediators;
    procedure btnEditClicked(Sender: TObject);
  public
    procedure AfterCreate; override;
    property Data: TCountryList read FData write SetData;
  end;

{@VFD_NEWFORM_DECL}

procedure ShowCountries(const AList: TCountryList);


implementation




procedure ShowCountries(const AList: TCountryList);
var
  frm: TCountryListForm;
begin
  frm := TCountryListForm.Create(nil);
  try
    frm.SetData(AList);
    frm.ShowModal;
  finally;
    frm.Free;
  end;
end;

{@VFD_NEWFORM_IMPL}

procedure TCountryListForm.SetupMediators;
begin
  if not Assigned(FMediator) then
  begin
    FMediator := TtiModelMediator.Create(self);
    FMediator.AddComposite('ISO(60);Name(110)', grdName1);
  end;
  FMediator.Subject := FData;
  FMediator.Active := True;
end;

procedure TCountryListForm.btnEditClicked(Sender: TObject);
begin
  //
end;

procedure TCountryListForm.SetData(const AValue: TCountryList);
begin
  if FData=AValue then exit;
  FData:=AValue;
  SetupMediators;
end;

procedure TCountryListForm.AfterCreate;
begin
  {@VFD_BODY_BEGIN: CountryListForm}
  Name := 'CountryListForm';
  SetPosition(412, 278, 421, 315);
  WindowTitle := 'Country Listing';
  Hint := '';
  IconName := '';
  ShowHint := True;

  bvlName1 := TfpgBevel.Create(self);
  with bvlName1 do
  begin
    Name := 'bvlName1';
    SetPosition(0, 0, 420, 36);
    Anchors := [anLeft,anRight,anTop];
    Hint := '';
    Shape := bsSpacer;
    Shape := bsSpacer;
  end;

  btnAdd := TfpgButton.Create(bvlName1);
  with btnAdd do
  begin
    Name := 'btnAdd';
    SetPosition(12, 4, 52, 24);
    Text := 'Add';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 1;
  end;

  btnEdit := TfpgButton.Create(bvlName1);
  with btnEdit do
  begin
    Name := 'btnEdit';
    SetPosition(68, 4, 52, 24);
    Text := 'Edit';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 1;
    OnClick := @btnEditClicked;
  end;

  btnDelete := TfpgButton.Create(bvlName1);
  with btnDelete do
  begin
    Name := 'btnDelete';
    SetPosition(124, 4, 52, 24);
    Text := 'Delete';
    Enabled := False;
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    TabOrder := 2;
  end;

  grdName1 := TfpgStringGrid.Create(self);
  with grdName1 do
  begin
    Name := 'grdName1';
    SetPosition(8, 40, 404, 220);
    BackgroundColor := TfpgColor($80000002);
    FontDesc := '#Grid';
    HeaderFontDesc := '#GridHeader';
    Hint := '';
    RowCount := 0;
    RowSelect := False;
    TabOrder := 1;
  end;

  btnClose := TfpgButton.Create(self);
  with btnClose do
  begin
    Name := 'btnClose';
    SetPosition(332, 276, 80, 24);
    Text := 'Close';
    FontDesc := '#Label1';
    Hint := '';
    ImageName := '';
    ModalResult := mrOK;
    TabOrder := 2;
  end;

  {@VFD_BODY_END: CountryListForm}
end;


end.
