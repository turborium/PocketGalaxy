# PocketGalaxy
**PocketGalaxy animated pixel effect**

[Powered By Lazarus (ObjectPascal)](https://www.lazarus-ide.org/)  

---
Precompiled exe: https://github.com/turborium/PocketGalaxy/raw/main/PocketGalaxy.exe  

![scr](scr.png)

Maked by Lazarus(ObjectPascal) with love.  
Also, see JavaScript version: https://github.com/turborium/PocketGalaxyJs and run online.

---
Inspired by article [Complex beauty in a simple formula](https://habr.com/ru/articles/817869/) and comment by [kipar](https://habr.com/ru/articles/817869/#comment_26881773) with code:
```pascal
RandSeed := 1;
for i := 1 to 100 do
begin
  x := random;
  y := random;
  color := Random(MaxLongint);
  for j := 1 to 1000 do
  begin
    pr2d_Pixel(x*1000,y*1000,color);
    x := Frac(x+cos(y));
    y := Frac(y+sin(x));
  end;
end;
```
