-- Vista para ver los autos actualmente en subasta, junto con los datos de sus vendedores y la cantidad de pujas recibidas por cada vehículo

CREATE VIEW autos_En_Subasta AS
SELECT 
    v.VEHICULO_MARCA,
    v.VEHICULO_MODELO,
    v.VEHICULO_ANIO,
    v.VEHICULO_PRECIO_BASE,
    v.VEHICULO_PLACA,
    v.VEHICULO_COLOR,
    v.VEHICULO_KILOMETRAJE,
    ven.USUARIO_NOMBRE AS VENDEDOR_NOMBRE,
    ven.USUARIO_APELLIDO AS VENDEDOR_APELLIDO,
    ven.USUARIO_CEDULA AS VENDEDOR_CEDULA,
    ven.USUARIO_CORREO AS VENDEDOR_CORREO,
    COUNT(p.PUJA_ID) AS CANTIDAD_PUJAS
FROM 
    vehiculo v
JOIN 
    vendedor ven ON v.USUARIO_ID = ven.USUARIO_ID
JOIN 
    subasta_vehiculo sv ON v.VEHICULO_ID = sv.VEHICULO_ID
JOIN 
    subasta s ON sv.SUBASTA_ID = s.SUBASTA_ID
LEFT JOIN 
    puja p ON v.VEHICULO_ID = p.VEHICULO_ID
WHERE 
    s.SUBASTA_VIGENTE = 1 -- Solo autos en subasta vigente
GROUP BY 
    v.VEHICULO_ID, ven.USUARIO_ID;
    
-- Vista para ver cuál es el comprador que ha gastado más dinero en subastas ganadas, sumando el monto total de sus compras
CREATE VIEW comprador_Que_Ha_Gastado_Mas AS
SELECT 
    c.USUARIO_NOMBRE,
    c.USUARIO_APELLIDO,
    c.USUARIO_CEDULA,
    c.USUARIO_CORREO,
    SUM(p.PUJA_MONTO) AS GASTO_TOTAL
FROM 
    puja p
JOIN 
    comprador c ON p.USUARIO_ID = c.USUARIO_ID
JOIN 
    subasta s ON p.SUBASTA_ID = s.SUBASTA_ID
WHERE 
    p.PUJA_GANADOR = 1  -- Solo las pujas ganadas
    AND s.SUBASTA_VIGENTE = 0  -- Solo subastas que han finalizado
GROUP BY 
    p.USUARIO_ID
ORDER BY 
    GASTO_TOTAL DESC
LIMIT 1;  -- Solo el comprador que más ha gastado

-- Vista para ver información sobre los vendedores con más autos subastados y el porcentaje de autos vendidos en comparación con los que fueron publicados.
CREATE VIEW vista_vendedores_autos_subastados AS
SELECT 
    ven.USUARIO_NOMBRE,
    ven.USUARIO_APELLIDO,
    ven.USUARIO_CEDULA,
    ven.USUARIO_CORREO,
    COUNT(v.VEHICULO_ID) AS AUTOS_PUBLICADOS,
    COUNT(sv.VEHICULO_ID) AS AUTOS_SUBASTADOS,
    COUNT(CASE WHEN sv.SUBASTA_VEHICULO_VENDIDO = 1 THEN 1 END) AS AUTOS_VENDIDOS,
    IF(COUNT(v.VEHICULO_ID) > 0, 
        (COUNT(CASE WHEN sv.SUBASTA_VEHICULO_VENDIDO = 1 THEN 1 END) / COUNT(v.VEHICULO_ID)) * 100, 
        0) AS PORCENTAJE_VENDIDOS
FROM 
    vendedor ven
JOIN 
    vehiculo v ON ven.USUARIO_ID = v.USUARIO_ID
LEFT JOIN 
    subasta_vehiculo sv ON v.VEHICULO_ID = sv.VEHICULO_ID
LEFT JOIN 
    subasta s ON sv.SUBASTA_ID = s.SUBASTA_ID
GROUP BY 
    ven.USUARIO_ID
ORDER BY 
    AUTOS_SUBASTADOS DESC;
    
