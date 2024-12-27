SELECT  REFERENCE1, sum(nvl(ENTERED_DR,0)) DR , sum(nvl(ENTERED_CR,0)) CR ,  sum(nvl(ENTERED_CR,0))  - 


(SELECT SUM(N_AMT)
FROM GNMT_GL_MASTER M,GNDT_GL_DETAILS D
WHERE M.N_REF_NO = D.N_REF_NO
AND M.V_JOURNAL_STATUS = 'C'
AND NVL(M.V_REMARKS,'N') != 'X'
AND V_DOCU_TYPE !='VOUCHER'
AND V_DOCU_TYPE  ='RECEIPT'
AND V_PROCESS_CODE NOT IN ('ACT021','RIACT01')
AND V_DOCU_REF_NO  = REFERENCE1 
and V_TYPE = 'C') DIFF

FROM JHL_OFA_GL_INTERFACE
WHERE
REFERENCE1 IN( 
'HQ200074266',
'HQ200074267',
'HQ200074268',
'HQ200074270',
'HQ200073982',
'HQ200073983',
'HQ200074250',
'HQ200074153',
'HQ200074154',
'HQ200074155',
'HQ200074156',
'HQ200074158',
'HQ200073979',
'HQ200073980',
'HQ200073981',
'HQ200073989',
'HQ200073990',
'HQ200073993',
'HQ200074111',
'HQ200074112',
'HQ200074113',
'HQ200074114',
'HQ200074115',
'HQ200074116',
'HQ200074117',
'HQ200074118',
'HQ200074119',
'HQ200074120',
'HQ200074121',
'HQ200074122',
'HQ200074123',
'HQ200074124',
'HQ200074125',
'HQ200074126',
'HQ200074127',
'HQ200074128',
'HQ200074129',
'HQ200074130',
'HQ200074131',
'HQ200074132',
'HQ200074133',
'HQ200074134',
'HQ200074135',
'HQ200074136',
'HQ200074137',
'HQ200074138',
'HQ200074139',
'HQ200074140',
'HQ200074141',
'HQ200074142',
'HQ200074143',
'HQ200074144',
'HQ200074147',
'HQ200074150',
'HQ200074151',
'HQ200074152',
'HQ200074157',
'HQ200074159',
'HQ200074160',
'HQ200074161',
'HQ200074162',
'HQ200074163',
'HQ200074164',
'HQ200074165',
'HQ200074166',
'HQ200074167',
'HQ200074168',
'HQ200074169',
'HQ200074170',
'HQ200074171',
'HQ200074172',
'HQ200074176',
'HQ200074178',
'HQ200074182',
'HQ200074183',
'HQ200074184',
'HQ200074185',
'HQ200074186',
'HQ200074187',
'HQ200074188',
'HQ200074189',
'HQ200074190',
'HQ200074191',
'HQ200074192',
'HQ200074193',
'HQ200074194',
'HQ200074195',
'HQ200074196',
'HQ200074197',
'HQ200074198',
'HQ200074199',
'HQ200074200',
'HQ200074201',
'HQ200074202',
'HQ200074204',
'HQ200074205',
'HQ200074209',
'HQ200074210',
'HQ200074211',
'HQ200074212',
'HQ200074213',
'HQ200074214',
'HQ200074215',
'HQ200074219',
'HQ200074220',
'HQ200074221',
'HQ200074222',
'HQ200074223',
'HQ200074232',
'HQ200074233',
'HQ200074234',
'HQ200074236',
'HQ200074237',
'HQ200074257',
'HQ200073984',
'HQ200073985',
'HQ200073986',
'HQ200073987',
'HQ200073988',
'HQ200073991',
'HQ200073992',
'HQ200074177',
'HQ200074179',
'HQ200074180',
'HQ200074181',
'HQ200074206',
'HQ200074207',
'HQ200074208',
'HQ200074216',
'HQ200074217',
'HQ200074218',
'HQ200074224',
'HQ200074225',
'HQ200074226',
'HQ200074227',
'HQ200074228',
'HQ200074229',
'HQ200074230',
'HQ200074231',
'HQ200074235',
'HQ200074238',
'HQ200074239',
'HQ200074240',
'HQ200074241',
'HQ200074242',
'HQ200074243',
'HQ200074244',
'HQ200074245',
'HQ200074246',
'HQ200074247',
'HQ200074248',
'HQ200074249',
'HQ200074251',
'HQ200074252',
'HQ200074253',
'HQ200074254',
'HQ200074255',
'HQ200074256',
'HQ200074258',
'HQ200074259',
'HQ200074260',
'HQ200074261',
'HQ200074262',
'HQ200074263',
'HQ200074264',
'HQ200074265',
'HQ200074271',
'HQ200074148',
'HQ200073994',
'HQ200073995',
'HQ200073996',
'HQ200073997',
'HQ200073998',
'HQ200073999',
'HQ200074000',
'HQ200074001',
'HQ200074002',
'HQ200074003',
'HQ200074004',
'HQ200074005',
'HQ200074006',
'HQ200074007',
'HQ200074008',
'HQ200074009',
'HQ200074010',
'HQ200074011',
'HQ200074012',
'HQ200074013',
'HQ200074014',
'HQ200074015',
'HQ200074016',
'HQ200074017',
'HQ200074018',
'HQ200074019',
'HQ200074020',
'HQ200074021',
'HQ200074022',
'HQ200074023',
'HQ200074024',
'HQ200074025',
'HQ200074026',
'HQ200074027',
'HQ200074028',
'HQ200074029',
'HQ200074030',
'HQ200074031',
'HQ200074032',
'HQ200074033',
'HQ200074034',
'HQ200074035',
'HQ200074036',
'HQ200074037',
'HQ200074038',
'HQ200074039',
'HQ200074040',
'HQ200074041',
'HQ200074042',
'HQ200074043',
'HQ200074044',
'HQ200074045',
'HQ200074046',
'HQ200074047',
'HQ200074048',
'HQ200074049',
'HQ200074050',
'HQ200074051',
'HQ200074052',
'HQ200074053',
'HQ200074054',
'HQ200074055',
'HQ200074056',
'HQ200074057',
'HQ200074058',
'HQ200074059',
'HQ200074060',
'HQ200074061',
'HQ200074062',
'HQ200074063',
'HQ200074064',
'HQ200074065',
'HQ200074066',
'HQ200074067',
'HQ200074068',
'HQ200074069',
'HQ200074070',
'HQ200074071',
'HQ200074072',
'HQ200074073',
'HQ200074074',
'HQ200074075',
'HQ200074076',
'HQ200074077',
'HQ200074078',
'HQ200074079',
'HQ200074080',
'HQ200074081',
'HQ200074082',
'HQ200074083',
'HQ200074084',
'HQ200074085',
'HQ200074086',
'HQ200074087',
'HQ200074088',
'HQ200074089',
'HQ200074090',
'HQ200074091',
'HQ200074092',
'HQ200074093',
'HQ200074094',
'HQ200074095',
'HQ200074096',
'HQ200074097',
'HQ200074098',
'HQ200074099',
'HQ200074100',
'HQ200074101',
'HQ200074102',
'HQ200074103',
'HQ200074104',
'HQ200074105',
'HQ200074106',
'HQ200074107',
'HQ200074108',
'HQ200074109',
'HQ200074110',
'HQ200074269',
'HQ200074173',
'HQ200074174',
'HQ200074175'

) 

