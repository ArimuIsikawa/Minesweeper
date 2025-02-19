uses GraphABC, ABCObjects, ABCButtons, Screen;

type
  OneCell = record
    mine: boolean; //Наличие мины
    flag: boolean; //Наличие флага
    neighbour: shortint; //Кол-во соседей
    click: boolean; //Открыта ли
  end;

var
  BtNewGame, BtStartGame, BtSetting, BtRules, BtAboutAuthor: ButtonABC;
  BtN9, BtN15, BtN20: ButtonABC;
  Cell: array[1..20, 1..23] of SquareABC;
  Field: array[1..20, 1..23] of OneCell;
  N, NMine: byte; //Поле N х N
  SetFlag: byte; //Кол-во установленных флагов
  TrueFlag: byte; //Кол-во правильно установленных флагов
  FW: integer;
  lose, sett, ngame: boolean;

procedure CreateButtonMenu;
begin 
  clearwindow;
  
  BtStartGame := ButtonABC.Create(310, 120, 100, 'Начать игру', clSkyBlue);
  BtSetting := ButtonABC.Create(310, 160, 100, 'Настройки', clSkyBlue);
  BtRules := ButtonABC.Create(310, 200, 100, 'Правила', clSkyBlue);
  BtAboutAuthor := ButtonABC.Create(310, 240, 100, 'Об авторе', clSkyBlue);
end;

procedure DeleteButtonMenu;
begin
  BtStartGame.Destroy;
  BtSetting.Destroy;
  BtRules.Destroy;
  BtAboutAuthor.Destroy;
end;

procedure DeleteSetting;
begin
  BtN9.Destroy;
  BtN15.Destroy;
  BtN20.Destroy;
end;

procedure DeleteAllObj;
begin
  DeleteButtonMenu;
  if Sett = true then
    DeleteSetting;
  Sett := false;
end;

procedure CreateField;
var
  xs, ys: integer;
begin
  for var y := 1 to N do
    for var x := 1 to N do
    begin
      xs := 10 + (x - 1) * (40 + 2);
      ys := 10 + (y - 1) * (40 + 2);
      Cell[x, y] := new SquareABC(xs, ys, 40, clMediumBlue);
      Cell[x, y].BorderColor := clGreen;
      Cell[x, y].BorderWidth := 2;
      Cell[x, y].TextScale := 1;
    end;    
end;

procedure CountNeighbour;
var
  imin, imax, jmin, jmax: byte;
  c: byte;
begin
  
  for var i := 1 to N do
  begin
    for var j := 1 to N do
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

procedure NewGame;
var
  FieldH, FieldW: integer;
begin

  clearwindow;
  DeleteAllObj;
  ngame := true;
  
  FieldW := 40 * N + (10 * N div 2) + 140;
  FieldH := 40 * N + (10 * N div 2);
  SetWindowSize(FieldW, FieldH);
  
  CreateField;
  btNewGame := ButtonABC.Create(FieldW - 130, 10, 100, 'Новая игра', clSkyBlue);
  btNewGame.OnClick := NewGame;

  lose := false;
  
  for var j := 1 to N do
  begin
    for var i := 1 to N do
    begin
      Field[i, j].mine := false;
      Field[i, j].click := false;
      Field[i, j].flag := false;
      Field[i, j].neighbour := 0;
    end; 
  end; 
  SetFlag := 0;
  TrueFlag := 0;
  
  FW := FieldW - 130;
  var ss:string;
  ss := 'Кол-во мин: ' + NMine;
  textout(FW, 50, ss);
end;

procedure OpenEmpty(fx, fy: integer);
var
  f1: boolean;
  step, imin, imax, jmin, jmax: integer;
begin
  Field[fx, fy].neighbour := -1;
  step := -1;
  
  repeat
    f1 := true;
    
    for var x := 1 to N do
    begin
      for var y := 1 to N do
      begin
        if field[x, y].neighbour < 0 then begin
         
          if x > 1 then imin := x - 1 else imin := x;
          if x < N then imax := x + 1 else imax := x;
          if y > 1 then jmin := y - 1 else jmin := y;
          if y < N then jmax := y + 1 else jmax := y;
          
          for var k := imin to imax do
          begin
            for var l := jmin to jmax do
            begin
              if (k = 0) and (l = 0) then continue;
              
              if Field[k, l].click = true then continue;
              if Field[k, l].flag = true then continue;
              
              if Field[k, l].neighbour = 0 then begin
                Sleep(30); //Для анимации открывания клеток
                Cell[k, l].Color := clMediumSlateBlue;
                Field[k, l].click := true;
                Field[k, l].neighbour := step;
                f1 := false; //Была открыта клетка - ищем др.
              end;
              
              if Field[k, l].neighbour > 0 then begin
                Cell[k, l].Color := clMediumSlateBlue;
                Cell[k, l].Text := IntToStr(Field[k, l].neighbour);
                Field[k, l].click := true;
              end;
            end;
          end;
        
       end;
        
      end;
    end;
  
  until f1 = true;
end;

