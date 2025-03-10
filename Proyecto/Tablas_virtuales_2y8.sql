

CREATE VIEW historial_pujas_usuario AS
SELECT 
    c.USUARIO_ID,
    v.VEHICULO_ID,
    v.VEHICULO_MARCA,
    v.VEHICULO_MODELO,
    v.VEHICULO_ANIO,
    p.PUJA_MONTO,
    p.PUJA_FECHA
FROM 
    PUJA p
JOIN 
    VEHICULO v ON p.VEHICULO_ID = v.VEHICULO_ID
JOIN 
    COMPRADOR c ON p.USUARIO_ID = c.USUARIO_ID;

SELECT * FROM historial_pujas_usuario WHERE USUARIO_ID = 1;  


CREATE VIEW historial_pagos_ganadores AS
SELECT 
    c.USUARIO_ID AS COMPRADOR_ID,
    c.USUARIO_NOMBRE AS COMPRADOR_NOMBRE,
    c.USUARIO_APELLIDO AS COMPRADOR_APELLIDO,
    v.VEHICULO_ID,
    v.VEHICULO_MARCA,
    v.VEHICULO_MODELO,
    v.VEHICULO_ANIO,
    p.PAGO_ID,
    p.PAGO_FECHA,
    p.PAGO_ESTADO,
    p.PAGO_METODO,
    s.SUBASTA_ID,
    s.SUBASTA_FECHA_INICIO,
    s.SUBASTA_FECHA_FIN
FROM 
    PAGO p
JOIN 
    PUJA puja ON p.PUJA_ID = puja.PUJA_ID
JOIN 
    VEHICULO v ON puja.VEHICULO_ID = v.VEHICULO_ID
JOIN 
    COMPRADOR c ON puja.USUARIO_ID = c.USUARIO_ID
JOIN 
    SUBASTA s ON puja.SUBASTA_ID = s.SUBASTA_ID
WHERE 
    puja.PUJA_GANADOR = TRUE;  

SELECT * FROM historial_pagos_ganadores;