GROUP BY REFERENCE1
ORDER BY 4 desc ;

-------------------------------------------------------------------------------------------------------------------------------------------------------

select *

FROM JHL_OFA_GL_INTERFACE
WHERE
REFERENCE1 IN( 
'HQ200074266',
'HQ200074267',
'HQ200074268',
'HQ200074270',
'HQ200073982',
'HQ200073983',
'HQ200074250',
'HQ200074153',
'HQ200074154',
'HQ200074155',
'HQ200074156',
'HQ200074158',
'HQ200073979',
'HQ200073980',
'HQ200073981',
'HQ200073989',
'HQ200073990',
'HQ200073993',
'HQ200074111',
'HQ200074112',
'HQ200074113',
'HQ200074114',
'HQ200074115',
'HQ200074116',
'HQ200074117',
'HQ200074118',
'HQ200074119',
'HQ200074120',
'HQ200074121',
'HQ200074122',
'HQ200074123',
'HQ200074124',
'HQ200074125',
'HQ200074126',
'HQ200074127',
'HQ200074128',
'HQ200074129',
'HQ200074130',
'HQ200074131',
'HQ200074132',
'HQ200074133',
'HQ200074134',
'HQ200074135',
'HQ200074136',
'HQ200074137',
'HQ200074138',
'HQ200074139',
'HQ200074140',
'HQ200074141',
'HQ200074142',
'HQ200074143',
'HQ200074144',
'HQ200074147',
'HQ200074150',
'HQ200074151',
'HQ200074152',
'HQ200074157',
'HQ200074159',
'HQ200074160',
'HQ200074161',
'HQ200074162',
'HQ200074163',
'HQ200074164',
'HQ200074165',
'HQ200074166',
'HQ200074167',
'HQ200074168',
'HQ200074169',
'HQ200074170',
'HQ200074171',
'HQ200074172',
'HQ200074176',
'HQ200074178',
'HQ200074182',
'HQ200074183',
'HQ200074184',
'HQ200074185',
'HQ200074186',
'HQ200074187',
'HQ200074188',
'HQ200074189',
'HQ200074190',
'HQ200074191',
'HQ200074192',
'HQ200074193',
'HQ200074194',
'HQ200074195',
'HQ200074196',
'HQ200074197',
'HQ200074198',
'HQ200074199',
'HQ200074200',
'HQ200074201',
'HQ200074202',
'HQ200074204',
'HQ200074205',
'HQ200074209',
'HQ200074210',
'HQ200074211',
'HQ200074212',
'HQ200074213',
'HQ200074214',
'HQ200074215',
'HQ200074219',
'HQ200074220',
'HQ200074221',
'HQ200074222',
'HQ200074223',
'HQ200074232',
'HQ200074233',
'HQ200074234',
'HQ200074236',
'HQ200074237',
'HQ200074257',
'HQ200073984',
'HQ200073985',
'HQ200073986',
'HQ200073987',
'HQ200073988',
'HQ200073991',
'HQ200073992',
'HQ200074177',
'HQ200074179',
'HQ200074180',
'HQ200074181',
'HQ200074206',
'HQ200074207',
'HQ200074208',
'HQ200074216',
'HQ200074217',
'HQ200074218',
'HQ200074224',
'HQ200074225',
'HQ200074226',
'HQ200074227',
'HQ200074228',
'HQ200074229',
'HQ200074230',
'HQ200074231',
'HQ200074235',
'HQ200074238',
'HQ200074239',
'HQ200074240',
'HQ200074241',
'HQ200074242',
'HQ200074243',
'HQ200074244',
'HQ200074245',
'HQ200074246',
'HQ200074247',
'HQ200074248',
'HQ200074249',
'HQ200074251',
'HQ200074252',
'HQ200074253',
'HQ200074254',
'HQ200074255',
'HQ200074256',
'HQ200074258',
'HQ200074259',
'HQ200074260',
'HQ200074261',
'HQ200074262',
'HQ200074263',
'HQ200074264',
'HQ200074265',
'HQ200074271',
'HQ200074148',
'HQ200073994',
'HQ200073995',
'HQ200073996',
'HQ200073997',
'HQ200073998',
'HQ200073999',
'HQ200074000',
'HQ200074001',
'HQ200074002',
'HQ200074003',
'HQ200074004',
'HQ200074005',
'HQ200074006',
'HQ200074007',
'HQ200074008',
'HQ200074009',
'HQ200074010',
'HQ200074011',
'HQ200074012',
'HQ200074013',
'HQ200074014',
'HQ200074015',
'HQ200074016',
'HQ200074017',
'HQ200074018',
'HQ200074019',
'HQ200074020',
'HQ200074021',
'HQ200074022',
'HQ200074023',
'HQ200074024',
'HQ200074025',
'HQ200074026',
'HQ200074027',
'HQ200074028',
'HQ200074029',
'HQ200074030',
'HQ200074031',
'HQ200074032',
'HQ200074033',
'HQ200074034',
'HQ200074035',
'HQ200074036',
'HQ200074037',
'HQ200074038',
'HQ200074039',
'HQ200074040',
'HQ200074041',
'HQ200074042',
'HQ200074043',
'HQ200074044',
'HQ200074045',
'HQ200074046',
'HQ200074047',
'HQ200074048',
'HQ200074049',
'HQ200074050',
'HQ200074051',
'HQ200074052',
'HQ200074053',
'HQ200074054',
'HQ200074055',
'HQ200074056',
'HQ200074057',
'HQ200074058',
'HQ200074059',
'HQ200074060',
'HQ200074061',
'HQ200074062',
'HQ200074063',
'HQ200074064',
'HQ200074065',
'HQ200074066',
'HQ200074067',
'HQ200074068',
'HQ200074069',
'HQ200074070',
'HQ200074071',
'HQ200074072',
'HQ200074073',
'HQ200074074',
'HQ200074075',
'HQ200074076',
'HQ200074077',
'HQ200074078',
'HQ200074079',
'HQ200074080',
'HQ200074081',
'HQ200074082',
'HQ200074083',
'HQ200074084',
'HQ200074085',
'HQ200074086',
'HQ200074087',
'HQ200074088',
'HQ200074089',
'HQ200074090',
'HQ200074091',
'HQ200074092',
'HQ200074093',
'HQ200074094',
'HQ200074095',
'HQ200074096',
'HQ200074097',
'HQ200074098',
'HQ200074099',
'HQ200074100',
'HQ200074101',
'HQ200074102',
'HQ200074103',
'HQ200074104',
'HQ200074105',
'HQ200074106',
'HQ200074107',
'HQ200074108',
'HQ200074109',
'HQ200074110',
'HQ200074269',
'HQ200074173',
'HQ200074174',
'HQ200074175') 
order by REFERENCE1;