procedure OpenBomb;
begin
  
  for var i := 1 to N do
    for var j := 1 to N do 
      if field[i, j].mine = true then begin
        sleep(30);
        field[i, j].click := true;
        Cell[i, j].Color := clRed;
        field[i, j].flag := false;
        Cell[i, j].Text := 'M';
      end;
      
end;

procedure NumClickOpen(x, y: integer);
var
  c, imin, imax, jmin, jmax: byte;
begin
  
  if x > 1 then imin := x - 1 else imin := x;
  if x < N then imax := x + 1 else imax := x;
  if y > 1 then jmin := y - 1 else jmin := y;
  if y < N then jmax := y + 1 else jmax := y;
  
  for var i := imin to imax do begin
    for var j := jmin to jmax do begin
      if field[i, j].flag = true then
        inc(c);
    end;
  end;
  
  if c <> field[x, y].neighbour then begin
    cell[x, y].Text := '☒';
    sleep(100);
    cell[x, y].Text := IntToStr(field[x, y].neighbour);
  end
  else begin
    for var i := imin to imax do begin
      for var j := jmin to jmax do begin
        
        if (field[i, j].flag = false) then begin
          if (field[i, j].mine = true) then begin
            lose := true;
            OpenBomb;
          end;
          
          if (field[i, j].neighbour > 0) then begin
            field[i, j].click := true;
            Cell[i, j].Text := IntToStr(Field[i, j].neighbour);
            Cell[i, j].Color := clMediumSlateBlue;
          end
          else begin
            field[i, j].click := true;
            Cell[i, j].Color := clMediumSlateBlue;
            OpenEmpty(i, j);    
          end;
        end; 
        
      end;
    end;
  end;  
end;

procedure FlagCalc;
begin
  TrueFlag := 0;
  SetFlag := 0;
  for var i := 1 to n do begin
    for var j := 1 to n do begin
      if field[i, j].flag = true then begin
        inc(SetFlag);
        if field[i, j].mine = true then
          inc(TrueFlag);
      end;
    end; 
  end;
  
end;

procedure MouseDown(x, y, mb: integer);
var
  fx, fy: integer;
begin
  
  if ObjectUnderPoint(x, y) = nil then exit;
  
  if lose = true then exit;
  
  fx := (x - 10) div (40 + 2) + 1; 
  fy := (y - 10) div (40 + 2) + 1;
  
  
  if mb = 1 then begin
    
    if ngame = true then begin
      
      ngame := false;
      Field[fx, fy].click := true; 
      
      var Rx, Ry: integer;
      for var i := 1 to NMine do
      begin
        Rx := Random(N) + 1;
        Ry := Random(N) + 1;
        while (fx >= Rx - 2) and (fx <= Rx + 2) do
          Rx := Random(N) + 1;
        while (fy >= Ry - 2) and (fy <= Ry + 2) do
          Ry := Random(N) + 1;
        while Field[Rx, Ry].mine = true do
        begin
          Rx := Random(N) + 1;
          Ry := Random(N) + 1;            
        end;
        Field[Rx, Ry].mine := true;
      end; 
      
      CountNeighbour;
      OpenEmpty(fx, fy);
      exit;
    end;
    
    if (field[fx, fy].neighbour > 0) and (field[fx, fy].click = true) then begin
      NumClickOpen(fx, fy);
    end;
    
    Field[fx, fy].click := true; 
  
    if field[fx, fy].mine = true then begin
      OpenBomb;
      //MoveTo(530, 10);
      writeln('Проигрыш!');
      lose := true;
    end;
    
    if field[fx, fy].mine = false then begin
      if Field[fx, fy].neighbour > 0 then
        Cell[fx, fy].Text := IntToStr(Field[fx, fy].neighbour);
      if field[fx, fy].neighbour = 0 then
        OpenEmpty(fx, fy);
      Cell[fx, fy].Color := clMediumSlateBlue;
    end;
    
  end;
  
  if mb = 2 then begin          
    if (field[fx, fy].click = true) then begin
      exit;
    end;   
    if Cell[fx, fy].Text = 'F' then begin
      Cell[fx, fy].Text := '';
      Cell[fx, fy].color := clLightGreen;
      Field[fx, fy].flag := false;
    end
    else begin
      Cell[fx, fy].Text := 'F';
      Field[fx, fy].flag := true;
      Cell[fx, fy].color := clLightGreen;
    end;
    FlagCalc;
    if (TrueFlag = NMine) and (SetFlag = NMine) then begin
      Cell[fx, fy].Color := clGreen;
      writeln('Вы выиграли!');
      lose := true;
    end;  
    
  var ss:string;
  SetBrushColor(clSkyBlue);
  SetFontSize(10);
  ss := 'Кол-во флагов: ' + SetFlag;
  textout(FW, 70, ss);
  end;
  
end;

procedure MouseMove(x, y, mb: integer);
var
  fx, fy: integer;
