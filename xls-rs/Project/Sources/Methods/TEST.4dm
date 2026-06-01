//%attributes = {}
#DECLARE($params : Object)

If ($params=Null:C1517)
	
	CALL WORKER:C1389(1; Current method name:C684; {})
	
Else 
	
	$events:={}
	$events.onResponse:=Formula:C1597(onData)
	$events.onError:=Formula:C1597(ALERT:C41("error!"))
	
	var $xls_rs : cs:C1710.xls_rs
	$xls_rs:=cs:C1710.xls_rs.new(cs:C1710._xls_rs_Controller)
	
	$folder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder(Generate UUID:C1066)
	$folder.create()
	$in:=$folder.file("sample.csv")
	$csv:="Product,Category,Price,Quantity,Date\nLaptop,Electronics,1200,1,2026-01-01\nMouse,Electronics,25,2,2026-01-02\nDesk,Furniture,300,1,2026-01-03\nChair,Furniture,150,4,2026-01-04\nPen,Stationery,2,10,2026-01-05\nLamp,Home,45,1,2026-01-06\n"
	$in.setText($csv)
	
	$out:=Folder:C1567(fk desktop folder:K87:19).file("sample.xlsx")
	
	$tasks:=[]
	
	$tasks.push(["convert"; "--input"; $in; "--output"; $out; {data: $out; file: Null:C1517}])
	$results:=$xls_rs.execute($tasks; $events)
	
End if 