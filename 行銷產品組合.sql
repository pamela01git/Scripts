SELECT         *
FROM             (SELECT         A.prod AS S1, B.prod AS S2
                           FROM              TABLE1 A CROSS JOIN
                                                      TABLE1 B) DERIVEDTBL
WHERE         (RIGHT(CAST(S1 AS VARCHAR(5)), 3) > RIGHT(CAST(S2 AS VARCHAR(5)), 3))