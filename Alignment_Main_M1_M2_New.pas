unit Alignment_Main_M1_M2_New;

interface

uses
     Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,Math,
     StdCtrls, Buttons, Inifiles, ComCtrls, Spin, ExtCtrls, D2XXUnit, Menus; // in 'D2XXUnit.pas';
//подключение модуля, позволяющего работать с ini файлами

type
     TAligment = class(TForm)
          ListView1: TListView;
          ProgBar_V: TProgressBar;
          ProgBar_H: TProgressBar;
          Image1: TImage;
          StaticText_N: TStaticText;
          StaticText_S: TStaticText;
          StaticText_W: TStaticText;
          StaticText_E: TStaticText;
          MyImg: TImage;
    Light: TShape;
          procedure ListView1KeyDown(Sender: TObject; var Key: Word;
               Shift: TShiftState);
          procedure FormCreate(Sender: TObject);
          procedure SpeedButton_ExitClick(Sender: TObject);
          procedure RadioGroup1Click(Sender: TObject);
          procedure btn1Click(Sender: TObject);
          //  procedure Check(x1: integer; y1: integer; controlRadius: integer);
          procedure GdBackground();
          procedure GdPaintStartObject();
          procedure krug(R, Xc, Yc: integer);
          procedure MoveTelescope(A,B,C,x0,y0:Double);
          procedure GdPaintObject  ;
     private
          { Private declarations }
     public
          { Public declarations }
     end;

const
     power_on = 16;
     power_off = 0;
     //  speed = 50;
     lR = 55;
     mR = 100;
var

    legal: integer;
    legalw: Integer;
     Aligment: TAligment;
     Ini: Tinifile;
     N_alig: Integer;
     speed_motor: Integer;
     i: Integer;
     n: Integer;
     N_step: Integer;

     m: Byte;
     no_power: Byte;
     code_M1: Byte;
     code_M2: Byte;
     code_M1_M2: Byte;
     code_M3: Byte;
     code_M4: Byte;
     code_M3_M4: Byte;

     FT_HANDLE_Port_A: DWord = 0;
     FT_HANDLE_Port_B: DWord = 0;

     position_M1: Integer;
     position_M2: Integer;
     position_M3: Integer;
     position_M4: Integer;

     vposition_M1: Integer;
     vposition_M2: Integer;
     vtextposition : Integer;
     ver_M1: Integer;
     hor_M2: Integer;
     ver_M3: Integer;
     hor_M4: Integer;
     step_M1: Integer;
     step_M2: Integer;
     step_M3: Integer;
     step_M4: Integer;
     rWCent: Integer;
     rHCent: Integer;
     WCent: Integer;
     HCent: Integer;
     deltav: real;

     vvis_pos: Real;
     hvis_pos: Real;
     pic: Tbitmap;
     h,w:integer;
     a,b,c: Double;
implementation

{$R *.dfm}

procedure Open_Port_A_B;
//******************************************************************************
begin
     GetFTDeviceCount; //Проверяем наличие FTDI
     if FT_Device_Count = 0 then
     begin //Если ничего нет, то выходим с сообщением об ошибке.
          Writeln('No - FT2232H', FT_Device_Count);
          Exit;
     end;

     Open_USB_Device_By_Device_Description('USB <-> Step Motor A');
     FT_HANDLE_Port_A := FT_HANDLE;
     Set_USB_Device_BitMode($1F, $04); //Синхр-й битбанг, все пины на вых.
     FT_Current_Baud := 200;
     Set_USB_Device_BaudRate; //Устанавливаем это значение

     Open_USB_Device_By_Device_Description('USB <-> Step Motor B');
     FT_HANDLE_Port_B := FT_HANDLE;
     Set_USB_Device_BitMode($FF, $04); //Синхр-й битбанг, все пины на вых.
     FT_Current_Baud := 200; //200
     Set_USB_Device_BaudRate; //Устанавливаем это значение
end;

procedure Purge_Port_A_B;
//******************************************************************************
begin
     FT_HANDLE := FT_HANDLE_Port_A;
     Purge_USB_Device_In;
     Purge_USB_Device_Out;
     FT_HANDLE := FT_HANDLE_Port_B;
     Purge_USB_Device_In;
     Purge_USB_Device_Out;
end;

procedure Move_M1_M2;
//******************************************************************************

