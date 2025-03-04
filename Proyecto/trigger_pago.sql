


DELIMITER $$

CREATE PROCEDURE calcular_ganador(puja_id INT)
BEGIN
    DECLARE ganador_id INT;
    DECLARE monto_maximo DECIMAL(10, 2);

    -- Obtener el monto máximo de la puja y el ID del comprador ganador
    SELECT PUJA_MONTO, USUARIO_ID
    INTO monto_maximo, ganador_id
    FROM PUJA
    WHERE SUBASTA_ID = (SELECT SUBASTA_ID FROM PUJA WHERE PUJA_ID = puja_id)
    ORDER BY PUJA_MONTO DESC
    LIMIT 1;

    -- Actualizar la puja ganadora
    UPDATE PUJA
    SET PUJA_GANADOR = TRUE
    WHERE PUJA_MONTO = monto_maximo
    AND SUBASTA_ID = (SELECT SUBASTA_ID FROM PUJA WHERE PUJA_ID = puja_id);

END $$

DELIMITER ;



DELIMITER $$

CREATE TRIGGER antes_insercion_pago
BEFORE INSERT ON PAGO
FOR EACH ROW
BEGIN
    -- Fecha límite: 1 mes desde la creación
    SET NEW.PAGO_FECHA_LIMITE = DATE_ADD(NOW(), INTERVAL 1 MONTH);

    -- Validar que el método de pago sea válido
    IF NOT NEW.PAGO_METODO IN ('tarjeta de credito', 'tarjeta de debito', 'transferencia bancaria', 'efectivo', 'pago por terceros') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Método de pago inválido. Debe ser tarjeta de credito, tarjeta de debito, transferencia bancaria, efectivo o pago por terceros.';
    END IF;

    -- Validar que el estado esté vacío o sea 'pendiente'
    IF NEW.PAGO_ESTADO IS NOT NULL AND NEW.PAGO_ESTADO != 'pendiente' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El estado solo puede estar vacío o ser "pendiente".';
    END IF;
END $$

DELIMITER ;


DELIMITER $$


DELIMITER $$

CREATE TRIGGER despues_insercion_pago_estado
AFTER INSERT ON PAGO
FOR EACH ROW
BEGIN
    -- Si la fecha límite es menor que la fecha actual, cambia el estado a 'retirado'
    IF NEW.PAGO_FECHA_LIMITE < NOW() THEN
        UPDATE PAGO
        SET PAGO_ESTADO = 'retirado'
        WHERE PAGO_ID = NEW.PAGO_ID;

        -- Llamada a la función para calcular el ganador (suponiendo que la función ya esté definida)
        CALL calcular_ganador(NEW.PUJA_ID);
        
		-- Insertar registro en AUDITORIA
		INSERT INTO AUDITORIA (USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALLE)
		VALUES (0, NOW(), 'Pago pendiente creado');
    END IF;
END $$

DELIMITER ;





DELIMITER $$

CREATE TRIGGER antes_actualizacion_pago
BEFORE UPDATE ON PAGO
FOR EACH ROW
BEGIN
    -- Validar que la fecha límite no cambie
    IF OLD.PAGO_FECHA_LIMITE != NEW.PAGO_FECHA_LIMITE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha límite no se puede cambiar.';
    END IF;

    -- Validar que el estado sea válido
    IF NOT NEW.PAGO_ESTADO IN ('completado', 'pendiente', 'retirado') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El estado debe ser "completado", "pendiente" o "retirado".';
    END IF;
END $$

DELIMITER ;




DELIMITER $$

CREATE TRIGGER despues_actualizacion_pago
AFTER UPDATE ON PAGO
FOR EACH ROW
BEGIN
    -- Obtener el VEHICULO_ID de la tabla PUJA usando el PUJA_ID
    DECLARE vehiculo_id INT;
    SELECT VEHICULO_ID INTO vehiculo_id
    FROM PUJA
    WHERE PUJA_ID = NEW.PUJA_ID;

    -- Si el estado es 'completado'
    IF NEW.PAGO_ESTADO = 'completado' THEN
        -- Actualizar la fecha de pago a la fecha actual
        UPDATE PAGO
        SET PAGO_FECHA = NOW()
        WHERE PAGO_ID = NEW.PAGO_ID;

        -- Marcar el vehículo como vendido en SUBASTA_VEHICULO_VENDIDO
        UPDATE subasta_vehiculo
        SET SUBASTA_VEHICULO_VENDIDO = TRUE
        WHERE VEHICULO_ID = vehiculo_id;

        -- Cambiar el estado del vehículo a 'vendido'
        UPDATE vehiculo
        SET VEHICULO_ESTADO = 'vendido'
        WHERE VEHICULO_ID = vehiculo_id;

        -- Insertar en auditoria con el detalle 'Pago completado'
        INSERT INTO auditoria (USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALLE)
        VALUES (0, NOW(), 'Pago completado');
    END IF;

    -- Si el estado es 'retirado'
    IF NEW.PAGO_ESTADO = 'retirado' THEN
        -- Llamada a la función para calcular el ganador (suponiendo que la función ya esté definida)
        CALL calcular_ganador(NEW.PUJA_ID);

        -- Insertar en auditoria con el detalle 'Pago retirado'
        INSERT INTO AUDITORIA (USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALLE)
        VALUES (0, NOW(), 'Pago retirado');
    END IF;

    -- Si el estado es 'pendiente'
    IF NEW.PAGO_ESTADO = 'pendiente' THEN
        -- Insertar en auditoria con el detalle 'Pago pendiente'
        INSERT INTO AUDITORIA (USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALLE)
        VALUES (0, NOW(), 'Pago pendiente');
    END IF;
END $$

DELIMITER ;


