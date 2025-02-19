unit Screen;

uses GraphABC, ABCObjects, ABCButtons;

type
  OneCell = record
    mine: boolean; //Наличие мины
    flag: boolean; //Наличие флага
    neighbour: shortint; //Кол-во соседей
    click: boolean; //Открыта ли
  end;

var
  Cell: array[1..9, 1..23] of SquareABC;
  Field: array[1..9, 1..23] of OneCell;
  N, M: byte; //Поле N х N
  stop: boolean;

procedure DeleteAll;
begin
  for var i := 1 to n do begin
    for var j := 1 to M do begin
      Cell[i, j].Destroy;
    end;   
  end;
end;

procedure SSCreateField;
var
  xs, ys: integer;
begin
  for var y := 1 to N do
    for var x := 1 to M do
    begin
      xs := 10 + (x - 1) * (40 + 2);
      ys := 10 + (y - 1) * (40 + 2);
      Cell[y, x] := new SquareABC(xs, ys, 40, clMediumBlue);
      Cell[y, x].BorderColor := clGreen;
      Cell[y, x].BorderWidth := 2;
      Cell[y, x].TextScale := 1;
    end;    
end;

procedure SetMine;
begin
  
  for var i := 3 to 22 do begin
    if (i mod 4) <> 2 then
      Field[3, i].mine := true;
  end;
  Field[3, 7].mine := False;
  Field[3, 9].mine := False;
  
  for var i := 7 to 22 do begin
    if (i mod 4) <> 2 then
      Field[5, i].mine := true;
  end;
  Field[5, 3].mine := True;
  Field[5, 8].mine := False;
  Field[5, 12].mine := False;
  
  for var i := 3 to 19 do begin
    if (i mod 4) <> 2 then
      Field[7, i].mine := true;
  end;
  Field[7, 8].mine := False;
  Field[7, 12].mine := False;
  
  Field[4, 3].mine := True;
  Field[6, 3].mine := True;
  
  Field[4, 7].mine := True;
  Field[4, 9].mine := True;
  Field[6, 7].mine := True;
  Field[6, 8].mine := True;
  Field[6, 9].mine := True;
  
  Field[4, 11].mine := True;
  Field[6, 11].mine := True;
  Field[4, 13].mine := True;
  Field[6, 13].mine := True;
   
  Field[4, 15].mine := True;
  Field[6, 15].mine := True;
  
  Field[4, 19].mine := True;
  Field[4, 21].mine := True;
  Field[6, 19].mine := True;
end;

procedure SSCountNeighbour;
var
  imin, imax, jmin, jmax: byte;
  c: byte;
begin
  
  for var i := 1 to N do
  begin
    for var j := 1 to M do
    begin  
      if i > 1 then imin := i - 1 else imin := i;
      if i < N then imax := i + 1 else imax := i;
      if j > 1 then jmin := j - 1 else jmin := j;
      if j < N then jmax := j + 1 else jmax := j;
      c := 0;     
      for var k := imin to imax do
      begin
        for var l := jmin to jmax do
        begin
          if field[k, l].mine = true then inc(c);
        end;
      end;      
      field[i, j].neighbour := c;     
    end;  
  end;   
end;

procedure SSNewGame;
begin
  
  clearwindow;
  SSCreateField;
  
  for var i := 1 to N do
  begin
    for var j := 1 to M do
    begin
      Field[i, j].mine := false;
      Field[i, j].click := false;
      Field[i, j].neighbour := 0;
    end; 
  end; 
end;

procedure SSOpenField(fx, fy: integer);
begin
  
  for var i := 1 to N do begin
    for var j := 1 to M do begin
      
      if stop = true then begin DeleteAll; exit; end;
      if Field[i, j].mine = true then continue;
      
      if Field[i, j].neighbour <> 0 then begin 
        Field[i, j].click := true;
        Cell[i, j].Color := clMediumSlateBlue;
        Cell[i, j].Text := IntToStr(Field[i, j].neighbour);
      end
      else begin
        Field[i, j].click := true;
        Cell[i, j].Color := clMediumSlateBlue;
      end;
      
      sleep(20);
    end;
  end;
  
  var st: string;
  
  st := 'Нажмите пробел';
  
  for var i := 1 to length(st) do begin
    Cell[n, i + 4].text := st[i];
    sleep(20);
  end;
  
  while stop <> true do;
  
  DeleteAll;
  exit;
end;

procedure EndScreen(key: integer);
begin
  if key = 32 then stop := True;
end;

procedure StartScreen;
begin
  
  OnKeyDown := EndScreen;
  
  stop := False;
  SetSmoothingOff; //Отключаем сглаживание
  SetWindowSize(1000, 400);
  n := 9;
  m := 23;
  
  SSNewGame;
  SetMine;
  SSCountNeighbour;
  sleep(1000);
  Field[1, 1].click := true;
  Cell[1, 1].Color := clMediumSlateBlue;
  SSOpenField(1, 1);
end;

begin
  StartScreen;
end.