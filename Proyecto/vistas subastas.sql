--  Información sobre los ganadores de cada subasta
CREATE VIEW Vista_Ganadores AS
SELECT 
    P.PUJA_ID, 
    P.SUBASTA_ID, 
    P.VEHICULO_ID, 
    C.USUARIO_NOMBRE AS COMPRADOR_NOMBRE, 
    C.USUARIO_APELLIDO AS COMPRADOR_APELLIDO, 
    P.PUJA_MONTO AS MONTO_FINAL, 
    S.SUBASTA_FECHA_FIN AS FECHA_CIERRE
FROM PUJA P
INNER JOIN COMPRADOR C ON P.USUARIO_ID = C.USUARIO_ID
INNER JOIN SUBASTA S ON P.SUBASTA_ID = S.SUBASTA_ID
WHERE P.PUJA_GANADOR = TRUE;

--  Autos actualmente en subasta con datos del vendedor y número de pujas
CREATE VIEW Vista_Autos_En_Subasta AS
SELECT 
    V.VEHICULO_ID, 
    V.VEHICULO_MARCA, 
    V.VEHICULO_MODELO, 
    V.VEHICULO_ANIO,
    VEN.USUARIO_NOMBRE AS VENDEDOR_NOMBRE,
    VEN.USUARIO_APELLIDO AS VENDEDOR_APELLIDO,
    COUNT(P.PUJA_ID) AS CANTIDAD_PUJAS
FROM SUBASTA_VEHICULO SV
INNER JOIN VEHICULO V ON SV.VEHICULO_ID = V.VEHICULO_ID
INNER JOIN VENDEDOR VEN ON V.USUARIO_ID = VEN.USUARIO_ID
LEFT JOIN PUJA P ON V.VEHICULO_ID = P.VEHICULO_ID AND SV.SUBASTA_ID = P.SUBASTA_ID
WHERE SV.SUBASTA_VEHICULO_VENDIDO = FALSE
GROUP BY V.VEHICULO_ID;

--  Subastas con mayor número de pujas, incluyendo las que no recibieron ofertas
CREATE VIEW Vista_Subastas_Mayor_Pujas AS
SELECT 
    S.SUBASTA_ID,
    S.SUBASTA_FECHA_INICIO,
    S.SUBASTA_FECHA_FIN,
    COUNT(P.PUJA_ID) AS TOTAL_PUJAS
FROM SUBASTA S
LEFT JOIN PUJA P ON S.SUBASTA_ID = P.SUBASTA_ID
GROUP BY S.SUBASTA_ID
ORDER BY TOTAL_PUJAS DESC;

--  Vendedores con más autos subastados y porcentaje de autos vendidos
CREATE VIEW Vista_Vendedores_Exitosos AS
SELECT 
    V.USUARIO_ID AS VENDEDOR_ID,
    VEN.USUARIO_NOMBRE,
    VEN.USUARIO_APELLIDO,
    COUNT(DISTINCT V.VEHICULO_ID) AS AUTOS_SUBASTADOS,
    COUNT(DISTINCT CASE WHEN SV.SUBASTA_VEHICULO_VENDIDO = TRUE THEN V.VEHICULO_ID END) AS AUTOS_VENDIDOS,
    (COUNT(DISTINCT CASE WHEN SV.SUBASTA_VEHICULO_VENDIDO = TRUE THEN V.VEHICULO_ID END) * 100.0 / COUNT(DISTINCT V.VEHICULO_ID)) AS PORCENTAJE_VENTAS
FROM VEHICULO V
INNER JOIN VENDEDOR VEN ON V.USUARIO_ID = VEN.USUARIO_ID
INNER JOIN SUBASTA_VEHICULO SV ON V.VEHICULO_ID = SV.VEHICULO_ID
GROUP BY V.USUARIO_ID;

-- Autos subastados múltiples veces sin haber sido comprados
CREATE VIEW Vista_Autos_Subastados_Multiples AS
SELECT 
    V.VEHICULO_ID,
    V.VEHICULO_MARCA,
    V.VEHICULO_MODELO,
    COUNT(SV.SUBASTA_ID) AS VECES_SUBASTADO
FROM SUBASTA_VEHICULO SV
INNER JOIN VEHICULO V ON SV.VEHICULO_ID = V.VEHICULO_ID
WHERE SV.SUBASTA_VEHICULO_VENDIDO = FALSE
GROUP BY V.VEHICULO_ID
HAVING COUNT(SV.SUBASTA_ID) > 1;

--  Autos vendidos en subastas con comparación de precios año tras año
CREATE VIEW Vista_Ventas_Anuales AS
SELECT 
    YEAR(S.SUBASTA_FECHA_FIN) AS ANIO,
    COUNT(P.PUJA_ID) AS AUTOS_VENDIDOS,
    AVG(P.PUJA_MONTO) AS PRECIO_PROMEDIO
FROM PUJA P
INNER JOIN SUBASTA S ON P.SUBASTA_ID = S.SUBASTA_ID
WHERE P.PUJA_GANADOR = TRUE
GROUP BY ANIO
ORDER BY ANIO;
