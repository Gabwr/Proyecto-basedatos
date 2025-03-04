
-- TRIGGER ANTES DE INSERTAR PUJA
DELIMITER //
CREATE TRIGGER trigger_antes_insertar_puja
BEFORE INSERT
ON puja
FOR EACH ROW
BEGIN
	DECLARE estado_usuario VARCHAR(50);
	DECLARE fecha_inicio_subasta DATETIME;
	DECLARE fecha_fin_subasta DATETIME;
    DECLARE vehiculo_en_subasta INT;
    DECLARE monto_maximo DECIMAL(10,2);
    DECLARE estado_vehiculo VARCHAR(50);

	-- Si el estado es "Inactivo", se lanza un mensaje de error y evita la inserción de ese usuario
    SELECT c.USUARIO_ESTADO INTO estado_usuario FROM comprador c WHERE c.USUARIO_ID = NEW.USUARIO_ID;

    IF estado_usuario = 'Inactivo' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede ingresar el usuario porque su cuenta está desactivada';
    END IF;
    
	-- Verificar si la fecha de la puja está dentro del rango de vigencia de la subasta
    SELECT s.SUBASTA_FECHA_INICIO, s.SUBASTA_FECHA_FIN INTO fecha_inicio_subasta, fecha_fin_subasta FROM subasta s WHERE s.SUBASTA_ID = NEW.SUBASTA_ID;
    
    IF NEW.PUJA_FECHA < fecha_inicio_subasta OR NEW.PUJA_FECHA > fecha_fin_subasta THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha de la puja no está dentro del rango de vigencia de la subasta';
    END IF;
    
    -- Verificar si el auto se encuentra en la subasta, sino lanzar un error y un mensaje 
	SELECT COUNT(*) INTO vehiculo_en_subasta FROM SUBASTA_VEHICULO sv WHERE sv.VEHICULO_ID = NEW.VEHICULO_ID AND sv.SUBASTA_ID = NEW.SUBASTA_ID;

    IF vehiculo_en_subasta = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El vehículo no está en la subasta especificada';
    END IF;
    
    -- Si no hay pujas previas, el monto máximo será 0 y Verificar si el monto de la nueva puja es mayor que el monto máximo
    SELECT MAX(PUJA_MONTO) INTO monto_maximo FROM puja p WHERE p.VEHICULO_ID = NEW.VEHICULO_ID AND p.SUBASTA_ID = NEW.SUBASTA_ID;
    
    IF monto_maximo IS NULL THEN
        SET monto_maximo = 0;
    END IF;

    IF NEW.PUJA_MONTO <= monto_maximo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto de la puja debe ser mayor que el monto máximo anterior para este vehículo en esta subasta';
    END IF;
    
	-- Verificar si el vehículo está retirado o vendido
    SELECT v.VEHICULO_ESTADO INTO estado_vehiculo FROM vehiculo v WHERE v.VEHICULO_ID= NEW.VEHICULO_ID;
    
    IF estado_vehiculo IN ('Retirado', 'Vendido') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El vehículo ya está retirado o vendido y no puede recibir más pujas';
    END IF;

END//

DELIMITER ;

-- TRIGGER DESPUÉS DE INSERTAR PUJA
DELIMITER //
CREATE TRIGGER trigger_despues_insertar_puja
AFTER INSERT ON puja
FOR EACH ROW
BEGIN
	INSERT INTO AUDITORIA (COM_USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALLE)
    VALUES (NEW.USUARIO_ID, NOW(), 'Puja realizada');
END//

DELIMITER ;

-- TRIGGER ANTES DE ACTUALIZAR PUJA
DELIMITER //

CREATE TRIGGER antes_actualizar_puja
BEFORE UPDATE ON puja
FOR EACH ROW
BEGIN
    -- Verificar que solo se está intentando modificar PUJA_ESTADO y que sea un cambio de activo a retirado y no al revés
    IF OLD.PUJA_ESTADO <> NEW.PUJA_ESTADO THEN
        IF NOT (OLD.PUJA_ESTADO = 'Activo' AND NEW.PUJA_ESTADO = 'Retirado') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solo se permite cambiar el estado de activo a retirado';
        END IF;
    ELSE
        IF OLD.PUJA_MONTO <> NEW.PUJA_MONTO OR
           OLD.PUJA_FECHA <> NEW.PUJA_FECHA OR
           OLD.PUJA_GANADOR <> NEW.PUJA_GANADOR THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se permite modificar otros campos excepto PUJA_ESTADO';
        END IF;
    END IF;
END//

DELIMITER ;


-- TRIGGER DESPUÉS DE ACTUALIZAR
DELIMITER //

CREATE TRIGGER despues_actualizar_puja
AFTER UPDATE ON puja
FOR EACH ROW
BEGIN
    -- Verificar si el estado cambió de 'Activo' a 'Retirado' y agrega el cambio en auditoría
    IF OLD.PUJA_ESTADO = 'Activo' AND NEW.PUJA_ESTADO = 'Retirado' THEN
        INSERT INTO auditoria (COM_USUARIO_ID, VEN_USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALL)
        VALUES (NEW.USUARIO_ID, NULL, NOW(), CONCAT('Puja ID ', NEW.PUJA_ID, ' retirada por el comprador.'));
    END IF;
END//

DELIMITER ;



