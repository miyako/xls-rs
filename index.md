---
layout: default
---

![version](https://img.shields.io/badge/version-21%2B-3B69E9)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/xls-rs)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/xls-rs/total)
 
# Use xls-rs from 4D

```4d
#DECLARE($params : Object)

If ($params=Null)
    
    CALL WORKER(1; Current method name; {})
    
Else 
    
    $events:={}
    $events.onResponse:=Formula(onData)
    $events.onError:=Formula(ALERT("error!"))
    
    var $xls_rs : cs.xls_rs.xls_rs
    $xls_rs:=cs.xls_rs.xls_rs.new(cs.xls_rs._xls_rs_Controller)
    
    $folder:=Folder(Temporary folder; fk platform path).folder(Generate UUID)
    $folder.create()
    $in:=$folder.file("sample.csv")
    $csv:="Product,Category,Price,Quantity,Date\nLaptop,Electronics,1200,1,2026-01-01\nMouse,Electronics,25,2,2026-01-02\nDesk,Furniture,300,1,2026-01-03\nChair,Furniture,150,4,2026-01-04\nPen,Stationery,2,10,2026-01-05\nLamp,Home,45,1,2026-01-06\n"
    $in.setText($csv)
    
    $out:=Folder(fk desktop folder).file("sample.xlsx")
    
    $tasks:=[]
    
    $tasks.push(["convert"; "--input"; $in; "--output"; $out; {data: $out; file: Null}])
    $results:=$xls_rs.execute($tasks; $events)
    
End if 
```
