
DECLARE @dt as varchar(1) ='{?DateType}', @DateFrom DATE={?dateFrom}, @Dateto date= {?dateTo}
DECLARE @Branch Varchar(10) = '{?Branch}'



set @branch = replace((@branch),'ALL BRANCH','')


----------------------------------------- CASH
SELECT * FROM (
SELECT DISTINCT
T0.DOCNUM AS 'DOCNUM',
T0.TaxDate as 'Document Date',
T0.Docdate as 'Posting Date',
CONCAT('RC ',T0.DOCNUM) as 'Cash Receipt #',

CASE WHEN T0.U_PayLoc LIKE '%Store Collect%' THEN
		CONCAT (T0.U_CollRcptNo ,
		  		(SELECT Countries = STUFF((
         SELECT
			'; '+CASE WHEN T3.InvType = 203 Then ''
			WHEN T3.InvType = 46 Then ''
			WHEN T3.InvType = 13 Then 'AR' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 14 Then 'CM' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 30 Then ''
			END
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, '')))
	 WHEN T0.U_PayLoc = '' THEN

  		(SELECT Countries = STUFF((
         SELECT
			', '+CASE WHEN T3.InvType = 203 Then 'ARDPI'
			WHEN T3.InvType = 46 Then 'OP'
			WHEN T3.InvType = 13 Then 'AR'
			WHEN T3.InvType = 14 Then 'CM'
			WHEN T3.InvType = 30 Then 'JE'
			END,
			+'-' + CONVERT(varchar(10), T3.DOCENTRY)
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, ''))

	 WHEN T0.U_PayLoc LIKE '%Customer%' THEN
		CONCAT (T0.U_CollRcptNo ,
		  		(SELECT Countries = STUFF((
         SELECT
			'; '+CASE WHEN T3.InvType = 203 Then ''
			WHEN T3.InvType = 46 Then ''
			WHEN T3.InvType = 13 Then 'AR' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 14 Then 'CM' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 30 Then ''
			END
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, '')))
	 WHEN T0.U_PayLoc LIKE '%Head%' THEN
		CONCAT (T0.U_CollRcptNo ,
		  		(SELECT Countries = STUFF((
         SELECT
			'; '+CASE WHEN T3.InvType = 203 Then ''
			WHEN T3.InvType = 46 Then ''
			WHEN T3.InvType = 13 Then 'AR' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 14 Then 'CM' +'-' + CONVERT(varchar(10), T3.DOCENTRY)
			WHEN T3.InvType = 30 Then ''
			END
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, '')))
END AS 'Reference #',

T0.CardCode as 'Customer Code',
T0.CardName as 'Customer Name',
ISNULL((T1.LicTradNum),'-') as 'Customer TIN',
T3.Account as 'Account Code',
T4.AcctName as 'Account Name',

T3.DEBIT AS 'PHP Debit',

T3.CREDIT AS 'PHP Credit',
T2.MEMO as 'Remarks',
T0.BPLNAME
FROM ORCT T0
left JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN OJDT T2 ON T0.TRANSID = T2.Number
INNER JOIN JDT1 T3 ON T2.NUMBER = T3.TRANSID
AND (T0.CashAcct = T3.Account OR T0.CashAcct = T3.ContraAct)
INNER JOIN OACT T4 ON T3.Account = T4.AcctCode
WHERE T0.CASHSUM > 0.00 AND T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
AND T0.BPLName like  '%'+@Branch+'%'
and t3.TransType!=310000001
AND T0.Canceled = 'N'

----------------------------------------- // CASH
UNION ALL
-----------------------------------------
----------------------------------------- CHECKS

--SELECT DISTINCT
--T0.DOCNUM AS 'DOCNUM',
--T6.DeposDate as 'Document Date',
--T6.U_PostingDate as 'Posting Date',
--CONCAT('DP ',T6.DeposNum) as 'Cash Receipt #',
--CONVERT(varchar(10), CONCAT('RC ' , T4.RcptNum)) AS 'Reference #',
--
--T4.CardCode as 'Customer Code',
--T4.CardName as 'Customer Name',
--ISNULL((T7.LicTradNum),'-') as 'Customer TIN',
--T3.ACCOUNT AS 'Account Code',
--T8.AcctName AS 'Account Name',
--
--T3.DEBIT AS 'PHP DEBIT',
--T3.CREDIT AS 'PHP CREDIT',
--
--T6.Memo as 'Remarks',
--T0.BPLNAME
--FROM ORCT T0
--INNER JOIN RCT1 T1 ON T0.DocNum = T1.DocNum
--INNER JOIN OJDT T2 ON T2.BaseRef = T0.Docnum
--INNER JOIN JDT1 T3 ON T2.TransId = T3.TransId
--INNER JOIN OCHH T4 ON T4.RcptNum = T2.BaseRef
--INNER JOIN DPS1 T5 ON T5.CheckKey = T4.CheckKey
--INNER JOIN ODPS T6 ON T6.DeposId = T5.DepositId
--INNER JOIN OCRD T7 ON T0.CardCode = T7.CardCode
--INNER JOIN OACT T8 ON T8.AcctCode = T3.Account
--WHERE T0.CheckSum > 0.00 AND T0.CANCELED = 'N' AND T6.DEPOSTYPE = 'K'  AND T2.TRANSTYPE = 24 AND T5.DepCancel = 'N'
--AND T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
--AND T3.TransType!=310000001
--AND T0.BPLName like  '%'+@Branch+'%'


-- JO CODE--

--SELECT DISTINCT
--T0.DOCNUM AS 'DOCNUM',
--T8.DeposDate as 'Document Date',
--T8.U_PostingDate as 'Posting Date',
--CONCAT('DP ',T8.DeposNum) as 'Cash Receipt #',
--CONVERT(varchar(10), CONCAT('RC ' , T6.RcptNum)) AS 'Reference #',
--
--T0.CardCode as 'Customer Code',
--T0.CardName as 'Customer Name',
--T1.LicTradNum as 'Customer TIN',
--T3.ACCOUNT AS 'Account Code',
--T4.AcctName AS 'Account Name',
--
--T3.DEBIT AS 'PHP DEBIT',
--T3.CREDIT AS 'PHP CREDIT',
--
--t8.Memo as 'Remarks',
--T0.BPLNAME
--
--FROM ORCT T0 
--INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE 
--inner join rct1 T5 on T0.docentry=T5.docnum
--INNER JOIN OCHH T6 ON T6.CheckKey=T5.CheckAbs
--INNER JOIN DPS1 T7 ON T7.CheckKey = T6.CheckKey
--INNER JOIN ODPS T8 ON T8.DeposId = T7.DepositId
--INNER JOIN OJDT T2 ON T2.BASEREF = T8.DEPOSNUM
--INNER JOIN JDT1 T3 ON T2.NUMBER = T3.TRANSID
--INNER JOIN OACT T4 ON T3.Account = T4.AcctCode
--WHERE T0.CheckSum > 0.00 AND T0.CANCELED = 'N' AND T8.DEPOSTYPE = 'K'  AND T2.TRANSTYPE = 25 AND T7.DepCancel = 'N'
--AND T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
--AND T3.TransType!=310000001
--AND T0.BPLName like  '%'+@Branch+'%'
--
--

SELECT DISTINCT
--T0.DOCNUM AS 'DOCNUM',
--(SELECT TOP 1 DOCNum FROM ORCT WHERE ORCT.DocNum = T6.RcptNum AND ORCT.DocNum = T0.DocNum) 'DOCNUM',
(SELECT TOP 1 RcptNum FROM OCHH WHERE OCHH.TransNum = T3.TransId AND OCHH.CheckSum = CASE WHEN T3.DEBIT = 0 THEN T3.CREDIT ELSE T3.DEBIT END)DOCNUM,
--
T8.DeposDate as 'Document Date',
T8.U_PostingDate as 'Posting Date',
CONCAT('DP ',T8.DeposNum) as 'Cash Receipt #',
--CONVERT(varchar(10), CONCAT('RC ' , T6.RcptNum)) AS 'Reference #',
CONVERT(varchar(10), CONCAT('RC ' ,(SELECT TOP 1 RcptNum FROM OCHH WHERE OCHH.TransNum = T3.TransId AND OCHH.CheckSum = CASE WHEN T3.DEBIT = 0 THEN T3.CREDIT ELSE T3.DEBIT END)))  AS 'Reference #',

T0.CardCode as 'Customer Code',
T0.CardName as 'Customer Name',
T1.LicTradNum as 'Customer TIN',
T3.ACCOUNT AS 'Account Code',
T4.AcctName AS 'Account Name',

T3.DEBIT AS 'PHP DEBIT',

T3.CREDIT AS 'PHP CREDIT',

t8.Memo as 'Remarks',
T0.BPLNAME
FROM ORCT T0 
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE 
inner join rct1 T5 on T0.docentry=T5.docnum
INNER JOIN OCHH T6 ON T6.CheckKey=T5.CheckAbs 
INNER JOIN DPS1 T7 ON T7.CheckKey = T6.CheckKey
INNER JOIN ODPS T8 ON T8.DeposId = T7.DepositId
INNER JOIN OJDT T2 ON T2.BASEREF = T8.DEPOSNUM
--INNER JOIN OJDT T2 ON T2.BASEREF = T8.DEPOSNUM
INNER JOIN JDT1 T3 ON T2.NUMBER = T3.TRANSID  AND T0.DocNum = T6.RcptNum
INNER JOIN OACT T4 ON T3.Account = T4.AcctCode
WHERE T0.CheckSum > 0.00 AND T0.CANCELED = 'N' AND T8.DEPOSTYPE = 'K'  AND T2.TRANSTYPE = 25 AND T7.DepCancel = 'N'
AND T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
AND T3.TransType!=310000001
AND T0.BPLName like  '%'+@Branch+'%'

----------------------------------------- // CHECKS

UNION ALL
-----------------------------------------
----------------------------------------- CREDIT CARD
select
-- T4.RctAbs as DOCNUM,
T0.DeposNum AS DOCNUM, 
T0.DEPOSDATE as 'Document Date',
T0.U_PostingDate as 'Posting Date',
CONCAT('DP ',T0.DeposNum) as 'Cash Receipt #',
CASE WHEN T4.RctAbs IS NULL THEN CONCAT('DP ' , T0.DeposNum) ELSE
CONVERT(varchar(10), CONCAT('RC ' ,T4.RctAbs)) END as 'Reference #',
ISNULL(t4.CardCode,'-') as 'Customer Code',
ISNULL(t4.cardname,'-') as 'Customer Name',
ISNULL(ISNULL(T6.U_TIN, T7.LicTradNum),'-') AS 'Customer TIN',
T2.Account AS 'Account Code',
T3.AcctName AS 'Account Name',
T2.Debit AS 'PHP Debit',
T2.Credit AS 'PHP Credit',
T0.MEMO AS 'Remarks',
T8.BPLName
from odps T0
LEFT JOIN OJDT T1 ON T0.DeposNum = T1.BaseRef AND T1.TransType = 25
LEFT JOIN JDT1 T2 ON T1.TransId = T2.TransId
LEFT JOIN OACT T3 ON T2.Account = T3.AcctCode
LEFT JOIN OCRH T4 ON t4.DepNum = t0.DeposId --AND (t4.FirstSum = T2.DEBIT or t4.FirstSum = T2.Credit) 
LEFT JOIN RCT2 T5 ON T4.RctAbs = T5.DocNum
LEFT JOIN OINV T6 ON T5.DOCENTRY = T6.DOCNUM
LEFT JOIN OCRD T7 ON T4.CARDCODE = T7.CARDCODE
LEFT JOIN ORCT T8 ON T4.RctAbs = T8.DocNum
where T0.DeposType = 'v'
-- AND (T2.ACCOUNT IN (SELECT TA.ACCTCODE FROM OCRH TA WHERE T0.DeposNum = TA.DEPNUM) OR T2.ACCOUNT IN (SELECT TA.CreditAcct FROM OCRH TA WHERE T0.DeposNum = TA.DEPNUM))
-- AND (T0.CrdBankAct NOT IN (SELECT TA.ACCTCODE FROM OCRH TA WHERE T0.DeposNum = TA.DEPNUM AND T2.Credit > 0)
-- OR T2.ACCOUNT IN (SELECT TA.CreditAcct FROM OCRH TA WHERE T0.DeposNum = TA.DEPNUM AND T2.Credit > 0))
AND T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
AND T2.TransType!=310000001
AND T8.BPLName like  '%'+@Branch+'%'

----------------------------------------- // CREDIT CARD
UNION ALL
-----------------------------------------
----------------------------------------- BANK TRANSFERS
SELECT DISTINCT
T0.DOCNUM AS 'DOCNUM',
T0.TaxDate as 'Document Date',
T0.Docdate as 'Posting Date',
CONCAT('RC ',T0.DOCNUM) as 'Cash Receipt #',

CASE WHEN T0.U_PayLoc LIKE '%Store Collect%' THEN
		T0.U_CollRcptNo
	 WHEN T0.U_PayLoc = '' THEN

  		(SELECT Countries = STUFF((
         SELECT
			', '+CASE WHEN T3.InvType = 203 Then 'ARDPI'
			WHEN T3.InvType = 46 Then 'OP'
			WHEN T3.InvType = 13 Then 'AR'
			WHEN T3.InvType = 14 Then 'CM'
			WHEN T3.InvType = 30 Then 'JE'
			END,
			+'-' + CONVERT(varchar(10), T3.DOCENTRY)
            FROM    RCT2 T3
			WHERE   T0.DOCNUM = T3.DOCNUM
            FOR XML PATH('')
         ), 1, 2, ''))

	 WHEN T0.U_PayLoc LIKE '%Customer%' THEN
		T0.U_CollRcptNo
	 WHEN T0.U_PayLoc LIKE '%Head%' THEN
		T0.U_CollRcptNo
END AS 'Reference #',

T0.CardCode as 'Customer Code',
T0.CardName as 'Customer Name',
ISNULL((T1.LicTradNum),'-') as 'Customer TIN',
t4.Account as 'Account Code',
T5.AcctName AS 'Account Name',
T4.DEBIT AS 'PHP Debit',

T4.CREDIT AS 'PHP Credit',
T2.MEMO as 'Remarks',
T0.BPLNAME

FROM ORCT T0
INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
INNER JOIN OJDT T2 ON T0.TRANSID = T2.Number
INNER JOIN JDT1 T4 ON T2.NUMBER = T4.TRANSID
INNER JOIN OACT T5 ON T4.Account = T5.AcctCode
WHERE T0.trsfrSum > 0.00 AND T0.CANCELED = 'N'
AND T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
AND T4.TransType!=310000001
AND T0.BPLName like  '%'+@Branch+'%'
)X
WHERE 
case when @dt='d'
then x.[Document Date] 
WHEN @dt ='p'
then x.[Posting Date]
END BETWEEN @DateFrom AND @Dateto


ORDER BY 
case when @dt='d'
then x.[Document Date] 
WHEN @dt ='p'
then x.[Posting Date]
END ,  'DOCNUM', 'Cash Receipt #' ASC




------------------------------------------- CASH
--SELECT * FROM (
--SELECT DISTINCT
--T0.DOCNUM AS 'DOCNUM',
--T8.DeposDate as 'Document Date',
--T8.U_PostingDate as 'Posting Date',
--CONCAT('DP ',T8.DeposNum) as 'Cash Receipt #',
--CONVERT(varchar(10), CONCAT('RC ' , T6.RcptNum)) AS 'Reference #',
--
--T0.CardCode as 'Customer Code',
--T0.CardName as 'Customer Name',
--ISNULL((T1.LicTradNum),'-') as 'Customer TIN',
--T3.ACCOUNT AS 'Account Code',
--T4.AcctName AS 'Account Name',
--
--T3.DEBIT AS 'PHP DEBIT',
--T3.CREDIT AS 'PHP CREDIT',
--
--t8.Memo as 'Remarks',
--T0.BPLNAME
--
--FROM ORCT T0
--INNER JOIN OCRD T1 ON T0.CARDCODE = T1.CARDCODE
--inner join rct1 T5 on T0.docentry=T5.docnum
--INNER JOIN OCHH T6 ON T6.CheckKey=T5.CheckAbs
--INNER JOIN DPS1 T7 ON T7.CheckKey = T6.CheckKey
--INNER JOIN ODPS T8 ON T8.DeposId = T7.DepositId
--INNER JOIN OJDT T2 ON T2.BASEREF = T8.DEPOSNUM
--INNER JOIN JDT1 T3 ON T2.NUMBER = T3.TRANSID AND T3.Account = T6.CashCheck
--INNER JOIN OACT T4 ON T3.Account = T4.AcctCode
--WHERE T0.CheckSum > 0.00 AND T0.CANCELED = 'N' AND T8.DEPOSTYPE = 'K'  AND T2.TRANSTYPE = 25 AND T7.DepCancel = 'N'
--AND T0.BPLId NOT IN (SELECT BPLId FROM OBPL WHERE OBPL.BPLName LIKE '%DC%')
--AND T3.TransType!=310000001
--AND T0.BPLName like  '%'+@Branch+'%'