begin
     {  FT_HANDLE:= FT_HANDLE_Port_A;
        Case step_M1 of
             1: code_M1:= 0;
             2: code_M1:= 1;
             3: code_M1:= 3;
             4: code_M1:= 2;
        end;

        Case step_M2 of
             1: code_M2:= 0;
             2: code_M2:= 4;
             3: code_M2:= 12;
             4: code_M2:= 8;
        end;
        Code_M1_M2:= Code_M1 + Code_M2;
        FT_Out_Buffer[0]:= Code_M1_M2 + power_on; //16
        Write_USB_Device_Buffer(1); //Считываем из буфера Out_Buffer
        Sleep(speed_motor); //It's min time  5 speed_motor
        FT_Out_Buffer[0]:= Code_M1_M2 + power_off;//16
        Write_USB_Device_Buffer(1); //Считываем из буфера Out_Buffer    }
end;

procedure Read_Ini;
//******************************************************************************
label
     1;
begin
     Ini := TiniFile.Create(extractfilepath(paramstr(0)) + 'Alignment.ini');
     position_M1 := Ini.ReadInteger('Position', 'Vertical M1', position_M1);
     position_M2 := Ini.ReadInteger('Position', 'Horisontal M2', position_M2);
     position_M3 := Ini.ReadInteger('Position', 'Vertical M3', position_M3);
     position_M4 := Ini.ReadInteger('Position', 'Horisontal M4', position_M4);
     N_alig := Ini.ReadInteger('Code', 'Alignment N', N_alig);
     speed_motor := Ini.ReadInteger('Code', 'Speed motor', speed_motor);
     step_M1 := Ini.ReadInteger('Code', 'Step M1', step_M1);
     step_M2 := Ini.ReadInteger('Code', 'Step M2', step_M2);

     vposition_M1 := Ini.ReadInteger('VPosition', 'VVertical M1', vposition_M1);
     vposition_M2 := Ini.ReadInteger('VPosition', 'VHorisontal M2', vposition_M2);
     vtextposition:= Ini.ReadInteger('VPosition', 'VHorisontalM2Text', vtextposition);
     //  step_M1:= Ini.ReadInteger('Code','Step M3',step_M3);
     //  step_M2:= Ini.ReadInteger('Code','Step M4',step_M4);
     Ini.Free;

     case step_M1 of
          1: code_M1 := 0;
          2: code_M1 := 1;
          3: code_M1 := 3;
          4: code_M1 := 2;
     end;

     case step_M2 of
          1: code_M2 := 0;
          2: code_M1 := 4;
          3: code_M1 := 12;
          4: code_M1 := 8;
     end;
     { code_M1_M2 := code_M1 + code_M2;
       FT_HANDLE := FT_HANDLE_Port_A;
       FT_Out_Buffer[0] := code_M1_M2 + power_on;//
       Write_USB_Device_Buffer(1); //Считываем из буфера Out_Buffer
       Sleep(speed_motor); //It's min time  5
       FT_Out_Buffer[0] := Code_M1_M2 + power_off;//
       Write_USB_Device_Buffer(1); //Считываем из буфера Out_Buffer

       Repeat
             Get_USB_Device_QueueStatus;
       Until (FT_Q_Bytes >= 1);

       Read_USB_Device_Buffer(1);  // Read buffer
       no_power := FT_In_Buffer[0];
       no_power := no_power and 32;  // Mask = 32   }
end;

procedure TAligment.GdBackground();
begin
     MyImg.Canvas.Brush.Color := clMedGray;
     MyImg.Canvas.Pen.Color := clMedGray;
     MyImg.Canvas.Rectangle(0, 0, MyImg.Width, MyImg.Height);

     MyImg.Canvas.Brush.Color := clMedGray;
     MyImg.Canvas.Pen.Color := clGreen;
     MyImg.Canvas.Ellipse(0, 0, MyImg.Width, MyImg.Height);
end;


procedure TAligment.GdPaintStartObject();
var

     lRadius: Integer;
begin
     lRadius := lR;

    // MyImg.Canvas.Brush.Color := clRed;
    // MyImg.Canvas.Pen.Color := clRed;
     //MyImg.Canvas.Rectangle(WCent,HCent,WCent + 2*Radius,HCent +2*Radius);
     krug(lRadius, WCent + lRadius, HCent + lRadius);
     MyImg.Canvas.Brush.Color := clGreen; //Цвет заливки окружности
     MyImg.Canvas.Pen.Color := clGreen; //Цвет самой окружности (точнее границ)
     MyImg.Canvas.Ellipse(WCent-1, HCent-1, WCent + 2 * lRadius+1, HCent + 2 * lRadius+1); // р // р
end;

procedure TAligment.FormCreate(Sender: TObject); // Вывод на форму
//******************************************************************************

begin
     GdPaintObject;
     a:=50;
     b:=50;
     c:=0;
end;

function Check(x1: integer; y1: integer; controlRadius: integer): bool;
var
     x0: integer;
     y0: Integer;
begin
     x0 := 146;
     y0 := 146;

     if  sqrt(power((x1 - x0),2) + power((y1 - y0),2) )<= controlRadius then
         result:=true
     else
         result:=false;

end;

function krugcheck(R, Xc, Yc: integer): bool;//thin point
var
     x, y, p: integer;
     Color: TColor;
     res: bool;
begin
     x := -1;
     y := R;
     p := 1 - R;
     Color := clRed;
     res := true;
     while (x <= y) and (res)  do
     begin
          x := x + 1;
          if p < 0 then
               p := p + 2 * x + 1
          else
          begin
               y := y - 1;
               p := p + 2 * x + 1 - 2 * y;
          end;
          if not Check(Xc + x, Yc + y, 146) then res := false;
          if not Check(Xc - x, Yc + y, 146) then res := false;
          if not Check(Xc - y, Yc + x, 146) then res := false;
          if not Check(Xc + y, Yc + x, 146) then res := false;
          if not Check(Xc - y, Yc - x, 146) then res := false;
          if not Check(Xc + y, Yc - x, 146) then res := false;
          if not Check(Xc - x, Yc - y, 146) then res := false;
          if not Check(Xc + x, Yc - y, 146) then res := false;
     end;
     result:=res;
end;

procedure TAligment.krug(R, Xc, Yc: integer);
var
     x, y, p: integer;
     Color: TColor;
begin
     x := -1;
     y := R;
     p := 1 - R;
     Color := clGreen;
     while x <= y do
     begin
          x := x + 1;
          if p < 0 then
               p := p + 2 * x + 1
          else
          begin
               y := y - 1;
               p := p + 2 * x + 1 - 2 * y;
          end;
          MyImg.Canvas.Pixels[Xc - x, Yc + y] := Color;
          MyImg.Canvas.Pixels[Xc + x, Yc + y] := Color;
          MyImg.Canvas.Pixels[Xc - y, Yc + x] := Color;
          MyImg.Canvas.Pixels[Xc + y, Yc + x] := Color;
          MyImg.Canvas.Pixels[Xc - y, Yc - x] := Color;
          MyImg.Canvas.Pixels[Xc + y, Yc - x] := Color;
          MyImg.Canvas.Pixels[Xc - x, Yc - y] := Color;
          MyImg.Canvas.Pixels[Xc + x, Yc - y] := Color;      {}
          if x = y then
               Color := clGreen
          else
               Color := clGreen;
     end;
end;


procedure TAligment.GdPaintObject;
var

     lRadius: Integer;
begin

     MyImg.Canvas.Brush.Color := clBtnFace; //Цвет заливки окружности
     MyImg.Canvas.Pen.Color := clBtnFace; //Цвет самой окружности (точнее границ)
     MyImg.Canvas.Rectangle(0, 0, MyImg.Width, MyImg.Height); // р
     MyImg.Canvas.Brush.Color := clSilver; //Цвет заливки окружности
     MyImg.Canvas.Pen.Color := clSilver; //Цвет самой окружности (точнее границ)
     MyImg.Canvas.Ellipse(0, 0, MyImg.Width, MyImg.Height); // р
end;

procedure TAligment.MoveTelescope(A,B,C,x0,y0:Double);
 VAR
    Bitmap       :  TBitmap;
    i            :  INTEGER;
    RotationAngle:  Double;
    StepCount    :  INTEGER;
    theta        :  Double;    // angle parameter for ellipse
    x            :  Double;
    xCenter      :  Double;
    xRotated     :  INTEGER;   // final values are integers
    y            :  Double;
    yCenter      :  Double;
    yRotated     :  INTEGER;   // final values are integers
BEGIN
  StepCount := 50;  // Example 50

  RotationAngle := c{degrees} *
                   PI/180 {radians/degee};

 /// Bitmap := TBitmap.Create;
  TRY
  // Bitmap.Width  := MyImg.Width;  // Example:  200
   // Bitmap.Height := MyImg.Height; // Example:  150

    MyImg.Canvas.Pen.Color := clRed;

    // Axis of rotation will be center of Bitmap (Image)
    xCenter := MyImg.Width  DIV 2;
    yCenter := MyImg.Height DIV 2;

    FOR i := 0 TO StepCount DO   // actually StepCount + 1 points
    BEGIN
      theta := 360*(i/StepCount) {degrees} * (PI/180) {radians/degree};

      // Ellipse (x,y) coordinates [pre-rotation]
      x := xCenter + A*COS(theta);
      y := yCenter + B*SIN(theta);

      // Rotate Ellipse around (xCenter, yCenter) axis
      xRotated :=
           ROUND(
                 xCenter + (x - xCenter)* COS(RotationAngle)
                         - (y - yCenter)* SIN(RotationAngle) );

      yRotated :=
           ROUND(
                 yCenter + (x - xCenter)* SIN(RotationAngle)
                         + (y - yCenter)* COS(RotationAngle) );

      IF   i = 0
      THEN MyImg.Canvas.MoveTo(xRotated, yRotated)
      ELSE MyImg.Canvas.LineTo(xRotated, yRotated)

    END;

 //   MyImg.Picture.Graphic := Bitmap

  FINALLY
  //  Bitmap.Free
  END
end;








procedure TAligment.ListView1KeyDown(Sender: TObject; var Key: Word;
     Shift: TShiftState); //Управ-е юстировками
//******************************************************************************
     // На ListView цвет - clBtnFace
     //StaticText - стиль бордюра sbsSunken, цвет фона - clCream
var
  x,y:double ;
begin
      x:= Light.Left;
      y:= Light.Top;

     case Key of
               VK_Up:
               begin
                   GdPaintObject;
                   //if (b<100) and (b>1) then
                   b:=b-1;
                   MoveTelescope(a,b,c,x,y);
               end;
               VK_Down:
               begin
                   GdPaintObject;
                   //if (b<100) and (b>1) then
                   b:=b+1;
                  MoveTelescope(a,b,c,x,y);
               end;
               VK_RIGHT:
               begin
                   GdPaintObject;
                   c:=c+1;
                    MoveTelescope(a,b,c,x,y);
               end;
               VK_LEFT:
               begin
                    GdPaintObject;
                    c:=c-1;
                    MoveTelescope(a,b,c,x,y);
               end;
     end;
end;
procedure Write_Ini;
//******************************************************************************
begin
     Ini := TiniFile.Create(extractfilepath(paramstr(0)) + 'Alignment.ini');
     Ini.WriteInteger('VPosition', 'VVertical M1', vposition_M1);
     Ini.WriteInteger('VPosition', 'VHorisontal M2', vposition_M2);
     Ini.WriteInteger('VPosition', 'VHorisontalM2Text', vposition_M2);

     Ini.WriteInteger('Position', 'Vertical M1', position_M1);
     Ini.WriteInteger('Position', 'Horisontal M2', position_M2);
     Ini.WriteInteger('Position', 'Vertical M3', position_M3);
     Ini.WriteInteger('Position', 'Horisontal M4', position_M4);
     Ini.WriteInteger('Code', 'Alignment N', N_alig);
     Ini.WriteInteger('Code', 'Speed motor', speed_motor);
     Ini.WriteInteger('Code', 'Step M1', step_M1);
     Ini.WriteInteger('Code', 'Step M2', step_M2);
     //  Ini.WriteInteger('Code','Step M3',step_M3);
     //  Ini.WriteInteger('Code','Step M4',step_M4);
     Ini.Free;
end;

procedure TAligment.SpeedButton_ExitClick(Sender: TObject); //Вых и запом. установок
//******************************************************************************
begin
     Write_Ini; // Запись в Ini файл
     {  Set_USB_Device_BitMode($00,$00); // сброс установок
        Close_USB_Device;  }
     Close;
end;

procedure TAligment.RadioGroup1Click(Sender: TObject); //Выбор юстировки
//******************************************************************************
begin
     ActiveControl := ListView1; // Переводим фокус управления на ListView1
end;

procedure TAligment.btn1Click(Sender: TObject);
begin
     ShowMessage('');
end;


end.

