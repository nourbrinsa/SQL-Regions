DROP VIEW IF EXISTS communes_prefectures;

CREATE VIEW
    communes_prefectures AS
SELECT
    d.nom,
    z.commune,
    z.quartier,
    d.prefecture,
    'Oui' categorie
FROM
    departements d,
    zus z
WHERE
    z.commune = d.prefecture
    OR z.commune LIKE d.prefecture || ' %'
    OR z.commune LIKE d.prefecture || ',%'
    OR z.commune LIKE '%, ' || d.prefecture
    OR z.commune LIKE '%,  ' || d.prefecture
    OR z.commune LIKE '%-' || d.prefecture
UNION ALL
SELECT
    z.departement nom,
    z.commune,
    z.quartier,
    (
        SELECT
            prefecture
        FROM
            departements
        WHERE
            nom = z.departement
    ) prefecture,
    'Non' categorie
FROM
    zus z
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            departements d
        WHERE
            z.commune = d.prefecture
            OR z.commune LIKE d.prefecture || ' %'
            OR z.commune LIKE d.prefecture || ',%'
            OR z.commune LIKE '%, ' || d.prefecture
            OR z.commune LIKE '%,  ' || d.prefecture
            OR z.commune LIKE '%-' || d.prefecture
    );

SELECT
    COUNT(*) count,
    categorie
FROM
    communes_prefectures
GROUP BY
    categorie
UNION ALL
SELECT
    COUNT(*),
    'Total'
FROM
    communes_prefectures
ORDER BY
    categorie DESC;