begin
  
  if ObjectUnderPoint(x, y) = nil then exit;
  
  fx := (x - 10) div (40 + 2) + 1; 
  fy := (y - 10) div (40 + 2) + 1;
  
  //Все клетки закрашиваются синим
  for var j := 1 to N do
  begin
    for var i := 1 to N do
    begin
      if (Field[i, j].click = false) and (Field[i, j].flag = false) then Cell[i, j].Color := clMediumBlue;
      if Field[i, j].flag = true then Cell[i, j].Color := clLightGreen;
    end;
  end;
  
  //Клетка над которой находится мышь, становится пурпурным
  if (Field[fx, fy].click = false) and (Field[fx, fy].flag = false) then
    Cell[fx, fy].Color := clMediumSlateBlue
  else if Field[fx, fy].flag = true then
    Cell[fx, fy].Color := clLightGreen
  else if (Field[fx, fy].mine = true) and (lose = true) then
    Cell[fx, fy].Color := ClRed;
end;

procedure N9;
begin
  N := 9;
  NMine := 10;
end;

procedure N15;
begin
  N := 15;
  NMine := 25;
end;

procedure N20;
begin
  N := 20;
  NMine := 50;
end;

procedure Clear;
begin
  SetBrushColor(clWhite);
  var i: integer;
  i := 280;
  while i < 520  do begin
  TextOut(10, i, '                                                                                                                                                                             ');
  inc(i, 15);
  end;
end;

procedure Setting;
begin
  
  Clear;
  if Sett = true then
    DeleteSetting
  else
    Sett := true; 
  
  BtN9 := ButtonABC.Create(30, 350, 175, '9х9  10 Мин', clSkyBlue);
  BtN15 := ButtonABC.Create(275, 350, 175, '15х15  25 Мин', clSkyBlue);
  BtN20 := ButtonABC.Create(515, 350, 175, '20х20  50 Мин', clSkyBlue);
  
  BtN9.OnClick := N9;
  BtN15.OnClick := N15;
  BtN20.OnClick := N20;
end;

procedure Rules;
begin
  
  Clear;
  if Sett = true then
    DeleteSetting;
  
  SetFontSize(13);
  SetBrushColor(clWhite);
  TextOut(10, 280, 'Цель игры полность открыть поле и обезвредить все мины при помощи флагов. При');
  TextOut(10, 300, 'нажатии на закрытую клетку левой кнопкой мыши, клетка будет открыта. А при нажатии');
  TextOut(10, 320, 'на закрытую клетку правой кнопкой мыши, на клетку будет поставлен флаг.');
  TextOut(10, 340, 'Флажки нужно ставить на клетки с минами, если вы уверены в этом; в противном');
  TextOut(10, 360, 'случае при открытии соседних клеток, вы можете попасть на мину. При нажатии на');
  TextOut(10, 380, 'клетку, если она пуста, то соседние клетки будут открываться, вплоть до тех рядом с');
  TextOut(10, 400, 'которыми есть мины. Если под клеткой цифра, значит соседние клетки заманировы.');
  TextOut(10, 420, 'Цифра показывает количество мин вокруг неё. Если количество флагов вокруг цифры ');
  TextOut(10, 440, 'совпадает с самой цифрой, вы можете открыть соседние с ней клетки нажатием на эту');
  TextOut(10, 460, 'цифру, но если один из флагов окажется не на мине, вы проиграете! Если же под');
  TextOut(10, 480, 'клеткой будет мина, игра также будет окончена!');
end;

procedure Author;
begin
  
  Clear;
  if Sett = true then
    DeleteSetting;
  
  SetFontSize(13);
  SetBrushColor(clWhite);
  TextOut(10, 280, 'Загаштоков Алим. 17 Лет. Студент 3 курса  "Я ПРОГРАММИСТ"                          ');
  TextOut(10, 300, 'На полное создание этого проекта ушло чуть меньше 20 часов, с перерывами.');
  TextOut(10, 320, 'Идея сделать именно эту игру пришла мне в голову когда я сидел за компьютером');
  TextOut(10, 340, 'и мне нечем было заняться, так как современные игры уже надоели. Тогда я');
  TextOut(10, 360, 'вспомнил об этой игре, и я не долго раздумывал перед тем как садиться за проект.');
  TextOut(10, 380, 'Реализация самой игры была довольно простой, за исключение механики открытия всех');
  TextOut(10, 400, 'пустых клеток, но самым проблемным оказалось создание меню.');
  TextOut(10, 440, 'Спасибо за то что играте в эту игру. Приятной вам игры!');
  TextOut(10, 460, 'В случае нахождения багов просьба писать сюда: zagashtokov.97@mail.ru');
  TextOut(10, 480, 'Если вы изъявите желание поддержать автора монетой, добавлю ссылку на донат ;)');
end;

procedure Menu;
begin
  CreateButtonMenu;
  
  BtStartGame.OnClick := NewGame;
  BtSetting.OnClick := Setting;
  BtRules.OnClick := Rules;
  BtAboutAuthor.OnClick := Author;

end;

begin
  
  SetSmoothingOff; //Отключаем сглаживание
  SetWindowSize(720, 520);
  n := 9;
  NMine := 10;
  Window.Title := 'Сапёр';
  Window.IsFixedSize := True; 
  
  ngame := false;
  sett := false;
  Menu;
  
  OnMouseDown := MouseDown;
  OnMouseMove := MouseMove;
  
end.
