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
    
    IF estado_vehiculo IN ('retirado', 'vendido') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El vehículo ya está retirado o vendido y no puede recibir más pujas';
    END IF;

END//

DELIMITER ;
