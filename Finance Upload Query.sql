;with base_table  as (select * from (
select
'AP' [Type],	
CAST(b.PERSON_CODE AS VARCHAR) AS Reference,
'D000000016' [Vendor No.],
CAST(b.TERM_1_A_EQUIPMENT_PAYMENT AS VARCHAR) AS Amount,
cast(b.PERSON_CODE as varchar) + '-' +'Bursrary Payment to student' [Description],
'WCC' [Borough],
'CT UPLOAD' [Business Area],
p.FORENAME + ' ' + p.SURNAME [Vendor Name],
'London' [Address]


FROM UT_PEOPLE_BURSARY b
inner join PEOPLE p		on p.PERSON_CODE = b.PERSON_CODE
left  join addresses a	on p.person_code = a.person_code and a.END_DATE is null and a.ADDRESS_TYPE <> 'DEAD' 

  OUTER APPLY (select top (1) CREATED_DATE
  from UT_PEOPLE_BURSARY_OUTCOMES o
  where o.BURSARY_ID = b.ID 
  and o.OUTCOME = 'A'
  order by CREATED_DATE desc) bo 	  

union all 

select
'GL',	
CAST(b.PERSON_CODE AS VARCHAR),
'V0',	
CAST(b.TERM_1_A_EQUIPMENT_PAYMENT AS VARCHAR),
cast(b.PERSON_CODE as varchar) + '-' +'Bursrary Payment to student',
'W22003',
'5371',
' ',
' '
FROM UT_PEOPLE_BURSARY b
inner join PEOPLE p		on p.PERSON_CODE = b.PERSON_CODE
left  join addresses a	on p.person_code = a.person_code and a.END_DATE is null and a.ADDRESS_TYPE <> 'DEAD' 


  OUTER APPLY (select top (1) CREATED_DATE
  from UT_PEOPLE_BURSARY_OUTCOMES o
  where o.BURSARY_ID = b.ID 
  and o.OUTCOME = 'A'
  order by CREATED_DATE desc) bo

) A  where Reference in (516016,
316620,
516502))


, NumberedRows AS (
select base_table.* 
, ROW_NUMBER() OVER (PARTITION BY CAST(Reference AS VARCHAR) ORDER BY CAST(Reference AS VARCHAR)) AS RowNum
from base_table
)
 
, mytable as (
SELECT Type
, Reference
, [Vendor No.]
, Amount
, Description
,[Borough]
,[Business Area]
,[Vendor Name]
,[Address]
,RowNum
FROM NumberedRows
)

, row_data AS (
    SELECT 
        Type, 
        Reference, 
        [Vendor No.], 
        Amount, 
        Description, 
        [Borough],
		[Business Area],
		[Vendor Name],
		[Address],
        RowNum, 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowPosition
    FROM mytable
)
,union_data as (
SELECT 
    Type, 
    Reference, 
    [Vendor No.], 
    Amount, 
    Description, 
    [Borough], 
	[Business Area],
	[Vendor Name],
	[Address],
    RowNum,
	RowPosition
FROM row_data

UNION ALL

-- Insert blank rows after RowNum = 2
SELECT 
    NULL AS Type, 
    NULL AS Reference, 
    NULL AS [Vendor No.], 
    NULL AS Amount, 
    NULL AS Description, 
    NULL AS [Borough], 
	NULL AS [Business Area],
	NULL AS [Vendor Name],
	NULL AS [Address],
     RowNum,
	RowPosition
FROM row_data
WHERE RowNum = 2
)
,dummy_header as (
Select 

		Type, 
      Reference, 
     [Vendor No.], 
      Amount, 
      Description, 
      [Borough],
	  [Business Area],
	  [Vendor Name],
	  [Address]
	  ,1 as ordering
	  ,RowNum
	  ,RowPosition
    

from union_data

union all
select 
 'Type' as [Type], 
 'Reference' as Reference , 
 'VAT Code' as [Vendor No.], 
 'Amount' as  Amount, 
 'Description' as Description, 
 'Cost Centre' as [Borough],
 'GL Account' as [Business Area],
 'SIO' as [Vendor Name],
 '' as [Address]
	  ,-1 as ordering
	  ,-1 as rownum
	  ,-1 as RowPosition


)

Select 
Type, 
      Reference, 
     [Vendor No.], 
      Amount, 
      Description, 
      [Borough],
	  [Business Area],
	  [Vendor Name],
	  [Address]


from dummy_header
ORDER BY  RowPosition,RowNum;