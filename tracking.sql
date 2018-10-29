-- using the boleto tracking
WITH boleto_click AS (SELECT organization_uuid, MIN(timestamp) AS first_click
-- a merchant can click the boleto option multiple times, we assume the first click is when they purchase
FROM view.portal_request
WHERE subject = 'Webshop.Boleto.Easy.clicked'
GROUP BY organization_uuid),

-- all the readers that were activated in Brazil after the Boleto tracking began
-- assumption is that merhcants that activate their readers have bought their readers
reader AS (SELECT r.reader_hash, r.owner_organization_uuid, r.activation_date
FROM reader AS r
INNER JOIN organization_customer AS oc
    ON r.owner_organization_uuid = organization_uuid
WHERE oc.country_id = 'BR'
AND r.activation_date >= (SELECT MIN(timestamp)
                          FROM portal_request
                          WHERE subject = 'Webshop.Boleto.Easy.clicked')
GROUP BY r.reader_hash, r.owner_organization_uuid, r.activation_date
           
SELECT r.owner_organization_uuid, bc.first_click, r.activation_date
FROM reader AS r
LEFT JOIN boleto_click AS bc
    ON r.owner_organization_uuid = bc.organization_uuid
ORDER BY r.activation_date
